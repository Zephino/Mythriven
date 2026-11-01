class_name MissonBoss
extends BossController
## Captain Misson, 20:00 (docs/PACK_9_PLAN.md: Libertalia). Signature, broadsides: every few seconds his ship fires a
## broadside: rows of cannon-balls cross the arena in marked lanes, from one side and then the other. Stand between the
## lanes. Source: A General History of the Pyrates (1724), "Of Captain Misson" (the founder of Libertalia).

## Lanes about to be fired along: {"pos": Vector2 (a point on the lane), "dir": Vector2 (along it), "left": float}.
var lanes: Array = []
var broadsides: int = 0
## The Free Sailor secret: no broadside ever hits the local Hero.
var hit_local: bool = false
var _fire_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	for i: int in range(lanes.size() - 1, -1, -1):
		lanes[i]["left"] = float(lanes[i]["left"]) - delta
		if float(lanes[i]["left"]) <= 0.0:
			_fire_lane(lanes[i])
			lanes.remove_at(i)
	if not is_alive():
		return
	_fire_in -= delta
	if _fire_in <= 0.0:
		_fire_in = float(_sig().get("broadside_every_s", 8.0))
		broadside()


## Port then starboard: lanes across the arena, alternately along and across it.
func broadside() -> void:
	broadsides += 1
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	var along: Vector2 = Vector2.RIGHT if broadsides % 2 == 1 else Vector2.DOWN
	var count: int = int(_sig().get("lanes", 4))
	var gap: float = float(_sig().get("lane_gap_px", 90.0))
	var shift: float = gap * 0.5 if broadsides % 4 >= 2 else 0.0
	for k: int in count:
		lanes.append({"pos": centre + along.orthogonal() * (gap * (k - (count - 1) * 0.5) + shift), "dir": along,
				"left": float(_sig().get("telegraph_s", 1.4))})
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and broadsides == 1:
		banner.show_text(tr("BOSS_MISSON_BROADSIDE"))


## Distance from `at` to the lane's line.
func lane_distance(lane: Dictionary, at: Vector2) -> float:
	var to: Vector2 = at - Vector2(lane["pos"])
	return absf(to.dot(Vector2(lane["dir"]).orthogonal()))


func _fire_lane(lane: Dictionary) -> void:
	var half: float = float(_sig().get("lane_width_px", 32.0)) * 0.5
	for player: Player in GameAuthority.players:
		if player.alive and lane_distance(lane, player.position) <= half + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("ball_damage", 16.0)), str(data.get("id", "")), Vector2(lane["pos"]))
			if player.is_local:
				hit_local = true


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the lanes move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for lane: Dictionary in lanes:
		lane["pos"] = Vector2(lane["pos"]) - shift_px


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var half: float = float(_sig().get("lane_width_px", 32.0)) * 0.5
	for lane: Dictionary in lanes:
		var p: Vector2 = Vector2(lane["pos"]) - global_position
		var d: Vector2 = Vector2(lane["dir"])
		var n: Vector2 = d.orthogonal() * half
		var length: float = 320.0
		var fill: float = clampf(1.0 - float(lane["left"]) / float(_sig().get("telegraph_s", 1.4)), 0.0, 1.0)
		draw_colored_polygon(PackedVector2Array([p - d * length + n, p + d * length + n, p + d * length - n, p - d * length - n]), Color(area_color, 0.15 + 0.25 * fill))
	super._draw()


func secret_earned() -> String:
	return "the_free_sailor" if not hit_local else ""
