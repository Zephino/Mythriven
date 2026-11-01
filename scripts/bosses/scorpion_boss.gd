class_name ScorpionBoss
extends BossController
## The Scorpion, 10:00 (docs/PACK_10_PLAN.md: the Empyrean). Signature, the sting: every few seconds its tail strikes
## at a marked spot under a Hero; the sting Poisons and leaves a pool of venom that Poisons whoever stands in it.
## Sources: Ovid, Fasti 5.537-544; Hyginus, De Astronomia 2.26 (the scorpion Earth sent to kill Orion, set in the sky).

## The sting on its way: {"pos", "left"}; venom pools: {"pos", "left"}.
var stings: Array = []
var pools: Array = []
var struck: int = 0
var _sting_in: float = 3.0
var _tick: float = 1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	for i: int in range(stings.size() - 1, -1, -1):
		stings[i]["left"] = float(stings[i]["left"]) - delta
		if float(stings[i]["left"]) <= 0.0:
			_strike(stings[i]["pos"])
			stings.remove_at(i)
	for i: int in range(pools.size() - 1, -1, -1):
		pools[i]["left"] = float(pools[i]["left"]) - delta
		if float(pools[i]["left"]) <= 0.0:
			pools.remove_at(i)
	_tick -= delta
	if _tick <= 0.0:
		_tick = 1.0
		var reach: float = float(_sig().get("pool_radius_px", 30.0))
		for player: Player in GameAuthority.players:
			for p: Dictionary in pools:
				if player.alive and player.position.distance_to(p["pos"]) <= reach + player.body_radius:
					player.statuses.apply("poison")
					break
	if not is_alive():
		return
	_sting_in -= delta
	if _sting_in <= 0.0:
		_sting_in = float(_sig().get("sting_every_s", 5.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			stings.append({"pos": near.position, "left": float(_sig().get("telegraph_s", 1.0))})


func _strike(at: Vector2) -> void:
	var reach: float = float(_sig().get("sting_radius_px", 30.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			struck += 1
			GameAuthority.damage_player(player, float(_sig().get("sting_damage", 16.0)), str(data.get("id", "")), at)
			player.statuses.apply("poison")
	pools.append({"pos": at, "left": float(_sig().get("pool_s", 6.0))})


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks and pools move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for s: Dictionary in stings:
		s["pos"] = Vector2(s["pos"]) - shift_px
	for p: Dictionary in pools:
		p["pos"] = Vector2(p["pos"]) - shift_px


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	for p: Dictionary in pools:
		draw_circle(Vector2(p["pos"]) - global_position, float(_sig().get("pool_radius_px", 30.0)), Color(0.45, 0.75, 0.3, 0.3 * clampf(float(p["left"]), 0.0, 1.0)))
	for s: Dictionary in stings:
		draw_arc(Vector2(s["pos"]) - global_position, float(_sig().get("sting_radius_px", 30.0)), 0.0, TAU, 20, area_color, 1.5)
	super._draw()
