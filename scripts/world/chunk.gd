class_name Chunk
extends Node2D
## One 32×32-tile piece of the endless ground plus its decorations.
## Chunks are pooled by ChunkManager: when the player walks away a chunk is
## cleared and reused for a new spot, so memory stays flat.

## Absolute chunk coordinate (doesn't change when the world origin shifts).
var coord: Vector2i = Vector2i.ZERO
## Each decoration: {"position": Vector2, "art": Dictionary}. Visual only, no collision.
var decorations: Array[Dictionary] = []

var _layer: TileMapLayer
var _decor_canvas: Node2D
var _next_row: int = 0
var _rows: int = 0


func setup(tileset: TileSet, rows: int) -> void:
	_rows = rows
	_layer = TileMapLayer.new()
	_layer.tile_set = tileset
	add_child(_layer)
	# Drawn after (on top of) the ground.
	_decor_canvas = Node2D.new()
	add_child(_decor_canvas)
	_decor_canvas.draw.connect(_draw_decorations)


## Prepares the chunk for a new spot; the ground is then filled in a few rows at a time.
func begin(new_coord: Vector2i, new_decorations: Array[Dictionary]) -> void:
	coord = new_coord
	decorations = new_decorations
	_next_row = 0
	_layer.clear()
	visible = true
	_decor_canvas.queue_redraw()


func release() -> void:
	visible = false
	_layer.clear()
	decorations = []


func is_built() -> bool:
	return _next_row >= _rows


## Paints up to `max_rows` rows of ground. Returns how many rows were painted.
func build_rows(manager: ChunkManager, max_rows: int) -> int:
	var count: int = mini(max_rows, _rows - _next_row)
	var base: Vector2i = coord * _rows
	for r: int in count:
		var y: int = _next_row + r
		for x: int in _rows:
			_layer.set_cell(Vector2i(x, y), LevelArt.SOURCE_ID, manager.ground_cell(base + Vector2i(x, y)))
	_next_row += count
	return count


func _draw_decorations() -> void:
	for decoration: Dictionary in decorations:
		var art: Dictionary = decoration["art"]
		var pos: Vector2 = decoration["position"]
		var size_list: Array = art.get("size_px", [8, 8])
		var size := Vector2(float(size_list[0]), float(size_list[1]))
		var color := Color.html(str(art.get("placeholder_color", "#ff00ff")))
		if art.get("shape", "rect") == "circle":
			_decor_canvas.draw_circle(pos, size.x * 0.5, color)
		else:
			_decor_canvas.draw_rect(Rect2(pos - size * 0.5, size), color)
