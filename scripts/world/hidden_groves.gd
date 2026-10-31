class_name HiddenGroves
extends Node2D
## Hidden groves (docs/WORLD_PLAN.md: 3; owner request 10/31/2026). Now and then thick forest hides a clearing: a
## ring of trees too close to pass, its middle roofed over with leaves, so from outside it looks like more forest.
## A few trees in the ring can be walked through (the way in, with two trees standing before it so the path winds),
## and a faint glint shows there now and then. Stepping inside, the leaves overhead fade and the clearing shows:
## a chest (sometimes a big one), guarded by monsters that wake as you come in. Rarely, instead of the chest, the
## hidden shrine waits there (it gives a third god slot; see Shrines and docs/WORLD_PLAN.md: 4).
## Groves are planned with the forest (Flora), from the run seed, so every co-op player has the same ones; what's
## inside is decided by the game that decides, once, when the first Hero steps in.

var flora: Flora
var shrines: Shrines
var chests: ChestPickups

## How far each grove's leaves have faded on this device (key -> 0..1).
var _reveal: Dictionary = {}
var _time: float = 0.0


## Carves a grove into a chunk of thick forest, sometimes: clears its middle, rings it with trees and leaves a way in.
## Returns the grove ({"key", "at", "r", "shrine"}) or {} when this chunk has none.
static func carve(f: Flora, coord: Vector2i, items: Array, rng: RandomNumberGenerator) -> Dictionary:
	var chunk_px: float = f._chunk_px
	var at: Vector2 = (Vector2(coord) + Vector2(rng.randf_range(0.3, 0.7), rng.randf_range(0.3, 0.7))) * chunk_px
	if f.density_at(at) < Data.cfg_float("world.grove_min_density") or rng.randf() >= Data.cfg_float("world.grove_chance"):
		return {}
	var radius: float = Data.cfg_float("world.grove_radius_px")
	var trees: Array = []
	for key: String in f._trees:
		if key.ends_with("|medium") or key.ends_with("|large"):
			trees.append_array(f._trees[key])
	if trees.is_empty():
		return {}
	# Nothing else grows in or right round the ring.
	for k: int in range(items.size() - 1, -1, -1):
		if Vector2(items[k]["at"]).distance_to(at) <= radius + 14.0:
			items.remove_at(k)
	var spacing: float = Data.cfg_float("world.grove_tree_spacing_px")
	var count: int = maxi(int(TAU * radius / spacing), 8)
	var gate: int = rng.randi_range(0, count - 1)
	var gate_trees: int = Data.cfg_int("world.grove_gate_trees")
	var key: String = "grove_%d_%d" % [coord.x, coord.y]
	for k: int in count:
		var spot: Vector2 = at + Vector2.from_angle(TAU * k / count) * radius
		var item: Dictionary = f._item(trees[rng.randi_range(0, trees.size() - 1)], spot)
		item["grove"] = key
		# The way in: these trees can be walked through.
		if posmod(k - gate, count) < gate_trees:
			item["solid"] = 0.0
			item["secret"] = true
		items.append(item)
	# Two trees stand before the way in, so the path winds.
	var gate_dir: Vector2 = Vector2.from_angle(TAU * (gate + (gate_trees - 1) * 0.5) / count)
	for side: float in [-1.0, 1.0]:
		var spot: Vector2 = at + gate_dir * (radius + spacing * 1.2) + gate_dir.orthogonal() * side * spacing * 0.7
		var item: Dictionary = f._item(trees[rng.randi_range(0, trees.size() - 1)], spot)
		item["grove"] = key
		items.append(item)
	# The roof of leaves over the clearing: the tops of seven big trees.
	var roof: Array = []
	for k: int in 7:
		roof.append(trees[rng.randi_range(0, trees.size() - 1)])
	return {"key": key, "at": at, "r": radius, "gate": at + gate_dir * radius, "roof": roof,
			"shrine": rng.randf() < Data.cfg_float("world.grove_shrine_chance")}


func _process(delta: float) -> void:
	_time += delta
	if flora == null or not flora.enabled:
		return
	var hero: Player = GameAuthority.local_player()
	var offset: Vector2 = flora._offset()
	for key: String in flora.groves:
		var grove: Dictionary = flora.groves[key]
		var at: Vector2 = Vector2(grove["at"]) - offset
		var inside: bool = false
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(at) <= float(grove["r"]) - 4.0:
				inside = true
				if GameAuthority.decides():
					_open(grove, at, player)
		var mine: bool = hero != null and hero.position.distance_to(at) <= float(grove["r"]) + 6.0
		var target: float = 1.0 if mine else 0.0
		_reveal[key] = move_toward(float(_reveal.get(key, 0.0)), target, delta / Data.cfg_float("world.grove_reveal_s"))
		if not inside and not mine:
			continue
	queue_redraw()


## The first time anyone steps in, the clearing's contents appear and its guards wake (the deciding game only).
func _open(grove: Dictionary, at: Vector2, player: Player) -> void:
	var run: RunState = GameAuthority.run
	if run == null or run.poi_state.has(str(grove["key"])):
		return
	run.poi_state[str(grove["key"])] = "opened"
	var shrine_here: bool = bool(grove["shrine"]) and not run.poi_state.has("hidden_god_slot_shrine")
	if shrine_here and shrines != null:
		run.poi_state["hidden_god_slot_shrine"] = str(grove["key"])
		shrines.add(at, "", true, true)
	elif chests != null:
		chests.drop(at, run.rng.loot.randf() < Data.cfg_float("world.grove_big_chest_chance"))
	_guards(at, player)


func _guards(at: Vector2, player: Player) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null or GameAuthority.run == null:
		return
	var pool: Array = []
	var waves: String = JSON.stringify(Data.get_file(str(GameAuthority.run.level_data.get("waves", ""))))
	for entry: Dictionary in enemies.types:
		if bool(entry.get("elite", false)) or bool(entry.get("boss", false)) or bool(entry.get("animal", false)):
			continue
		if ["chaser", "brute", "caster"].has(str(entry.get("movement", ""))) and waves.contains("\"" + str(entry["id"]) + "\""):
			pool.append(str(entry["id"]))
	if pool.is_empty():
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.spawns
	var count: int = Data.cfg_int("world.grove_guards")
	for k: int in count:
		var spot: Vector2 = at + Vector2.from_angle(TAU * k / count + rng.randf()) * rng.randf_range(16.0, 40.0)
		if spot.distance_to(player.position) < 30.0:
			spot = at + (at - player.position).normalized() * 30.0
		GameAuthority.spawn_enemy(str(pool[rng.randi_range(0, pool.size() - 1)]), spot)


## Each grove's roof of leaves (fading as you come in) and, outside, a glint at its way in now and then.
func _draw() -> void:
	if flora == null or not flora.enabled or not flora.has_art():
		return
	var offset: Vector2 = flora._offset()
	var frames: Dictionary = flora._art["frames"]
	var view: Rect2 = (get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()).grow(120.0)
	for key: String in flora.groves:
		var grove: Dictionary = flora.groves[key]
		var at: Vector2 = Vector2(grove["at"]) - offset
		if not view.has_point(at):
			continue
		var alpha: float = 1.0 - float(_reveal.get(key, 0.0)) * Data.cfg_float("world.grove_reveal_fade")
		var roof: Array = grove["roof"]
		for k: int in roof.size():
			var texture: ImageTexture = (frames[roof[k]] as Array)[0]
			var spot: Vector2 = at + _roof_offset(k, float(grove["r"]))
			draw_texture(texture, spot - Vector2(texture.get_width() * 0.5, texture.get_height() * 0.6), Color(1, 1, 1, alpha))
		if float(_reveal.get(key, 0.0)) < 0.1 and fmod(_time + float(hash(key) % 7), 6.0) < 0.6:
			var gate: Vector2 = Vector2(grove["gate"]) - offset + Vector2(0, -14)
			var k2: float = fmod(_time, 6.0) / 0.6
			draw_line(gate - Vector2(3, 0) * k2, gate + Vector2(3, 0) * k2, Color(1, 1, 0.8, 0.8), 1.0)
			draw_line(gate - Vector2(0, 3) * k2, gate + Vector2(0, 3) * k2, Color(1, 1, 0.8, 0.8), 1.0)


static func _roof_offset(k: int, radius: float) -> Vector2:
	if k == 0:
		return Vector2.ZERO
	return Vector2.from_angle(TAU * (k - 1) / 6.0 + 0.4) * radius * 0.55
