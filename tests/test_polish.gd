extends GutTest
## Phase 19: settings (saved, stepping through values, applied to the game),
## first-run tips (each shown once, can be switched off and reset), the
## colourblind element colours, and the Settings screen.

const TEST_SAVE := "user://test_polish_save.json"


func before_each() -> void:
	SaveGame.use_test_file(TEST_SAVE)


func after_each() -> void:
	GameAuthority.end_scene()
	Settings.apply(get_tree())
	SaveGame.use_test_file("")
	Settings.apply(get_tree())
	for file: String in [TEST_SAVE, TEST_SAVE + ".bak", TEST_SAVE + ".tmp"]:
		DirAccess.remove_absolute(file)


func test_settings_use_config_defaults_until_changed_and_survive_a_restart() -> void:
	assert_eq(Settings.text("shake"), str(Data.cfg("settings.defaults")["shake"]))
	Settings.change("shake", "low")
	Settings.change("damage_numbers", false)
	SaveGame.forget_loaded()
	assert_eq(Settings.text("shake"), "low")
	assert_false(Settings.flag("damage_numbers"))


func test_stepping_cycles_through_choices_and_flips_switches() -> void:
	Settings.change("shake", "off")
	Settings.step("shake")
	assert_eq(Settings.text("shake"), "low")
	Settings.step("shake")
	Settings.step("shake")
	assert_eq(Settings.text("shake"), "off", "wraps back to the first choice")
	Settings.change("volume_pct", 100)
	Settings.step("volume_pct")
	assert_eq(int(Settings.number("volume_pct")), 0)
	var banter: bool = Settings.flag("banter")
	Settings.step("banter")
	assert_eq(Settings.flag("banter"), not banter)


func test_shake_and_flash_strength_follow_the_setting() -> void:
	Settings.change("shake", "off")
	Settings.change("flash", "low")
	assert_eq(Settings.shake_strength(), 0.0)
	assert_almost_eq(Settings.flash_strength(), float(Data.cfg("settings.flash_strength")["low"]), 0.001)


func test_apply_sets_volume_and_text_size() -> void:
	Settings.change("volume_pct", 0)
	Settings.change("text_size_pct", 140)
	Settings.apply(get_tree())
	assert_true(AudioServer.is_bus_mute(0))
	assert_eq(ThemeDB.get_default_theme().default_font_size, roundi(Data.cfg_float("settings.base_font_px") * 1.4))


func test_effect_opacity_fades_player_effects() -> void:
	Settings.change("effect_opacity_pct", 50)
	var layer: Node2D = add_child_autofree(Node2D.new())
	Settings.fade_player_effect(layer)
	assert_almost_eq(layer.modulate.a, 0.5, 0.001)
	Settings.change("effect_opacity_pct", 30)
	Settings.apply(get_tree())
	assert_almost_eq(layer.modulate.a, 0.3, 0.001)


func test_colourblind_setting_swaps_element_colours() -> void:
	var normal: Color = Elements.color("fire")
	Settings.change("colorblind", true)
	assert_ne(Elements.color("fire"), normal)
	assert_eq(Elements.color("fire"), Color.html(str(Elements.element("fire")["colorblind_color"])))
	assert_eq(Elements.tag("fire").length(), 2)


func test_each_first_run_tip_shows_once() -> void:
	var tips: Onboarding = add_child_autofree(Onboarding.new())
	assert_true(tips.show_tip("level_up"))
	assert_false(tips.show_tip("level_up"), "never twice")
	assert_false(tips.show_tip("not_a_tip"))
	Onboarding.reset()
	Settings.change("tips", false)
	assert_false(tips.show_tip("level_up"), "switched off")
	Settings.change("tips", true)
	assert_true(tips.show_tip("level_up"), "shows again after a reset")


func test_auto_summon_and_auto_collect_settings_reach_the_run() -> void:
	Settings.change("auto_collect", "smart")
	GameAuthority.start_run("aegean_shore")
	assert_eq(GameAuthority.auto_collect, "smart")
	Settings.change("auto_summon", true)
	var gods: GodManager = add_child_autofree(GodManager.new())
	assert_true(gods.auto_summon)


func test_settings_screen_rows_all_have_text_and_defaults() -> void:
	for key: String in SettingsScreen.ROWS:
		assert_false(SettingsScreen.value_text(key).begins_with("UI_"), "%s's value has text" % key)
		assert_true((Data.cfg("settings.defaults") as Dictionary).has(key), "%s has a default" % key)
		assert_true(TranslationServer.translate("UI_SETTING_" + key.to_upper()).contains("%s"), "%s has a row label" % key)
