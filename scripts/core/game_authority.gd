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
## kind: "normal", "crit", "weak", "resist", or "dot" (damage over time).
signal enemy_damaged(slot: int, amount: float, kind: String, at: Vector2)
signal reaction_triggered(reaction_id: String, at: Vector2, reach: float, by: Player)
signal xp_collected(player: Player, amount: float)
signal enemy_killed(slot: int, enemy_type: Dictionary, at: Vector2, killer: Player)
signal xp_changed(run: RunState)
## A level-up is waiting to be chosen (the level-up screen opens).
signal level_up_ready(run: RunState)
signal card_applied(player: Player, card: Dictionary)
## A new Age began (RunArc ids: "dusk", "night", "deep_night", "unraveling").
signal age_changed(age_id: String)
## An elite died (split copies too, with is_copy true): drops a chest and gold.
signal elite_killed(at: Vector2, enemy_type: Dictionary, is_copy: bool)
signal gold_collected(player: Player, amount: float)

const LEVELS_FILE := "levels.json"
const WEAPONS_FILE := "weapons.json"

var players: Array[Player] = []
var run: RunState = null
## Set by the main scene; null between runs.
var enemies: EnemyManager = null
var enemy_shots: EnemyProjectiles = null
## Auto-collect setting: "off", "gold", "heal", or "smart". Saved with the
## other settings once the save system exists (Phase 15).
var auto_collect: String = ""
## Turns hits into damage, statuses, and reactions (see hit_resolver.gd).
var hits := HitResolver.new()
## The Hero picked on the Hero select screen; kept for Retry, cleared by "Change Hero".
var selected_hero_id: String = ""


func _process(delta: float) -> void:
	if run != null and not run.ended:
		run.elapsed_s += delta


## Starts a new run on a level. Uses config run.fixed_seed, or a random seed when it is 0.
func start_run(level_id: String) -> RunState:
	if auto_collect == "":
		auto_collect = Data.cfg_string("level_up.auto_collect_default")
	players.clear()
	enemies = null
	enemy_shots = null
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
	enemy_shots = null


func find_level(level_id: String) -> Dictionary:
	var levels: Variant = Data.get_file(LEVELS_FILE)
	if levels is Array:
		for level: Variant in levels:
			if level is Dictionary and (level as Dictionary).get("id", "") == level_id:
				return level
	push_error("GameAuthority: level '%s' not found in %s" % [level_id, LEVELS_FILE])
	return {}


## Creates a player, adds it under `parent`, and registers it in the list.
func spawn_player(parent: Node, spawn_position: Vector2, input: PlayerInput, is_local: bool,
		hero_id: String = "") -> Player:
	var player := Player.new()
	player.hero = HeroRules.find(hero_id) if hero_id != "" else {}
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
## `from` is where the hit came from (Vector2.INF when unknown).
func damage_player(player: Player, amount: float, source_id: String, _from: Vector2 = Vector2.INF) -> void:
	if not player.alive or player.god_mode or (player.kit != null and player.kit.is_untargetable()):
		return
	var armor: float = player.armor * player.statuses.armor_mult()
	var dealt: float = Damage.to_player(amount * player.statuses.consume_shock(), armor, Data.cfg_float("combat.min_damage"))
	if player.kit != null:
		dealt = player.kit.incoming_damage(dealt)
		if dealt <= 0.0:
			return
	player.hp -= dealt
	player_damaged.emit(player, dealt, source_id)
	if player.hp <= 0.0:
		_kill_player(player, source_id)


## Burn and Poison on a player: skips Armor.
func damage_player_over_time(player: Player, amount: float) -> void:
	if not player.alive or player.god_mode:
		return
	player.hp -= amount
	if player.hp <= 0.0:
		_kill_player(player, "status")


## From 30:00, an enemy touching a player can pass on its element's status.
func status_player_from_enemy(player: Player, element: String) -> void:
	if element == "" or run == null or run.elapsed_s < Data.cfg_float("combat.player_status_start_s"):
		return
	if player.alive and not player.god_mode:
		player.statuses.apply(Elements.status_of(element))


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


## Damages an enemy: damage formula, weakness/resistance, statuses, and
## reactions. `status_chance` is the chance (0–1) to apply the element's status.
func damage_enemy(slot: int, base_damage: float, attacker: Player, push: Vector2, element: String,
		status_chance: float = 0.0) -> void:
	hits.hit(slot, base_damage, attacker, push, element, status_chance)


## An enemy dies: counts the kill, tells listeners (XP drops), frees the slot.
func kill_enemy(slot: int, killer: Player) -> void:
	if enemies == null or enemies.active[slot] == 0:
		return
	var at: Vector2 = enemies.positions[slot]
	var data: Dictionary = enemies.type_of(slot)
	var elite: bool = enemies.is_elite(slot)
	var copy: bool = enemies.elites.is_copy[slot] != 0
	if elite:
		enemies.elites.on_killed(enemies, slot)
	if run != null:
		run.kills += 1
	enemies.despawn(slot)
	enemy_killed.emit(slot, data, at, killer)
	if elite:
		elite_killed.emit(at, data, copy)


## Adds run gold (spent at the Trader or banked at the end of the run).
func collect_gold(player: Player, amount: float) -> void:
	if run == null or run.ended:
		return
	run.gold += amount
	gold_collected.emit(player, amount)


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
	weapon.expert = HeroRules.is_expert(player.hero, data)
	player.weapons.append(weapon)
	return weapon


# --- XP and level-ups -----------------------------------------------------------

## Adds XP to the shared bar and queues any level-ups it earns.
func collect_xp(player: Player, amount: float) -> void:
	if run == null or run.ended:
		return
	xp_collected.emit(player, amount)
	run.xp += amount
	var gained: int = 0
	while run.xp >= LevelUpRules.xp_to_next(run.level):
		run.xp -= LevelUpRules.xp_to_next(run.level)
		run.level += 1
		gained += 1
	xp_changed.emit(run)
	if gained > 0:
		run.unspent_level_ups += gained
		level_up_ready.emit(run)


## Applies a level-up card to a player and uses up one level-up.
func apply_card(player: Player, card: Dictionary) -> void:
	match str(card.get("kind", "")):
		LevelUpRules.WEAPON_NEW:
			give_weapon(player, str(card["id"]))
		LevelUpRules.WEAPON_UP:
			for weapon: WeaponInstance in player.weapons:
				if weapon.id() == str(card["id"]):
					weapon.level = mini(weapon.level + 1, weapon.max_level())
		LevelUpRules.PASSIVE_NEW, LevelUpRules.PASSIVE_UP:
			var passive: Dictionary = LevelUpRules.passive_data(str(card["id"]))
			player.passives[str(card["id"])] = int(player.passives.get(str(card["id"]), 0)) + 1
			player.stats.add_bonus(str(passive.get("stat", "")), float(passive.get("per_level", 0.0)))
		LevelUpRules.STAT:
			player.stats.add_bonus(str(card["id"]), float(card["amount"]))
		LevelUpRules.GOLD:
			run.gold += float(card["amount"])
		LevelUpRules.HEAL:
			heal_player(player, player.max_hp * float(card["amount"]))
	player.refresh_stats()
	run.unspent_level_ups = maxi(run.unspent_level_ups - 1, 0)
	run.current_offer.clear()
	card_applied.emit(player, card)


## The cards for the next level-up (kept while the choice is banked).
func current_offer(player: Player) -> Array[Dictionary]:
	if run.current_offer.is_empty():
		run.current_offer = LevelUpRules.build_offer(player, run.rng.loot)
	return run.current_offer
