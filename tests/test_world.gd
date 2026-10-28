extends GutTest
## Phase 3: the same seed gives the same ground and decorations; chunk maths
## stays correct after the world origin shifts.

const LEVEL_ID := "aegean_shore"


func _make_chunks(run_seed: int) -> ChunkManager:
	var chunks: ChunkManager = autofree(ChunkManager.new())
	chunks.setup(GameAuthority.find_level(LEVEL_ID), run_seed)
	return chunks


func test_level_data_exists() -> void:
	var level: Dictionary = GameAuthority.find_level(LEVEL_ID)
	assert_eq(level.get("id", ""), LEVEL_ID)
	assert_eq(level.get("care_tier", ""), "A")


func test_same_seed_gives_same_ground() -> void:
	var a: ChunkManager = _make_chunks(777)
	var b: ChunkManager = _make_chunks(777)
	for i: int in 200:
		var tile := Vector2i(i * 37 - 3000, i * 53 - 2000)
		assert_eq(a.ground_cell(tile), b.ground_cell(tile))


func test_same_seed_gives_same_decorations() -> void:
	var a: ChunkManager = _make_chunks(4242)
	var b: ChunkManager = _make_chunks(4242)
	for coord: Vector2i in [Vector2i(0, 0), Vector2i(5, -3), Vector2i(-40, 12)]:
		assert_eq(a.decoration_layout(coord), b.decoration_layout(coord))


func test_mirrored_chunks_are_not_identical() -> void:
	var chunks: ChunkManager = _make_chunks(99)
	# run_seed + x + y would give these the same layout; ours must not.
	assert_ne(chunks.decoration_layout(Vector2i(1, 0)), chunks.decoration_layout(Vector2i(0, 1)))


func test_different_seeds_give_different_ground() -> void:
	var a: ChunkManager = _make_chunks(1)
	var b: ChunkManager = _make_chunks(2)
	var differences: int = 0
	for i: int in 200:
		var tile := Vector2i(i * 41, i * 17)
		if a.ground_cell(tile) != b.ground_cell(tile):
			differences += 1
	assert_gt(differences, 0)


func test_world_to_chunk_respects_origin_shift() -> void:
	var chunks: ChunkManager = _make_chunks(5)
	assert_eq(chunks.world_to_chunk(Vector2(-1, -1)), Vector2i(-1, -1))
	assert_eq(chunks.world_to_chunk(Vector2(chunks.chunk_px * 2 + 1, 0)), Vector2i(2, 0))
	chunks.on_origin_shifted(Vector2(chunks.chunk_px * 100, 0), Vector2i(100, 0))
	assert_eq(chunks.world_to_chunk(Vector2(1, 1)), Vector2i(100, 0))
