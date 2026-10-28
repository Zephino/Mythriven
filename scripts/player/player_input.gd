class_name PlayerInput
extends RefCounted
## Movement input for one local player: keyboard (WASD / arrows), gamepad
## (left stick / D-pad) through the Input Map, or the touch joystick.
## Movement uses 8 directions at full speed, so diagonals are never faster.

## Touch joystick for this player (null on devices without one).
var joystick: TouchJoystick = null


func get_move_vector() -> Vector2:
	var raw: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if joystick != null and joystick.is_active():
		raw = joystick.get_vector()
	return shape_move(raw, Data.cfg_float("player.move_deadzone"), Data.cfg_bool("player.snap_to_8_directions"))


## Turns a raw stick/key vector into a unit direction (or zero).
## With snapping on, the direction is rounded to the nearest of 8 directions.
static func shape_move(raw: Vector2, deadzone: float, snap_to_8: bool) -> Vector2:
	if raw.length() <= deadzone:
		return Vector2.ZERO
	if not snap_to_8:
		return raw.normalized()
	return Vector2.from_angle(snappedf(raw.angle(), PI / 4.0))
