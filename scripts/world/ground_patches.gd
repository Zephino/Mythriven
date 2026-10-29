class_name GroundPatches
extends Node2D
## Ground features from the hazard library (slow ground, teleport rings): a
## level's "ground_patches" data scatters patches around the players, kept
## near them as they travel (seeded by the run, so the same run seed lays them
## out the same way):
##   slide     frozen ponds: you keep sliding (less grip)
##   slow      quicksand: you move slower
##   teleport  fairy rings, in pairs: stepping into one carries you to the other
## Like every hazard, patches do nothing while a boss arena is up.
## Data: kind, count, radius_px [min, max], color, grip_per_s, speed_mult,
## teleport_cooldown_s, pair_distance_screens.

## Each patch: {"pos", "radius", "pair" (index of its partner, teleport only)}.
var patches: Array[Dictionary] = []

var _data: Dictionary = {}
var _cooldown: Dictionary = {}


func setup(data: Dictionary) -> void:
	_data = data
	z_index = -5


func kind() -> String:
	return str(_data.get("kind", ""))


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for patch: Dictionary in patches:
		patch["pos"] = Vector2(patch["pos"]) - shift_px


func _process(delta: float) -> void:
	var player: Player = GameAuthority.local_player()
	if player == null or GameAuthority.run == null or _data.is_empty():
		return
	_keep_near(player)
	var arena: bool = GameAuthority.run.boss_arena_active
	for other: Player in GameAuthority.players:
		other.ground_speed_mult = 1.0
		other.ground_grip_per_s = 0.0
		_cooldown[other.player_id] = maxf(float(_cooldown.get(other.player_id, 0.0)) - delta, 0.0)
		if arena or not other.alive:
			continue
		var index: int = patch_at(other.position)
		if index == -1:
			continue
		match kind():
			"slide":
				other.ground_grip_per_s = float(_data.get("grip_per_s", 2.0))
			"slow":
				other.ground_speed_mult = float(_data.get("speed_mult", 0.5))
			"teleport":
				_teleport(other, index)
	queue_redraw()


## The patch under `at`, or -1.
func patch_at(at: Vector2) -> int:
	for i: int in patches.size():
		if at.distance_to(patches[i]["pos"]) <= float(patches[i]["radius"]):
			return i
	return -1


func _teleport(player: Player, index: int) -> void:
	if float(_cooldown.get(player.player_id, 0.0)) > 0.0 or player.position.distance_to(patches[index]["pos"]) > float(patches[index]["radius"]) * 0.6:
		return
	var pair: int = int(patches[index].get("pair", -1))
	if pair < 0 or pair >= patches.size():
		return
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(player.position, float(patches[index]["radius"]), Color.html(str(_data.get("color", "#ffffff"))))
	player.position = patches[pair]["pos"]
	_cooldown[player.player_id] = float(_data.get("teleport_cooldown_s", 4.0))


## Keeps `count` patches within reach: far ones are moved to the ring ahead.
func _keep_near(player: Player) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	var limit: float = view.x * 1.5
	var count: int = int(_data.get("count", 6))
	var rng: RandomNumberGenerator = GameAuthority.run.rng.world
	var sizes: Array = _data.get("radius_px", [24, 40])
	while patches.size() < count:
		patches.append({"pos": _spot(player, view, rng, patches.is_empty()), "radius": rng.randf_range(float(sizes[0]), float(sizes[1])), "pair": -1})
	if kind() == "teleport":
		for i: int in range(0, patches.size() - 1, 2):
			patches[i]["pair"] = i + 1
			patches[i + 1]["pair"] = i
	for i: int in patches.size():
		if player.position.distance_to(patches[i]["pos"]) > limit:
			if kind() == "teleport" and i % 2 == 1:
				var partner: Vector2 = patches[i - 1]["pos"]
				patches[i]["pos"] = partner + Vector2.from_angle(rng.randf() * TAU) * view.x * float(_data.get("pair_distance_screens", 1.0))
			else:
				patches[i]["pos"] = _spot(player, view, rng, false)


## A spot on the ring 0.6–1.2 screens out (the first may be closer, so it's seen early).
func _spot(player: Player, view: Vector2, rng: RandomNumberGenerator, near: bool) -> Vector2:
	var reach: float = view.x * (rng.randf_range(0.25, 0.45) if near else rng.randf_range(0.6, 1.2))
	return player.position + Vector2.from_angle(rng.randf() * TAU) * reach


func _draw() -> void:
	var color := Color.html(str(_data.get("color", "#ffffff")))
	var faded: bool = GameAuthority.run != null and GameAuthority.run.boss_arena_active
	for patch: Dictionary in patches:
		var radius: float = float(patch["radius"])
		if kind() == "teleport":
			draw_arc(patch["pos"], radius, 0.0, TAU, 24, Color(color, 0.4 if faded else 0.9), 3.0)
			for k: int in 8:
				draw_circle(Vector2(patch["pos"]) + Vector2.from_angle(TAU * k / 8.0) * radius, 2.5, Color(color, 0.5 if faded else 1.0))
		else:
			draw_circle(patch["pos"], radius, Color(color, 0.35 if faded else 0.7))
