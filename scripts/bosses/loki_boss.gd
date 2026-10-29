class_name LokiBoss
extends BossController
## Loki, 20:00 (GAME_DESIGN.md: Midgard's Edge bosses). Signature,
## shapeshifting illusions: he splits into copies, and only the real Loki
## casts a shadow; copies burst into fire when hit. Phases: fire-dagger fans
## → three illusions → he swaps places with the player and fakes a shrine
## that bursts into flame when touched.

var _illusions: Array[int] = []
var _illusion_left: float = 0.0
var _swap_left: float = -1.0
var _swap_charge: float = -1.0
## The fake shrine's position (Vector2.INF = none).
var _fake := Vector2.INF
var _fake_left: float = 0.0


func _ready() -> void:
	super._ready()
	GameAuthority.enemy_killed.connect(_on_enemy_killed)


func _on_phase_started(index: int) -> void:
	_illusion_left = 0.5 if index >= 1 else 0.0
	_swap_left = float(_sig().get("swap_every_s", 9.0)) if index >= 2 else -1.0
	_fake_left = 2.0


func signature(delta: float) -> void:
	if phase_index >= 1:
		_illusion_left -= delta
		if _illusion_left <= 0.0:
			_illusion_left = float(_sig().get("illusion_every_s", 8.0))
			_refill_illusions()
	if phase_index >= 2 and target != null:
		_tick_swap(delta)
		_tick_fake_shrine(delta)


func _sig() -> Dictionary:
	return data.get("signature", {})


func _refill_illusions() -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	for i: int in range(_illusions.size() - 1, -1, -1):
		var copy_slot: int = _illusions[i]
		if enemies.active[copy_slot] == 0 or str(enemies.type_of(copy_slot)["id"]) != str(_sig().get("illusion", "")):
			_illusions.remove_at(i)
	var wanted: int = int(_sig().get("illusions", 3))
	while _illusions.size() < wanted:
		var at: Vector2 = position_now() + Vector2.from_angle(GameAuthority.run.rng.combat.randf() * TAU) * 60.0
		var copy: int = GameAuthority.spawn_enemy(str(_sig().get("illusion", "loki_illusion")), at)
		if copy == -1:
			return
		_illusions.append(copy)


## A copy bursts into fire when it falls.
func _on_enemy_killed(killed_slot: int, enemy_type: Dictionary, at: Vector2, _killer: Player) -> void:
	if puppet or not _illusions.has(killed_slot) or str(enemy_type.get("id", "")) != str(_sig().get("illusion", "")):
		return
	_illusions.erase(killed_slot)
	if patterns != null and target != null:
		patterns.run(_sig().get("burst", {"pattern": "radial_burst"}), at, target.position, "fire", str(data.get("id", "")), _damage_mult())


## He glows for a moment, then trades places with the player.
func _tick_swap(delta: float) -> void:
	if _swap_charge >= 0.0:
		_swap_charge += delta
		if _swap_charge >= float(_sig().get("swap_warning_s", 1.0)):
			_swap_charge = -1.0
			var mine: Vector2 = position_now()
			GameAuthority.enemies.positions[slot] = target.position
			GameAuthority.place_player(target, mine)
		return
	_swap_left -= delta
	if _swap_left <= 0.0:
		_swap_left = float(_sig().get("swap_every_s", 9.0))
		_swap_charge = 0.0


func _tick_fake_shrine(delta: float) -> void:
	if _fake == Vector2.INF:
		_fake_left -= delta
		if _fake_left <= 0.0:
			_fake = target.position + Vector2.from_angle(GameAuthority.run.rng.combat.randf() * TAU) * 90.0
		return
	if target.position.distance_to(_fake) <= Data.cfg_float("gods.shrine_radius_px") + target.body_radius:
		if patterns != null:
			patterns.run({"pattern": "ground_circles", "count": 1, "spread_px": 0, "radius_px": 40, "damage": float(_sig().get("fake_damage", 18)),
					"telegraph_s": 0.3}, _fake, _fake, "fire", str(data.get("id", "")), _damage_mult())
		_fake = Vector2.INF
		_fake_left = float(_sig().get("fake_every_s", 12.0))


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if _fake != Vector2.INF:
		_fake -= shift_px


func _draw() -> void:
	if is_alive():
		# Only the real Loki casts a shadow.
		var at: Vector2 = position_now() - global_position
		var radius: float = GameAuthority.enemies.radius[slot]
		draw_set_transform(at + Vector2(0, radius * 0.8), 0.0, Vector2(1.0, 0.4))
		draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.45))
		draw_set_transform(Vector2.ZERO)
		if _swap_charge >= 0.0 and target != null:
			var color := Color.html(Data.cfg_string("bosses.fire_telegraph_color"))
			draw_arc(at, radius + 6.0, 0.0, TAU, 20, color, 2.0)
			draw_arc(target.position - global_position, 14.0, 0.0, TAU, 20, color, 2.0)
	super._draw()
	if _fake != Vector2.INF:
		var spot: Vector2 = _fake - global_position
		var stone := Color.html(Data.cfg_string("gods.shrine_stone_color"))
		draw_rect(Rect2(spot - Vector2(6, 14), Vector2(12, 24)), stone)
		draw_circle(spot + Vector2(0, -16), 5.0, Color.html(str(_sig().get("fake_glow", "#ff9030"))))
