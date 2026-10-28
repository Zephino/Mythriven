class_name Player
extends Node2D
## One player's Hero in the world (Phase 2: a placeholder square).
## Created only through GameAuthority.spawn_player, which keeps the list of
## players. Facing is the last direction the player moved in.

var player_id: int = 0
var is_local: bool = true
var input: PlayerInput = null
var move_speed: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT


func _ready() -> void:
	move_speed = Data.cfg_float("player.placeholder_move_speed")


func _process(delta: float) -> void:
	if input != null:
		step(input.get_move_vector(), delta)


## Moves by one frame in `direction` (a unit vector or zero) and updates facing.
func step(direction: Vector2, delta: float) -> void:
	velocity = direction * move_speed
	position += velocity * delta
	if direction != Vector2.ZERO and direction != facing:
		facing = direction
		queue_redraw()


func _draw() -> void:
	var size_px: float = Data.cfg_float("player.placeholder_size_px")
	var color := Color.html(Data.cfg_string("player.placeholder_color"))
	draw_rect(Rect2(Vector2(-size_px, -size_px) * 0.5, Vector2(size_px, size_px)), color)
	# A small dot on the facing side shows which way the player last moved.
	var marker_px: float = Data.cfg_float("player.facing_marker_px")
	var marker_color := Color.html(Data.cfg_string("player.facing_marker_color"))
	draw_circle(facing * (size_px * 0.5 - marker_px * 0.5), marker_px * 0.5, marker_color)
