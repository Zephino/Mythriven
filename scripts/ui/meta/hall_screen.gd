class_name HallScreen
extends MenuScreen
## The Hall of Legends (GAME_DESIGN.md: Screens / Hall of Legends; World and
## tone): a place outside time where fallen Heroes rest and offerings are made.
## Begin a Last Stand, Offerings, Unlocks, Omens, Bestiary, Pantheon
## Compendium, Hall of Heroes, Codex, Achievements, and the Oracle.

var flow: MenuFlow


static func new_for(menu_flow: MenuFlow) -> HallScreen:
	var screen := HallScreen.new()
	screen.flow = menu_flow
	return screen


func build() -> void:
	set_title(tr_key("UI_HALL_OF_LEGENDS") + "  ·  " + tr_key("UI_GOLD_BANKED") % SaveGame.gold())
	add_button(tr_key("UI_BEGIN_LAST_STAND"), func() -> void: flow.play(self))
	add_button(tr_key("UI_OFFERINGS"), func() -> void: open_child(OfferingsScreen.new()))
	add_button(tr_key("UI_UNLOCKS"), func() -> void: open_child(UnlocksScreen.new()))
	add_button(tr_key("UI_OMENS") if OmenRules.unlocked() else tr_key("UI_OMENS_LOCKED"), func() -> void: open_child(OmensScreen.new()),
			OmenRules.unlocked())
	add_button(tr_key("UI_BESTIARY"), func() -> void: open_child(BestiaryScreen.new()))
	add_button(tr_key("UI_COMPENDIUM"), func() -> void: open_child(CompendiumScreen.new()))
	add_button(tr_key("UI_HALL_OF_HEROES"), func() -> void: open_child(HeroesHallScreen.new()))
	add_button(tr_key("UI_CODEX"), func() -> void: open_overlay(CodexScreen.new()))
	add_button(tr_key("UI_ACHIEVEMENTS"), func() -> void: open_child(AchievementsScreen.new()))
	add_button(tr_key("UI_ORACLE"), func() -> void: open_child(OracleScreen.new()))
