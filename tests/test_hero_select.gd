extends GutTest
## Hero select's Color button shows only for a Hero who has unlocked another colour by playing as them (owner
## request 11/03/2026: it shouldn't show up until the player can change the colour).

const TEST_SAVE := "user://test_hero_select_save.json"


func before_each() -> void:
	SaveGame.use_test_file(TEST_SAVE)


func test_the_color_button_appears_only_once_a_hero_has_unlocked_a_colour() -> void:
	var select: HeroSelect = add_child_autofree(HeroSelect.new())
	await wait_process_frames(1)
	select._remember("heracles")
	assert_false(select._palette.visible, "no colour unlocked yet: no Color button")
	var first_step: float = float((Data.cfg("heroes.mastery_minutes") as Array)[0])
	(SaveGame.data()["mastery"] as Dictionary)["heracles"] = (first_step + 1.0) * 60.0
	select._remember("heracles")
	assert_true(select._palette.visible, "after enough time as Heracles, the Color button shows")
	select._remember("cu_chulainn")
	assert_false(select._palette.visible, "but not for a Hero who hasn't unlocked one")


func test_there_is_no_leaderboard_button_and_back_is_on_the_left() -> void:
	var select: HeroSelect = add_child_autofree(HeroSelect.new())
	await wait_process_frames(1)
	var row: Node = select._palette.get_parent()
	assert_eq((row.get_child(0) as Button).text, "UI_BACK", "Back comes first, on the left")
	for button: Node in row.get_children():
		assert_ne((button as Button).text, "UI_LEADERBOARD", "no Leaderboard button on Hero select")


func test_a_boss_unlock_names_the_boss_and_where_it_is_fought() -> void:
	var text: String = HeroSelect.unlock_text(HeroRules.find("rostam"))
	assert_string_contains(text, tr("BOSS_WHITE_DIV_NAME"), "Rostam's unlock names the White Div")
	assert_string_contains(text, tr("LEVEL_MAZANDARAN_NAME"), "and Mazandaran")
