extends GutTest
## Phase 1: the same seed always produces the same sequence from each RNG.

const COUNT := 20


func test_same_seed_gives_same_sequence_for_every_stream() -> void:
	for stream: String in RunRng.STREAMS:
		var a: PackedInt64Array = RunRng.new(424242).next_ints(stream, COUNT)
		var b: PackedInt64Array = RunRng.new(424242).next_ints(stream, COUNT)
		assert_eq(a, b, "stream %s should repeat for the same seed" % stream)


func test_reseed_restarts_the_sequence() -> void:
	var rng := RunRng.new(7)
	var first: PackedInt64Array = rng.next_ints("loot", COUNT)
	rng.reseed(7)
	assert_eq(rng.next_ints("loot", COUNT), first)


func test_streams_are_independent() -> void:
	var rng := RunRng.new(99)
	var world_before: PackedInt64Array = RunRng.new(99).next_ints("world", COUNT)
	rng.next_ints("loot", 500)
	rng.next_ints("spawns", 500)
	assert_eq(rng.next_ints("world", COUNT), world_before, "using loot and spawns must not change world")
	assert_ne(RunRng.new(99).next_ints("world", COUNT), RunRng.new(99).next_ints("loot", COUNT))


func test_different_seeds_differ() -> void:
	assert_ne(RunRng.new(1).next_ints("world", COUNT), RunRng.new(2).next_ints("world", COUNT))
