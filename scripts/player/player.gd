class_name Player
extends Node2D
## One player's Hero in the world (a placeholder square in the Hero's colour).
## Created only through GameAuthority.spawn_player, which keeps the list of
## players. Facing is the last direction the player moved in. Health changes
## only through GameAuthority, so co-op can later run them on the host.

var player_id: int = 0
var is_local: bool = true
var input: PlayerInput = null
var move_speed: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT

var stats: PlayerStats = null
## The Hero's entry from heroes.json (empty in tests that don't pick one).
var hero: Dictionary = {}
## The Hero's Legend Trait and passive (see scripts/player/hero_traits/).
var kit: HeroKit = null
## Weapons held this run (up to 6), each a WeaponInstance.
var weapons: Array[WeaponInstance] = []
## Passives held this run (up to 6): passive id -> level 1–5.
var passives: Dictionary = {}
## Elemental statuses (only from 30:00, at reduced strength).
var statuses := PlayerStatuses.new()

var max_hp: float = 0.0
var hp: float = 0.0
var armor: float = 0.0
var body_radius: float = 0.0
var alive: bool = true
## Debug-menu god mode: takes no damage.
var god_mode: bool = false
## Enemy, boss, or hazard id that dealt the final blow (for the run log).
var cause_of_death: String = ""
## From bound gods (Phase 11): Blessing switches (blessing key -> value), extra
## damage per element (fractions), the gold multiplier, and invulnerable time.
var god_flags: Dictionary = {}
var element_damage: Dictionary = {}
var gold_mult: float = 1.0
var invulnerable_s: float = 0.0
## Multiplier on reaction damage this player causes (Väinämöinen's Divine Link).
var reaction_damage_mult: float = 1.0
## Elements of the gods bound to this player (used by Divine Links).
var god_elements: PackedStringArray = []
## Projectiles launched this run (Thor's Blessing chains every 10th).
var projectiles_launched: int = 0
## Boss effects (Phase 13): petrified (can't move), slow-time zones, Boon projectiles.
var rooted_s: float = 0.0
var slow_zone_mult: float = 1.0
var extra_projectiles: int = 0
## Phase 15: Swift Mode projectile speed; the mastery palette colour and an
## equipped cosmetic aura (alpha 0 = none).
var projectile_speed_mult: float = 1.0
var palette_color := Color(0, 0, 0, 0)
## Seconds left of a weapon swing: the held weapon is hidden while its picture sweeps (EffectLayer.spawn_swing).
var swinging_s: float = 0.0
## Distance walked, for the walking frames of the Hero's pixel art.
var _stride: float = 0.0
var _last_drawn_at := Vector2.ZERO
var aura_color := Color(0, 0, 0, 0)
## Ground patches (Phase 16+): quicksand slows (speed multiplier); frozen
## ponds slide (grip per second; 0 = full control).
var ground_speed_mult: float = 1.0
var ground_grip_per_s: float = 0.0
## Co-op (Phase 20): downed (bleeding out, an ally can revive), revives used,
## and the Wandering Shade (after the last revive: a ghost that collects XP
## and gold for the team, can't die or deal damage).
var downed: bool = false
var bleed_s: float = 0.0
var revive_progress_s: float = 0.0
var revives_used: int = 0
var shade: bool = false
## On a joining player's device: the host's slow on this player (statuses,
## slow zones, quicksand…) and its id-to-player mapping in co-op.
var net_speed_mult: float = 1.0
## Co-op: run gold this player spent at the Trader (each player spends only their own).
var gold_spent: float = 0.0

var _shown_hp: float = -1.0


func _ready() -> void:
	if stats == null:
		stats = PlayerStats.from_hero(hero) if not hero.is_empty() else PlayerStats.from_config()
	body_radius = Data.cfg_float("player.body_radius_px")
	if not hero.is_empty():
		kit = HeroKit.create(str((hero.get("trait", {}) as Dictionary).get("id", "")))
		add_child(kit)
		kit.setup(self, hero)
	refresh_stats()
	hp = max_hp


func kit_attack_speed_bonus() -> float:
	return kit.attack_speed_bonus() if kit != null else 0.0


func kit_damage_mult(weapon: WeaponInstance) -> float:
	return (kit.damage_mult(weapon) if kit != null else 1.0) * SecretPassives.low_hp_mult(self)


## Extra damage with an element from Blessings (e.g. Thor: +15% Lightning).
func element_damage_mult(element: String) -> float:
	return 1.0 + float(element_damage.get(element, 0.0))


## Re-reads speed, Max HP, and Armor after a stat changes. A higher Max HP
## also raises current HP by the same amount.
func refresh_stats() -> void:
	move_speed = stats.move_speed()
	armor = stats.armor()
	var new_max: float = stats.max_hp()
	if max_hp > 0.0 and new_max > max_hp:
		hp += new_max - max_hp
	max_hp = new_max
	hp = minf(hp, max_hp)


func _process(delta: float) -> void:
	if swinging_s > 0.0:
		swinging_s -= delta
		queue_redraw()                                 # hide the held weapon now, and show it again after
	if invulnerable_s > 0.0:
		invulnerable_s = maxf(invulnerable_s - delta, 0.0)
		queue_redraw()
	if rooted_s > 0.0:
		rooted_s = maxf(rooted_s - delta, 0.0)
		queue_redraw()
	if alive:
		var dot: float = statuses.tick(delta)
		if dot > 0.0:
			GameAuthority.damage_player_over_time(self, dot)
	if kit != null and kit.controls_movement():
		pass
	elif input != null and (alive or shade):
		step(input.get_move_vector(), delta)
	elif not alive:
		velocity = Vector2.ZERO
	if hp != _shown_hp:
		_shown_hp = hp
		queue_redraw()
	# Walking frames: redraw as the Hero moves (own steering, pushes, or co-op updates).
	var moved: float = position.distance_to(_last_drawn_at)
	if moved > 0.0:
		_stride += moved
		_last_drawn_at = position
		queue_redraw()


## Moves by one frame in `direction` (a unit vector or zero) and updates facing.
func step(direction: Vector2, delta: float) -> void:
	if rooted_s > 0.0:
		direction = Vector2.ZERO
	var wanted: Vector2 = direction * move_speed * statuses.speed_mult() * slow_zone_mult * ground_speed_mult \
			* (kit.speed_mult() if kit != null else 1.0) * net_speed_mult
	# On ice the Hero keeps sliding and only slowly turns toward where they steer.
	velocity = wanted if ground_grip_per_s <= 0.0 else velocity.lerp(wanted, minf(ground_grip_per_s * delta, 1.0))
	position += velocity * delta
	if direction != Vector2.ZERO and direction != facing:
		facing = direction
		queue_redraw()


func _draw() -> void:
	var size_px: float = Data.cfg_float("player.placeholder_size_px")
	var color := Color.html(str(hero.get("placeholder_color", Data.cfg_string("player.placeholder_color"))))
	if palette_color.a > 0.0:
		color = palette_color
	if not alive:
		color = Color.html(Data.cfg_string("player.fallen_color"))
	if shade:
		color = Color(Color.html(Data.cfg_string("coop.shade_color")), 0.55)
	if aura_color.a > 0.0 and alive:
		draw_arc(Vector2.ZERO, size_px * 0.95, 0.0, TAU, 24, aura_color, 2.0)
	# The mastery colour (Hero select: Color) recolours the Hero's clothes.
	var art: Dictionary = PixelArt.find(str(hero.get("id", "")), palette_color)
	if not art.is_empty():
		_draw_art(art)
	else:
		draw_rect(Rect2(Vector2(-size_px, -size_px) * 0.5, Vector2(size_px, size_px)), color)
		# A small dot on the facing side shows which way the player last moved.
		var marker_px: float = Data.cfg_float("player.facing_marker_px")
		var marker_color := Color.html(Data.cfg_string("player.facing_marker_color"))
		draw_circle(facing * (size_px * 0.5 - marker_px * 0.5), marker_px * 0.5, marker_color)
		if rooted_s > 0.0:
			draw_rect(Rect2(Vector2(-size_px, -size_px) * 0.5, Vector2(size_px, size_px)), Color.html(Data.cfg_string("bosses.petrified_color")))
	if invulnerable_s > 0.0:
		draw_arc(Vector2.ZERO, size_px * 0.9, 0.0, TAU, 20, Color.html(Data.cfg_string("gods.invulnerable_color")), 2.0)
	if downed:
		_draw_downed(size_px)
	elif not shade:
		_draw_hp_bar()


## Where the Hero's weapon hand is in the world (their art's "hand" point, mirrored when facing left), so
## thrown weapons and swings start from it (owner request 10/31/2026); the body's centre without art.
func hand_position() -> Vector2:
	var art: Dictionary = PixelArt.find(str(hero.get("id", "")))
	if art.is_empty() or not art.has("hand"):
		return position
	var anchor: Vector2 = art["anchor"]
	var local: Vector2 = Vector2(-anchor.x, body_radius - anchor.y) + art["hand"]
	if facing.x < 0.0:
		local.x = -local.x
	return position + local


## The Hero's pixel art (PixelArt), feet at the bottom of the body, mirrored
## when facing left; greyed when fallen, faded as a Shade, stone-grey when petrified.
func _draw_art(art: Dictionary) -> void:
	var texture: ImageTexture = PixelArt.frame(art, alive and velocity.length() > 1.0, _stride)
	var anchor: Vector2 = art["anchor"]
	var tint := Color.WHITE
	if not alive:
		tint = Color.html(Data.cfg_string("player.fallen_color"))
	if shade:
		tint = Color(Color.html(Data.cfg_string("coop.shade_color")), 0.55)
	if rooted_s > 0.0:
		tint = Color.html(Data.cfg_string("bosses.petrified_color"))
	var left: bool = facing.x < 0.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0 if left else 1.0, 1.0))
	var top_left := Vector2(-anchor.x, body_radius - anchor.y)
	# The weapon they use most, in their hand (behind the fist, so the fingers wrap round it).
	var held: Dictionary = PixelArt.held_weapon(weapons) if art.has("hand") and swinging_s <= 0.0 else {}
	if not held.is_empty():
		draw_texture(PixelArt.frame(held, false, 0.0), top_left + art["hand"] - held["grip"], tint)
	draw_texture(texture, top_left, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## A downed player: a shrinking ring for the bleed-out time, and the revive progress.
func _draw_downed(size_px: float) -> void:
	var bleed_total: float = Data.cfg_float("coop.bleed_out_s")
	draw_arc(Vector2.ZERO, size_px, -PI * 0.5, -PI * 0.5 + TAU * clampf(bleed_s / bleed_total, 0.0, 1.0), 24,
			Color.html(Data.cfg_string("coop.bleed_color")), 2.0)
	if revive_progress_s > 0.0:
		var needed: float = CoopRevives.revive_time(self)
		draw_arc(Vector2.ZERO, size_px * 1.4, -PI * 0.5, -PI * 0.5 + TAU * clampf(revive_progress_s / needed, 0.0, 1.0), 24,
				Color.html(Data.cfg_string("coop.revive_color")), 3.0)


## HP bar over the Hero (GAME_DESIGN.md: HUD).
func _draw_hp_bar() -> void:
	var width: float = Data.cfg_float("player.hp_bar_width_px")
	var height: float = Data.cfg_float("player.hp_bar_height_px")
	var offset: float = Data.cfg_float("player.hp_bar_offset_px")
	var art: Dictionary = PixelArt.find(str(hero.get("id", "")))
	if not art.is_empty():
		# Just above the top of the Hero's art.
		offset = (art["anchor"] as Vector2).y - body_radius + Data.cfg_float("player.hp_bar_art_gap_px")
	var top_left := Vector2(-width * 0.5, -offset)
	draw_rect(Rect2(top_left, Vector2(width, height)), Color.html(Data.cfg_string("player.hp_bar_back_color")))
	var fraction: float = clampf(hp / max_hp, 0.0, 1.0) if max_hp > 0.0 else 0.0
	draw_rect(Rect2(top_left, Vector2(width * fraction, height)), Color.html(Data.cfg_string("player.hp_bar_color")))
