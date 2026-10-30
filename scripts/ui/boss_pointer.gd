class_name BossPointer
extends CanvasLayer
## An arrow at the edge of the screen pointing to each living boss that's off
## screen, so a boss is never lost in the horde or behind you (owner request
## 10/30/2026). Pulses with the boss ring's colour (config: bosses.marker).

var bosses: BossManager

var _canvas: Node2D


func _ready() -> void:
	layer = 9
	_canvas = Node2D.new()
	_canvas.draw.connect(_draw_pointers)
	add_child(_canvas)


func _process(_delta: float) -> void:
	_canvas.queue_redraw()


func _draw_pointers() -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if bosses == null or camera == null:
		return
	var marker: Dictionary = Data.cfg("bosses.marker")
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var view: Vector2 = screen / maxf(Data.cfg_float("camera.zoom"), 0.01)
	var center: Vector2 = camera.get_screen_center_position()
	var size: float = float(marker.get("pointer_px", 30.0))
	var margin: float = Data.cfg_float("ui.min_touch_target_px") * 0.5 + size
	var seconds: float = GameAuthority.run.elapsed_s if GameAuthority.run != null else 0.0
	var pulse: float = 0.9 + 0.1 * sin(seconds * TAU * float(marker.get("pulse_hz", 1.0)))
	var color := Color(Color.html(str(marker.get("color", "#ff3050"))), pulse)
	var outline := Color.html(str(marker.get("outline_color", "#000000")))
	for controller: BossController in bosses.controllers:
		if not controller.is_alive():
			continue
		var at: Vector2 = controller.position_now()
		if Rect2(center - view * 0.5, view).has_point(at):
			continue
		var dir: Vector2 = (at - center).normalized()
		var half: Vector2 = screen * 0.5 - Vector2(margin, margin)
		var reach: float = minf(half.x / maxf(absf(dir.x), 0.001), half.y / maxf(absf(dir.y), 0.001))
		var tip: Vector2 = screen * 0.5 + dir * reach
		var back: Vector2 = tip - dir * size * 1.4
		var side: Vector2 = dir.orthogonal() * size * 0.7
		var arrow := PackedVector2Array([tip, back + side, back - side])
		_canvas.draw_colored_polygon(arrow, color)
		arrow.append(tip)
		_canvas.draw_polyline(arrow, outline, 3.0)
		_canvas.draw_circle(back - dir * size * 0.5, size * 0.45, outline)
		_canvas.draw_circle(back - dir * size * 0.5, size * 0.3, color)
