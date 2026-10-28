extends Node
## Autoload "GameAuthority". Every game event (spawns, damage, drops, deaths,
## god binding) goes through here, so co-op can later run them only on the
## host (GAME_DESIGN.md: Multiplayer-ready from day one).
## Players are always a list, never a single global player.

signal run_started(run: RunState)
signal player_spawned(player: Player)
signal player_removed(player: Player)
signal player_damaged(player: Player, amount: float, source_id: String)
signal player_died(player: Player, cause_id: String)
signal run_ended(run: RunState)
signal enemy_damaged(slot: int, amount: float, crit: bool, at: Vector2)
signal enemy_killed(slot: int, enemy_type: Dictionary, at: Vector2, killer: Player)

const LEVELS_FILE := "levels.json"
const WEAPONS_FILE := "weapons.json"

var players: Array[Player] = []
var run: RunState = null
## Set by the main scene; null between runs.
var enemies: EnemyManager = null


func _process(delta: float) -> void:
	if run != null and not run.ended:
		run.elapsed_s += delta


## Starts a new run on a level. Uses config run.fixed_seed, or a random seed when it is 0.
func start_run(level_id: String) -> RunState:
	players.clear()
	enemies = null
	var run_seed: int = Data.cfg_int("run.fixed_seed")
	if run_seed == 0:
		var seeder := RandomNumberGenerator.new()
		seeder.randomize()
		run_seed = seeder.randi()
	run = RunState.new(run_seed, find_level(level_id))
	run_started.emit(run)
	return run


## Forgets the players and managers of a scene that is being freed.
func end_scene() -> void:
	players.clear()
	enemies = null


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


# --- Enemies and damage ---------------------------------------------------------

## Spawns an enemy. Returns its slot, or -1 when the enemy cap is reached.
func spawn_enemy(type_id: String, at: Vector2) -> int:
	if enemies == null:
		return -1
	return enemies.spawn(type_id, at)


## Damages a player (enemy damage − Armor, minimum 1; no invulnerability frames).
func damage_player(player: Player, amount: float, source_id: String) -> void:
	if not player.alive or player.god_mode:
		return
	var dealt: float = Damage.to_player(amount, player.armor, Data.cfg_float("combat.min_damage"))
	player.hp -= dealt
	player_damaged.emit(player, dealt, source_id)
	if player.hp <= 0.0:
		_kill_player(player, source_id)


func heal_player(player: Player, amount: float) -> void:
	if player.alive:
		player.hp = minf(player.hp + amount, player.max_hp)


func _kill_player(player: Player, cause_id: String) -> void:
	player.hp = 0.0
	player.alive = false
	player.cause_of_death = cause_id
	player_died.emit(player, cause_id)
	for other: Player in players:
		if other.alive:
			return
	if run != null and not run.ended:
		run.ended = true
		run_ended.emit(run)


## Damages an enemy using the damage formula and the attacker's stats.
## `element` is unused until Phase 8 (weakness ×1.5 / resistance ×0.5).
func damage_enemy(slot: int, base_damage: float, attacker: Player, push: Vector2, _element: String) -> void:
	if enemies == null or enemies.active[slot] == 0:
		return
	var data: Dictionary = enemies.type_of(slot)
	var result: Dictionary = Damage.hit(base_damage, 0.0, attacker.stats.might(), attacker.stats.crit_chance(),
			Data.cfg_float("combat.crit_mult"), run.rng.combat.randf(), 1.0, float(data.get("armor", 0.0)),
			Data.cfg_float("combat.min_damage"))
	var amount: float = result["amount"]
	enemies.hp[slot] -= amount
	enemies.flash_timer[slot] = Data.cfg_float("enemies.hit_flash_s")
	enemies.knockback[slot] += push * (1.0 - float(data.get("knockback_resist", 0.0)))
	enemy_damaged.emit(slot, amount, bool(result["crit"]), enemies.positions[slot])
	if enemies.hp[slot] <= 0.0:
		kill_enemy(slot, attacker)


## An enemy dies: counts the kill, tells listeners (XP drops), frees the slot.
func kill_enemy(slot: int, killer: Player) -> void:
	if enemies == null or enemies.active[slot] == 0:
		return
	var at: Vector2 = enemies.positions[slot]
	var data: Dictionary = enemies.type_of(slot)
	if run != null:
		run.kills += 1
	enemies.despawn(slot)
	enemy_killed.emit(slot, data, at, killer)


func find_weapon(weapon_id: String) -> Dictionary:
	var weapons: Variant = Data.get_file(WEAPONS_FILE)
	if weapons is Array:
		for weapon: Variant in weapons:
			if weapon is Dictionary and (weapon as Dictionary).get("id", "") == weapon_id:
				return weapon
	push_error("GameAuthority: weapon '%s' not found in %s" % [weapon_id, WEAPONS_FILE])
	return {}


## Gives a player a new weapon at level 1. Returns it, or null if unknown.
func give_weapon(player: Player, weapon_id: String) -> WeaponInstance:
	var data: Dictionary = find_weapon(weapon_id)
	if data.is_empty():
		return null
	var weapon := WeaponInstance.new(data, player)
	player.weapons.append(weapon)
	return weapon
