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


func test_whole_screen_joystick_starts_anywhere_but_on_a_button() -> void:
	var joystick: TouchJoystick = add_child_autofree(TouchJoystick.new())
	var view: Rect2 = joystick.get_viewport_rect()
	var far_right := Vector2(view.end.x - 20.0, view.get_center().y)
	Settings.change("joystick_side", "anywhere")
	assert_true(joystick._in_joystick_area(far_right), "whole screen")
	Settings.change("joystick_side", "left")
	assert_false(joystick._in_joystick_area(far_right), "left side only")
	Settings.change("joystick_side", "anywhere")
	var button: Button = add_child_autofree(Button.new())
	button.add_to_group(TouchJoystick.BLOCKERS)
	button.position = far_right - Vector2(10, 10)
	button.size = Vector2(20, 20)
	assert_false(joystick._in_joystick_area(far_right), "a touch on a button presses the button")


func test_bosses_go_through_the_release_lore_check() -> void:
	for boss: Variant in Data.get_file("bosses.json"):
		assert_eq(str((boss as Dictionary).get("care_tier", "")), "A", str(boss["id"]))
		assert_true((boss as Dictionary).get("lore_verified") is bool, str(boss["id"]))
	var unverified: Dictionary = {"id": "x", "care_tier": "A", "lore_verified": false}
	assert_eq(ContentGate.filter([unverified], "bosses.json", true)["kept"].size(), 0)


func test_the_aegean_shore_only_spawns_greek_creatures() -> void:
	var waves: Dictionary = Data.get_file("waves_aegean_shore.json")
	var text: String = JSON.stringify(waves)
	for enemy: Variant in Data.get_file("enemies.json"):
		var entry: Dictionary = enemy
		if text.contains('"%s"' % entry["id"]) and not bool(entry.get("boss", false)) and str(entry.get("tradition", "")) != "":
			assert_eq(str(entry["tradition"]), "greek", "%s on the Aegean Shore" % entry["id"])


func test_the_title_screen_always_has_quit() -> void:
	var title: TitleScreen = add_child_autofree(TitleScreen.new_for(null))
	var texts: Array[String] = []
	for button: Control in title._buttons:
		texts.append((button as Button).text)
	assert_has(texts, TranslationServer.translate("UI_QUIT_GAME"))
	title._quit = true
	title.refresh()
	assert_true(title._rows.get_child(0) is Label and (title._rows.get_child(0) as Label).text.contains("close this tab"),
		"in a browser it says the tab can be closed")


func test_suggest_a_feature_is_on_the_title_screen() -> void:
	var title: TitleScreen = add_child_autofree(TitleScreen.new_for(null))
	var texts: Array[String] = []
	for button: Control in title._buttons:
		texts.append((button as Button).text)
	assert_has(texts, TranslationServer.translate("UI_SUGGEST_FEATURE"))


func test_text_boxes_work_as_usual_outside_phone_browsers() -> void:
	assert_false(WebTextInput.needed(), "only a browser on a phone uses the typing pop-up")
	var box: LineEdit = add_child_autofree(LineEdit.new())
	WebTextInput.attach(box)
	assert_eq(box.gui_input.get_connections().size(), 0)


func test_settings_have_fullscreen_and_the_web_apps_install_and_update() -> void:
	SaveGame.use_test_file("user://test_app_actions.json")
	var screen: SettingsScreen = add_child_autofree(SettingsScreen.new())
	var labels: Array[String] = []
	for button: Button in screen.find_children("*", "Button", true, false):
		labels.append(button.text)
	assert_true(labels.any(func(t: String) -> bool: return t.begins_with(tr("UI_FULLSCREEN").split(":")[0])), "Fullscreen on PC and the web")
	assert_eq(labels.has(tr("UI_UPDATE_APP")), AppActions.is_web(), "Install and Update are for the web version")
	assert_eq(AppActions.install_state(), "unavailable", "nothing to install outside a browser")
	SaveGame.use_test_file("")
	DirAccess.remove_absolute("user://test_app_actions.json")


func test_playing_as_shows_only_when_signed_in_with_google() -> void:
	SaveGame.use_test_file("user://test_playing_as.json")
	SaveGame.set_player_name("Zeph")
	var lines := func() -> String:
		var title: TitleScreen = TitleScreen.new_for(null)
		add_child(title)
		var text: String = ""
		for label: Label in title.find_children("*", "Label", true, false):
			text += label.text + "\n"
		title.free()
		return text
	assert_false(lines.call().contains("Zeph"), "not signed in: no username on the title")
	CloudSync.set_code("ABCDEFGHJK23")
	CloudSync.set_account("google", "zeph@example.com")
	if OnlineConfig.cloud_url() != "":
		assert_true(lines.call().contains("Zeph"), "signed in: Playing as Zeph")
	CloudSync.set_account("")
	CloudSync.set_code("")
	DirAccess.remove_absolute(CloudSync.file_path())
	SaveGame.use_test_file("")
	DirAccess.remove_absolute("user://test_playing_as.json")
