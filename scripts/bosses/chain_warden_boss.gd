class_name ChainWardenBoss
extends BossController
## The Chain Warden, 10:00 (docs/PACK_11_PLAN.md: Ashkarrow, the game's own invented realm). Signature, the chain: every
## so often he marks a line toward the farthest Hero and hurls his red-hot chain along it; a Hero caught on the line is
## hurt and dragged to his feet.

## The chain being thrown: from him toward `aim`, and seconds until it flies (INF = none).
var aim := Vector2.INF
var caught: int = 0
var _throw_in: float = 3.0
var _left: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		aim = Vector2.INF
		return
	if aim != Vector2.INF:
		_left -= delta
		if _left <= 0.0:
			throw_chain()
		return
	_throw_in -= delta
	if _throw_in <= 0.0:
		_throw_in = float(_sig().get("throw_every_s", 6.0))
		var far: Player = _farthest()
		if far != null:
			var to: Vector2 = far.position - position_now()
			aim = position_now() + to.normalized() * float(_sig().get("reach_px", 320.0))
			_left = float(_sig().get("telegraph_s", 0.9))


func _farthest() -> Player:
	var best: Player = null
	for player: Player in GameAuthority.players:
		if player.alive and (best == null or player.position.distance_to(position_now()) > best.position.distance_to(position_now())):
			best = player
	return best


## The chain flies along the marked line: whoever it catches is hurt and pulled to him.
func throw_chain() -> void:
	var from: Vector2 = position_now()
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		var near: Vector2 = Geometry2D.get_closest_point_to_segment(player.position, from, aim)
		if near.distance_to(player.position) <= float(_sig().get("width_px", 14.0)) + player.body_radius:
			caught += 1
			GameAuthority.damage_player(player, float(_sig().get("damage", 12.0)), str(data.get("id", "")), from)
			if not (player.kit != null and player.kit.controls_movement()):
				player.position = from + (player.position - from).limit_length(float(data.get("radius", 20.0)) + 16.0)
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null and caught == 1:
				banner.show_text(tr("BOSS_CHAIN_WARDEN_CAUGHT"))
	aim = Vector2.INF


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marked line moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if aim != Vector2.INF:
		aim -= shift_px


func _draw() -> void:
	if aim != Vector2.INF and is_alive():
		var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
		var from: Vector2 = position_now() - global_position
		draw_line(from, aim - global_position, area_color, float(_sig().get("width_px", 14.0)) * 0.4)
		var links: int = int(from.distance_to(aim - global_position) / 10.0)
		for k: int in links:
			draw_circle(from.lerp(aim - global_position, float(k) / maxf(links, 1)), 2.0, Color(0.9, 0.35, 0.15))
	super._draw()


## Unchained secret: beaten without his chain catching anyone.
func secret_earned() -> String:
	return "unchained" if caught == 0 else ""
