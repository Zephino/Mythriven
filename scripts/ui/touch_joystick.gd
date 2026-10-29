class_name TouchJoystick
extends Control
## Floating virtual joystick (GAME_DESIGN.md: Controls). It appears where a
## finger touches the screen (anywhere but a button, or only the left or
## right part, a setting), only while that finger is down, and follows no
## fixed position. Placeholder circles for art. Its size is a setting too.

## On-screen buttons (god buttons, pause, Labors) that a touch should press
## instead of starting the joystick.
const BLOCKERS := "joystick_blockers"

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
	return (_knob - _center) / _radius()


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
	_knob = _center + (drag.position - _center).limit_length(_radius())
	queue_redraw()


func _radius() -> float:
	return Data.cfg_float("joystick.radius_px") * Settings.control_scale()


## The whole screen, or its left or right part (the joystick side setting),
## inside the safe area on phones with notches, and never on a button.
func _in_joystick_area(point: Vector2) -> bool:
	var view: Rect2 = get_viewport_rect()
	var area: Rect2 = view
	var side: String = Settings.text("joystick_side")
	if side != "anywhere":
		var width: float = view.size.x * Data.cfg_float("joystick.screen_fraction")
		area = Rect2(view.position, Vector2(width, view.size.y))
		if side == "right":
			area.position.x = view.end.x - width
	area = area.intersection(SafeArea.rect(get_viewport()))
	if not area.has_point(point):
		return false
	for blocker: Node in get_tree().get_nodes_in_group(BLOCKERS):
		var control := blocker as Control
		if control != null and control.is_visible_in_tree() and control.get_global_rect().has_point(point):
			return false
	return true


func _draw() -> void:
	if not _active:
		return
	draw_circle(_center, _radius(), Color.html(Data.cfg_string("joystick.base_color")))
	draw_circle(_knob, Data.cfg_float("joystick.knob_radius_px") * Settings.control_scale(), Color.html(Data.cfg_string("joystick.knob_color")))
