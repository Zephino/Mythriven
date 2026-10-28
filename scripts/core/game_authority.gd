extends Node
## Autoload "GameAuthority". Every game event (spawns, damage, drops, deaths,
## god binding) goes through here, so co-op can later run them only on the
## host (GAME_DESIGN.md: Multiplayer-ready from day one).
## Players are always a list, never a single global player.

signal run_started(run: RunState)
signal player_spawned(player: Player)
signal player_removed(player: Player)

const LEVELS_FILE := "levels.json"

var players: Array[Player] = []
var run: RunState = null


func _process(delta: float) -> void:
	if run != null and not run.ended:
		run.elapsed_s += delta


## Starts a new run on a level. Uses config run.fixed_seed, or a random seed when it is 0.
func start_run(level_id: String) -> RunState:
	players.clear()
	var run_seed: int = Data.cfg_int("run.fixed_seed")
	if run_seed == 0:
		var seeder := RandomNumberGenerator.new()
		seeder.randomize()
		run_seed = seeder.randi()
	run = RunState.new(run_seed, find_level(level_id))
	run_started.emit(run)
	return run


func find_level(level_id: String) -> Dictionary:
	var levels: Variant = Data.get_file(LEVELS_FILE)
	if levels is Array:
		for level: Variant in levels:
			if level is Dictionary and (level as Dictionary).get("id", "") == level_id:
				return level
	push_error("GameAuthority: level '%s' not found in %s" % [level_id, LEVELS_FILE])
	return {}


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
