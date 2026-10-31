class_name Flora
extends Node2D
## Trees, rocks and bushes (docs/WORLD_PLAN.md: 1; owner request 10/31/2026). Placed per chunk from the run seed (so
## every co-op player sees the same forest) over a smooth density map: open fields, light woods and thick forest.
## Pictures and sizes come from data/art/flora/<level>.json ("items" says what each is).
##   trees and boulders  solid: Heroes and walking monsters slide round their base (flyers go over)
##   stones              slow whoever walks over them a little
##   bushes, pebbles     walked over
## Trees whose base is below the local Hero are drawn in front of them (and fade where they'd hide the Hero); the rest
## behind. Kept clear: the start of the run, boss arenas, shrines, points of interest (clear zones).

## The flora of the current run (null outside one).
static var current: Flora

const CELL := 64.0

var origin_chunk: Vector2i = Vector2i.ZERO
## Where shrines and points of interest are, to keep clear round them (RunSystems sets these).
var shrines: Shrines
var pois: PoiManager
## False while the party is in a dungeon (nothing out here blocks them there).
var enabled: bool = true

var _art: Dictionary = {}
var _items_info: Dictionary = {}
var _names: Dictionary = {}          # kind -> [picture names]
var _trees: Dictionary = {}          # tree kind -> [picture names]
var _level: Dictionary = {}
var _seed: int = 0
var _chunk_px: float = 512.0
var _noise := FastNoiseLite.new()
## Absolute chunk -> Array of items {"name", "at" (absolute px), "solid", "slow", "kind", "hidden"}.
var _chunks: Dictionary = {}
## Absolute cell -> Array of items whose solid or slow circle reaches into it.
var _grid: Dictionary = {}
## The same, packed for the movers' hot path (rebuilt when the forest changes): cell -> [x, y, r, x, y, r...].
var _solid_cells: Dictionary = {}
var _slow_cells: Dictionary = {}
var _packed_dirty: bool = true
var _stone_mult: float = 1.0
## What each layer draws this frame (worked out once per frame).
var _back_list: Array = []
var _front_list: Array = []
var _zones: Dictionary = {}          # key -> [absolute centre, radius]
## Hidden groves in the loaded forest (HiddenGroves): key -> {"key", "at" (absolute), "r", "gate", "roof", "shrine"}.
var groves: Dictionary = {}
var _scan_s: float = 0.0
var _back: Node2D
var _front: Node2D


func setup(level: Dictionary, run_seed: int) -> void:
	current = self
	_level = level
	_seed = run_seed
	_chunk_px = Data.cfg_float("world.chunk_tiles") * Data.cfg_float("world.tile_px")
	_art = PixelArt.find("flora/" + str(level.get("id", "")))
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(PixelArt.ART_DIR + "flora/" + str(level.get("id", "")) + ".json")) \
			if not _art.is_empty() else {}
	_items_info = (raw as Dictionary).get("items", {}) if raw is Dictionary else {}
	for name: String in _items_info:
		var kind: String = str(_items_info[name]["kind"])
		if not _names.has(kind):
			_names[kind] = []
		(_names[kind] as Array).append(name)
		if kind == "tree":
			var tree: String = str(_items_info[name]["tree"]) + "|" + str(_items_info[name]["size"])
			if not _trees.has(tree):
				_trees[tree] = []
			(_trees[tree] as Array).append(name)
	_zones["start"] = [Vector2.ZERO, Data.cfg_float("world.clear_start_px")]
	_stone_mult = Data.cfg_float("world.stone_speed_mult")
	_noise.seed = RunRng.derive_seed(run_seed, "forest")
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = Data.cfg_float("world.forest_frequency")
	_back = Node2D.new()
	_back.z_as_relative = false
	_back.z_index = Data.cfg_int("world.flora_back_z")
	_back.draw.connect(_draw_layer.bind(false))
	add_child(_back)
	_front = Node2D.new()
	_front.z_as_relative = false
	_front.z_index = Data.cfg_int("world.flora_front_z")
	_front.draw.connect(_draw_layer.bind(true))
	add_child(_front)


func _exit_tree() -> void:
	if current == self:
		current = null


func has_art() -> bool:
	return not _art.is_empty()


# --- Clear zones ---------------------------------------------------------------------------------------------------

## Keeps a circle clear of trees and rocks (a shrine, a boss arena...). `at` is in local (on-screen world) px.
func clear_zone(key: String, at: Vector2, radius: float) -> void:
	_zones[key] = [_absolute(at), radius]
	_refresh_hidden()


func remove_zone(key: String) -> void:
	if _zones.erase(key):
		_refresh_hidden()


## The places kept clear right now: the start of the run, the boss arena while it's up, every shrine and every point
## of interest nearby. Only rebuilt when they change.
func _gather_zones() -> void:
	var zones: Dictionary = {}
	if _zones.has("start"):
		zones["start"] = _zones["start"]
	var bosses: BossManager = GameAuthority.bosses
	if bosses != null and GameAuthority.run != null and GameAuthority.run.boss_arena_active:
		zones["arena"] = [_absolute(bosses.arena_center), bosses.arena_radius + Data.cfg_float("world.clear_margin_px")]
	if shrines != null:
		for shrine: Dictionary in shrines.shrines:
			zones["shrine%s" % str(shrine["seed"])] = [_absolute(shrine["pos"]), Data.cfg_float("world.clear_shrine_px")]
	if pois != null:
		for poi: Dictionary in pois.nearby:
			var reach: float = float(PoiRules.find(str(poi["id"])).get("radius_px", 40.0))
			zones["poi" + str(poi["key"])] = [Vector2(poi["pos"]), reach + Data.cfg_float("world.clear_margin_px")]
	if zones.hash() != _zones.hash():
		_zones = zones
		_refresh_hidden()


func _refresh_hidden() -> void:
	_packed_dirty = true
	for list: Variant in _chunks.values():
		for item: Dictionary in list:
			item["hidden"] = _in_zone(item["at"])


func _in_zone(at: Vector2) -> bool:
	for zone: Array in _zones.values():
		if at.distance_to(zone[0]) <= float(zone[1]):
			return true
	return false


# --- Movement ------------------------------------------------------------------------------------------------------

## Where a mover of `radius` that wants to be at `at` (local px) ends up: pushed out of every tree and boulder it
## overlaps, so it slides round them.
func resolve(at: Vector2, radius: float) -> Vector2:
	if not enabled:
		return at
	var abs_at: Vector2 = _absolute(at)
	for item: Dictionary in _near(abs_at):
		var solid: float = float(item["solid"])
		if solid <= 0.0 or bool(item["hidden"]):
			continue
		var away: Vector2 = abs_at - Vector2(item["at"])
		var reach: float = solid + radius
		var dist: float = away.length()
		if dist < reach:
			abs_at = Vector2(item["at"]) + (away / dist if dist > 0.01 else Vector2.DOWN) * reach
	return abs_at - _offset()


## Moves a walker of `radius` at `at` (local px) by `step`: slower on stones and dunes, then pushed out of trees and
## boulders so it slides round them. The fast path every Hero and walking monster uses each frame.
func move(at: Vector2, step: Vector2, radius: float) -> Vector2:
	if not enabled:
		return at + step
	var off: Vector2 = _offset()
	var a: Vector2 = at + off
	var cell := Vector2i(floori(a.x / CELL), floori(a.y / CELL))
	var slow: PackedFloat32Array = _slow_cells.get(cell, PackedFloat32Array())
	for k: int in range(0, slow.size(), 3):
		if a.distance_squared_to(Vector2(slow[k], slow[k + 1])) <= slow[k + 2] * slow[k + 2]:
			step *= _stone_mult
			break
	a += step
	cell = Vector2i(floori(a.x / CELL), floori(a.y / CELL))
	var solid: PackedFloat32Array = _solid_cells.get(cell, PackedFloat32Array())
	for k: int in range(0, solid.size(), 3):
		var centre := Vector2(solid[k], solid[k + 1])
		var reach: float = solid[k + 2] + radius
		var away: Vector2 = a - centre
		var dist_sq: float = away.length_squared()
		if dist_sq < reach * reach:
			var dist: float = sqrt(dist_sq)
			a = centre + (away / dist if dist > 0.01 else Vector2.DOWN) * reach
	return a - off


func _repack() -> void:
	_packed_dirty = false
	_solid_cells.clear()
	_slow_cells.clear()
	for cell: Vector2i in _grid:
		var solid := PackedFloat32Array()
		var slow := PackedFloat32Array()
		for item: Dictionary in _grid[cell]:
			if bool(item["hidden"]):
				continue
			var at: Vector2 = item["at"]
			if float(item["solid"]) > 0.0:
				solid.append_array([at.x, at.y, float(item["solid"])])
			if float(item["slow"]) > 0.0:
				slow.append_array([at.x, at.y, float(item["slow"])])
		if not solid.is_empty():
			_solid_cells[cell] = solid
		if not slow.is_empty():
			_slow_cells[cell] = slow


## How fast a walker moves here: slower on stones.
func speed_at(at: Vector2) -> float:
	if not enabled:
		return 1.0
	var abs_at: Vector2 = _absolute(at)
	for item: Dictionary in _near(abs_at):
		if float(item["slow"]) > 0.0 and not bool(item["hidden"]) and abs_at.distance_to(item["at"]) <= float(item["slow"]):
			return Data.cfg_float("world.stone_speed_mult")
	return 1.0


## How many trees and boulders stand between `from` and `to` (local px): spawns pick a side open to the Heroes.
func blockers_between(from: Vector2, to: Vector2) -> int:
	if not enabled:
		return 0
	var a: Vector2 = _absolute(from)
	var b: Vector2 = _absolute(to)
	var count: int = 0
	var seen := {}
	var steps: int = maxi(int(a.distance_to(b) / (CELL * 0.5)), 1)
	for k: int in steps + 1:
		var p: Vector2 = a.lerp(b, float(k) / steps)
		for item: Dictionary in _near(p):
			if float(item["solid"]) > 0.0 and not bool(item["hidden"]) and not seen.has(item):
				if Geometry2D.get_closest_point_to_segment(item["at"], a, b).distance_to(item["at"]) <= float(item["solid"]) + 6.0:
					seen[item] = true
					count += 1
	return count


func _near(abs_at: Vector2) -> Array:
	var cell := Vector2i(floori(abs_at.x / CELL), floori(abs_at.y / CELL))
	return _grid.get(cell, [])


# --- Building the forest -------------------------------------------------------------------------------------------

func on_origin_shifted(_shift_px: Vector2, shift_chunks: Vector2i) -> void:
	origin_chunk += shift_chunks


func _offset() -> Vector2:
	return Vector2(origin_chunk) * _chunk_px


func _absolute(local: Vector2) -> Vector2:
	return local + _offset()


func _process(delta: float) -> void:
	if not has_art():
		return
	_scan_s -= delta
	if _scan_s <= 0.0:
		_scan_s = 0.25
		_load_around_players()
		_gather_zones()
	if _packed_dirty:
		_repack()
	_sort_visible()
	_back.queue_redraw()
	_front.queue_redraw()


func _load_around_players() -> void:
	var wanted := {}
	var radius: int = Data.cfg_int("world.flora_chunk_radius")
	for player: Player in GameAuthority.players:
		var here := Vector2i(floori(_absolute(player.position).x / _chunk_px), floori(_absolute(player.position).y / _chunk_px))
		for dy: int in range(-radius, radius + 1):
			for dx: int in range(-radius, radius + 1):
				wanted[here + Vector2i(dx, dy)] = true
	for coord: Vector2i in _chunks.keys():
		if not wanted.has(coord):
			_unload(coord)
	for coord: Vector2i in wanted:
		if not _chunks.has(coord):
			_load(coord)


## How thick the forest is at `abs_at`: 0 (open) to 1 (thick), from the smooth noise, scaled by the level.
func density_at(abs_at: Vector2) -> float:
	var flora: Dictionary = _level.get("flora", {})
	var raw: float = (_noise.get_noise_2dv(abs_at) + 1.0) * 0.5
	return clampf(smoothstep(0.35, 0.8, raw) * float(flora.get("density", 1.0)), 0.0, 1.0)


func _load(coord: Vector2i) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([_seed, "flora", coord.x, coord.y])
	var items: Array = []
	var per: int = Data.cfg_int("world.flora_cells_per_chunk")
	var step: float = _chunk_px / per
	var base := Vector2(coord) * _chunk_px
	for cy: int in per:
		for cx: int in per:
			var at: Vector2 = base + (Vector2(cx, cy) + Vector2(0.5, 0.5) + Vector2(rng.randf_range(-0.4, 0.4), rng.randf_range(-0.4, 0.4))) * step
			var name: String = _pick(rng, density_at(at))
			if name == "":
				continue
			items.append(_item(name, at))
			# Rocks often lie in clusters: a few more boulders and stones of mixed sizes round the first.
			if str(_items_info[name]["kind"]) == "boulder" and rng.randf() < Data.cfg_float("world.rock_cluster_chance"):
				for k: int in rng.randi_range(2, Data.cfg_int("world.rock_cluster_max")):
					var kind: String = "boulder" if rng.randf() < 0.55 else "stone"
					var names: Array = _names.get(kind, [])
					if names.is_empty():
						continue
					var spot: Vector2 = at + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(14.0, Data.cfg_float("world.rock_cluster_px"))
					items.append(_item(names[rng.randi_range(0, names.size() - 1)], spot))
	# Now and then thick forest hides a grove (docs/WORLD_PLAN.md: 3).
	var grove: Dictionary = HiddenGroves.carve(self, coord, items, rng)
	if not grove.is_empty():
		groves[grove["key"]] = grove
	_chunks[coord] = items
	_packed_dirty = true
	for item: Dictionary in items:
		var reach: float = maxf(float(item["solid"]), float(item["slow"]))
		if reach <= 0.0:
			continue
		# Indexed in every cell its circle (plus a Hero's or monster's body) can touch.
		var pad: float = reach + Data.cfg_float("world.flora_index_pad_px")
		var at: Vector2 = item["at"]
		for gy: int in range(floori((at.y - pad) / CELL), floori((at.y + pad) / CELL) + 1):
			for gx: int in range(floori((at.x - pad) / CELL), floori((at.x + pad) / CELL) + 1):
				var cell := Vector2i(gx, gy)
				if not _grid.has(cell):
					_grid[cell] = []
				(_grid[cell] as Array).append(item)


func _item(name: String, at: Vector2) -> Dictionary:
	var info: Dictionary = _items_info[name]
	return {"name": name, "at": at, "kind": str(info["kind"]), "solid": float(info.get("solid_r", 0.0)),
			"slow": float(info.get("slow_r", 0.0)), "hidden": _in_zone(at)}


func _unload(coord: Vector2i) -> void:
	var items: Array = _chunks[coord]
	_chunks.erase(coord)
	groves.erase("grove_%d_%d" % [coord.x, coord.y])
	_packed_dirty = true
	var gone := {}
	for item: Dictionary in items:
		gone[item] = true
	var lo := Vector2i(floori(coord.x * _chunk_px / CELL) - 2, floori(coord.y * _chunk_px / CELL) - 2)
	var hi := Vector2i(floori((coord.x + 1) * _chunk_px / CELL) + 2, floori((coord.y + 1) * _chunk_px / CELL) + 2)
	for gy: int in range(lo.y, hi.y + 1):
		for gx: int in range(lo.x, hi.x + 1):
			var cell := Vector2i(gx, gy)
			if _grid.has(cell):
				var kept: Array = (_grid[cell] as Array).filter(func(item: Dictionary) -> bool: return not gone.has(item))
				if kept.is_empty():
					_grid.erase(cell)
				else:
					_grid[cell] = kept


## What grows in one spot of the forest (a picture name, or "" for nothing). Thick forest is mostly trees; open
## ground has the odd bush, stone and boulder.
func _pick(rng: RandomNumberGenerator, density: float) -> String:
	var roll: float = rng.randf()
	var tree_chance: float = density * Data.cfg_float("world.tree_chance")
	if roll < tree_chance:
		return _tree(rng)
	roll -= tree_chance
	for kind: String in ["mound", "boulder", "bush", "stone", "pebbles"]:
		var chance: float = Data.cfg_float("world.%s_chance" % kind) * (1.0 + density * (1.0 if kind == "bush" else 0.0))
		if roll < chance and _names.has(kind):
			var names: Array = _names[kind]
			return names[rng.randi_range(0, names.size() - 1)]
		roll -= chance
	return ""


func _tree(rng: RandomNumberGenerator) -> String:
	var flora: Dictionary = _level.get("flora", {})
	var weights: Dictionary = flora.get("trees", {})
	var kinds: Array = []
	for key: String in _trees:
		var kind: String = key.get_slice("|", 0)
		if not kinds.has(kind):
			kinds.append(kind)
	if kinds.is_empty():
		return ""
	var total: float = 0.0
	for kind: String in kinds:
		total += float(weights.get(kind, 1.0))
	var roll: float = rng.randf() * total
	var chosen: String = kinds[0]
	for kind: String in kinds:
		roll -= float(weights.get(kind, 1.0))
		if roll <= 0.0:
			chosen = kind
			break
	var sizes: Dictionary = Data.cfg("world.tree_size_weights")
	var size_roll: float = rng.randf()
	var size: String = "medium"
	for key: String in ["small", "medium", "large"]:
		size_roll -= float(sizes.get(key, 0.33))
		if size_roll <= 0.0:
			size = key
			break
	var names: Array = _trees.get(chosen + "|" + size, [])
	return names[rng.randi_range(0, names.size() - 1)] if not names.is_empty() else ""


# --- Drawing -------------------------------------------------------------------------------------------------------

## Works out once a frame what each layer draws, looking only at the chunks on screen: the back layer has everything
## low and the trees and boulders standing behind the local Hero; the front layer the trees and boulders in front of
## them. Mounds (dunes, drifts) lie under everything; the rest in order of depth.
func _sort_visible() -> void:
	_back_list.clear()
	_front_list.clear()
	var view: Rect2 = get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()
	view = view.grow(64.0)
	var hero: Player = GameAuthority.local_player()
	var hero_y: float = hero.position.y if hero != null else INF
	var offset: Vector2 = _offset()
	var lo := Vector2i(floori((view.position.x + offset.x) / _chunk_px), floori((view.position.y + offset.y) / _chunk_px))
	var hi := Vector2i(floori((view.end.x + offset.x) / _chunk_px), floori((view.end.y + offset.y) / _chunk_px))
	for cy: int in range(lo.y, hi.y + 1):
		for cx: int in range(lo.x, hi.x + 1):
			for item: Dictionary in _chunks.get(Vector2i(cx, cy), []):
				if bool(item["hidden"]):
					continue
				var at: Vector2 = Vector2(item["at"]) - offset
				if not view.has_point(at):
					continue
				var kind: String = item["kind"]
				var entry: Array = [at, item, 0 if kind == "mound" else 1]
				if (kind == "tree" or kind == "boulder") and at.y > hero_y:
					_front_list.append(entry)
				else:
					_back_list.append(entry)
	var order := func(a: Array, b: Array) -> bool:
		if int(a[2]) != int(b[2]):
			return int(a[2]) < int(b[2])
		return Vector2(a[0]).y < Vector2(b[0]).y
	_back_list.sort_custom(order)
	_front_list.sort_custom(order)


## Draws one layer (worked out by _sort_visible); trees in front fade where they'd hide a Hero.
func _draw_layer(front: bool) -> void:
	var canvas: Node2D = _front if front else _back
	var fade: float = Data.cfg_float("world.canopy_fade_alpha")
	for entry: Array in (_front_list if front else _back_list):
		var at: Vector2 = entry[0]
		var texture: ImageTexture = (_art["frames"][str(entry[1]["name"])] as Array)[0]
		var top_left: Vector2 = at - Vector2(texture.get_width() * 0.5, texture.get_height() - 2.0)
		var tint := Color.WHITE
		if front:
			for player: Player in GameAuthority.players:
				if player.position.y < at.y and Rect2(top_left, texture.get_size()).has_point(player.position):
					tint.a = fade
					break
		canvas.draw_texture(texture, top_left, tint)
