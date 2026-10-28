extends Node
## Dev-build only: adds the player and world test options to the debug menu
## (Phases 2–3). Created by main.gd; removed with the scene on Retry.

var world: WorldRoot
var chunks: ChunkManager
var grid: Node2D
var camera: GameCamera


func _ready() -> void:
	DebugMenu.add_info(self, _player_info)
	DebugMenu.add_info(self, _world_info)
	DebugMenu.add_button(self, "DEBUG_RESET_PLAYER", _reset_player)
	DebugMenu.add_button(self, "DEBUG_TELEPORT_FAR", _teleport_far)
	DebugMenu.add_check(self, "DEBUG_SHOW_GRID", false, _on_grid_toggled)


func _player_info() -> String:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return tr("DEBUG_NO_PLAYER") % GameAuthority.players.size()
	return tr("DEBUG_PLAYER_INFO") % [
		GameAuthority.players.size(), roundi(player.position.x), roundi(player.position.y),
		player.facing.x, player.facing.y, roundi(player.velocity.length()),
	]


func _world_info() -> String:
	var player: Player = GameAuthority.local_player()
	var chunk: Vector2i = chunks.world_to_chunk(player.position) if player != null else Vector2i.ZERO
	return tr("DEBUG_WORLD_INFO") % [
		GameAuthority.run.seed_value, chunk.x, chunk.y, chunks.origin_chunk.x, chunks.origin_chunk.y,
		chunks.loaded_count(), chunks.pooled_count(),
	]


## Moves the local player back to (0, 0) and snaps the camera there.
func _reset_player() -> void:
	_move_player_to(Vector2.ZERO)


## Jumps far east so the origin shift (past ~50,000 px) can be tested quickly.
func _teleport_far() -> void:
	var player: Player = GameAuthority.local_player()
	if player != null:
		_move_player_to(player.position + Vector2(Data.cfg_float("debug.teleport_px"), 0.0))


func _move_player_to(target: Vector2) -> void:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return
	player.position = target
	chunks.update_chunks()
	chunks.build_all_now()
	camera.snap_to_target()


func _on_grid_toggled(on: bool) -> void:
	grid.set("enabled", on)
