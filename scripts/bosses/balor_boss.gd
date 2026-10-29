class_name BalorBoss
extends BossController
## Balor of the Evil Eye, 30:00 (GAME_DESIGN.md: The Misty Isles bosses).
## Signature, the Eye: when his eye opens (with a warning), a death-beam sweeps
## across the arena; stand behind one of the stone circles to break its line
## of sight. Hitting him while the eye is open fills his Guard gauge ×3, as
## Lugh's sling-stone struck it in myth. Phases: Fomorian minions and fire
## breath → the Eye → the Eye opens twice as often. Lugh's Sling secret:
## strike the open eye 5 times in one fight.

## Stone circles that block the beam (and shots).
var stones := PackedVector2Array()
var eye_hits: int = 0

var _eye_timer: float = 0.0
var _warning: float = -1.0
var _open_left: float = 0.0
var _beam_angle: float = 0.0
var _hit_gap: float = 0.0
var _burn_tick: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func secret_earned() -> String:
	return "lughs_sling" if eye_hits >= int(_sig().get("sling_hits", 5)) else ""


func eye_open() -> bool:
	return _open_left > 0.0


func _on_phase_started(index: int) -> void:
	if index >= 1 and stones.is_empty() and GameAuthority.bosses != null:
		var count: int = int(_sig().get("stones", 4))
		var ring: float = GameAuthority.bosses.arena_radius * float(_sig().get("stone_ring_fraction", 0.5))
		for k: int in count:
			stones.append(GameAuthority.bosses.arena_center + Vector2.from_angle(TAU * k / count + 0.3) * ring)
	_eye_timer = 2.0


func on_hit(amount: float, element_mult: float, attacker: Player, push: Vector2) -> float:
	if eye_open() and broken_s <= 0.0:
		guard += amount * (float(_sig().get("eye_guard_mult", 3.0)) - 1.0)
		if _hit_gap <= 0.0:
			_hit_gap = float(_sig().get("eye_hit_gap_s", 0.5))
			eye_hits += 1
	return super.on_hit(amount, element_mult, attacker, push)


func signature(delta: float) -> void:
	_hit_gap = maxf(_hit_gap - delta, 0.0)
	var reach: float = float(_sig().get("stone_radius_px", 18.0))
	for stone: Vector2 in stones:
		if GameAuthority.enemy_shots != null:
			GameAuthority.enemy_shots.block_circle(stone, reach)
	if phase_index < 1 or target == null:
		return
	if eye_open():
		_open_left -= delta
		_beam_angle += float(_sig().get("sweep_rad_s", 1.2)) * delta
		_burn_beam(delta)
		return
	if _warning >= 0.0:
		_warning += delta
		if _warning >= float(_sig().get("warning_s", 1.2)):
			_warning = -1.0
			_open_left = float(_sig().get("open_s", 3.0))
			_beam_angle = (target.position - position_now()).angle() - float(_sig().get("sweep_rad_s", 1.2)) * _open_left * 0.5
		return
	_eye_timer -= delta
	if _eye_timer <= 0.0:
		_eye_timer = float(_sig().get("eye_every_s", 10.0)) / (2.0 if phase_index >= 2 else 1.0)
		_warning = 0.0
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_BALOR_EYE"))


func _burn_beam(delta: float) -> void:
	_burn_tick -= delta
	if _burn_tick > 0.0:
		return
	_burn_tick = 0.25
	var at: Vector2 = position_now()
	var dir := Vector2.from_angle(_beam_angle)
	var width: float = float(_sig().get("beam_width_px", 26.0))
	for player: Player in GameAuthority.players:
		var offset: Vector2 = player.position - at
		var along: float = offset.dot(dir)
		if not player.alive or along < 0.0 or absf(offset.cross(dir)) > width * 0.5 + player.body_radius:
			continue
		if _shielded(at, player.position):
			continue
		GameAuthority.damage_player(player, float(_sig().get("beam_damage", 12.0)) * _damage_mult(), str(data.get("id", "")))


## True when a stone circle stands between the Eye and `spot`.
func _shielded(eye: Vector2, spot: Vector2) -> bool:
	var reach: float = float(_sig().get("stone_radius_px", 18.0))
	for stone: Vector2 in stones:
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(stone, eye, spot)
		if closest.distance_to(stone) <= reach:
			return true
	return false


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in stones.size():
		stones[i] -= shift_px


func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	var stone_color := Color.html(Data.cfg_string("gods.shrine_stone_color"))
	for stone: Vector2 in stones:
		draw_circle(stone - global_position, float(_sig().get("stone_radius_px", 18.0)), stone_color)
	var at: Vector2 = position_now() - global_position
	var eye_color := Color.html(Data.cfg_string("bosses.fire_telegraph_color"))
	if _warning >= 0.0:
		draw_circle(at, 5.0 + _warning * 4.0, Color(eye_color, 0.6))
	if eye_open():
		var length: float = GameAuthority.bosses.arena_radius * 2.2 if GameAuthority.bosses != null else 600.0
		draw_line(at, at + Vector2.from_angle(_beam_angle) * length, Color(eye_color, 0.8), float(_sig().get("beam_width_px", 26.0)))
		draw_circle(at, 7.0, Color.WHITE)
