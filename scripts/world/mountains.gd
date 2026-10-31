class_name Mountains
extends Node2D
## Mountains (docs/WORLD_PLAN.md: 5; owner request 10/31/2026). Now and then (about one per world.mountain_region_chunks
## square of world) raised ground rises from the land, ringed by cliffs you can't walk through, with two higher peaks
## on top. Ways up:
##   handholds   cut into a cliff: anyone can climb, slowly
##   rope ladder rolled at the top of a cliff: hanging it uses a rope; then it's a quick way up for everyone
##   rope bridge between the two peaks, broken: fixing it uses a rope
## The far peak has a cave with treasure (CaveDungeon). Ropes come from the Wandering Trader or chests.
## Every Hero has a height (0 ground, 1 the raised ground, 2 a peak) and can only walk on ground of their height;
## walking monsters too (they can't climb, so monsters come for Heroes on top by appearing up there); flyers and
## bosses go anywhere. Built from the run seed, so every co-op player has the same mountains; ladders and bridges
## are remembered in run.poi_state.

## The mountains of the current run (null outside one).
static var current: Mountains

const TILE := 16.0

var cave: CaveDungeon
var origin_chunk: Vector2i = Vector2i.ZERO

var _art: Dictionary = {}
var _seed: int = 0
var _chunk_px: float = 512.0
var _region_px: float = 0.0
## Region -> mountain ({} when the region has none). A mountain: {"key", "c" (centre tile), "r", "tiles" (tile ->
## height), "bridge" (tiles), "spots" ([{"kind", "tile" (the upper tile), "from", "to"}]), "cave" (tile)}.
var _mountains: Dictionary = {}
var _height: Dictionary = {}       # absolute tile -> height, for loaded mountains
var _bridge_of: Dictionary = {}    # absolute tile -> mountain key
var _elev: Dictionary = {}         # player id -> height they're at
var _last_pos: Dictionary = {}     # player id -> last position (to notice teleports)
var _enemy_elev: Dictionary = {}   # enemy slot -> height (monsters up on the mountain)
var _climb: Dictionary = {}        # player id -> {"t", "total", "from", "to", "to_elev"}
var _hint_s: float = 0.0
var _top_spawn_s: float = 0.0
var _scan_s: float = 0.0
## The roads to the mountains, drawn on the ground under trees and Heroes (owner request 10/31/2026).
var _road_layer: Node2D
var _road_style: Dictionary = {}


func setup(level: Dictionary, run_seed: int) -> void:
	current = self
	z_as_relative = false
	z_index = Data.cfg_int("world.mountain_z")
	process_priority = 6              # after the Heroes move, so cliffs can stop them
	_seed = run_seed
	_art = PixelArt.find("mountain/" + str(level.get("id", "")))
	_chunk_px = Data.cfg_float("world.chunk_tiles") * Data.cfg_float("world.tile_px")
	_region_px = Data.cfg_float("world.mountain_region_chunks") * _chunk_px
	_road_style = level.get("road", {})
	_road_layer = Node2D.new()
	_road_layer.z_as_relative = false
	_road_layer.z_index = Data.cfg_int("world.road_z")
	_road_layer.draw.connect(_draw_roads)
	add_child(_road_layer)


func _exit_tree() -> void:
	if current == self:
		current = null


func on_origin_shifted(shift_px: Vector2, shift_chunks: Vector2i) -> void:
	origin_chunk += shift_chunks
	for id: Variant in _last_pos.keys():
		_last_pos[id] = Vector2(_last_pos[id]) - shift_px
	for id: Variant in _climb.keys():
		_climb[id]["from"] = Vector2(_climb[id]["from"]) - shift_px
		_climb[id]["to"] = Vector2(_climb[id]["to"]) - shift_px


func _offset() -> Vector2:
	return Vector2(origin_chunk) * _chunk_px


func tile_of(local: Vector2) -> Vector2i:
	var a: Vector2 = local + _offset()
	return Vector2i(floori(a.x / TILE), floori(a.y / TILE))


func tile_center(tile: Vector2i) -> Vector2:
	return (Vector2(tile) + Vector2(0.5, 0.5)) * TILE - _offset()


## Height of the ground under `local` (0 off any mountain).
func height_at(local: Vector2) -> int:
	return int(_height.get(tile_of(local), 0))


func elevation_of(player: Player) -> int:
	return int(_elev.get(player.player_id, 0))


func is_climbing(player: Player) -> bool:
	return _climb.has(player.player_id)


## Places to keep clear of trees: every loaded mountain's footprint ([absolute centre, radius]), and its roads.
func clear_zones() -> Array:
	var out: Array = []
	var road_clear: float = Data.cfg_float("world.road_width_px") * 0.5 + Data.cfg_float("world.road_clear_px")
	for m: Dictionary in _mountains.values():
		if not m.is_empty():
			out.append([(Vector2(m["c"]) + Vector2(0.5, 0.5)) * TILE, (float(m["r"]) + 3.0) * TILE])
			for road: PackedVector2Array in m.get("roads", []):
				for i: int in range(0, road.size(), 2):
					out.append([road[i], road_clear])
	return out


# --- Building -----------------------------------------------------------------------------------------------------

func _load_around(at_local: Vector2) -> void:
	var a: Vector2 = at_local + _offset()
	var here := Vector2i(floori(a.x / _region_px), floori(a.y / _region_px))
	for dy: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var region: Vector2i = here + Vector2i(dx, dy)
			if not _mountains.has(region):
				_mountains[region] = plan(region)
				_index(_mountains[region])


## The mountain of a region, or {} (the same for every player with this run seed).
func plan(region: Vector2i) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([_seed, "mountain", region.x, region.y])
	if rng.randf() >= Data.cfg_float("world.mountain_chance"):
		return {}
	var centre_px: Vector2 = (Vector2(region) + Vector2(rng.randf_range(0.25, 0.75), rng.randf_range(0.25, 0.75))) * _region_px
	if centre_px.length() < Data.cfg_float("world.mountain_start_clear_px"):
		return {}
	var c := Vector2i(floori(centre_px.x / TILE), floori(centre_px.y / TILE))
	var r: float = rng.randf_range(Data.cfg_float("world.mountain_min_tiles"), Data.cfg_float("world.mountain_max_tiles"))
	var phase: Array = [rng.randf() * TAU, rng.randf() * TAU, rng.randf() * TAU]
	var tiles: Dictionary = {}
	var span: int = ceili(r) + 3
	for y: int in range(-span, span + 1):
		for x: int in range(-span, span + 1):
			var a: float = atan2(float(y), float(x))
			var edge: float = r + sin(a * 2.0 + phase[0]) * 1.4 + sin(a * 3.0 + phase[1]) * 0.9
			if Vector2(x, y * 1.15).length() < edge:
				tiles[c + Vector2i(x, y)] = 1
	# Two peaks, side by side, with a gap between them for the bridge.
	var peak_r: float = clampf(r * 0.32, 3.0, 5.0)
	var peak_y: int = c.y - roundi(r * 0.15)
	var peaks: Array = [Vector2i(c.x - roundi(r * 0.45), peak_y), Vector2i(c.x + roundi(r * 0.45), peak_y)]
	for peak: Vector2i in peaks:
		for y: int in range(-ceili(peak_r), ceili(peak_r) + 1):
			for x: int in range(-ceili(peak_r), ceili(peak_r) + 1):
				var t: Vector2i = peak + Vector2i(x, y)
				if Vector2(x, y * 1.2).length() <= peak_r and int(tiles.get(t, 0)) == 1 and absi(t.x - c.x) >= 2:
					tiles[t] = 2
	var bridge: Array = []
	var left := Vector2i(peaks[0].x, peak_y)
	while int(tiles.get(left + Vector2i.RIGHT, 0)) == 2:
		left += Vector2i.RIGHT
	var right := Vector2i(peaks[1].x, peak_y)
	while int(tiles.get(right + Vector2i.LEFT, 0)) == 2:
		right += Vector2i.LEFT
	for x: int in range(left.x + 1, right.x):
		bridge.append(Vector2i(x, peak_y))
	# Ways up: handholds and a rope ladder up the outer cliff, handholds up the near peak; the far peak only by bridge.
	var spots: Array = []
	var outer: Array = _south_edge(tiles, 1, 0)
	if outer.size() >= 2:
		var a_index: int = rng.randi_range(0, outer.size() - 1)
		var b_index: int = (a_index + outer.size() / 2) % outer.size()
		spots.append({"kind": "hand", "tile": outer[a_index], "from": 0, "to": 1})
		spots.append({"kind": "ladder", "tile": outer[b_index], "from": 0, "to": 1})
	var near: Array = _south_edge(tiles, 2, 1).filter(func(t: Vector2i) -> bool: return t.x < c.x)
	if not near.is_empty():
		spots.append({"kind": "hand", "tile": near[rng.randi_range(0, near.size() - 1)], "from": 1, "to": 2})
	var cave_tile: Vector2i = peaks[1]
	var roads: Array = []
	for spot: Dictionary in spots:
		if int(spot["from"]) == 0:
			roads.append(_road_from(Vector2i(spot["tile"]), c, r, rng))
	return {"key": "mtn_%d_%d" % [region.x, region.y], "c": c, "r": r, "tiles": tiles, "bridge": bridge, "spots": spots,
			"cave": cave_tile, "roads": roads}


## A road (owner request 10/31/2026): from the foot of a way up the cliff, it winds out across the land, away from the
## mountain, for one to two screens, so a Hero who finds it can follow it to the mountain. Points in absolute px.
func _road_from(spot: Vector2i, c: Vector2i, r: float, rng: RandomNumberGenerator) -> PackedVector2Array:
	var at: Vector2 = (Vector2(spot) + Vector2(0.5, 2.5)) * TILE
	var centre: Vector2 = (Vector2(c) + Vector2(0.5, 0.5)) * TILE
	var dir: Vector2 = (at - centre).normalized().rotated(rng.randf_range(-0.5, 0.5))
	var step: float = Data.cfg_float("world.road_step_px")
	var length: float = rng.randf_range(Data.cfg_float("world.road_min_px"), Data.cfg_float("world.road_max_px"))
	var turn: float = Data.cfg_float("world.road_turn")
	var points := PackedVector2Array([at])
	var bend: float = 0.0
	var walked: float = 0.0
	while walked < length:
		bend = clampf(bend + rng.randf_range(-turn, turn) * 0.5, -turn, turn)
		dir = dir.rotated(bend)
		# Never back into the mountain.
		var out: Vector2 = (at - centre).normalized()
		if dir.dot(out) < 0.2:
			dir = dir.lerp(out, 0.5).normalized()
		at += dir * step
		walked += step
		points.append(at)
	return points


## Tiles of `height` whose southern neighbour is `below`: where a cliff face shows, sorted west to east.
static func _south_edge(tiles: Dictionary, height: int, below: int) -> Array:
	var out: Array = []
	for t: Vector2i in tiles:
		if int(tiles[t]) == height and int(tiles.get(t + Vector2i.DOWN, 0)) == below and int(tiles.get(t + Vector2i.DOWN * 2, 0)) == below:
			out.append(t)
	out.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	return out


func _index(m: Dictionary) -> void:
	if m.is_empty():
		return
	for t: Vector2i in m["tiles"]:
		_height[t] = int(m["tiles"][t])
	for t: Vector2i in m["bridge"]:
		_bridge_of[t] = str(m["key"])


func _state(key: String) -> String:
	return str(GameAuthority.run.poi_state.get(key, "")) if GameAuthority.run != null else ""


func _set_state(key: String, value: String) -> void:
	if GameAuthority.run != null:
		GameAuthority.run.poi_state[key] = value


## Can someone at `elev` stand on `tile`? Their own height, or a fixed bridge if they're up on a peak.
func walkable(tile: Vector2i, elev: int) -> bool:
	if _bridge_of.has(tile) and elev == 2:
		return _state(str(_bridge_of[tile]) + "_bridge") == "fixed"
	return int(_height.get(tile, 0)) == elev


# --- Heroes -------------------------------------------------------------------------------------------------------

func _process(delta: float) -> void:
	if GameAuthority.run == null or (Flora.current != null and not Flora.current.enabled):
		return
	_hint_s -= delta
	_scan_s -= delta
	if _scan_s <= 0.0:
		_scan_s = 0.5
		for player: Player in GameAuthority.players:
			_load_around(player.position)
	for player: Player in GameAuthority.players:
		_keep_on_level(player, delta)
	if GameAuthority.decides():
		_monsters_on_top(delta)
		_cave_entrances(delta)
	queue_redraw()


func _keep_on_level(player: Player, delta: float) -> void:
	var id: int = player.player_id
	if _climb.has(id):
		_tick_climb(player, delta)
		return
	var elev: int = int(_elev.get(id, 0))
	var last: Vector2 = _last_pos.get(id, player.position)
	# Moved by the game (a dungeon, a revive, a push): take the height of wherever they are now.
	if last.distance_to(player.position) > Data.cfg_float("world.mountain_teleport_px"):
		elev = int(_height.get(tile_of(player.position), 0))
		_elev[id] = elev
		last = player.position
	if not walkable(tile_of(player.position), elev):
		var slide_x := Vector2(player.position.x, last.y)
		var slide_y := Vector2(last.x, player.position.y)
		if walkable(tile_of(slide_x), elev):
			player.position = slide_x
		elif walkable(tile_of(slide_y), elev):
			player.position = slide_y
		else:
			player.position = last
	_last_pos[id] = player.position
	if player.is_local and player.alive and player.input != null:
		_try_climb(player, elev, player.input.get_move_vector())


func _try_climb(player: Player, elev: int, wish: Vector2) -> void:
	var here: Vector2i = tile_of(player.position)
	for m: Dictionary in _mountains.values():
		if m.is_empty():
			continue
		for spot: Dictionary in m["spots"]:
			var top: Vector2i = spot["tile"]
			var up: bool = elev == int(spot["from"]) and here == top + Vector2i.DOWN and wish.y < -0.5
			var down: bool = elev == int(spot["to"]) and here == top and wish.y > 0.5
			if not up and not down:
				continue
			var ladder_key: String = str(m["key"]) + "_ladder"
			if str(spot["kind"]) == "ladder" and _state(ladder_key) != "hung":
				if not _use_rope("UI_ROPE_LADDER"):
					return
				_set_state(ladder_key, "hung")
			var seconds: float = Data.cfg_float("world.climb_ladder_s" if str(spot["kind"]) == "ladder" else "world.climb_hand_s")
			var to: Vector2 = tile_center(top if up else top + Vector2i.DOWN * 2)
			_climb[player.player_id] = {"t": 0.0, "total": seconds, "from": player.position, "to": to,
					"to_elev": int(spot["to"]) if up else int(spot["from"])}
			player.auto_walk = Vector2.ZERO
			player.auto_walk_s = seconds
			return
		# The broken bridge, from either end of it.
		var bridge: Array = m["bridge"]
		if elev == 2 and not bridge.is_empty() and _state(str(m["key"]) + "_bridge") != "fixed":
			var at_start: bool = here == Vector2i(bridge[0]) + Vector2i.LEFT and wish.x > 0.5
			var at_end: bool = here == Vector2i(bridge.back()) + Vector2i.RIGHT and wish.x < -0.5
			if (at_start or at_end) and _use_rope("UI_ROPE_BRIDGE"):
				_set_state(str(m["key"]) + "_bridge", "fixed")


## Spends one of the party's ropes, or says one is needed.
func _use_rope(done_key: String) -> bool:
	var run: RunState = GameAuthority.run
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if run.ropes <= 0:
		if _hint_s <= 0.0 and banner != null:
			_hint_s = 3.0
			banner.show_text(tr("UI_ROPE_NEEDED"))
		return false
	run.ropes -= 1
	if banner != null:
		banner.show_text(tr(done_key))
	return true


func _tick_climb(player: Player, delta: float) -> void:
	var climb: Dictionary = _climb[player.player_id]
	climb["t"] = float(climb["t"]) + delta
	var k: float = clampf(float(climb["t"]) / maxf(float(climb["total"]), 0.01), 0.0, 1.0)
	player.position = Vector2(climb["from"]).lerp(climb["to"], k)
	player.velocity = Vector2.ZERO
	if k >= 1.0:
		_elev[player.player_id] = int(climb["to_elev"])
		_climb.erase(player.player_id)
		player.auto_walk_s = 0.0
	_last_pos[player.player_id] = player.position


# --- Monsters -----------------------------------------------------------------------------------------------------

## Walking monsters keep to their own height (those on the mountain stay up; the rest go round it).
func keep_enemy(slot: int, from: Vector2, to: Vector2) -> Vector2:
	var tile: Vector2i = tile_of(to)
	if _height.is_empty():
		return to
	if not _enemy_elev.has(slot):
		var start: int = int(_height.get(tile_of(from), 0))
		if start == 0 and int(_height.get(tile, 0)) == 0:
			return to
		_enemy_elev[slot] = start
	var elev: int = int(_enemy_elev[slot])
	if walkable(tile, elev):
		return to
	if walkable(tile_of(Vector2(to.x, from.y)), elev):
		return Vector2(to.x, from.y)
	if walkable(tile_of(Vector2(from.x, to.y)), elev):
		return Vector2(from.x, to.y)
	return from


func forget_enemy(slot: int) -> void:
	_enemy_elev.erase(slot)


## Monsters can't climb, so while Heroes are up on a mountain, some appear up there with them.
func _monsters_on_top(delta: float) -> void:
	_top_spawn_s -= delta
	if _top_spawn_s > 0.0:
		return
	_top_spawn_s = Data.cfg_float("world.mountain_top_spawn_s")
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null:
		return
	for slot: Variant in _enemy_elev.keys():
		if enemies.active[int(slot)] == 0:
			_enemy_elev.erase(slot)
	for player: Player in GameAuthority.players:
		var elev: int = int(_elev.get(player.player_id, 0))
		if elev == 0 or not player.alive:
			continue
		var up_here: int = _enemy_elev.values().filter(func(e: int) -> bool: return e == elev).size()
		if up_here >= Data.cfg_int("world.mountain_top_enemies"):
			continue
		var pool: Array = []
		for entry: Dictionary in enemies.types:
			if ["chaser", "brute"].has(str(entry.get("movement", ""))) and not bool(entry.get("elite", false)) \
					and not bool(entry.get("boss", false)) and not bool(entry.get("animal", false)) \
					and not bool(entry.get("flies", false)) and not bool(entry.get("placeholder", false)):
				pool.append(str(entry["id"]))
		var level_ids: String = JSON.stringify(Data.get_file(str(GameAuthority.run.level_data.get("waves", ""))))
		pool = pool.filter(func(id: String) -> bool: return level_ids.contains("\"" + id + "\""))
		if pool.is_empty():
			continue
		var rng: RandomNumberGenerator = GameAuthority.run.rng.spawns
		for k: int in 2:
			for attempt: int in 12:
				var spot: Vector2 = player.position + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(70.0, 150.0)
				if walkable(tile_of(spot), elev):
					var slot: int = GameAuthority.spawn_enemy(str(pool[rng.randi_range(0, pool.size() - 1)]), spot)
					if slot != -1:
						_enemy_elev[slot] = elev
					break


# --- The cave -----------------------------------------------------------------------------------------------------

## The cave's mouth on the far peak: where the party gathers to go in (local px).
func cave_door(m: Dictionary) -> Vector2:
	return tile_center(Vector2i(m["cave"])) + Vector2(0.0, TILE * 0.5)


## Every loaded cave's mouth (local px), for the solid rock round it.
func cave_doors() -> Array:
	var out: Array = []
	for m: Dictionary in _mountains.values():
		if not m.is_empty():
			out.append(cave_door(m))
	return out


func _cave_entrances(delta: float) -> void:
	if cave == null:
		return
	for m: Dictionary in _mountains.values():
		if m.is_empty() or _state(str(m["key"]) + "_cave") == "looted":
			continue
		var door: Vector2 = cave_door(m)
		for player: Player in GameAuthority.players:
			if player.alive and int(_elev.get(player.player_id, 0)) == 2 and player.position.distance_to(door) <= 40.0:
				cave.tick_entrance({"key": str(m["key"]) + "_cave"}, door, delta)
				break


# --- Drawing ------------------------------------------------------------------------------------------------------

func _process_roads() -> void:
	if _road_layer != null:
		_road_layer.queue_redraw()


## The roads: a worn track with darker edges, lighter wheel ruts down the middle and stones along it, fading out at
## its far end. Each land its own colours (levels.json "road").
func _draw_roads() -> void:
	var view: Rect2 = (get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()).grow(64.0)
	var off: Vector2 = _offset()
	var width: float = Data.cfg_float("world.road_width_px")
	var base := Color.html(str(_road_style.get("color", "#a08a64")))
	var edge := Color.html(str(_road_style.get("edge", "#7a6a4c")))
	var stone := Color.html(str(_road_style.get("stones", "#8a8478")))
	for m: Dictionary in _mountains.values():
		if m.is_empty():
			continue
		for road: PackedVector2Array in m.get("roads", []):
			var local := PackedVector2Array()
			for p: Vector2 in road:
				local.append(p - off)
			var box := Rect2(local[0], Vector2.ZERO)
			for p: Vector2 in local:
				box = box.expand(p)
			if not view.intersects(box.grow(width)):
				continue
			var n: int = local.size()
			for i: int in n - 1:
				var fade: float = clampf(float(n - 1 - i) / 6.0, 0.0, 1.0)    # the far end fades into the ground
				_road_layer.draw_line(local[i], local[i + 1], Color(edge, 0.8 * fade), width + 4.0, true)
				_road_layer.draw_circle(local[i], (width + 4.0) * 0.5, Color(edge, 0.8 * fade))
			for i: int in n - 1:
				var fade: float = clampf(float(n - 1 - i) / 6.0, 0.0, 1.0)
				_road_layer.draw_line(local[i], local[i + 1], Color(base, fade), width, true)
				_road_layer.draw_circle(local[i], width * 0.5, Color(base, fade))
			for i: int in n - 1:
				var fade: float = clampf(float(n - 1 - i) / 6.0, 0.0, 1.0)
				var side: Vector2 = (local[i + 1] - local[i]).normalized().orthogonal()
				for rut: float in [-0.22, 0.22]:
					_road_layer.draw_line(local[i] + side * width * rut, local[i + 1] + side * width * rut,
							Color(base.lightened(0.12), 0.7 * fade), 2.0)
				var h: int = absi(int(road[i].x * 7.0 + road[i].y * 13.0))
				if h % 3 == 0:
					_road_layer.draw_circle(local[i] + side * width * (0.5 if h % 2 == 0 else -0.5), 1.6, Color(stone, fade))


func _draw() -> void:
	_process_roads()
	if _art.is_empty():
		return
	var frames: Dictionary = _art["frames"]
	var view: Rect2 = (get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()).grow(48.0)
	var off: Vector2 = _offset()
	var tops: Array = frames["top"]
	var faces: Array = frames["face"]
	for m: Dictionary in _mountains.values():
		if m.is_empty():
			continue
		var c_local: Vector2 = Vector2(m["c"]) * TILE - off
		if not view.grow(float(m["r"]) * TILE + 64.0).has_point(c_local):
			continue
		var tiles: Dictionary = m["tiles"]
		for level: int in [1, 2]:
			# Tops, then the cliff faces below their southern edges, so the higher ground sits over the lower.
			for t: Vector2i in tiles:
				if int(tiles[t]) < level:
					continue
				var at: Vector2 = Vector2(t) * TILE - off
				if not view.has_point(at):
					continue
				var shade := Color(1, 1, 1) if level == 1 else Color(1.06, 1.06, 1.06)
				draw_texture(tops[absi(t.x * 7 + t.y * 3) % tops.size()], at, shade)
			for t: Vector2i in tiles:
				if int(tiles[t]) != level or int(tiles.get(t + Vector2i.DOWN, 0)) >= level:
					continue
				var at: Vector2 = Vector2(t.x, t.y + 1) * TILE - off
				if view.has_point(at):
					draw_texture(faces[absi(t.x * 5 + t.y) % faces.size()], at)
			# The sides of the raised ground: a dark edge where it drops away east or west.
			for t: Vector2i in tiles:
				if int(tiles[t]) != level:
					continue
				var at: Vector2 = Vector2(t) * TILE - off
				if int(tiles.get(t + Vector2i.LEFT, 0)) < level:
					draw_rect(Rect2(at, Vector2(2, TILE)), Color(0, 0, 0, 0.35))
				if int(tiles.get(t + Vector2i.RIGHT, 0)) < level:
					draw_rect(Rect2(at + Vector2(TILE - 2, 0), Vector2(2, TILE)), Color(0, 0, 0, 0.35))
				if int(tiles.get(t + Vector2i.UP, 0)) < level:
					draw_rect(Rect2(at, Vector2(TILE, 1)), Color(1, 1, 1, 0.25))
		_draw_ways(m, frames, off)


func _draw_ways(m: Dictionary, frames: Dictionary, off: Vector2) -> void:
	for spot: Dictionary in m["spots"]:
		var at: Vector2 = Vector2(Vector2i(spot["tile"]) + Vector2i.DOWN) * TILE - off
		if str(spot["kind"]) == "ladder":
			if _state(str(m["key"]) + "_ladder") == "hung":
				draw_texture((frames["ladder"] as Array)[0], at + Vector2(0, -4))
			else:
				draw_texture((frames["ladder_rolled"] as Array)[0], at + Vector2(0, -8))
		else:
			draw_texture((frames["handholds"] as Array)[0], at)
	var bridge: Array = m["bridge"]
	var fixed: bool = _state(str(m["key"]) + "_bridge") == "fixed"
	for k: int in bridge.size():
		var at: Vector2 = Vector2(Vector2i(bridge[k])) * TILE - off
		var broken: bool = not fixed and k == bridge.size() / 2
		draw_texture((frames["plank_broken" if broken else "plank"] as Array)[0], at)
	if not bridge.is_empty():
		for end: Vector2i in [Vector2i(bridge[0]) + Vector2i.LEFT, Vector2i(bridge.back()) + Vector2i.RIGHT]:
			draw_texture((frames["post"] as Array)[0], Vector2(end) * TILE - off + Vector2(4, -10))
	var mouth: ImageTexture = (frames["cave"] as Array)[0]
	var door: Vector2 = cave_door(m)
	draw_texture(mouth, door - Vector2(mouth.get_width() * 0.5, mouth.get_height()),
			Color(1, 1, 1, 0.55) if _state(str(m["key"]) + "_cave") == "looted" else Color.WHITE)
