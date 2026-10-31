class_name LevelSelectScreen
extends MenuScreen
## Level select (GAME_DESIGN.md: Regional levels / Unlock flow): each level
## with its best time, bosses defeated, and local gods; locked levels say how
## to open them. Swift Mode can be switched on for a level whose 30:00 boss
## you've beaten.

var flow: MenuFlow
var _swift: Dictionary = {}


static func new_for(menu_flow: MenuFlow) -> LevelSelectScreen:
	var screen := LevelSelectScreen.new()
	screen.flow = menu_flow
	return screen


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


## Each level is a card (owner decision 10/31/2026: item cards): its best time, bosses beaten and local gods, a Play
## button, and Swift Mode beside it once unlocked. Locked levels are greyed, saying how to open them.
func build() -> void:
	set_title(tr_key("UI_LEVEL_SELECT"))
	for level: Dictionary in LevelRules.all():
		var id: String = str(level.get("id", ""))
		var name: String = tr_key(str(level.get("name_key", id)))
		var gods: PackedStringArray = []
		for god_id: Variant in level.get("local_gods", []):
			gods.append(tr_key(str(GodRules.find(str(god_id)).get("name_key", god_id))))
		# The level's first local god, as a dark shape until met.
		var first_god: String = str((level.get("local_gods", [""]) as Array).front()) if not (level.get("local_gods", []) as Array).is_empty() else ""
		var face: Texture2D = UiTheme.god_face(first_god, 1) if first_god != "" else null
		var unmet: bool = first_god == "" or not GodLevels.bound_ever(first_god)
		if not LevelRules.is_unlocked(level):
			add_card(face, name, [tr_key("LEVEL_LOCKED_HOW")], "", "", Callable(), true, true, true)
			continue
		var swift: bool = bool(_swift.get(id, false))
		var card: PanelContainer = add_card(face, name, [
			tr_key("LEVEL_BEST") % _best_time(id, swift) + "  ·  " + tr_key("LEVEL_BOSSES") % LevelRules.bosses_defeated(id).size(),
			tr_key("LEVEL_GODS") % ", ".join(gods),
		], tr_key("UI_SWIFT_MODE") if swift else "", tr_key("LEVEL_PLAY"), flow.choose_level.bind(id, swift), true, false, unmet)
		if LevelRules.swift_unlocked(id):
			add_card_button(card, tr_key("LEVEL_SWIFT_ON") if swift else tr_key("LEVEL_SWIFT_OFF"), _toggle_swift.bind(id))


## The best time on a level with any Hero ("—" when never played).
func _best_time(level_id: String, swift: bool) -> String:
	var best: float = 0.0
	for hero: Dictionary in HeroRules.all():
		best = maxf(best, Records.best(str(hero.get("id", "")), level_id, swift))
	return TextFormat.run_time(best) if best > 0.0 else tr_key("UI_NONE_YET")


func _toggle_swift(level_id: String) -> void:
	_swift[level_id] = not bool(_swift.get(level_id, false))
	refresh()
