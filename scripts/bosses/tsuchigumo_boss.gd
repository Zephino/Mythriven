class_name TsuchigumoBoss
extends BossController
## Tsuchigumo, 10:00 (docs/PACK_3_PLAN.md: the Land of Legends). Signature, webs: every few seconds the earth spider
## casts webs round its target; a Hero who steps into one is stuck fast for a moment (and tears it). Fire burns every
## web away: any Fire hit on the spider, or a Hero burning while caught. Source: the Tsuchigumo Soshi (Minamoto no
## Raiko and the earth spider).

## Webs: {"pos": Vector2, "left": float}.
var webs: Array = []
var _cast_in: float = 2.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func on_element_hit(element: String) -> void:
	if element == "fire" and not webs.is_empty():
		webs.clear()
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_TSUCHIGUMO_WEBS_BURN"))


func signature(delta: float) -> void:
	if not is_alive():
		return
	_cast_in -= delta
	if _cast_in <= 0.0:
		_cast_in = float(_sig().get("every_s", 3.5))
		var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
		var around: Vector2 = target.position if target != null and is_instance_valid(target) else position_now()
		for _k: int in int(_sig().get("webs", 2)):
			webs.append({"pos": around + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(30.0, 110.0), "left": float(_sig().get("web_s", 20.0))})
		while webs.size() > int(_sig().get("max_webs", 10)):
			webs.pop_front()
	var reach: float = float(_sig().get("web_radius_px", 24.0))
	for i: int in range(webs.size() - 1, -1, -1):
		webs[i]["left"] = float(webs[i]["left"]) - delta
		if float(webs[i]["left"]) <= 0.0:
			webs.remove_at(i)
			continue
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(webs[i]["pos"]) <= reach:
				player.rooted_s = maxf(player.rooted_s, float(_sig().get("root_s", 1.2)))
				webs.remove_at(i)
				break


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for web: Dictionary in webs:
		web["pos"] = Vector2(web["pos"]) - shift_px


## Webs: pale threads in rings and spokes.
func _draw() -> void:
	var reach: float = float(_sig().get("web_radius_px", 24.0))
	for web: Dictionary in webs:
		var at: Vector2 = Vector2(web["pos"]) - global_position
		var c := Color(0.9, 0.9, 0.85, 0.7)
		for k: int in 8:
			draw_line(at, at + Vector2.from_angle(TAU * k / 8.0) * reach, c, 1.0)
		for r: int in 3:
			draw_arc(at, reach * (r + 1) / 3.0, 0.0, TAU, 8, c, 1.0)
	super._draw()
