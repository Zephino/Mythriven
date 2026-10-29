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
			HeroesHallScreen.new(), AchievementsScreen.new(), OracleScreen.new(), LevelSelectScreen.new_for(title.flow)]:
		hall.open_child(page)
		await wait_frames(1)
		assert_gt(page._rows.get_child_count(), 0, "%s has content" % page.get_script().get_global_name())
		page.close()
	title.flow.choose_level("aegean_shore", false)
	await wait_frames(1)
	assert_eq(main.find_children("*", "HeroSelect", true, false).size(), 1, "level select leads to Hero select")
	main.free()
	await wait_frames(1)
