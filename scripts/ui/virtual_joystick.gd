class_name VirtualJoystick
extends Control
## Floating virtual joystick (GAME_DESIGN.md: Controls). It appears where a
## finger touches the left part of the screen, only while that finger is
## down, and follows no fixed position. Placeholder circles for art.

var _active: bool = false
var _touch_index: int = -1
var _center: Vector2 = Vector2.ZERO
var _knob: Vector2 = Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func is_active() -> bool:
	return _active


## Direction and strength, from (0, 0) to length 1.
func get_vector() -> Vector2:
	if not _active:
		return Vector2.ZERO
	return (_knob - _center) / Data.cfg_float("joystick.radius_px")


# Unhandled input, so touches on menus and buttons never move the player.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_on_drag(event as InputEventScreenDrag)


func _on_touch(touch: InputEventScreenTouch) -> void:
	if touch.pressed and not _active and _in_joystick_area(touch.position):
		_active = true
		_touch_index = touch.index
		_center = touch.position
		_knob = touch.position
		queue_redraw()
	elif not touch.pressed and touch.index == _touch_index:
		_active = false
		_touch_index = -1
		queue_redraw()


func _on_drag(drag: InputEventScreenDrag) -> void:
	if not _active or drag.index != _touch_index:
		return
	_knob = _center + (drag.position - _center).limit_length(Data.cfg_float("joystick.radius_px"))
	queue_redraw()


## Left part of the screen, inside the safe area on phones with notches.
func _in_joystick_area(point: Vector2) -> bool:
	var view: Rect2 = get_viewport_rect()
	var area := Rect2(view.position, Vector2(view.size.x * Data.cfg_float("joystick.screen_fraction"), view.size.y))
	if OS.has_feature("mobile"):
		var safe := Rect2(DisplayServer.get_display_safe_area())
		area = area.intersection(safe)
	return area.has_point(point)


func _draw() -> void:
	if not _active:
		return
	draw_circle(_center, Data.cfg_float("joystick.radius_px"), Color.html(Data.cfg_string("joystick.base_color")))
	draw_circle(_knob, Data.cfg_float("joystick.knob_radius_px"), Color.html(Data.cfg_string("joystick.knob_color")))
