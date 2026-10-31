extends HeroKit
## Atalanta. Legend Trait, The Race (she would marry only the man who outran
## her): every 25 s a golden marker appears 1.5 screens away; reaching it
## within 6 s grants an XP burst and +30% Move Speed for 8 s. A golden apple
## sometimes rolls off to the side: grabbing it doubles the reward but costs
## time, a nod to how she lost her famous race.
## Passive: +15% Move Speed; +1 pierce on bows.
## Divine Link: while hasted from The Race, summons charge 30% faster.

## World position of the marker and the apple (Vector2.INF = none).
var marker := Vector2.INF
var apple := Vector2.INF
var haste_left: float = 0.0

var _next_in: float = 0.0
var _window_left: float = 0.0
var _apple_dir := Vector2.ZERO
var _doubled: bool = false


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	player.stats.add_bonus("move_speed", float(passive_data().get("move_speed_pct", 0.0)) / 100.0)
	_next_in = float(trait_data().get("every_s", 25.0))
	var world: WorldRoot = player.get_parent() as WorldRoot
	if world != null:
		world.origin_shifted.connect(on_origin_shifted)


func speed_mult() -> float:
	return 1.0 + float(trait_data().get("haste_pct", 0.0)) / 100.0 if haste_left > 0.0 else 1.0


func extra_pierce(weapon: WeaponInstance) -> int:
	return int(passive_data().get("bow_pierce", 0)) if (weapon.data.get("categories", []) as Array).has("bow") else 0


func charge_bonus() -> float:
	return float((hero.get("divine_link", {}) as Dictionary).get("charge_bonus", 0.0)) if haste_left > 0.0 else 0.0


func hud_text() -> String:
	if marker != Vector2.INF:
		return tr("HUD_RACE") % maxi(ceili(_window_left), 0)
	return tr("HUD_RACE_HASTE") if haste_left > 0.0 else ""


## Keeps the marker and apple in place when the world origin shifts.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if marker != Vector2.INF:
		marker -= shift_px
	if apple != Vector2.INF:
		apple -= shift_px


func _process(delta: float) -> void:
	haste_left = maxf(haste_left - delta, 0.0)
	if not player.alive or GameAuthority.run == null:
		return
	var data: Dictionary = trait_data()
	if marker == Vector2.INF:
		_next_in -= delta
		if _next_in <= 0.0:
			_start_race(data)
	else:
		_window_left -= delta
		var reach: float = float(data.get("marker_radius_px", 14.0)) + player.body_radius
		if apple != Vector2.INF:
			apple += _apple_dir * float(data.get("apple_roll_px_s", 45.0)) * delta
			if player.position.distance_to(apple) <= float(data.get("apple_radius_px", 8.0)) + player.body_radius:
				_doubled = true
				apple = Vector2.INF
		if player.position.distance_to(marker) <= reach:
			_win(data)
		elif _window_left <= 0.0:
			marker = Vector2.INF
			apple = Vector2.INF
	queue_redraw()


func _start_race(data: Dictionary) -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.world
	var view: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	var heading: Vector2 = Vector2.from_angle(rng.randf() * TAU)
	marker = player.position + heading * view.x * 0.5 * float(data.get("distance_screens", 1.5))
	_window_left = float(data.get("window_s", 6.0))
	_doubled = false
	apple = Vector2.INF
	if rng.randf() < float(data.get("apple_chance", 0.0)):
		_apple_dir = heading.orthogonal() * (1.0 if rng.randf() < 0.5 else -1.0)
		apple = player.position.lerp(marker, 0.5) + _apple_dir * float(data.get("apple_offset_px", 110.0))


func _win(data: Dictionary) -> void:
	var mult: float = 2.0 if _doubled else 1.0
	GameAuthority.collect_xp(player, LevelUpRules.xp_to_next(GameAuthority.run.level) * float(data.get("xp_level_fraction", 0.5)) * mult)
	haste_left = float(data.get("haste_s", 8.0)) * mult
	marker = Vector2.INF
	apple = Vector2.INF
	_next_in = float(data.get("every_s", 25.0))
	var effects: EffectLayer = effect_layer()
	if effects != null:
		effects.spawn_ring(player.position, 30.0, Color.html(Data.cfg_string("heroes.race_color")))


## The goal is a stone turning post, as at a Greek race-course, glowing gold in a ring; an arrow at the Hero points
## the way. The apple is a golden apple (data/art/pickups/golden_apple.json). Owner request 10/31/2026.
func _draw() -> void:
	var color := Color.html(Data.cfg_string("heroes.race_color"))
	if marker != Vector2.INF:
		var local: Vector2 = marker - player.position
		var radius: float = float(trait_data().get("marker_radius_px", 14.0))
		var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.006)
		draw_circle(local, radius, Color(color, 0.25 + 0.15 * pulse))
		draw_arc(local, radius, 0.0, TAU, 24, color, 2.0)
		var stone := Color.html(Data.cfg_string("gods.shrine_stone_color"))
		draw_rect(Rect2(local + Vector2(-3, -16), Vector2(6, 18)), Color(0.14, 0.09, 0.05))
		draw_rect(Rect2(local + Vector2(-2, -15), Vector2(4, 16)), stone)
		draw_rect(Rect2(local + Vector2(-4, -18), Vector2(8, 3)), stone)
		draw_line(local + Vector2(-1, -14), local + Vector2(-1, -1), Color(1, 1, 1, 0.35), 1.0)
		draw_line(local.normalized() * 14.0, local.normalized() * 24.0, color, 2.0)
	if apple != Vector2.INF:
		var art: Dictionary = PixelArt.find("pickups/golden_apple")
		if art.is_empty():
			draw_circle(apple - player.position, float(trait_data().get("apple_radius_px", 8.0)), color)
		else:
			var texture: ImageTexture = PixelArt.frame(art, false, 0.0)
			draw_texture(texture, apple - player.position - texture.get_size() * 0.5)
