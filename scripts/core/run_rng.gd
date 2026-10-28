class_name RunRng
extends RefCounted
## Seeded random number generators for one run (GAME_DESIGN.md: Deterministic
## randomness). World generation, spawns, loot, and combat rolls (crits,
## random targets) each get their own generator, so rolling loot never
## changes what the world looks like.
## The same run seed always gives the same sequence from every generator.

const STREAMS: PackedStringArray = ["world", "spawns", "loot", "combat"]

var run_seed: int = 0
var world := RandomNumberGenerator.new()
var spawns := RandomNumberGenerator.new()
var loot := RandomNumberGenerator.new()
var combat := RandomNumberGenerator.new()


func _init(seed_value: int = 0) -> void:
	reseed(seed_value)


## Restarts every generator from the given run seed.
func reseed(seed_value: int) -> void:
	run_seed = seed_value
	world.seed = derive_seed(seed_value, "world")
	spawns.seed = derive_seed(seed_value, "spawns")
	loot.seed = derive_seed(seed_value, "loot")
	combat.seed = derive_seed(seed_value, "combat")


## Each stream gets its own seed derived from the run seed and its name.
static func derive_seed(seed_value: int, stream: String) -> int:
	return ("%d:%s" % [seed_value, stream]).hash()


## Returns the generator for "world", "spawns", "loot", or "combat".
func get_stream(stream: String) -> RandomNumberGenerator:
	match stream:
		"world":
			return world
		"spawns":
			return spawns
		"loot":
			return loot
		"combat":
			return combat
	push_error("RunRng: unknown stream '%s'" % stream)
	return null


## Draws the next `count` integers from a stream (used by tests and the debug menu).
func next_ints(stream: String, count: int) -> PackedInt64Array:
	var out := PackedInt64Array()
	var rng: RandomNumberGenerator = get_stream(stream)
	if rng == null:
		return out
	for _i: int in count:
		out.append(rng.randi())
	return out
