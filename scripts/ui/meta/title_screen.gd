class_name TitleScreen
extends MenuScreen
## The title screen (GAME_DESIGN.md: Screens / Title): Play, Hall of Legends,
## Co-op, Leaderboard, Settings, and Quit (on every platform; progress is
## already saved). In a browser the page asks to close its tab; browsers
## usually only allow that for tabs a script opened, so it then says the tab
## can be closed. Shows the banked gold and the version.

var flow: MenuFlow
## True after Quit in a browser (the "you can close this tab" page).
var _quit: bool = false


static func new_for(menu_flow: MenuFlow) -> TitleScreen:
	var screen := TitleScreen.new()
	screen.flow = menu_flow
	return screen


func has_back() -> bool:
	return false


func build() -> void:
	set_title(tr_key("UI_GAME_TITLE"))
	if _quit:
		add_line(tr_key("UI_QUIT_WEB"))
		add_button(tr_key("UI_KEEP_PLAYING"), _on_keep_playing)
		return
	add_button(tr_key("UI_PLAY"), func() -> void: flow.play(self))
	add_button(tr_key("UI_COOP"), func() -> void: open_child(CoopScreen.new_for(flow)))
	add_button(tr_key("UI_HALL_OF_LEGENDS"), func() -> void: open_child(HallScreen.new_for(flow)))
	add_button(tr_key("UI_LEADERBOARD"), func() -> void: open_overlay(LeaderboardScreen.new()))
	add_button(tr_key("UI_SETTINGS"), func() -> void: open_child(SettingsScreen.new()))
	add_button(tr_key("UI_QUIT_GAME"), _on_quit)
	add_line(tr_key("UI_GOLD_BANKED") % SaveGame.gold())
	add_line(tr_key("UI_VERSION_LABEL") % ProjectSettings.get_setting("application/config/version", ""))


func _on_quit() -> void:
	if Net.active():
		Net.leave()
	if not OS.has_feature("web"):
		get_tree().quit()
		return
	JavaScriptBridge.eval("window.close()", true)
	_quit = true
	refresh()


func _on_keep_playing() -> void:
	_quit = false
	refresh()
