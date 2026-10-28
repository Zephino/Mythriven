class_name RunSystems
extends Node
## Builds and connects the run systems added from Phase 10 on, so main.gd
## stays short: the run director (Ages, elites, hazard), enemy projectiles,
## gold and chests, elite health bars, the Age colour shift, the banner, the
## chest reveal, and the pause menu. Created by main.gd for each run.

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


func build(world: WorldRoot, enemies: EnemyManager, spawner: EnemySpawner, level_up: LevelUpScreen,
		death_screen: DeathScreen, hud: Hud) -> void:
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
	for listener: Node in [shots, gold, chests, hazard]:
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
	pause_menu = PauseMenu.new()
	pause_menu.blockers = [level_up, chest_screen, death_screen]
	add_child(pause_menu)
	hud.pause_menu = pause_menu

	director = RunDirector.new()
	director.spawner = spawner
	director.hazard = hazard
	add_child(director)
	if OS.is_debug_build():
		var actions: Node = preload("res://scripts/core/debug_actions_world.gd").new()
		actions.set("systems", self)
		add_child(actions)
