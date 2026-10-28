class_name RunSystems
extends Node
## Builds and connects the run systems added from Phase 10 on, so main.gd
## stays short: the run director (Ages, elites, hazard), enemy projectiles,
## gold and chests, elite health bars, the Age colour shift, the banner, the
## chest reveal, and the pause menu; from Phase 11 the gods (shrines,
## trials, summons, god buttons, banter) and the attack pattern library; from
## Phase 13 the bosses, Boons, and the Unraveling; from Phase 14 points of
## interest, the compass, the Wandering Trader, and world events.
## Created by main.gd for each run.

var director: RunDirector
var hazard: HazardStrikes
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
var trial: GodTrial
var god_choice: GodChoiceScreen
var banter: BanterBubble
var god_buttons: GodButtons
var bosses: BossManager
var boss_hud: BossHud
var boons: BoonScreen
var unraveling: Unraveling
var storm: HazardStrikes
var pois: PoiManager
var compass: Compass
var trader: TraderScreen
var ruins_choice: RuinsChoiceScreen


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
	hazard = HazardStrikes.new()
	world.add_child(hazard)
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
	shrines = Shrines.new()
	world.add_child(shrines)
	trial = GodTrial.new()
	trial.shrines = shrines
	trial.patterns = patterns
	trial.spawner = spawner
	world.add_child(trial)
	shrines.trial = trial
	storm = HazardStrikes.new()
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
	add_child(god_buttons)
	pause_menu = PauseMenu.new()
	pause_menu.gods = gods
	pause_menu.blockers = [level_up, chest_screen, death_screen, god_choice, infusion_choice, boons, trader, ruins_choice]
	add_child(pause_menu)
	hud.pause_menu = pause_menu

	director = RunDirector.new()
	director.spawner = spawner
	director.hazard = hazard
	director.storm = storm
	add_child(director)
	if OS.is_debug_build():
		for path: String in ["res://scripts/core/debug_actions_world.gd", "res://scripts/core/debug_actions_gods.gd",
				"res://scripts/core/debug_actions_bosses.gd", "res://scripts/core/debug_actions_discoveries.gd"]:
			var actions: Node = load(path).new()
			actions.set("systems", self)
			add_child(actions)
