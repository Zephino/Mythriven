class_name HallScreen
extends MenuScreen
## The Hall of Legends (GAME_DESIGN.md: Screens / Hall of Legends; World and
## tone): a place outside time where fallen Heroes rest and offerings are made.
## Three tabs (owner decision 10/31/2026), each page opening inside the Hall so you can flick between them:
## Progress (Offerings, Unlocks, Omens), Lore (Bestiary, Pantheon Compendium, Hall of Heroes, Codex) and
## Records (Achievements, the Oracle, the Leaderboard); and Begin a Last Stand beside the tabs.

## [tab name key, [[page name key, page id], ...]].
const TABS := [
	["UI_HALL_PROGRESS", [["UI_OFFERINGS", "offerings"], ["UI_UNLOCKS", "unlocks"], ["UI_OMENS", "omens"]]],
	["UI_HALL_LORE", [["UI_BESTIARY", "bestiary"], ["UI_COMPENDIUM_SHORT", "compendium"], ["UI_HALL_OF_HEROES", "heroes"], ["UI_CODEX", "codex"]]],
	["UI_HALL_RECORDS", [["UI_ACHIEVEMENTS", "achievements"], ["UI_ORACLE", "oracle"], ["UI_LEADERBOARD", "leaderboard"]]],
]

## The tab and page open last, so the Hall opens where it was left (this session).
static var _tab: int = 0
static var _page_of: Array[int] = [0, 0, 0]

var flow: MenuFlow
## Pages made so far (kept, so each remembers what was chosen on it).
var _pages: Dictionary = {}


static func new_for(menu_flow: MenuFlow) -> HallScreen:
	var screen := HallScreen.new()
	screen.flow = menu_flow
	return screen


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	set_title(tr_key("UI_HALL_OF_LEGENDS") + "  ·  " + tr_key("UI_GOLD_BANKED") % SaveGame.gold())
	var names := PackedStringArray()
	for tab: Array in TABS:
		names.append(tr_key(str(tab[0])))
	# The three tabs in the title bar, with Begin a Last Stand beside them; the gold in the corner.
	var row: HBoxContainer = add_tabs(names, _tab, func(index: int) -> void:
		_tab = index
		refresh(), [], true)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var begin := Button.new()
	begin.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	begin.text = tr_key("UI_BEGIN_LAST_STAND")
	begin.custom_minimum_size = Vector2(0, Data.cfg_float("ui.min_touch_target_px"))
	begin.pressed.connect(func() -> void: flow.play(self))
	_top_slot.add_child(begin)
	_buttons.append(begin)
	set_corners(tr_key("UI_GOLD_BANKED") % SaveGame.gold(), "")
	var pages: Array = TABS[_tab][1]
	var page_names := PackedStringArray()
	var enabled: Array = []
	for entry: Array in pages:
		page_names.append(tr_key(str(entry[0])))
		enabled.append(str(entry[1]) != "omens" or OmenRules.unlocked())
	add_tabs(page_names, _page_of[_tab], func(index: int) -> void:
		var id: String = str(pages[index][1])
		# The Codex and the Leaderboard are the run's own full screens: they open over the Hall.
		if id == "codex":
			open_overlay(CodexScreen.new())
		elif id == "leaderboard":
			open_overlay(LeaderboardScreen.new())
		else:
			_page_of[_tab] = index
			refresh(), enabled)
	var index: int = _page_of[_tab]
	if not bool(enabled[index]) or ["codex", "leaderboard"].has(str(pages[index][1])):
		index = 0
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 4)
	_rows.add_child(box)
	var page: MenuScreen = _page(str(pages[index][1]))
	page.embed(self, box)
	page.build()


func _page(id: String) -> MenuScreen:
	if not _pages.has(id):
		var page: MenuScreen
		match id:
			"offerings": page = OfferingsScreen.new()
			"unlocks": page = UnlocksScreen.new()
			"omens": page = OmensScreen.new()
			"bestiary": page = BestiaryScreen.new()
			"compendium": page = CompendiumScreen.new()
			"heroes": page = HeroesHallScreen.new()
			"achievements": page = AchievementsScreen.new()
			_: page = OracleScreen.new()
		_pages[id] = page
	return _pages[id]


func _exit_tree() -> void:
	for page: Variant in _pages.values():
		if is_instance_valid(page):
			(page as Node).free()
	_pages.clear()
