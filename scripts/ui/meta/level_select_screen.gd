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


func build() -> void:
	set_title(tr_key("UI_LEVEL_SELECT"))
	for level: Dictionary in LevelRules.all():
		var id: String = str(level.get("id", ""))
		var name: String = tr_key(str(level.get("name_key", id)))
		if not LevelRules.is_unlocked(level):
			add_button(tr_key("UI_LEVEL_LOCKED") % name, func() -> void: pass, false)
			continue
		var gods: PackedStringArray = []
		for god_id: Variant in level.get("local_gods", []):
			gods.append(tr_key(str(GodRules.find(str(god_id)).get("name_key", god_id))))
		var swift: bool = bool(_swift.get(id, false))
		var lines: PackedStringArray = [name + (" · " + tr_key("UI_SWIFT_MODE") if swift else ""),
			tr_key("UI_LEVEL_DETAILS") % [_best_time(id, swift), LevelRules.bosses_defeated(id).size(), ", ".join(gods)]]
		add_button("\n".join(lines), flow.choose_level.bind(id, swift))
		if LevelRules.swift_unlocked(id):
			add_button(tr_key("UI_SWIFT_ON") if swift else tr_key("UI_SWIFT_OFF"), _toggle_swift.bind(id))


## The best time on a level with any Hero ("—" when never played).
func _best_time(level_id: String, swift: bool) -> String:
	var best: float = 0.0
	for hero: Dictionary in HeroRules.all():
		best = maxf(best, Records.best(str(hero.get("id", "")), level_id, swift))
	return TextFormat.run_time(best) if best > 0.0 else tr_key("UI_NONE_YET")


func _toggle_swift(level_id: String) -> void:
	_swift[level_id] = not bool(_swift.get(level_id, false))
	refresh()
