class_name MorvarchBoss
extends BossController
## Morvarc'h, 10:00 (docs/PACK_4_PLAN.md: Ys). Signature, over the waves: every few seconds King Gradlon's sea-horse
## gallops straight across the field, trampling anyone in its path, and leaves a wake of foam that slows for a while.
## Source: Albert Le Grand (1636); Souvestre (1844): the horse that could gallop over the sea.

var gallop_s: float = 0.0
var gallop_dir := Vector2.RIGHT
## Foam left behind: {"pos": Vector2, "left": float}.
var foam: Array = []
var _gallop_in: float = 2.5
var _drop_in: float = 0.0
var _slowed: Dictionary = {}


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_gallop_in -= delta
	if _gallop_in <= 0.0 and gallop_s <= 0.0:
		_gallop_in = float(_sig().get("gallop_every_s", 4.0))
		gallop_s = float(_sig().get("gallop_s", 0.6))
		var toward: Vector2 = (target.position - position_now()) if target != null and is_instance_valid(target) else Vector2.RIGHT
		gallop_dir = toward.normalized()
	if gallop_s > 0.0:
		gallop_s -= delta
		var speed: float = float(_sig().get("gallop_px", 280.0)) / maxf(float(_sig().get("gallop_s", 0.6)), 0.01)
		GameAuthority.enemies.positions[slot] += gallop_dir * speed * GameAuthority.enemies.statuses.speed_mult(slot) * delta
		_drop_in -= delta
		if _drop_in <= 0.0:
			_drop_in = 0.08
			foam.append({"pos": position_now(), "left": float(_sig().get("foam_s", 5.0))})
	for i: int in range(foam.size() - 1, -1, -1):
		foam[i]["left"] = float(foam[i]["left"]) - delta
		if float(foam[i]["left"]) <= 0.0:
			foam.remove_at(i)
	var reach: float = float(_sig().get("foam_radius_px", 22.0))
	for player: Player in GameAuthority.players:
		var inside: bool = false
		for f: Dictionary in foam:
			if player.position.distance_to(f["pos"]) <= reach:
				inside = true
				break
		if inside:
			player.slow_zone_mult = float(_sig().get("foam_slow", 0.55))
			_slowed[player.player_id] = true
		elif _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
			_slowed.erase(player.player_id)


func _exit_tree() -> void:
	for player: Player in GameAuthority.players:
		if is_instance_valid(player) and _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
	_slowed.clear()


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for f: Dictionary in foam:
		f["pos"] = Vector2(f["pos"]) - shift_px


func _draw() -> void:
	var reach: float = float(_sig().get("foam_radius_px", 22.0))
	for f: Dictionary in foam:
		var fade: float = clampf(float(f["left"]) / 1.5, 0.0, 1.0)
		draw_circle(Vector2(f["pos"]) - global_position, reach, Color(0.85, 0.95, 1.0, 0.35 * fade))
	super._draw()
