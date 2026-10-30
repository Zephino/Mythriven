class_name WorldRoot
extends Node2D
## Parent of everything in the game world. Far from (0, 0) floating-point
## numbers lose precision and sprites start to wobble, so once the players are
## more than ~50,000 px away the whole world is moved back toward (0, 0) by a
## whole number of chunks (GAME_DESIGN.md: Far distances). Systems that keep
## their own positions listen to `origin_shifted`. In co-op only the host
## decides when to shift; joining players' games follow it (CoopClient).

signal origin_shifted(shift_px: Vector2, shift_chunks: Vector2i)

## Every shift so far, in chunks (a player joining a co-op run late catches up to it).
var total_shift := Vector2i.ZERO


func _ready() -> void:
	# After players move (0) and before the camera follows (10).
	process_priority = 5


func _process(_delta: float) -> void:
	if GameAuthority.players.is_empty() or Net.is_client():
		return
	var center := Vector2.ZERO
	for player: Player in GameAuthority.players:
		center += player.position
	center /= GameAuthority.players.size()
	var limit: float = Data.cfg_float("world.origin_shift_px")
	if absf(center.x) > limit or absf(center.y) > limit:
		shift_origin(center)


## Moves players, the camera, and (through the signal) everything else so that
## `center` ends up near (0, 0).
func shift_origin(center: Vector2) -> void:
	var chunk_px: float = Data.cfg_float("world.tile_px") * Data.cfg_float("world.chunk_tiles")
	shift_by(Vector2i(roundi(center.x / chunk_px), roundi(center.y / chunk_px)))


## Shifts by a whole number of chunks (CoopClient repeats the host's shifts).
func shift_by(shift_chunks: Vector2i) -> void:
	var chunk_px: float = Data.cfg_float("world.tile_px") * Data.cfg_float("world.chunk_tiles")
	var shift_px := Vector2(shift_chunks) * chunk_px
	total_shift += shift_chunks
	for player: Player in GameAuthority.players:
		player.position -= shift_px
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera != null and is_ancestor_of(camera):
		camera.position -= shift_px
	origin_shifted.emit(shift_px, shift_chunks)
