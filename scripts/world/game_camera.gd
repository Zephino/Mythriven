class_name GameCamera
extends Camera2D
## Smooth follow with slight look-ahead in the direction of movement
## (GAME_DESIGN.md: Chunks / Camera). Runs every frame after the player has
## moved, using frame-rate independent smoothing so it never jitters.
## Shakes briefly on god summons and Guard Breaks (GAME_DESIGN.md: Game feel),
## scaled by the screen shake setting (off / low / full).

const GROUP := "game_camera"

var target: Player = null

var _shake_px: float = 0.0
var _shake_left: float = 0.0


func _ready() -> void:
	# Higher priority runs later in the frame, after the player moves.
	process_priority = 10
	add_to_group(GROUP)
	var zoom_level: float = Data.cfg_float("camera.zoom")
	zoom = Vector2(zoom_level, zoom_level)
	snap_to_target()


## Shakes the run's camera, if there is one.
static func shake_screen(tree: SceneTree, strength_px: float) -> void:
	if tree != null:
		tree.call_group(GROUP, "shake", strength_px)


func shake(strength_px: float) -> void:
	var scaled: float = strength_px * Settings.shake_strength()
	if scaled <= 0.0:
		return
	_shake_px = maxf(_shake_px, scaled)
	_shake_left = Data.cfg_float("settings.shake_s")


## Jumps straight to the target (on spawn, or after a teleport).
func snap_to_target() -> void:
	if target != null:
		global_position = target.global_position


func _process(delta: float) -> void:
	if target == null:
		return
	var look_ahead: Vector2 = Vector2.ZERO
	if target.velocity != Vector2.ZERO:
		look_ahead = target.velocity.normalized() * Data.cfg_float("camera.look_ahead_px")
	var goal: Vector2 = target.global_position + look_ahead
	var weight: float = 1.0 - exp(-Data.cfg_float("camera.follow_speed") * delta)
	global_position = global_position.lerp(goal, weight)
	if _shake_left > 0.0:
		_shake_left -= delta
		var fade: float = clampf(_shake_left / Data.cfg_float("settings.shake_s"), 0.0, 1.0)
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_px * fade
	elif offset != Vector2.ZERO:
		offset = Vector2.ZERO
		_shake_px = 0.0
