class_name ChunkManager
extends Node2D
## Endless ground (GAME_DESIGN.md: Endless world / Chunks). Keeps a 5×5 grid
## of 32×32-tile chunks loaded around each player and reuses chunks that fall
## out of range. Ground is painted from FastNoiseLite; decorations come from a
## generator seeded by the run seed and the chunk position, so returning to a
## spot always shows the same ground and decorations.

var tile_px: int = 16
var chunk_tiles: int = 32
var chunk_px: int = 512
## How far the world origin has moved, in chunks (see WorldRoot).
var origin_chunk: Vector2i = Vector2i.ZERO

var _level: Dictionary = {}
var _run_seed: int = 0
var _tileset: TileSet
var _noise := FastNoiseLite.new()
var _grounds: Array = []
var _loaded: Dictionary = {}
var _pool: Array[Chunk] = []
var _queue: Array[Chunk] = []


func setup(level: Dictionary, run_seed: int) -> void:
	z_index = -10
	_level = level
	_run_seed = run_seed
	tile_px = Data.cfg_int("world.tile_px")
	chunk_tiles = Data.cfg_int("world.chunk_tiles")
	chunk_px = tile_px * chunk_tiles
	var tileset_data: Dictionary = level.get("tileset", {})
	_grounds = tileset_data.get("ground", [])
	_tileset = LevelArt.build_tileset(tileset_data, tile_px)
	_noise.seed = RunRng.derive_seed(run_seed, "ground")
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = float(tileset_data.get("noise_frequency", 0.03))
	var per_side: int = Data.cfg_int("world.loaded_chunks_per_side")
	for _i: int in per_side * per_side:
		_pool.append(_new_chunk())


func _process(_delta: float) -> void:
	update_chunks()
	_build_some(Data.cfg_int("world.build_tiles_per_frame"))


## Loads chunks around every player and returns the rest to the pool.
func update_chunks() -> void:
	var radius: int = floori(Data.cfg_int("world.loaded_chunks_per_side") / 2.0)
	var wanted: Dictionary = {}
	for player: Player in GameAuthority.players:
		var center: Vector2i = world_to_chunk(player.position)
		for dy: int in range(-radius, radius + 1):
			for dx: int in range(-radius, radius + 1):
				wanted[center + Vector2i(dx, dy)] = true
	for loaded_coord: Vector2i in _loaded.keys():
		if not wanted.has(loaded_coord):
			_release(loaded_coord)
	for wanted_coord: Vector2i in wanted:
		if not _loaded.has(wanted_coord):
			_acquire(wanted_coord)


## Paints every waiting chunk at once (used at the start of a run).
func build_all_now() -> void:
	while not _queue.is_empty():
		_build_some(chunk_tiles * chunk_tiles)


func world_to_chunk(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x / chunk_px), floori(world_pos.y / chunk_px)) + origin_chunk


func loaded_count() -> int:
	return _loaded.size()


func pooled_count() -> int:
	return _pool.size()


## Atlas cell for an absolute tile: noise picks the ground type, a hash picks the shade.
func ground_cell(tile: Vector2i) -> Vector2i:
	var value: float = _noise.get_noise_2d(tile.x, tile.y)
	var index: int = _grounds.size() - 1
	for i: int in _grounds.size():
		if value <= float((_grounds[i] as Dictionary).get("max", 1.0)):
			index = i
			break
	var variant: int = absi(hash(tile)) % LevelArt.VARIANTS
	return Vector2i(index * LevelArt.VARIANTS + variant, 0)


## Called by WorldRoot when everything is moved back toward (0, 0).
func on_origin_shifted(_shift_px: Vector2, shift_chunks: Vector2i) -> void:
	origin_chunk += shift_chunks
	for loaded_coord: Vector2i in _loaded:
		(_loaded[loaded_coord] as Chunk).position = Vector2(loaded_coord - origin_chunk) * chunk_px


## Decorations for a chunk, the same every time for the same run seed and chunk.
func decoration_layout(chunk_coord: Vector2i) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([_run_seed, chunk_coord.x, chunk_coord.y])
	var result: Array[Dictionary] = []
	var art_table: Dictionary = _level.get("decoration_art", {})
	var ids: Array = _level.get("decorations", [])
	var count_range: Array = _level.get("decorations_per_chunk", [0, 0])
	if ids.is_empty():
		return result
	var count: int = rng.randi_range(int(count_range[0]), int(count_range[1]))
	for _i: int in count:
		var id: String = _pick_weighted(rng, ids, art_table)
		var art: Dictionary = art_table.get(id, {})
		var pos := Vector2(rng.randf() * chunk_px, rng.randf() * chunk_px)
		result.append({"position": pos, "art": art, "id": id})
	return result


func _pick_weighted(rng: RandomNumberGenerator, ids: Array, art_table: Dictionary) -> String:
	var total: float = 0.0
	for id: Variant in ids:
		total += float((art_table.get(id, {}) as Dictionary).get("weight", 1.0))
	var roll: float = rng.randf() * total
	for id: Variant in ids:
		roll -= float((art_table.get(id, {}) as Dictionary).get("weight", 1.0))
		if roll <= 0.0:
			return str(id)
	return str(ids[ids.size() - 1])


func _new_chunk() -> Chunk:
	var chunk := Chunk.new()
	chunk.setup(_tileset, chunk_tiles)
	chunk.visible = false
	add_child(chunk)
	return chunk


func _acquire(chunk_coord: Vector2i) -> void:
	var chunk: Chunk = _pool.pop_back() if not _pool.is_empty() else _new_chunk()
	chunk.position = Vector2(chunk_coord - origin_chunk) * chunk_px
	chunk.begin(chunk_coord, decoration_layout(chunk_coord))
	_loaded[chunk_coord] = chunk
	_queue.append(chunk)


func _release(chunk_coord: Vector2i) -> void:
	var chunk: Chunk = _loaded[chunk_coord]
	_loaded.erase(chunk_coord)
	_queue.erase(chunk)
	chunk.release()
	_pool.append(chunk)


## Paints at most `tile_budget` tiles this frame, so walking never stutters.
func _build_some(tile_budget: int) -> void:
	var rows_left: int = maxi(floori(float(tile_budget) / chunk_tiles), 1)
	while rows_left > 0 and not _queue.is_empty():
		var chunk: Chunk = _queue[0]
		rows_left -= chunk.build_rows(self, rows_left)
		if chunk.is_built():
			_queue.pop_front()
