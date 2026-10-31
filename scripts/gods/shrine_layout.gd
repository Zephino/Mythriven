class_name ShrineLayout
extends RefCounted
## A god's shrine built at random from its people's parts (owner request 10/31/2026; docs/ART_RULES.md: Shrines;
## parts in data/art/shrines/<pantheon>.json): a floor of tiles, walls on three sides and a front wall with an
## entrance flanked by columns, columns beside the throne at the back, fire bowls beside the altar in the middle, and
## a few decorations. The god either sits on the throne or walks about inside, never leaving it. Everything is
## placed relative to the altar (the shrine's position), from a seed, so every co-op player sees the same shrine.

const TILE := 16.0

## {"floor": [[Vector2 top-left, variant]], "objects": [{"part", "at" (bottom-centre), "variant"}], "throne": Vector2
## (feet), "sits": bool, "path": PackedVector2Array (the walking god's loop), "size": Vector2 (cells)}
static func make(seed_value: int, pantheon: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var cols: int = [7, 9, 11][rng.randi_range(0, 2)]
	var rows: int = rng.randi_range(5, 7)
	var altar_cell := Vector2i(cols / 2, maxi(3, rows / 2 + 1))
	# Cell (x, y) has its bottom-centre at this offset from the altar.
	var cell_foot := func(x: int, y: int) -> Vector2:
		return Vector2((x - altar_cell.x) * TILE, (y - altar_cell.y) * TILE + TILE * 0.5)
	var floor_tiles: Array = []
	for y: int in rows:
		for x: int in cols:
			var foot: Vector2 = cell_foot.call(x, y)
			floor_tiles.append([foot - Vector2(TILE * 0.5, TILE), rng.randi_range(0, 1)])
	var objects: Array = []
	var taken := {}
	var put := func(part: String, x: int, y: int) -> void:
		objects.append({"part": part, "at": cell_foot.call(x, y)})
		taken[Vector2i(x, y)] = true
	# Walls round three sides, and the front with an entrance of 1 or 3 cells (centred, or a little to one side).
	var gap: int = 1 if cols == 7 else [1, 3][rng.randi_range(0, 1)]
	var gap_left: int = clampi(cols / 2 - gap / 2 + rng.randi_range(-1, 1), 2, cols - 2 - gap)
	for x: int in cols:
		put.call("wall", x, 0)
		if x < gap_left or x >= gap_left + gap:
			put.call("wall", x, rows - 1)
	for y: int in range(1, rows - 1):
		put.call("wall", 0, y)
		put.call("wall", cols - 1, y)
	put.call("column", gap_left - 1, rows - 1)
	put.call("column", gap_left + gap, rows - 1)
	# The throne at the back, columns beside it; the altar in the middle with a fire bowl each side.
	var throne_cell := Vector2i(cols / 2, 1)
	taken[throne_cell] = true
	if cols >= 9:
		put.call("column", throne_cell.x - 2, 1)
		put.call("column", throne_cell.x + 2, 1)
	put.call("altar", altar_cell.x, altar_cell.y)
	put.call("brazier", altar_cell.x - 2, altar_cell.y)
	put.call("brazier", altar_cell.x + 2, altar_cell.y)
	# A few decorations against the walls, never in the way in from the entrance.
	var spots: Array = []
	for y: int in range(1, rows - 1):
		for x: int in [1, cols - 2]:
			if not taken.has(Vector2i(x, y)):
				spots.append(Vector2i(x, y))
	for k: int in mini(rng.randi_range(1, 3), spots.size()):
		var spot: Vector2i = spots.pop_at(rng.randi_range(0, spots.size() - 1))
		put.call("decor", spot.x, spot.y)
	# The walking god's loop: a few points inside the walls, away from the throne row.
	var path := PackedVector2Array()
	for k: int in 5:
		var x: float = rng.randf_range(1.0, cols - 2.0)
		var y: float = rng.randf_range(2.0, rows - 2.0)
		path.append(Vector2((x - altar_cell.x) * TILE, (y - altar_cell.y) * TILE + TILE * 0.4))
	return {"floor": floor_tiles, "objects": objects, "throne": cell_foot.call(throne_cell.x, throne_cell.y),
			"sits": rng.randf() < 0.5, "path": path, "size": Vector2(cols, rows)}


## Where the walking god is `seconds` into their loop (walking `speed` px/s): {"feet", "left", "stride"}.
static func walker(layout: Dictionary, seconds: float, speed: float) -> Dictionary:
	var path: PackedVector2Array = layout["path"]
	var lengths: Array = []
	var total: float = 0.0
	for k: int in path.size():
		var length: float = path[k].distance_to(path[(k + 1) % path.size()])
		lengths.append(length)
		total += length
	var along: float = fmod(seconds * speed, maxf(total, 1.0))
	for k: int in path.size():
		if along <= lengths[k]:
			var a: Vector2 = path[k]
			var b: Vector2 = path[(k + 1) % path.size()]
			return {"feet": a.lerp(b, along / maxf(lengths[k], 0.01)), "left": b.x < a.x, "stride": seconds * speed}
		along -= lengths[k]
	return {"feet": path[0], "left": false, "stride": 0.0}
