class_name KrakenBoss
extends BossController
## The Kraken, 30:00 (docs/PACK_9_PLAN.md: Libertalia; the design's boss). Signature, arms and whirlpool: its arms rise
## and slam down on marked spots round the Heroes, and every so often it sinks and makes a whirlpool that drags every
## Hero toward it for a few seconds. Source: Erik Pontoppidan, The Natural History of Norway (1752-53): the Kraken,
## so vast it was taken for islands, whose arms could pull down the greatest ship, and which made a whirlpool as it sank.

## Arm slams on their way: {"pos": Vector2, "left": float}.
var slams: Array = []
var whirl_s: float = 0.0
var whirlpools: int = 0
var _arms_in: float = 3.0
var _whirl_in: float = 12.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	for i: int in range(slams.size() - 1, -1, -1):
		slams[i]["left"] = float(slams[i]["left"]) - delta
		if float(slams[i]["left"]) <= 0.0:
			_slam(slams[i]["pos"])
			slams.remove_at(i)
	if not is_alive():
		return
	if whirl_s > 0.0:
		whirl_s -= delta
		for player: Player in GameAuthority.players:
			if player.alive and not (player.kit != null and player.kit.controls_movement()):
				player.position = player.position.move_toward(position_now(), float(_sig().get("pull_px_s", 80.0)) * delta)
		return
	_whirl_in -= delta
	if _whirl_in <= 0.0:
		_whirl_in = float(_sig().get("whirl_every_s", 14.0))
		whirlpool()
		return
	_arms_in -= delta
	if _arms_in <= 0.0:
		_arms_in = float(_sig().get("arms_every_s", 5.0))
		raise_arms()


func raise_arms() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		slams.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 1.2))})
		for _k: int in int(_sig().get("extra_arms", 2)):
			slams.append({"pos": player.position + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(50.0, 110.0),
					"left": float(_sig().get("telegraph_s", 1.2))})


func whirlpool() -> void:
	whirlpools += 1
	whirl_s = float(_sig().get("whirl_s", 3.0))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and whirlpools == 1:
		banner.show_text(tr("BOSS_KRAKEN_WHIRLPOOL"))


func _slam(at: Vector2) -> void:
	var reach: float = float(_sig().get("slam_radius_px", 30.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("slam_damage", 15.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.5, 0.3, 0.45), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for s: Dictionary in slams:
		s["pos"] = Vector2(s["pos"]) - shift_px


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var reach: float = float(_sig().get("slam_radius_px", 30.0))
	for s: Dictionary in slams:
		var at: Vector2 = Vector2(s["pos"]) - global_position
		draw_arc(at, reach, 0.0, TAU, 20, area_color, 1.5)
		draw_circle(at, reach * clampf(1.0 - float(s["left"]) / float(_sig().get("telegraph_s", 1.2)), 0.0, 1.0), Color(0.5, 0.3, 0.45, 0.35))
	if whirl_s > 0.0 and is_alive():
		var me: Vector2 = position_now() - global_position
		for r: int in 4:
			var spin: float = Time.get_ticks_msec() * 0.004 + r
			draw_arc(me, 40.0 + r * 40.0, spin, spin + 4.0, 24, Color(0.4, 0.6, 0.75, 0.5), 2.0)
	super._draw()


## Not an Island secret: beaten before its third whirlpool.
func secret_earned() -> String:
	return "not_an_island" if whirlpools < 3 else ""
