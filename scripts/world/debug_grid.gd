extends Node2D
## Dev-build test aid: faint grid lines over the world (64 px apart by
## default), handy for judging movement and enemy spacing. Off by default;
## toggled in the debug menu.

var enabled: bool = false


func _ready() -> void:
	z_index = -1


func _process(_delta: float) -> void:
	visible = enabled
	if visible:
		queue_redraw()


func _draw() -> void:
	var spacing: float = Data.cfg_float("debug.grid_spacing_px")
	if spacing <= 0.0:
		return
	var color := Color.html(Data.cfg_string("debug.grid_color"))
	# The visible part of the world, in world coordinates.
	var view: Rect2 = get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()
	var x: float = floorf(view.position.x / spacing) * spacing
	while x <= view.end.x:
		draw_line(Vector2(x, view.position.y), Vector2(x, view.end.y), color)
		x += spacing
	var y: float = floorf(view.position.y / spacing) * spacing
	while y <= view.end.y:
		draw_line(Vector2(view.position.x, y), Vector2(view.end.x, y), color)
		y += spacing
