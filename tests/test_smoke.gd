extends GutTest
## Plays the real game scene for a few frames at several points of a run, so
## any script error in the systems working together fails the tests. GUT
## treats an engine error during a test as a failure.

const TEST_PROFILE := "user://test_save_scratch.json"


var _gut_mode: Node.ProcessMode


func before_each() -> void:
	SaveGame.use_test_file(TEST_PROFILE)
	# The game pauses itself (level-ups, chests); the test runner must keep going.
	_gut_mode = gut.process_mode
	gut.process_mode = Node.PROCESS_MODE_ALWAYS


func after_each() -> void:
	gut.process_mode = _gut_mode
	get_tree().paused = false
	GameAuthority.selected_hero_id = ""
	DirAccess.remove_absolute(TEST_PROFILE)
	SaveGame.use_test_file("")


func test_a_run_plays_through_every_age() -> void:
	for hero_id: String in ["heracles", "tomoe_gozen", "king_arthur", "atalanta", "odysseus"]:
		GameAuthority.selected_hero_id = hero_id
		var main: Node = load("res://scenes/main.tscn").instantiate()
		main.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(main)
		await wait_frames(3)
		var run: RunState = GameAuthority.run
		assert_not_null(run)
		var player: Player = GameAuthority.local_player()
		player.god_mode = true
		var gods: GodManager = GameAuthority.gods
		for seconds: float in [0.0, 130.0, 301.0, 620.0, 905.0, 1210.0, 1505.0, 1830.0]:
			run.elapsed_s = seconds
			get_tree().paused = false
			if seconds == 301.0:
				gods.bind(player, "thor")
				gods.bind(player, "sekhmet")
			if seconds >= 620.0:
				for index: int in gods.gods_of(player).size():
					gods.set_meter(player, index, 1.0)
					gods.summon(player, index)
			await wait_frames(20)
		assert_gt(GameAuthority.enemies.active_count(), 0, "enemies spawned")
		main.free()
		await wait_frames(1)


func test_every_level_plays_through_its_bosses() -> void:
	for level: Dictionary in LevelRules.all():
		if str(level["id"]) == "aegean_shore" or bool(level.get("coming_soon", false)):
			continue
		SaveGame.data()["levels"][str(level["id"])] = {"unlocked": true}
		Meta.level_id = str(level["id"])
		GameAuthority.selected_hero_id = "heracles"
		var main: Node = load("res://scenes/main.tscn").instantiate()
		main.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(main)
		await wait_frames(3)
		var run: RunState = GameAuthority.run
		assert_eq(str(run.level_data["id"]), str(level["id"]))
		GameAuthority.local_player().god_mode = true
		for seconds: float in [0.0, 130.0, 301.0, 605.0, 640.0, 1205.0, 1240.0, 1805.0, 1840.0]:
			run.elapsed_s = seconds
			get_tree().paused = false
			await wait_frames(15)
		main.free()
		await wait_frames(1)
	Meta.level_id = ""


func test_back_from_the_hall_after_a_run_returns_to_the_title() -> void:
	# The end screen's Hall of Legends button: after Back there must still be a screen.
	Meta.next_screen = "hall"
	var main: Node = load("res://scenes/main.tscn").instantiate()
	add_child(main)
	await wait_frames(2)
	var hall: HallScreen = main.find_children("*", "HallScreen", true, false)[0]
	hall.close()
	await wait_frames(2)
	var titles: Array[Node] = main.find_children("*", "TitleScreen", true, false)
	assert_eq(titles.size(), 1, "the title screen is still there")
	main.free()
	await wait_frames(1)


func test_the_menus_open_every_page() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	add_child(main)
	await wait_frames(2)
	var title: TitleScreen = main.find_children("*", "TitleScreen", true, false)[0]
	assert_not_null(title)
	var hall := HallScreen.new_for(title.flow)
	title.open_child(hall)
	await wait_frames(1)
	for page: MenuScreen in [OfferingsScreen.new(), UnlocksScreen.new(), OmensScreen.new(), BestiaryScreen.new(), CompendiumScreen.new(),
			HeroesHallScreen.new(), AchievementsScreen.new(), OracleScreen.new(), SettingsScreen.new(), LevelSelectScreen.new_for(title.flow)]:
		hall.open_child(page)
		await wait_frames(1)
		assert_gt(page._rows.get_child_count(), 0, "%s has content" % page.get_script().get_global_name())
		page.close()
	title.flow.choose_level("aegean_shore", false)
	await wait_frames(1)
	assert_eq(main.find_children("*", "HeroSelect", true, false).size(), 1, "level select leads to Hero select")
	main.free()
	await wait_frames(1)


func test_a_run_taken_over_on_another_device_keeps_its_build() -> void:
	GameAuthority.selected_hero_id = "heracles"
	var main: Node = load("res://scenes/main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(main)
	await wait_frames(3)
	var run: RunState = GameAuthority.run
	var player: Player = GameAuthority.local_player()
	player.god_mode = true
	LevelUpRules.apply_effects(player, {"kind": LevelUpRules.PASSIVE_NEW, "id": "belt_of_strength"}, run)
	GameAuthority.gods.bind(player, "thor")
	run.elapsed_s = 700.0
	run.level = 14
	run.gold = 321.0
	run.kills = 999
	run.ropes = 2
	run.poi_state["grove_x"] = "empty"
	GameAuthority.bosses.defeated_indices.append(0)
	player.hp = player.max_hp * 0.5
	var bonus: Dictionary = player.stats.bonus.duplicate()
	var weapons: int = player.weapons.size()
	var seed_was: int = run.seed_value
	# Through the cloud as JSON, like the real thing.
	var snap: Dictionary = JSON.parse_string(JSON.stringify(RunSnapshot.capture()))
	assert_true(RunSnapshot.usable(snap), "the snapshot can be rebuilt")
	assert_string_contains(RunSnapshot.summary(snap), "11:40")
	main.free()
	await wait_frames(1)

	RunSnapshot.prepare(snap)
	main = load("res://scenes/main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(main)
	await wait_frames(3)
	run = GameAuthority.run
	player = GameAuthority.local_player()
	assert_eq(run.seed_value, seed_was, "the same world")
	assert_eq(str(player.hero["id"]), "heracles")
	assert_almost_eq(run.elapsed_s, 700.0, 1.0, "the same time")
	assert_eq(run.level, 14)
	assert_eq(run.kills, 999)
	assert_almost_eq(run.gold, 321.0, 0.01)
	assert_eq(run.ropes, 2)
	assert_eq(run.poi_state.get("grove_x", ""), "empty", "the world remembers what was used")
	assert_eq(int(player.passives.get("belt_of_strength", 0)), 1, "passives carry over")
	assert_eq(player.weapons.size(), weapons, "weapons carry over")
	assert_eq(GameAuthority.gods.bound_ids(player), PackedStringArray(["thor"]), "gods carry over")
	for stat: String in bonus:
		assert_almost_eq(float(player.stats.bonus[stat]), float(bonus[stat]), 0.0001, "%s carries over (not doubled)" % stat)
	assert_almost_eq(player.hp, player.max_hp * 0.5, 1.0, "HP carries over")
	assert_true(GameAuthority.bosses.defeated_indices.has(0), "beaten bosses stay beaten")
	assert_true(Meta.takeover.is_empty(), "used once")
	main.free()
	await wait_frames(1)

