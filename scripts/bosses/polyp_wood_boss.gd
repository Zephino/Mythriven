class_name PolypWoodBoss
extends BossController
## The Polyp Wood, 10:00 (docs/PACK_13_PLAN.md: the Sea King's Hall). Signature, the grasping polyps: every few seconds
## their arms shoot out to marked spots under the Heroes; whoever is still there is seized (hurt and held fast for a
## moment). Source: Andersen, "The Little Mermaid" (1837: the polyps round the Sea Witch's house, which seize whatever
## comes near and never let go).

var marks: Array = []
var seized: int = 0
var _grab_in: float = 2.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	for i: int in range(marks.size() - 1, -1, -1):
		marks[i]["left"] = float(marks[i]["left"]) - delta
		if float(marks[i]["left"]) <= 0.0:
			_grab(marks[i]["pos"])
			marks.remove_at(i)
	if not is_alive():
		return
	_grab_in -= delta
	if _grab_in <= 0.0:
		_grab_in = float(_sig().get("grab_every_s", 3.0))
		for player: Player in GameAuthority.players:
			if player.alive:
				marks.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 1.0))})


func _grab(at: Vector2) -> void:
	var reach: float = float(_sig().get("grab_radius_px", 28.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			seized += 1
			GameAuthority.damage_player(player, float(_sig().get("grab_damage", 8.0)), str(data.get("id", "")), at)
			player.rooted_s = maxf(player.rooted_s, float(_sig().get("hold_s", 1.5)))
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.5, 0.7, 0.45), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for m: Dictionary in marks:
		m["pos"] = Vector2(m["pos"]) - shift_px


## The marked spots, with slimy arms reaching toward them from the wood.
func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var me: Vector2 = position_now() - global_position
	for m: Dictionary in marks:
		var p: Vector2 = Vector2(m["pos"]) - global_position
		draw_arc(p, float(_sig().get("grab_radius_px", 28.0)), 0.0, TAU, 20, area_color, 1.5)
		if is_alive():
			var t: float = 1.0 - float(m["left"]) / float(_sig().get("telegraph_s", 1.0))
			draw_line(me, me.lerp(p, t), Color(0.45, 0.65, 0.4, 0.7), 3.0)
	super._draw()


## Out of the Wood secret: beaten without the polyps ever seizing anyone.
func secret_earned() -> String:
	return "out_of_the_wood" if seized == 0 else ""
