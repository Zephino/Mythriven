class_name TitleScreen
extends MenuScreen
## The title screen (GAME_DESIGN.md: Screens / Title): Play, Hall of Legends,
## Leaderboard, and Quit (PC). Co-op arrives with Phase 20 and Settings with
## Phase 19. Shows the banked gold and the version.

var flow: MenuFlow


static func new_for(menu_flow: MenuFlow) -> TitleScreen:
	var screen := TitleScreen.new()
	screen.flow = menu_flow
	return screen


func has_back() -> bool:
	return false


func build() -> void:
	set_title(tr_key("UI_GAME_TITLE"))
	add_button(tr_key("UI_PLAY"), func() -> void: flow.play(self))
	add_button(tr_key("UI_HALL_OF_LEGENDS"), func() -> void: open_child(HallScreen.new_for(flow)))
	add_button(tr_key("UI_LEADERBOARD"), func() -> void: open_overlay(LeaderboardScreen.new()))
	if OS.has_feature("pc") and not OS.has_feature("web"):
		add_button(tr_key("UI_QUIT_GAME"), func() -> void: get_tree().quit())
	add_line(tr_key("UI_GOLD_BANKED") % SaveGame.gold())
	add_line(tr_key("UI_VERSION_LABEL") % ProjectSettings.get_setting("application/config/version", ""))
