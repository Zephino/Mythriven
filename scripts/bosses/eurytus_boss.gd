class_name EurytusBoss
extends BossController
## Eurytus, 10:00 (docs/PACK_13_PLAN.md: Mount Pelion). Signature, the wine-bowls: every few seconds he hurls a great
## wine-bowl at a marked spot near the nearest Hero; it bursts, hurting whoever is under it, and leaves a pool of wine:
## a Hero standing in a pool reels (slowed). Source: Ovid, Metamorphoses 12.219-240 (the drunken centaur Eurytus, struck
## down at the wedding with an old wine-bowl).

## Bowls in the air: {"pos", "left"}; pools of wine: {"pos", "left"}.
var bowls: Array = []
var pools: Array = []
var bowl_hits: int = 0
var _throw_in: float = 2.0
var _reel_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	for i: int in range(bowls.size() - 1, -1, -1):
		bowls[i]["left"] = float(bowls[i]["left"]) - delta
		if float(bowls[i]["left"]) <= 0.0:
			_burst(bowls[i]["pos"])
			bowls.remove_at(i)
	for i: int in range(pools.size() - 1, -1, -1):
		pools[i]["left"] = float(pools[i]["left"]) - delta
		if float(pools[i]["left"]) <= 0.0:
			pools.remove_at(i)
	_reel_in -= delta
	if _reel_in <= 0.0:
		_reel_in = 1.0
		for player: Player in GameAuthority.players:
			if player.alive and in_pool(player.position):
				player.statuses.apply("chill")
	if not is_alive():
		return
	_throw_in -= delta
	if _throw_in <= 0.0:
		_throw_in = float(_sig().get("throw_every_s", 4.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			bowls.append({"pos": near.position, "left": float(_sig().get("telegraph_s", 1.0))})


func in_pool(at: Vector2) -> bool:
	for p: Dictionary in pools:
		if at.distance_to(p["pos"]) <= float(_sig().get("pool_radius_px", 40.0)):
			return true
	return false


func _burst(at: Vector2) -> void:
	var reach: float = float(_sig().get("bowl_radius_px", 30.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			bowl_hits += 1
			GameAuthority.damage_player(player, float(_sig().get("bowl_damage", 10.0)), str(data.get("id", "")), at)
	pools.append({"pos": at, "left": float(_sig().get("pool_s", 6.0))})
	if pools.size() == 1 and bowl_hits <= 1:
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_EURYTUS_WINE"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the bowls and pools move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for b: Dictionary in bowls:
		b["pos"] = Vector2(b["pos"]) - shift_px
	for p: Dictionary in pools:
		p["pos"] = Vector2(p["pos"]) - shift_px


## Dark red pools of wine, and the marked spots where bowls will land.
func _draw() -> void:
	var r: float = float(_sig().get("pool_radius_px", 40.0))
	for p: Dictionary in pools:
		draw_set_transform(Vector2(p["pos"]) - global_position, 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, r, Color(0.45, 0.08, 0.2, 0.45))
		draw_set_transform(Vector2.ZERO)
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	for b: Dictionary in bowls:
		draw_arc(Vector2(b["pos"]) - global_position, float(_sig().get("bowl_radius_px", 30.0)), 0.0, TAU, 20, area_color, 1.5)
	super._draw()
