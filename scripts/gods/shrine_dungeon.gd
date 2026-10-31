class_name ShrineDungeon
extends Node2D
## The way to a god (owner decisions 10/31/2026): a shrine in the world is the entrance to a dungeon built at random
## from its people's parts (data/art/shrines/<pantheon>.json). Walking into the entrance takes the party inside (in
## co-op, every standing player must be at the entrance together), and the run outside pauses: enemies, spawns,
## hazards, bosses and the clock all stop. Inside there are no monsters: corridors (sometimes a maze, sometimes wide
## halls with loops) lead to the god's throne room at the far end, built by ShrineLayout, where the god sits on their
## throne or walks about. Monsters of the level spawn in the corridors (owner decision 10/31/2026) until someone
## reaches the throne room; then the rest are banished and none come in with the god. Walls stop players and
## monsters alike. The enemies left outside sleep where they are. Standing at the altar binds a peaceful god; for a trial god it starts the trial outside.
## Either way the party is warped back out to where they went in; walking back out of the entrance also leaves.

signal entered
signal left_dungeon

const TILE := 16.0

## Systems that stop while the party is inside (RunSystems sets this).
var freeze: Array[Node] = []
var shrines: Shrines
var trial: GodTrial

var active: bool = false
var shrine: Dictionary = {}
## Tiles: Vector2i -> true for floor you can walk on.
var walkable: Dictionary = {}
var _plan: Dictionary = {}
var _origin := Vector2.ZERO
var _back: Dictionary = {}        # player_id -> where they stood outside
var _last: Dictionary = {}        # player_id -> last position inside on walkable floor
var _gather_s: float = 0.0
var _gather_at := Vector2.INF     # the entrance the party is gathering at
var _bind_s: Dictionary = {}
var _spawned: Array = []           # enemy slots spawned inside
var _enemy_last: Dictionary = {}   # slot -> last position on floor
var _spawn_in: float = 0.0
var _safe: bool = false            # someone reached the throne room: no more monsters
var _pool: Array = []


func _ready() -> void:
	z_index = -3                   # under the players (the world's ground is far away and frozen)
	process_priority = 5           # after the players move, so walls can stop them


# --- Building ------------------------------------------------------------------------------------------------------

## The dungeon for a shrine's seed: {"floor": [Vector2i], "walls": [Vector2i], "start": Vector2i, "exit": [Vector2i],
## "room": ShrineLayout layout, "room_origin": Vector2 (the altar, in tiles from the dungeon origin), "walk": {}}.
static func plan(seed_value: int, pantheon: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var w: int = rng.randi_range(3, 6)
	var h: int = rng.randi_range(3, 6)
	# A maze over cells (each cell is 2 × 2 tiles of floor with a 1-tile wall round it), by depth-first carving.
	var open := {}
	var seen := {Vector2i(0, h - 1): true}
	var stack: Array = [Vector2i(0, h - 1)]
	var start_cell := Vector2i(rng.randi_range(0, w - 1), h - 1)
	seen = {start_cell: true}
	stack = [start_cell]
	while not stack.is_empty():
		var cell: Vector2i = stack.back()
		var next: Array = []
		for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = cell + d
			if n.x >= 0 and n.y >= 0 and n.x < w and n.y < h and not seen.has(n):
				next.append(n)
		if next.is_empty():
			stack.pop_back()
			continue
		var pick: Vector2i = next[rng.randi_range(0, next.size() - 1)]
		open[_edge(cell, pick)] = true
		seen[pick] = true
		stack.append(pick)
	# Sometimes it stays a twisting maze; other times walls are knocked through into wide halls with loops.
	var loops: float = [0.0, 0.0, 0.25, 0.5][rng.randi_range(0, 3)]
	for y: int in h:
		for x: int in w:
			for d: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN]:
				var n := Vector2i(x, y) + d
				if n.x < w and n.y < h and rng.randf() < loops:
					open[_edge(Vector2i(x, y), n)] = true
	var floor := {}
	for y: int in h:
		for x: int in w:
			var t := Vector2i(x * 3 + 1, y * 3 + 1)
			for k: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
				floor[t + k] = true
			if open.has(_edge(Vector2i(x, y), Vector2i(x + 1, y))):
				floor[t + Vector2i(2, 0)] = true
				floor[t + Vector2i(2, 1)] = true
			if open.has(_edge(Vector2i(x, y), Vector2i(x, y + 1))):
				floor[t + Vector2i(0, 2)] = true
				floor[t + Vector2i(1, 2)] = true
	# The way in, below the starting cell, and the way on to the throne room above the farthest top-row cell.
	var entry := Vector2i(start_cell.x * 3 + 1, h * 3)
	var exit: Array = [entry, entry + Vector2i(1, 0), entry + Vector2i(0, 1), entry + Vector2i(1, 1)]
	for t: Vector2i in exit:
		floor[t] = true
	var far: Vector2i = _farthest_top(open, start_cell, w, h)
	var doorway := Vector2i(far.x * 3 + 1, 0)
	floor[doorway] = true
	floor[doorway + Vector2i(1, 0)] = true
	# The throne room: a ShrineLayout whose entrance gap sits on the doorway.
	var room: Dictionary = ShrineLayout.make(seed_value ^ 0x5eed, pantheon)
	var cells: Vector2 = room["size"]
	var altar_cell: Vector2i = room["altar_cell"]
	var gap_mid: float = int(room["gap_left"]) + (int(room["gap"]) - 1) * 0.5
	# Room cell (cx, cy) is at tile (room_left + cx, room_top + cy); its front row (cy = rows-1) is just above row 0.
	var room_top: int = -int(cells.y)
	var room_left: int = doorway.x - roundi(gap_mid)
	for cy: int in range(1, int(cells.y) - 1):
		for cx: int in range(1, int(cells.x) - 1):
			floor[Vector2i(room_left + cx, room_top + cy)] = true
	for k: int in int(room["gap"]):
		floor[Vector2i(room_left + int(room["gap_left"]) + k, -1)] = true
	floor[doorway + Vector2i(0, -1)] = true
	# Walls: every non-floor tile next to floor (in the maze; the throne room draws its own).
	var walls: Array = []
	for t: Vector2i in floor:
		for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN, Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]:
			var n: Vector2i = t + d
			if not floor.has(n) and n.y >= 0 and not walls.has(n):
				walls.append(n)
	return {"floor": floor.keys(), "walls": walls, "start": entry + Vector2i(0, -1), "exit": [entry + Vector2i(0, 1), entry + Vector2i(1, 1)],
			"room": room, "room_origin": Vector2(room_left + altar_cell.x + 0.5, room_top + altar_cell.y + 0.5), "walk": floor,
			"size": Vector2i(w * 3 + 1, h * 3 + 2)}


static func _edge(a: Vector2i, b: Vector2i) -> String:
	return str(a) + str(b) if a < b else str(b) + str(a)


## The top-row cell the longest way from the start (so the throne room is at the far end).
static func _farthest_top(open: Dictionary, start: Vector2i, w: int, h: int) -> Vector2i:
	var dist := {start: 0}
	var queue: Array = [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = cell + d
			if open.has(_edge(cell, n)) and not dist.has(n):
				dist[n] = int(dist[cell]) + 1
				queue.append(n)
	var best := Vector2i(0, 0)
	for x: int in w:
		if int(dist.get(Vector2i(x, 0), -1)) > int(dist.get(best, -1)):
			best = Vector2i(x, 0)
	return best


# --- Going in and out ----------------------------------------------------------------------------------------------

## Called each frame by Shrines while a shrine waits: the party gathers at its entrance. Returns true on going in.
func gather(at_shrine: Dictionary, delta: float) -> bool:
	if active:
		return false
	var standing: Array = []
	for player: Player in GameAuthority.players:
		if player.alive:
			standing.append(player)
	if standing.is_empty():
		return false
	for player: Player in standing:
		if player.position.distance_to(at_shrine["pos"]) > Data.cfg_float("gods.shrine_radius_px") + player.body_radius:
			# Only the entrance being gathered at resets; another one on screen leaves it alone.
			if Vector2(at_shrine["pos"]) == _gather_at:
				_gather_s = 0.0
			return false
	if Vector2(at_shrine["pos"]) != _gather_at:
		_gather_s = 0.0
		_gather_at = at_shrine["pos"]
	_gather_s += delta
	if _gather_s < Data.cfg_float("gods.dungeon_gather_s"):
		return false
	_gather_s = 0.0
	enter(at_shrine)
	return true


## How far the party is through gathering at the entrance at `at` (0 at any other entrance).
func gather_progress(at: Vector2 = Vector2.INF) -> float:
	if at != Vector2.INF and at != _gather_at:
		return 0.0
	return _gather_s / maxf(Data.cfg_float("gods.dungeon_gather_s"), 0.01)


func enter(at_shrine: Dictionary) -> void:
	shrine = at_shrine
	_plan = plan(int(shrine.get("seed", 0)), "")
	walkable = _plan["walk"]
	_origin = Vector2(shrine["pos"]) + Vector2(0, -Data.cfg_float("gods.dungeon_offset_px"))
	active = true
	_bind_s.clear()
	_safe = false
	_spawned.clear()
	_enemy_last.clear()
	_spawn_in = Data.cfg_float("gods.dungeon_first_spawn_s")
	_pool = _enemy_pool()
	_set_frozen(true)
	_sleep_outside(true)
	var start: Vector2 = _tile_center(_plan["start"])
	var k: int = 0
	for player: Player in GameAuthority.players:
		_back[player.player_id] = player.position
		if GameAuthority.decides():
			GameAuthority.place_player(player, start + Vector2(k * 10.0 - 5.0, 0.0))
		_last[player.player_id] = start
		k += 1
	_snap_camera()
	entered.emit()
	queue_redraw()


func leave() -> void:
	if not active:
		return
	active = false
	for player: Player in GameAuthority.players:
		if GameAuthority.decides() and _back.has(player.player_id):
			GameAuthority.place_player(player, _back[player.player_id])
	_back.clear()
	_last.clear()
	_banish()
	_sleep_outside(false)
	_set_frozen(false)
	_snap_camera()
	left_dungeon.emit()
	queue_redraw()


## The camera jumps with the party instead of sliding across the gap.
func _snap_camera() -> void:
	for camera: Node in get_tree().root.find_children("*", "GameCamera", true, false):
		(camera as GameCamera).call_deferred("snap_to_target")


func _set_frozen(on: bool) -> void:
	# Only the game that decides stops its systems; joining players' mirrored systems stay as CoopMirror set them.
	if not GameAuthority.decides():
		return
	if GameAuthority.run != null:
		GameAuthority.run.set_meta("frozen", on)
	for node: Node in freeze:
		if is_instance_valid(node):
			node.process_mode = Node.PROCESS_MODE_DISABLED if on else Node.PROCESS_MODE_INHERIT


## The enemies outside sleep while the party is inside (and wake when they come out).
func _sleep_outside(on: bool) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null or not GameAuthority.decides():
		return
	for i: int in enemies.capacity:
		if enemies.active[i] != 0:
			enemies.asleep[i] = 1 if on else 0


## The level's ordinary monsters that walk or cast (no elites, bosses, flyers or bombers) to fill the corridors.
func _enemy_pool() -> Array:
	var enemies: EnemyManager = GameAuthority.enemies
	var pool: Array = []
	if enemies == null or GameAuthority.run == null:
		return pool
	var waves: String = JSON.stringify(Data.get_file(str(GameAuthority.run.level_data.get("waves", ""))))
	for entry: Dictionary in enemies.types:
		if bool(entry.get("elite", false)) or bool(entry.get("boss", false)):
			continue
		if not ["chaser", "swarm", "brute", "caster"].has(str(entry.get("movement", ""))):
			continue
		if waves.contains("\"" + str(entry["id"]) + "\""):
			pool.append(str(entry["id"]))
	return pool


## Monsters arrive in the corridors a few tiles from the party, never in the throne room.
func _spawn_inside(delta: float) -> void:
	if _safe or _pool.is_empty():
		return
	_spawn_in -= delta
	if _spawn_in > 0.0:
		return
	_spawn_in = Data.cfg_float("gods.dungeon_spawn_every_s")
	_spawned = _spawned.filter(func(slot: int) -> bool: return GameAuthority.enemies.active[slot] != 0)
	var room: Dictionary = _room_tiles()
	var near: Array = []
	var lo: float = Data.cfg_float("gods.dungeon_spawn_min_tiles") * TILE
	var hi: float = Data.cfg_float("gods.dungeon_spawn_max_tiles") * TILE
	for t: Vector2i in walkable:
		if room.has(t):
			continue
		var at: Vector2 = _tile_center(t)
		var closest: float = INF
		for player: Player in GameAuthority.players:
			closest = minf(closest, at.distance_to(player.position))
		if closest >= lo and closest <= hi:
			near.append(at)
	var rng: RandomNumberGenerator = GameAuthority.run.rng.spawns
	for k: int in Data.cfg_int("gods.dungeon_spawn_count"):
		if near.is_empty() or _spawned.size() >= Data.cfg_int("gods.dungeon_max_enemies"):
			return
		var at: Vector2 = near[rng.randi_range(0, near.size() - 1)]
		var slot: int = GameAuthority.spawn_enemy(str(_pool[rng.randi_range(0, _pool.size() - 1)]), at)
		if slot != -1:
			_spawned.append(slot)
			_enemy_last[slot] = at


## The throne room's floor tiles (where no monster may go).
func _room_tiles() -> Dictionary:
	var out := {}
	var room: Dictionary = _plan["room"]
	var cells: Vector2 = room["size"]
	var origin: Vector2 = Vector2(_plan["room_origin"]) - Vector2(room["altar_cell"]) - Vector2(0.5, 0.5)
	for cy: int in range(1, int(cells.y) - 1):
		for cx: int in range(1, int(cells.x) - 1):
			out[Vector2i(roundi(origin.x) + cx, roundi(origin.y) + cy)] = true
	return out


## The god's presence banishes the monsters still in the dungeon (and they go when the party leaves).
func _banish() -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null or not GameAuthority.decides():
		_spawned.clear()
		return
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	for slot: int in _spawned:
		if enemies.active[slot] != 0:
			if effects != null:
				effects.spawn_ring(enemies.positions[slot], enemies.radius[slot] * 1.5, Color.WHITE, true)
			enemies.remove_quietly(slot)
	_spawned.clear()
	_enemy_last.clear()


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	_origin -= shift_px
	for slot: Variant in _enemy_last.keys():
		_enemy_last[slot] = Vector2(_enemy_last[slot]) - shift_px
	for id: Variant in _back.keys():
		_back[id] = Vector2(_back[id]) - shift_px
	for id: Variant in _last.keys():
		_last[id] = Vector2(_last[id]) - shift_px


# --- Inside --------------------------------------------------------------------------------------------------------

func _process(delta: float) -> void:
	if not active:
		return
	for player: Player in GameAuthority.players:
		_keep_inside(player)
	queue_redraw()
	if not GameAuthority.decides():
		return
	_keep_enemies_inside()
	if not _safe:
		var room: Dictionary = _room_tiles()
		for player: Player in GameAuthority.players:
			if player.alive and room.has(_tile_of(player.position)):
				_safe = true
				_banish()
				break
	_spawn_inside(delta)
	for player: Player in GameAuthority.players:
		if player.alive and _exit_tiles().has(_tile_of(player.position)):
			leave()
			return
	_goal(delta)


## What waits at the far end. Here: the god's altar, where standing binds a peaceful god or starts a trial outside.
func _goal(delta: float) -> void:
	var altar: Vector2 = altar_position()
	var reach: float = Data.cfg_float("gods.shrine_radius_px")
	var kind: String = str((shrine["god"].get("shrine", {}) as Dictionary).get("type", "peaceful"))
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		if player.position.distance_to(altar) > reach + player.body_radius:
			_bind_s.erase(player.player_id)
			continue
		if kind != "peaceful":
			# A trial god: the trial happens outside, at the shrine.
			leave()
			if trial != null and not trial.active:
				trial.begin(shrine, player)
			return
		_bind_s[player.player_id] = float(_bind_s.get(player.player_id, 0.0)) + delta
		if float(_bind_s[player.player_id]) >= Data.cfg_float("gods.peaceful_bind_s") and not (shrine["bound_by"] as Array).has(player.player_id):
			shrines.offer_binding(shrine, player)
			if not shrines.shrines.has(shrine) or _everyone_bound():
				leave()
				return


func _everyone_bound() -> bool:
	for player: Player in GameAuthority.players:
		if player.alive and not (shrine["bound_by"] as Array).has(player.player_id):
			return false
	return true


## Walls stop players: a step onto a tile that isn't floor is undone, sideways first so they slide along walls.
func _keep_inside(player: Player) -> void:
	var last: Vector2 = _last.get(player.player_id, player.position)
	if walkable.has(_tile_of(player.position)):
		_last[player.player_id] = player.position
		return
	var slide_x := Vector2(player.position.x, last.y)
	var slide_y := Vector2(last.x, player.position.y)
	if walkable.has(_tile_of(slide_x)):
		player.position = slide_x
	elif walkable.has(_tile_of(slide_y)):
		player.position = slide_y
	else:
		player.position = last
	_last[player.player_id] = player.position


## Monsters inside slide along the walls too, and never step into the throne room.
func _keep_enemies_inside() -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	var room: Dictionary = _room_tiles()
	for slot: int in _spawned:
		if enemies.active[slot] == 0:
			continue
		var at: Vector2 = enemies.positions[slot]
		var last: Vector2 = _enemy_last.get(slot, at)
		var ok := func(p: Vector2) -> bool:
			var t: Vector2i = _tile_of(p)
			return walkable.has(t) and not room.has(t)
		if not ok.call(at):
			if ok.call(Vector2(at.x, last.y)):
				at = Vector2(at.x, last.y)
			elif ok.call(Vector2(last.x, at.y)):
				at = Vector2(last.x, at.y)
			else:
				at = last
			enemies.positions[slot] = at
		_enemy_last[slot] = at


func altar_position() -> Vector2:
	return _origin + Vector2(_plan["room_origin"]) * TILE


func _exit_tiles() -> Array:
	return _plan.get("exit", [])


func _tile_of(at: Vector2) -> Vector2i:
	var local: Vector2 = (at - _origin) / TILE
	return Vector2i(floori(local.x), floori(local.y))


func _tile_center(tile: Vector2i) -> Vector2:
	return _origin + (Vector2(tile) + Vector2(0.5, 0.5)) * TILE


# --- Drawing -------------------------------------------------------------------------------------------------------

func _draw() -> void:
	if not active:
		return
	var parts: Dictionary = PixelArt.find(_parts_id())
	var art: Dictionary = PixelArt.god(str(shrine.get("god_id", "")))
	if parts.is_empty():
		return
	var frames: Dictionary = parts["frames"]
	var size: Vector2i = _plan["size"]
	var room: Dictionary = _plan["room"]
	var room_px: Vector2 = Vector2(room["size"]) * TILE
	# Darkness round everything, so nothing of the world shows.
	draw_rect(Rect2(_origin + Vector2(-room_px.x - 400.0, -room_px.y * 2.0 - 400.0), Vector2(size.x * TILE + room_px.x * 2.0 + 800.0,
			size.y * TILE + room_px.y * 2.0 + 800.0)), Color.html(Data.cfg_string("gods.dungeon_dark_color")))
	var floor_frames: Array = frames["floor"]
	# The corridors' floor a little darker than the walls, so the way through reads at a glance.
	var shade := Color.html(Data.cfg_string("gods.dungeon_floor_tint"))
	for t: Vector2i in walkable:
		draw_texture(floor_frames[(t.x * 7 + t.y * 3) % floor_frames.size()], _origin + Vector2(t) * TILE, shade)
	# Sets with debris scatter a little on the corridor floors (the same every time for this dungeon).
	if frames.has("debris"):
		var bits: Array = frames["debris"]
		var salt: int = int(shrine.get("seed", 0))
		for t: Vector2i in walkable:
			var roll: int = absi((t.x * 73856093) ^ (t.y * 19349663) ^ salt)
			if roll % 7 == 0:
				var bit: ImageTexture = bits[roll % bits.size()]
				draw_texture(bit, _origin + Vector2(t) * TILE + Vector2(roll % 7, (roll / 7) % 9), shade)
	# The throne room's floor, walls, altar, throne and god (ShrineLayout), drawn round its altar.
	var items: Array = []
	for tile: Array in room["floor"]:
		draw_texture(floor_frames[int(tile[1]) % floor_frames.size()], altar_position() + Vector2(tile[0]))
	for item: Dictionary in room["objects"]:
		items.append([altar_position().y + Vector2(item["at"]).y, item, altar_position() + Vector2(item["at"])])
	for wall: Vector2i in _plan["walls"]:
		items.append([_origin.y + (wall.y + 1) * TILE, {"part": "wall"}, _origin + Vector2(wall.x + 0.5, wall.y + 1) * TILE])
	var seconds: float = Time.get_ticks_msec() / 1000.0
	var walk: Dictionary = {} if bool(room["sits"]) else ShrineLayout.walker(room, seconds, Data.cfg_float("gods.temple_walk_speed_px"))
	if not art.is_empty():
		items.append([altar_position().y + Vector2(room["throne"]).y, {"part": "throne"}, altar_position() + Vector2(room["throne"])])
		if not walk.is_empty():
			items.append([altar_position().y + Vector2(walk["feet"]).y, {"part": "god"}, altar_position() + Vector2(walk["feet"])])
	items.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for entry: Array in items:
		var item: Dictionary = entry[1]
		var at: Vector2 = entry[2]
		match str(item["part"]):
			"throne":
				PixelArt.draw_standing(self, art, at, false, Color.WHITE, false, 0.0, "seated" if bool(room["sits"]) else "throne")
			"god":
				PixelArt.draw_standing(self, art, at, bool(walk["left"]), Color.WHITE, true, float(walk["stride"]))
			_:
				# Parts with several pictures (the ruins' rubble, bones, urns) pick one by where they stand.
				var pictures: Array = frames[str(item["part"])]
				var texture: ImageTexture = pictures[absi(int(at.x * 3.0 + at.y * 7.0)) % pictures.size()]
				draw_texture(texture, at - Vector2(texture.get_width() * 0.5, texture.get_height()))
	_draw_goal()


## The parts this dungeon is built from.
func _parts_id() -> String:
	return "shrines/" + str(shrine["god"].get("pantheon", ""))


## Drawn over the room: the altar's binding ring, filling as the party stands at it.
func _draw_goal() -> void:
	var color := Color.html(str(shrine["god"].get("placeholder_color", "#ffffff")))
	var most: float = 0.0
	for value: Variant in _bind_s.values():
		most = maxf(most, float(value))
	draw_arc(altar_position(), Data.cfg_float("gods.shrine_radius_px"), -PI * 0.5,
			-PI * 0.5 + TAU * clampf(most / Data.cfg_float("gods.peaceful_bind_s"), 0.0, 1.0), 32, color, 3.0)
