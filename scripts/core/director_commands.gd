class_name DirectorCommands
extends Node
## The things a shot list can do (see DirectorMode.COMMANDS and
## tools/video/README.md). run() does one step and returns how many seconds the
## runner should wait before the next one. Also drives the autopilot (walks in
## changing directions) and auto-pick (chooses the first level-up card), which
## keep working while the level-up screen has the game paused.

const DIRECTIONS: Array[Vector2] = [
	Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1),
	Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1),
]

var _chunks: ChunkManager
var _camera: GameCamera
var _spawner: EnemySpawner
var _hud: Hud
var _systems: RunSystems
var _level_up: LevelUpScreen
var _autopilot: bool = false
var _auto_pick: bool = false
var _walk_left: float = 0.0
var _turn_left: float = 0.0
var _rng := RandomNumberGenerator.new()


func setup(runner: Node) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var scene: Node = runner.get_parent()
	_chunks = _first(scene, "ChunkManager") as ChunkManager
	_camera = _first(scene, "GameCamera") as GameCamera
	_spawner = _first(scene, "EnemySpawner") as EnemySpawner
	_hud = _first(scene, "Hud") as Hud
	_systems = _first(scene, "RunSystems") as RunSystems
	_level_up = _first(scene, "LevelUpScreen") as LevelUpScreen
	_rng.randomize()


## Does one step. Returns the seconds to wait afterwards.
func run(step: Dictionary) -> float:
	var run_state: RunState = GameAuthority.run
	var enemies: EnemyManager = GameAuthority.enemies
	var player: Player = GameAuthority.local_player()
	if run_state == null or player == null:
		return 0.0
	match str(step["do"]):
		"wait":
			return float(step["seconds"])
		"set_time":
			run_state.elapsed_s = float(step["seconds"])
		"next_age":
			_next_age(run_state)
		"teleport":
			_teleport(player, enemies, step)
		"density":
			run_state.spawn_mult = float(step["mult"])
		"enemy_hp":
			_set_enemy_hp(run_state, enemies, float(step["mult"]))
		"auto_spawn":
			_spawner.auto_spawn = bool(step["on"])
		"fill":
			_spawner.spawn_ring(str(step.get("type", Data.cfg_string("enemies.auto_chaser_type"))), enemies.free_slots())
		"spawn":
			_spawn(step)
		"kill_all":
			_kill_all(enemies)
		"elite":
			_systems.director.spawn_elite()
		"god_mode":
			for each: Player in GameAuthority.players:
				each.god_mode = bool(step["on"])
		"heal":
			GameAuthority.heal_player(player, player.max_hp)
		"player_hp":
			player.hp = maxf(player.max_hp * float(step["fraction"]), 1.0)
		"levels":
			_gain_levels(run_state, player, int(step["count"]))
		"max_build":
			_max_build(player)
		"give_weapon":
			GameAuthority.give_weapon(player, str(step["id"]))
		"walk":
			_walk(Vector2(float(step.get("dx", 0.0)), float(step.get("dy", 0.0))))
			_walk_left = float(step["seconds"])
			return _walk_left
		"autopilot":
			_autopilot = bool(step["on"])
			if not _autopilot:
				_walk(Vector2.ZERO)
		"auto_pick":
			_auto_pick = bool(step["on"])
		"hud":
			_hud.visible = bool(step["on"])
		"zoom":
			_camera.zoom = Vector2.ONE * float(step["value"])
	return 0.0


func _process(delta: float) -> void:
	if _auto_pick and _level_up != null and _level_up.is_open():
		_level_up.call("_on_card_pressed", 0)
	if _walk_left > 0.0:
		_walk_left -= delta
		if _walk_left <= 0.0 and not _autopilot:
			_walk(Vector2.ZERO)
	if _autopilot:
		_turn_left -= delta
		if _turn_left <= 0.0:
			_turn_left = Data.cfg_float("director.autopilot_turn_s")
			_walk(DIRECTIONS[_rng.randi_range(0, DIRECTIONS.size() - 1)])


## Holds the move keys for a direction (zero lets go of all of them).
func _walk(dir: Vector2) -> void:
	_set_action("move_left", dir.x < 0.0)
	_set_action("move_right", dir.x > 0.0)
	_set_action("move_up", dir.y < 0.0)
	_set_action("move_down", dir.y > 0.0)


func _set_action(action: String, held: bool) -> void:
	if held:
		Input.action_press(action)
	else:
		Input.action_release(action)


## Moves the Hero: "x"/"y" go to that spot, "dx"/"dy" move by that much,
## "radius" jumps to a random spot that far around. "clear": true removes the
## enemies first so the arrival shot is clean.
func _teleport(player: Player, enemies: EnemyManager, step: Dictionary) -> void:
	if bool(step.get("clear", false)):
		_kill_all(enemies)
	var target: Vector2 = player.position
	if step.has("x") or step.has("y"):
		target = Vector2(float(step.get("x", target.x)), float(step.get("y", target.y)))
	if step.has("dx") or step.has("dy"):
		target += Vector2(float(step.get("dx", 0.0)), float(step.get("dy", 0.0)))
	if step.has("radius"):
		target += Vector2.from_angle(_rng.randf() * TAU) * float(step["radius"]) * sqrt(_rng.randf())
	player.position = target
	_chunks.update_chunks()
	_chunks.build_all_now()
	_camera.snap_to_target()


## Multiplies the HP of every enemy (bosses keep theirs) now and for new spawns.
func _set_enemy_hp(run_state: RunState, enemies: EnemyManager, mult: float) -> void:
	var ratio: float = mult / maxf(run_state.director_hp_mult, 0.0001)
	run_state.director_hp_mult = mult
	for i: int in enemies.capacity:
		if enemies.active[i] != 0 and not bool(enemies.type_of(i).get("boss", false)):
			enemies.max_hp[i] *= ratio
			enemies.hp[i] *= ratio


## "mode": "ring" (spread around the screen edge, default) or "pack" (one tight group).
func _spawn(step: Dictionary) -> void:
	var type_id: String = str(step["type"])
	var count: int = int(step["count"])
	if str(step.get("mode", "ring")) == "pack":
		_spawner.spawn_pack(type_id, count)
	else:
		_spawner.spawn_ring(type_id, count)


func _kill_all(enemies: EnemyManager) -> void:
	for i: int in enemies.capacity:
		if enemies.active[i] != 0:
			enemies.despawn(i)


func _next_age(run_state: RunState) -> void:
	var starts: Dictionary = Data.cfg("run_arc.age_start_s")
	for age: String in RunArc.AGES:
		if float(starts.get(age, 0.0)) > run_state.elapsed_s:
			run_state.elapsed_s = float(starts[age])
			return


## Gains levels one at a time and takes the first card of each, with no screen.
func _gain_levels(run_state: RunState, player: Player, count: int) -> void:
	for _i: int in count:
		GameAuthority.collect_xp(player, LevelUpRules.xp_to_next(run_state.level) - run_state.xp)
		var guard: int = 0
		while run_state.unspent_level_ups > 0 and guard < 50:
			guard += 1
			var cards: Array[Dictionary] = GameAuthority.current_offer(player)
			if cards.is_empty():
				run_state.unspent_level_ups = 0
				break
			GameAuthority.apply_card(player, cards[0])
	if _level_up != null:
		_level_up.close()


func _max_build(player: Player) -> void:
	var guard: int = 0
	while not LevelUpRules.is_maxed(player) and guard < 500:
		guard += 1
		GameAuthority.apply_card(player, LevelUpRules.item_cards(player)[0], false)


## The first node under `scene` whose script has this class_name (null if none).
func _first(scene: Node, type_name: String) -> Node:
	for child: Node in scene.get_children():
		var script: Script = child.get_script() as Script
		if script != null and script.get_global_name() == type_name:
			return child
		var deeper: Node = _first(child, type_name)
		if deeper != null:
			return deeper
	return null
