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
	return kit.damage_mult(weapon) if kit != null else 1.0


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
	elif input != null and alive:
		step(input.get_move_vector(), delta)
	elif not alive:
		velocity = Vector2.ZERO
	if hp != _shown_hp:
		_shown_hp = hp
		queue_redraw()


## Moves by one frame in `direction` (a unit vector or zero) and updates facing.
func step(direction: Vector2, delta: float) -> void:
	if rooted_s > 0.0:
		direction = Vector2.ZERO
	velocity = direction * move_speed * statuses.speed_mult() * slow_zone_mult * (kit.speed_mult() if kit != null else 1.0)
	position += velocity * delta
	if direction != Vector2.ZERO and direction != facing:
		facing = direction
		queue_redraw()


func _draw() -> void:
	var size_px: float = Data.cfg_float("player.placeholder_size_px")
	var color := Color.html(str(hero.get("placeholder_color", Data.cfg_string("player.placeholder_color"))))
	if not alive:
		color = Color.html(Data.cfg_string("player.fallen_color"))
	draw_rect(Rect2(Vector2(-size_px, -size_px) * 0.5, Vector2(size_px, size_px)), color)
	if invulnerable_s > 0.0:
		draw_arc(Vector2.ZERO, size_px * 0.9, 0.0, TAU, 20, Color.html(Data.cfg_string("gods.invulnerable_color")), 2.0)
	if rooted_s > 0.0:
		draw_rect(Rect2(Vector2(-size_px, -size_px) * 0.5, Vector2(size_px, size_px)), Color.html(Data.cfg_string("bosses.petrified_color")))
	# A small dot on the facing side shows which way the player last moved.
	var marker_px: float = Data.cfg_float("player.facing_marker_px")
	var marker_color := Color.html(Data.cfg_string("player.facing_marker_color"))
	draw_circle(facing * (size_px * 0.5 - marker_px * 0.5), marker_px * 0.5, marker_color)
	_draw_hp_bar()


## HP bar over the Hero (GAME_DESIGN.md: HUD).
func _draw_hp_bar() -> void:
	var width: float = Data.cfg_float("player.hp_bar_width_px")
	var height: float = Data.cfg_float("player.hp_bar_height_px")
	var top_left := Vector2(-width * 0.5, -Data.cfg_float("player.hp_bar_offset_px"))
	draw_rect(Rect2(top_left, Vector2(width, height)), Color.html(Data.cfg_string("player.hp_bar_back_color")))
	var fraction: float = clampf(hp / max_hp, 0.0, 1.0) if max_hp > 0.0 else 0.0
	draw_rect(Rect2(top_left, Vector2(width * fraction, height)), Color.html(Data.cfg_string("player.hp_bar_color")))
