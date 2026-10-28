class_name GameCamera
extends Camera2D
## Smooth follow with slight look-ahead in the direction of movement
## (GAME_DESIGN.md: Chunks / Camera). Runs every frame after the player has
## moved, using frame-rate independent smoothing so it never jitters.

var target: Player = null


func _ready() -> void:
	# Higher priority runs later in the frame, after the player moves.
	process_priority = 10
	var zoom_level: float = Data.cfg_float("camera.zoom")
	zoom = Vector2(zoom_level, zoom_level)
	snap_to_target()


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
