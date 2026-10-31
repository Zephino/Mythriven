extends Node
## Autoload "GameAuthority". Every game event (spawns, damage, drops, deaths,
## god binding) goes through here, so co-op can later run them only on the
## host (GAME_DESIGN.md: Multiplayer-ready from day one).
## Players are always a list, never a single global player.
## In a co-op run (Phase 20) the host's game decides everything: on a joining
## player's device (Net.is_client()) damage, kills, spawns, XP, and gold only
## happen when the host says so (CoopClient sets `replicating` while it applies
## the host's messages).

signal run_started(run: RunState)
signal player_spawned(player: Player)
signal player_removed(player: Player)
signal player_damaged(player: Player, amount: float, source_id: String)
signal player_died(player: Player, cause_id: String)
signal run_ended(run: RunState)
## kind: "normal", "crit", "weak", "resist", or "dot" (damage over time).
signal enemy_damaged(slot: int, amount: float, kind: String, at: Vector2, element: String)
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
## A weapon attacked (Thor's meter counts attacks made).
signal weapon_fired(player: Player, weapon: WeaponInstance)
## A game effect moved a player (a pull, a swap, the arena's edge): in co-op
## a joining player's Hero is moved on their own device too (CoopHost).
signal player_pushed(player: Player, offset: Vector2)
## Gods (Phase 11) and bosses (Phase 13): set by RunSystems; null between runs.
var gods: GodManager = null
var bosses: BossManager = null
## The seed for the next run only (a run taken over from another device, RunSnapshot); 0 = none.
var next_seed: int = 0

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
## True while CoopClient applies something the host decided.
var replicating: bool = false


## False on a joining player's device unless the host's message is being applied.
func decides() -> bool:
	return replicating or not Net.is_client()


func _process(delta: float) -> void:
	# The clock stops while the party is in a shrine's dungeon (ShrineDungeon).
	if run != null and not run.ended and not bool(run.get_meta("frozen", false)):
		run.elapsed_s += delta


## Starts a new run on a level. Uses config run.fixed_seed, or a random seed when it is 0.
func start_run(level_id: String) -> RunState:
	auto_collect = Settings.text("auto_collect")
	players.clear()
	enemies = null
	enemy_shots = null
	gods = null
	bosses = null
	var run_seed: int = Net.run_seed if Net.in_run() else Data.cfg_int("run.fixed_seed")
	if next_seed != 0 and not Net.in_run():
		run_seed = next_seed
	next_seed = 0
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
	gods = null


func find_level(level_id: String) -> Dictionary:
	return _find_in(LEVELS_FILE, level_id, "level")


## Creates a player, adds it under `parent`, and registers it in the list.
func spawn_player(parent: Node, spawn_position: Vector2, input: PlayerInput, is_local: bool,
		hero_id: String = "", id: int = -1) -> Player:
	var player := Player.new()
	player.hero = HeroRules.find(hero_id) if hero_id != "" else {}
	player.player_id = id if id >= 0 else _next_player_id()
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


## The player with this id (co-op ids match Net's), or null.
func player_by_id(id: int) -> Player:
	for player: Player in players:
		if player.player_id == id:
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
	if enemies == null or not decides():
		return -1
	return enemies.spawn(type_id, at)


## Damages a player (enemy damage − Armor, minimum 1; see PlayerHealth).
## `from` is where the hit came from (Vector2.INF when unknown).
func damage_player(player: Player, amount: float, source_id: String, from: Vector2 = Vector2.INF) -> void:
	PlayerHealth.damage(player, amount, source_id, from)


## Burn and Poison on a player: skips Armor.
func damage_player_over_time(player: Player, amount: float) -> void:
	PlayerHealth.damage_over_time(player, amount)


## From 30:00, an enemy touching a player can pass on its element's status.
func status_player_from_enemy(player: Player, element: String) -> void:
	PlayerHealth.status_from_enemy(player, element)


func heal_player(player: Player, amount: float) -> void:
	PlayerHealth.heal(player, amount)


## Moves a player by `offset` because of something in the game (not their own steering).
func push_player(player: Player, offset: Vector2) -> void:
	if offset == Vector2.ZERO:
		return
	player.position += offset
	if not player.is_local:
		player_pushed.emit(player, offset)


func place_player(player: Player, at: Vector2) -> void:
	push_player(player, at - player.position)


## The run ends when no player is still fighting (all fallen, downed, or Shades).
func check_run_over() -> void:
	for other: Player in players:
		if other.alive:
			return
	if run != null and not run.ended:
		run.ended = true
		run_ended.emit(run)



## Damages an enemy: damage formula, weakness/resistance, statuses, and
## reactions. `status_chance` is the chance (0–1) to apply the element's status.
## `weapon` is the weapon that hit (null for traits, summons, and hazards).
func damage_enemy(slot: int, base_damage: float, attacker: Player, push: Vector2, element: String,
		status_chance: float = 0.0, weapon: WeaponInstance = null) -> void:
	if not decides():
		return
	hits.hit(slot, base_damage, attacker, push, element, status_chance, true, weapon)


## An enemy dies: counts the kill, tells listeners (XP drops), frees the slot.
func kill_enemy(slot: int, killer: Player) -> void:
	if enemies == null or enemies.active[slot] == 0 or not decides():
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
	if run == null or run.ended or not decides():
		return
	if player != null:
		amount *= player.gold_mult
	run.gold += amount
	gold_collected.emit(player, amount)


func find_weapon(weapon_id: String) -> Dictionary:
	return _find_in(WEAPONS_FILE, weapon_id, "weapon")


## The entry with `id` in a list file (an error names it if it's missing).
static func _find_in(file: String, id: String, what: String) -> Dictionary:
	var listed: Variant = Data.get_file(file)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary and (entry as Dictionary).get("id", "") == id:
			return entry
	push_error("GameAuthority: %s '%s' not found in %s" % [what, id, file])
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
	if run == null or run.ended or not decides():
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


## Applies a level-up card to a player and uses up one level-up (in co-op,
## CoopTurns uses one up only after every player has picked: `use_level_up` false).
func apply_card(player: Player, card: Dictionary, use_level_up: bool = true) -> void:
	LevelUpRules.apply_effects(player, card, run)
	player.refresh_stats()
	if use_level_up:
		run.unspent_level_ups = maxi(run.unspent_level_ups - 1, 0)
		run.current_offer.clear()
	card_applied.emit(player, card)


## The cards for the next level-up (kept while the choice is banked).
func current_offer(player: Player) -> Array[Dictionary]:
	if run.current_offer.is_empty():
		run.current_offer = LevelUpRules.build_offer(player, run.rng.loot)
	return run.current_offer
