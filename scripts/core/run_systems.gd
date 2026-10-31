class_name RunSystems
extends Node
## Builds and connects the run systems added from Phase 10 on, so main.gd
## stays short: the run director (Ages, elites, hazard), enemy projectiles,
## gold and chests, elite health bars, the Age colour shift, the banner, the
## chest reveal, and the pause menu; from Phase 11 the gods (shrines,
## trials, summons, god buttons, banter) and the attack pattern library; from
## Phase 13 the bosses, Boons, and the Unraveling; from Phase 14 points of
## interest, the compass, the Wandering Trader, and world events; from
## Phase 16 the level's hazard from the hazard library and its ground patches;
## from Phase 19 the first-run tips.
## Created by main.gd for each run.

var director: RunDirector
var hazard: Hazard
var ground_patches: GroundPatches
var shots: EnemyProjectiles
var gold: GoldPickups
var chests: ChestPickups
var elite_bars: EliteBars
var banner: Banner
var chest_screen: ChestScreen
var pause_menu: PauseMenu
var age_visuals: AgeVisuals
var world_tint: CanvasModulate
var patterns: PatternRunner
var gods: GodManager
var summons: ResonanceLayer
var ground: GroundEffects
var resonance: ResonanceManager
var infusion_choice: InfusionChoiceScreen
var shrines: Shrines
var dungeon: ShrineDungeon
var trial: GodTrial
var god_choice: GodChoiceScreen
var banter: BanterBubble
var god_buttons: GodButtons
var bosses: BossManager
var boss_hud: BossHud
var boons: BoonScreen
var unraveling: Unraveling
var storm: HazardStrikes
var onboarding: Onboarding
var pois: PoiManager
var compass: Compass
var trader: TraderScreen
var ruins_choice: RuinsChoiceScreen
## Co-op (Phase 20): the host's CoopHost or a joining player's CoopClient, and level-up turns.
var coop_host: CoopHost
var coop_client: CoopClient
var coop_turns: CoopTurns


func build(world: WorldRoot, enemies: EnemyManager, spawner: EnemySpawner, level_up: LevelUpScreen,
		death_screen: DeathScreen, hud: Hud, orbs: XpOrbs) -> void:
	world_tint = CanvasModulate.new()
	world.add_child(world_tint)
	shots = EnemyProjectiles.new()
	world.add_child(shots)
	shots.setup()
	GameAuthority.enemy_shots = shots
	gold = GoldPickups.new()
	world.add_child(gold)
	gold.setup()
	chests = ChestPickups.new()
	world.add_child(chests)
	chests.setup()
	hazard = Hazard.create(GameAuthority.run.level_data.get("hazard", {}))
	hazard.name = "Hazard"
	world.add_child(hazard)
	var patches: Dictionary = GameAuthority.run.level_data.get("ground_patches", {})
	if not patches.is_empty():
		ground_patches = GroundPatches.new()
		ground_patches.setup(patches)
		world.add_child(ground_patches)
		world.origin_shifted.connect(ground_patches.on_origin_shifted)
	elite_bars = EliteBars.new()
	elite_bars.enemies = enemies
	world.add_child(elite_bars)
	patterns = PatternRunner.new()
	world.add_child(patterns)
	ground = GroundEffects.new()
	world.add_child(ground)
	summons = ResonanceLayer.new()
	summons.orbs = orbs
	summons.gold = gold
	summons.ground = ground
	world.add_child(summons)
	Settings.fade_player_effect(summons)
	shrines = Shrines.new()
	world.add_child(shrines)
	trial = GodTrial.new()
	trial.shrines = shrines
	trial.patterns = patterns
	trial.spawner = spawner
	world.add_child(trial)
	shrines.trial = trial
	storm = HazardStrikes.new()
	storm.name = "Storm"
	world.add_child(storm)
	pois = PoiManager.new()
	pois.spawner = spawner
	pois.chests = chests
	pois.gold = gold
	pois.shrines = shrines
	world.add_child(pois)
	unraveling = Unraveling.new()
	world.add_child(unraveling)
	bosses = BossManager.new()
	bosses.world = world
	bosses.spawner = spawner
	bosses.chests = chests
	bosses.gold = gold
	bosses.unraveling = unraveling
	world.add_child(bosses)
	for listener: Node in [shots, gold, chests, hazard, patterns, summons, shrines, trial, ground, unraveling, bosses, storm, pois]:
		world.origin_shifted.connect(Callable(listener, "on_origin_shifted"))
	GameAuthority.enemy_killed.connect(gold.on_enemy_killed)
	GameAuthority.elite_killed.connect(gold.on_elite_killed)
	GameAuthority.elite_killed.connect(chests.on_elite_killed)

	banner = Banner.new()
	add_child(banner)
	age_visuals = AgeVisuals.new()
	age_visuals.world_tint = world_tint
	add_child(age_visuals)
	chest_screen = ChestScreen.new()
	add_child(chest_screen)
	chests.reveal = chest_screen
	banter = BanterBubble.new()
	add_child(banter)
	gods = GodManager.new()
	gods.summons = summons
	gods.banter = banter
	gods.ground = ground
	gods.gold = gold
	add_child(gods)
	resonance = ResonanceManager.new()
	resonance.gods = gods
	resonance.layer = summons
	resonance.banter = banter
	add_child(resonance)
	gods.resonance = resonance
	infusion_choice = InfusionChoiceScreen.new()
	add_child(infusion_choice)
	chest_screen.infusion_choice = infusion_choice
	shrines.gods = gods
	# Shrines lead into dungeons; while the party is inside, the run outside stops (owner decision 10/31/2026).
	dungeon = ShrineDungeon.new()
	dungeon.shrines = shrines
	dungeon.trial = trial
	# Enemies keep moving (the ones outside sleep) so monsters can come at the party inside.
	dungeon.freeze.assign([spawner, hazard, ground_patches, patterns, ground, summons, shrines, trial, storm, pois,
			unraveling, bosses])
	world.add_child(dungeon)
	world.origin_shifted.connect(dungeon.on_origin_shifted)
	shrines.dungeon = dungeon
	shrines.banter = banter
	god_choice = GodChoiceScreen.new()
	god_choice.gods = gods
	add_child(god_choice)
	shrines.choice = god_choice
	god_buttons = GodButtons.new()
	god_buttons.gods = gods
	god_buttons.resonance = resonance
	boons = BoonScreen.new()
	add_child(boons)
	bosses.boons = boons
	bosses.banter = banter
	trader = TraderScreen.new()
	trader.gods = gods
	add_child(trader)
	pois.trader = trader
	ruins_choice = RuinsChoiceScreen.new()
	add_child(ruins_choice)
	pois.ruins_choice = ruins_choice
	compass = Compass.new()
	compass.pois = pois
	add_child(compass)
	boss_hud = BossHud.new()
	boss_hud.bosses = bosses
	add_child(boss_hud)
	var boss_pointer := BossPointer.new()
	boss_pointer.bosses = bosses
	add_child(boss_pointer)
	add_child(god_buttons)
	pause_menu = PauseMenu.new()
	pause_menu.gods = gods
	pause_menu.blockers = [level_up, chest_screen, death_screen, god_choice, infusion_choice, boons, trader, ruins_choice]
	add_child(pause_menu)
	hud.pause_menu = pause_menu
	onboarding = Onboarding.new()
	onboarding.banner = banner
	onboarding.gods = gods
	onboarding.resonance = resonance
	onboarding.shrines = shrines
	add_child(onboarding)

	director = RunDirector.new()
	director.spawner = spawner
	director.hazard = hazard
	director.storm = storm
	add_child(director)
	if Net.in_run():
		_build_coop(world, enemies, spawner, level_up)
	else:
		# Invite friends (pause menu): the solo run can go online later.
		Net.went_online.connect(func() -> void: _build_coop(world, enemies, spawner, level_up), CONNECT_ONE_SHOT)
	if OS.is_debug_build():
		for path: String in ["res://scripts/core/debug_actions_world.gd", "res://scripts/core/debug_actions_gods.gd",
				"res://scripts/core/debug_actions_bosses.gd", "res://scripts/core/debug_actions_discoveries.gd"]:
			var actions: Node = load(path).new()
			actions.set("systems", self)
			add_child(actions)


## Co-op: on the host, CoopHost sends everyone the game; on a joining
## player's device, CoopClient shows it and the systems that decide things
## (spawning, the director) are switched off.
func _build_coop(world: WorldRoot, enemies: EnemyManager, spawner: EnemySpawner, level_up: LevelUpScreen) -> void:
	if coop_host != null or coop_client != null or not is_inside_tree():
		return
	add_child(CoopRevives.new())
	add_child(CoopTether.new())
	coop_turns = CoopTurns.new()
	coop_turns.level_up = level_up
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if Net.is_host():
		coop_host = CoopHost.new()
		coop_host.world = world
		coop_host.enemies = enemies
		coop_host.gods = gods
		coop_host.turns = coop_turns
		coop_host.effects = effects
		coop_host.banner = banner
		coop_host.banter = banter
		coop_host.gold = gold
		coop_host.heals = get_tree().get_first_node_in_group("heal_pickups") as HealPickups
		coop_turns.host = coop_host
		add_child(coop_host)
		# Players may join during the run (public and friend games).
		var late_join := CoopLateJoin.new()
		late_join.host = coop_host
		add_child(late_join)
	else:
		spawner.process_mode = Node.PROCESS_MODE_DISABLED
		director.process_mode = Node.PROCESS_MODE_DISABLED
		coop_client = CoopClient.new()
		coop_client.world = world
		coop_client.enemies = enemies
		coop_client.gods = gods
		coop_client.turns = coop_turns
		coop_client.effects = effects
		coop_client.summons = summons
		coop_client.numbers = get_tree().get_first_node_in_group("damage_numbers") as DamageNumbers
		add_child(coop_client)
	add_child(coop_turns)
