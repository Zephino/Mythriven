extends Node
## Autoload "GameAuthority". Every game event (spawns, damage, drops, deaths,
## god binding) goes through here, so co-op can later run them only on the
## host (GAME_DESIGN.md: Multiplayer-ready from day one).
## Players are always a list, never a single global player.

signal player_spawned(player: Player)
signal player_removed(player: Player)

var players: Array[Player] = []


## Creates a player, adds it under `parent`, and registers it in the list.
func spawn_player(parent: Node, spawn_position: Vector2, input: PlayerInput, is_local: bool) -> Player:
	var player := Player.new()
	player.player_id = _next_player_id()
	player.is_local = is_local
	player.input = input
	player.position = spawn_position
	parent.add_child(player)
	players.append(player)
	player_spawned.emit(player)
	return player


func remove_player(player: Player) -> void:
	players.erase(player)
	player_removed.emit(player)
	player.queue_free()


## The first player controlled on this device, or null.
func local_player() -> Player:
	for player: Player in players:
		if player.is_local:
			return player
	return null


func _next_player_id() -> int:
	var highest: int = -1
	for player: Player in players:
		highest = maxi(highest, player.player_id)
	return highest + 1
