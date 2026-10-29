class_name HeroSelect
extends CanvasLayer
## Hero select (GAME_DESIGN.md: Screens / Hero select): each Hero with their
## tradition, role, stats, Legend Trait, passive, and signature weapon, plus
## their mastery; locked Heroes show how to unlock them. Picking one starts the
## run on the level chosen in level select, with the Omens switched on in the
## Hall of Legends. Color cycles the palettes mastery has unlocked; Back
## returns to the menus. Keyboard, gamepad, and touch all work; the first Hero
## is focused when the screen opens.

signal hero_chosen(hero_id: String)
signal back

var _last_hero: String = ""
var _palette: Button


func _ready() -> void:
	layer = 95
	process_mode = Node.PROCESS_MODE_ALWAYS
	var touch: float = Data.cfg_float("ui.min_touch_target_px")
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var background := ColorRect.new()
	background.color = Color.html(Data.cfg_string("heroes.menu_background"))
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, int(margin_px))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	var title := Label.new()
	title.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	title.text = tr("UI_CHOOSE_HERO") + "  ·  " + run_line()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title)
	var grid := GridContainer.new()
	grid.columns = Data.cfg_int("heroes.select_columns")
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(grid)
	var buttons: Array[Control] = []
	for hero: Dictionary in HeroRules.all():
		var button := Button.new()
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(touch * 4.0, touch * 3.0)
		var id: String = str(hero["id"])
		if HeroRules.is_unlocked(hero):
			button.text = describe(hero) + "\n" + tr("UI_HERO_MASTERY") % Rewards.mastery(id)
			button.pressed.connect(_on_pressed.bind(id))
			button.focus_entered.connect(_remember.bind(id))
		else:
			button.text = TranslationServer.translate(str(hero.get("name_key", ""))) + "\n" + unlock_text(hero)
			button.disabled = true
		grid.add_child(button)
		if not button.disabled:
			buttons.append(button)
	_link_focus(buttons, grid.columns)
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(row)
	var board := Button.new()
	board.text = "UI_LEADERBOARD"
	board.custom_minimum_size = Vector2(touch * 3.0, touch)
	board.pressed.connect(_on_view_board.bind(board))
	row.add_child(board)
	var palette := Button.new()
	_palette = palette
	palette.text = "UI_HERO_COLOR"
	palette.custom_minimum_size = Vector2(touch * 3.0, touch)
	palette.pressed.connect(_on_palette)
	row.add_child(palette)
	var back_button := Button.new()
	back_button.text = "UI_BACK"
	back_button.custom_minimum_size = Vector2(touch * 3.0, touch)
	back_button.pressed.connect(_on_back)
	row.add_child(back_button)
	var suggestion := SuggestionButton.new()
	suggestion.custom_minimum_size = Vector2(touch * 3.0, touch)
	row.add_child(suggestion)
	board.focus_neighbor_right = board.get_path_to(palette)
	palette.focus_neighbor_left = palette.get_path_to(board)
	palette.focus_neighbor_right = palette.get_path_to(back_button)
	back_button.focus_neighbor_left = back_button.get_path_to(palette)
	back_button.focus_neighbor_right = back_button.get_path_to(suggestion)
	suggestion.focus_neighbor_left = suggestion.get_path_to(back_button)
	# Down from the bottom row reaches the Leaderboard button; up or down from it returns to the Heroes.
	for i: int in buttons.size():
		if i + grid.columns >= buttons.size():
			buttons[i].focus_neighbor_bottom = buttons[i].get_path_to(board)
	if not buttons.is_empty():
		board.focus_neighbor_top = board.get_path_to(buttons[0])
		board.focus_neighbor_bottom = board.get_path_to(suggestion)
		suggestion.focus_neighbor_top = suggestion.get_path_to(board)
		suggestion.focus_neighbor_bottom = suggestion.get_path_to(buttons[0])
		buttons[0].grab_focus()


## Every line shown on a Hero's card.
static func describe(hero: Dictionary) -> String:
	var stats: Dictionary = hero.get("stats", {})
	var trait_data: Dictionary = hero.get("trait", {})
	var passive: Dictionary = hero.get("passive", {})
	var weapon: Dictionary = GameAuthority.find_weapon(str(hero.get("signature_weapon", "")))
	var lines: PackedStringArray = [
		TranslationServer.translate(str(hero.get("name_key", ""))),
		TranslationServer.translate("UI_HERO_TRADITION_ROLE") % [
			TranslationServer.translate(str(hero.get("tradition_key", ""))), TranslationServer.translate(str(hero.get("role_key", "")))],
		TranslationServer.translate("UI_HERO_STATS") % [int(stats.get("max_hp", 0)), int(stats.get("move_speed", 0)), int(stats.get("armor", 0))],
		TranslationServer.translate("UI_HERO_WEAPON") % TranslationServer.translate(str(weapon.get("name_key", ""))),
		TranslationServer.translate("UI_HERO_TRAIT") % [
			TranslationServer.translate(str(trait_data.get("name_key", ""))), TranslationServer.translate(str(trait_data.get("desc_key", "")))],
		TranslationServer.translate("UI_HERO_PASSIVE") % [
			TranslationServer.translate(str(passive.get("name_key", ""))), TranslationServer.translate(str(passive.get("desc_key", "")))],
	]
	return "\n".join(lines)


## "Aegean Shore · Swift Mode · Omens: Haste": what the run will be.
static func run_line() -> String:
	var parts: PackedStringArray = [TranslationServer.translate(str(GameAuthority.find_level(Meta.selected_level()).get("name_key", "")))]
	if Meta.swift and LevelRules.swift_unlocked(Meta.selected_level()):
		parts.append(TranslationServer.translate("UI_SWIFT_MODE"))
	var omens: PackedStringArray = []
	for omen: Dictionary in OmenRules.all():
		if OmenRules.active().has(str(omen.get("id", ""))):
			omens.append(TranslationServer.translate(str(omen.get("name_key", ""))))
	if not omens.is_empty():
		parts.append(TranslationServer.translate("UI_OMENS_ACTIVE") % ", ".join(omens))
	return " · ".join(parts)


## How a locked Hero is unlocked.
static func unlock_text(hero: Dictionary) -> String:
	var unlock: Dictionary = hero.get("unlock", {})
	match str(unlock.get("type", "")):
		"gold":
			return TranslationServer.translate("UI_HERO_UNLOCK_GOLD") % int(unlock.get("cost", 0))
		"achievement":
			return TranslationServer.translate("UI_HERO_UNLOCK_ACHIEVEMENT") % TranslationServer.translate(
					"ACH_%s_NAME" % str(unlock.get("achievement", "")).to_upper())
		"defeat_boss":
			return TranslationServer.translate("UI_HERO_UNLOCK_BOSS")
	return TranslationServer.translate("UI_HERO_UNLOCK_SECRET")


func _remember(hero_id: String) -> void:
	_last_hero = hero_id


## Cycles the palette of the Hero last selected (more unlock with mastery).
func _on_palette() -> void:
	if _last_hero == "":
		return
	Rewards.next_palette(_last_hero)
	var index: int = int((SaveGame.setting("palette", {}) as Dictionary).get(_last_hero, 0))
	_palette.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_palette.text = tr("UI_HERO_COLOR_N") % [tr(str(HeroRules.find(_last_hero).get("name_key", ""))), index]


func _on_back() -> void:
	back.emit()
	queue_free()


func _on_view_board(board: Button) -> void:
	var screen := LeaderboardScreen.new()
	screen.closed.connect(board.grab_focus)
	add_child(screen)


func _on_pressed(hero_id: String) -> void:
	hero_chosen.emit(hero_id)
	queue_free()


## Arrow keys / D-pad move around the grid of Heroes.
func _link_focus(buttons: Array[Control], columns: int) -> void:
	var count: int = buttons.size()
	for i: int in count:
		var button: Control = buttons[i]
		button.focus_mode = Control.FOCUS_ALL
		button.focus_neighbor_left = button.get_path_to(buttons[(i - 1 + count) % count])
		button.focus_neighbor_right = button.get_path_to(buttons[(i + 1) % count])
		button.focus_neighbor_top = button.get_path_to(buttons[(i - columns + count) % count])
		button.focus_neighbor_bottom = button.get_path_to(buttons[(i + columns) % count])
