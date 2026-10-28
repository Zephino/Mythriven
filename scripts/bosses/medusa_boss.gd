class_name MedusaBoss
extends BossController
## Medusa, 10:00 (GAME_DESIGN.md: The Aegean Shore bosses). Signature, the
## Gaze: she charges a stare with a visible cone; anyone moving toward her
## when it fires is petrified (rooted 1.5 s). Move away or sideways.
## Phases: serpent-hair volleys → gaze every 8 s → gaze plus stone statues
## that block projectiles (hers and yours).

## Times anyone was petrified this fight (kept for Phase 15's secrets).
var petrified_count: int = 0

var _gaze_timer: float = 0.0
var _gaze_charge: float = -1.0
var _gaze_dir := Vector2.LEFT
var _statues := PackedVector2Array()


func signature(delta: float) -> void:
	var sig: Dictionary = data.get("signature", {})
	for statue: Vector2 in _statues:
		var reach: float = float(sig.get("statue_radius_px", 14.0))
		if GameAuthority.enemy_shots != null:
			GameAuthority.enemy_shots.block_circle(statue, reach)
		get_tree().call_group("player_projectiles", "block_circle", statue, reach)
	if not bool(phase().get("gaze", false)) or target == null:
		return
	if _gaze_charge >= 0.0:
		_gaze_charge += delta
		if _gaze_charge >= float(sig.get("charge_s", 1.2)):
			_gaze_charge = -1.0
			_fire_gaze(sig)
		return
	_gaze_timer -= delta
	if _gaze_timer <= 0.0:
		_gaze_timer = float(sig.get("every_s", 8.0))
		_gaze_charge = 0.0
		_gaze_dir = (target.position - position_now()).normalized()


func _on_phase_started(index: int) -> void:
	_gaze_timer = 2.0
	if bool(phase().get("statues", false)) and _statues.is_empty():
		var count: int = int((data.get("signature", {}) as Dictionary).get("statues", 4))
		for k: int in count:
			_statues.append(position_now() + Vector2.from_angle(TAU * k / count + 0.4) * Data.cfg_float("bosses.statue_ring_px"))
	if index == 0:
		_statues.clear()


## Everyone in the cone who is moving toward her is petrified.
func _fire_gaze(sig: Dictionary) -> void:
	var at: Vector2 = position_now()
	var half: float = deg_to_rad(float(sig.get("cone_deg", 70.0)) * 0.5)
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		var offset: Vector2 = player.position - at
		if offset.length() > float(sig.get("range_px", 300.0)) or absf(_gaze_dir.angle_to(offset)) > half:
			continue
		if player.velocity.dot(-offset) > 0.0:
			player.rooted_s = maxf(player.rooted_s, float(sig.get("petrify_s", 1.5)))
			petrified_count += 1
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_arc(at, _gaze_dir.angle(), float(sig.get("range_px", 300.0)), half * 2.0, Color.html(Data.cfg_string("bosses.petrified_color")))


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in _statues.size():
		_statues[i] -= shift_px


func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	var sig: Dictionary = data.get("signature", {})
	var stone := Color.html(Data.cfg_string("gods.shrine_stone_color"))
	for statue: Vector2 in _statues:
		draw_circle(statue - global_position, float(sig.get("statue_radius_px", 14.0)), stone)
	if _gaze_charge >= 0.0:
		var k: float = clampf(_gaze_charge / float(sig.get("charge_s", 1.2)), 0.0, 1.0)
		var at: Vector2 = position_now() - global_position
		var half: float = deg_to_rad(float(sig.get("cone_deg", 70.0)) * 0.5)
		var reach: float = float(sig.get("range_px", 300.0))
		var points := PackedVector2Array([at])
		for s: int in 13:
			points.append(at + Vector2.from_angle(_gaze_dir.angle() - half + half * 2.0 * s / 12.0) * reach)
		var color := Color.html(Data.cfg_string("bosses.area_telegraph_color" if k < 0.8 else "bosses.fire_telegraph_color"))
		draw_colored_polygon(points, Color(color, 0.15 + 0.3 * k))
