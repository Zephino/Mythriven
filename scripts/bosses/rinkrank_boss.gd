class_name RinkrankBoss
extends BossController
## Old Rinkrank, 20:00 (docs/PACK_10_PLAN.md: the Glass Mountain). Signature, the ladder: every so often he lets down
## his ladder and climbs up out of reach, throwing glass shards down on marked spots under the Heroes, then climbs back
## down. Source: the Brothers Grimm, "Old Rinkrank" (KHM 196): the old man in the glass mountain who let down his ladder
## to come and go.

var up_s: float = 0.0
var climbs: int = 0
## Shards on their way down: {"pos", "left"}.
var shards: Array = []
var _climb_in: float = 6.0
var _throw_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return 0.0 if up_s > 0.0 else amount


func signature(delta: float) -> void:
	for i: int in range(shards.size() - 1, -1, -1):
		shards[i]["left"] = float(shards[i]["left"]) - delta
		if float(shards[i]["left"]) <= 0.0:
			_shatter(shards[i]["pos"])
			shards.remove_at(i)
	if not is_alive():
		return
	if up_s > 0.0:
		up_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], 0.2)
		_throw_in -= delta
		if _throw_in <= 0.0:
			_throw_in = float(_sig().get("throw_every_s", 1.0))
			for player: Player in GameAuthority.players:
				if player.alive:
					shards.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 0.9))})
		if up_s <= 0.0:
			GameAuthority.enemies.statuses.stun[slot] = 0.0
		return
	_climb_in -= delta
	if _climb_in <= 0.0:
		_climb_in = float(_sig().get("climb_every_s", 10.0))
		climb()


func climb() -> void:
	climbs += 1
	up_s = float(_sig().get("up_s", 3.0))
	_throw_in = 0.2
	cast = {}
	if patterns != null:
		patterns.clear()


func _shatter(at: Vector2) -> void:
	var reach: float = float(_sig().get("shard_radius_px", 26.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("shard_damage", 12.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.8, 0.95, 1.0), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for s: Dictionary in shards:
		s["pos"] = Vector2(s["pos"]) - shift_px


## Up the ladder: only the ladder shows.
func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	for s: Dictionary in shards:
		draw_arc(Vector2(s["pos"]) - global_position, float(_sig().get("shard_radius_px", 26.0)), 0.0, TAU, 20, area_color, 1.5)
	if up_s > 0.0 and is_alive():
		var at: Vector2 = position_now() - global_position
		draw_line(at + Vector2(-6, 0), at + Vector2(-6, -70), Color(0.5, 0.35, 0.2), 2.0)
		draw_line(at + Vector2(6, 0), at + Vector2(6, -70), Color(0.5, 0.35, 0.2), 2.0)
		for k: int in 7:
			draw_line(at + Vector2(-6, -k * 10), at + Vector2(6, -k * 10), Color(0.5, 0.35, 0.2), 1.5)
		return
	super._draw()
