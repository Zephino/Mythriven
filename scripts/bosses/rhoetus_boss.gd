class_name RhoetusBoss
extends BossController
## Rhoetus, 20:00 (docs/PACK_13_PLAN.md: Mount Pelion). Signature, the burning brand: every few seconds he swings his
## brand round him, hurting and Burning whoever is close; now and then he flings a brand at a marked spot near the
## farthest Hero, and the ground there burns for a while. Source: Ovid, Metamorphoses 12.271-290 (Rhoetus snatches a
## burning log from the altar).

## Brands in the air: {"pos", "left"}; burning ground: {"pos", "left"}.
var brands: Array = []
var fires: Array = []
var burned: int = 0
var _sweep_in: float = 2.0
var _throw_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	for i: int in range(brands.size() - 1, -1, -1):
		brands[i]["left"] = float(brands[i]["left"]) - delta
		if float(brands[i]["left"]) <= 0.0:
			fires.append({"pos": brands[i]["pos"], "left": float(_sig().get("fire_s", 5.0))})
			brands.remove_at(i)
	var reach: float = float(_sig().get("fire_radius_px", 34.0))
	for i: int in range(fires.size() - 1, -1, -1):
		fires[i]["left"] = float(fires[i]["left"]) - delta
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(fires[i]["pos"]) <= reach + player.body_radius:
				GameAuthority.damage_player_over_time(player, float(_sig().get("fire_dps", 6.0)) * delta)
		if float(fires[i]["left"]) <= 0.0:
			fires.remove_at(i)
	if not is_alive():
		return
	_sweep_in -= delta
	if _sweep_in <= 0.0:
		_sweep_in = float(_sig().get("sweep_every_s", 3.0))
		sweep()
	_throw_in -= delta
	if _throw_in <= 0.0:
		_throw_in = float(_sig().get("throw_every_s", 6.0))
		var far: Player = null
		for player: Player in GameAuthority.players:
			if player.alive and (far == null or player.position.distance_to(position_now()) > far.position.distance_to(position_now())):
				far = player
		if far != null:
			brands.append({"pos": far.position, "left": float(_sig().get("telegraph_s", 1.0))})


## The brand swung in a circle round him.
func sweep() -> void:
	var at: Vector2 = position_now()
	var reach: float = float(_sig().get("sweep_radius_px", 70.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			burned += 1
			GameAuthority.damage_player(player, float(_sig().get("sweep_damage", 10.0)), str(data.get("id", "")), at)
			player.statuses.apply("burn")
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.95, 0.5, 0.15), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the brands and fires move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for b: Dictionary in brands:
		b["pos"] = Vector2(b["pos"]) - shift_px
	for f: Dictionary in fires:
		f["pos"] = Vector2(f["pos"]) - shift_px


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var r: float = float(_sig().get("fire_radius_px", 34.0))
	for b: Dictionary in brands:
		draw_arc(Vector2(b["pos"]) - global_position, r, 0.0, TAU, 20, area_color, 1.5)
	for f: Dictionary in fires:
		var p: Vector2 = Vector2(f["pos"]) - global_position
		draw_set_transform(p, 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, r, Color(0.9, 0.35, 0.1, 0.35))
		draw_set_transform(Vector2.ZERO)
		for k: int in 3:
			var at: Vector2 = p + Vector2(-12 + k * 12, -2)
			draw_colored_polygon(PackedVector2Array([at + Vector2(-4, 0), at + Vector2(0, -10), at + Vector2(4, 0)]), Color(1.0, 0.6, 0.2))
	super._draw()
