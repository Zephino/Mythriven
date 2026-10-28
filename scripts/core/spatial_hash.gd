class_name SpatialHash
extends RefCounted
## Grid of ~64 px cells for finding nearby objects quickly (GAME_DESIGN.md:
## Tech stack). Used for enemy separation, contact damage, and smart
## targeting. Stores indices into the owner's position arrays.

var cell_px: float = 64.0
var _cells: Dictionary = {}
var _max_cells: int = 4096


func _init(cell_size_px: float) -> void:
	cell_px = maxf(cell_size_px, 1.0)


func cell_of(point: Vector2) -> Vector2i:
	return Vector2i(floori(point.x / cell_px), floori(point.y / cell_px))


## Rebuilds the grid from scratch. `active` says which indices are in use.
func rebuild(positions: PackedVector2Array, active: PackedByteArray) -> void:
	if _cells.size() > _max_cells:
		_cells.clear()
	for cell: Array in _cells.values():
		cell.clear()
	for i: int in positions.size():
		if active[i] == 0:
			continue
		var key: Vector2i = cell_of(positions[i])
		if not _cells.has(key):
			_cells[key] = []
		(_cells[key] as Array).append(i)


## Indices whose position is within `radius` of `center`.
func query(center: Vector2, radius: float, positions: PackedVector2Array, active: PackedByteArray) -> PackedInt32Array:
	var found := PackedInt32Array()
	var low: Vector2i = cell_of(center - Vector2(radius, radius))
	var high: Vector2i = cell_of(center + Vector2(radius, radius))
	var radius_sq: float = radius * radius
	for cy: int in range(low.y, high.y + 1):
		for cx: int in range(low.x, high.x + 1):
			var cell: Variant = _cells.get(Vector2i(cx, cy))
			if cell == null:
				continue
			for index: int in cell:
				if active[index] != 0 and positions[index].distance_squared_to(center) <= radius_sq:
					found.append(index)
	return found


## The closest active index within `max_range` of `center`, or -1.
func nearest(center: Vector2, max_range: float, positions: PackedVector2Array, active: PackedByteArray) -> int:
	var best: int = -1
	var best_sq: float = INF
	for index: int in query(center, max_range, positions, active):
		var dist_sq: float = positions[index].distance_squared_to(center)
		if dist_sq < best_sq:
			best_sq = dist_sq
			best = index
	return best
