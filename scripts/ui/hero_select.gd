class_name HeroSelect
extends CanvasLayer
## Hero select (GAME_DESIGN.md: Screens / Hero select): each Hero with their
## tradition, role, stats, Legend Trait, passive, and signature weapon, plus
## their mastery; locked Heroes show how to unlock them. Picking one starts the
## run on the level chosen in level select, with the Omens switched on in the
## Hall of Legends. Color cycles the palettes mastery has unlocked; Back
## returns to the menus. On phones and small windows the Heroes are a list
## beside the picked one's card, with a big button to play as them. Keyboard, gamepad, and touch all work; the first Hero
## is focused when the screen opens.

signal hero_chosen(hero_id: String)
signal back

var _last_hero: String = ""
var _palette: Button
## The compact (phone) layout's card text and play button.
var _detail: Label
var _play: Button


func _ready() -> void:
	layer = 95
	process_mode = Node.PROCESS_MODE_ALWAYS
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	root.add_child(MenuBackdrop.new())
	# Contents stay clear of phone notches; the backdrop fills the whole screen. The cards sit in a framed panel in
	# the middle (owner decision 10/31/2026: no full-width buttons), never wider than the screen.
	var safe := SafeAreaBox.new()
	root.add_child(safe)
	var middle := HBoxContainer.new()
	middle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, int(margin_px))
	middle.alignment = BoxContainer.ALIGNMENT_CENTER
	safe.add_child(middle)
	var room: float = get_viewport().get_visible_rect().size.x - margin_px * 4.0
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(minf(Data.cfg_float("ui.hero_select_width_px"), room), 0)
	middle.add_child(panel)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := Label.new()
	title.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	title.text = tr("UI_CHOOSE_HERO") + "  ·  " + run_line()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title)
	# Phones and small windows (owner request 10/31/2026): a list of Heroes beside the chosen one's details.
	if room < Data.cfg_float("heroes.compact_below_px"):
		panel.add_child(box)
		_build_compact(box)
		return
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	scroll.add_child(box)
	_build_cards(box)


## The full cards, two to a row: portrait, tradition and role, stats, weapon, Legend Trait, passive, mastery.
func _build_cards(box: VBoxContainer) -> void:
	var touch: float = Data.cfg_float("ui.min_touch_target_px")
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
		# Each Hero's portrait beside their name (owner request 10/31/2026).
		button.icon = UiTheme.portrait(PixelArt.find(id), Data.cfg_int("ui.portrait_scale"))
		button.add_theme_constant_override("icon_max_width", 0)
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
	_bottom_row(box, buttons, grid.columns)


## The compact layout: a scrolling list of Heroes (portrait and name) on the left; the one picked shows its whole
## card on the right, with a big button to play as them.
func _build_compact(box: VBoxContainer) -> void:
	var touch: float = Data.cfg_float("ui.min_touch_target_px")
	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(content)
	var list_scroll := ScrollContainer.new()
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_scroll.custom_minimum_size = Vector2(Data.cfg_float("heroes.compact_list_px"), 0)
	content.add_child(list_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.add_child(list)
	var side := VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(side)
	var detail_scroll := ScrollContainer.new()
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(detail_scroll)
	_detail = Label.new()
	_detail.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.add_child(_detail)
	_play = Button.new()
	_play.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_play.custom_minimum_size = Vector2(0, touch)
	_play.pressed.connect(func() -> void:
		if _last_hero != "":
			_on_pressed(_last_hero))
	side.add_child(_play)
	var buttons: Array[Control] = []
	for hero: Dictionary in HeroRules.all():
		var id: String = str(hero["id"])
		var button := Button.new()
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = TranslationServer.translate(str(hero.get("name_key", "")))
		button.icon = UiTheme.portrait(PixelArt.find(id), Data.cfg_int("heroes.compact_portrait_scale"))
		button.add_theme_constant_override("icon_max_width", 0)
		button.custom_minimum_size = Vector2(0, touch)
		button.pressed.connect(_show.bind(id))
		button.focus_entered.connect(_show.bind(id))
		list.add_child(button)
		buttons.append(button)
	_link_focus(buttons, 1)
	_bottom_row(box, buttons, 1)
	_show(str(HeroRules.all()[0]["id"]) if not HeroRules.all().is_empty() else "")


## Shows a Hero's whole card in the compact layout, and what the big button does.
func _show(hero_id: String) -> void:
	var hero: Dictionary = HeroRules.find(hero_id)
	if hero.is_empty() or _detail == null:
		return
	_remember(hero_id)
	if HeroRules.is_unlocked(hero):
		_detail.text = describe(hero) + "\n" + tr("UI_HERO_MASTERY") % Rewards.mastery(hero_id)
		_play.text = tr("UI_PLAY_AS") % tr(str(hero.get("name_key", "")))
		_play.disabled = false
	else:
		_detail.text = TranslationServer.translate(str(hero.get("name_key", ""))) + "\n" + unlock_text(hero)
		_play.text = tr("UI_HERO_LOCKED")
		_play.disabled = true


## Leaderboard, Color and Back under the Heroes.
func _bottom_row(box: VBoxContainer, buttons: Array[Control], columns: int) -> void:
	var touch: float = Data.cfg_float("ui.min_touch_target_px")
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(row)
	var board := Button.new()
	board.text = "UI_LEADERBOARD"
	board.custom_minimum_size = Vector2(touch * 2.4, touch)
	board.pressed.connect(_on_view_board.bind(board))
	row.add_child(board)
	var palette := Button.new()
	_palette = palette
	palette.text = "UI_HERO_COLOR"
	palette.custom_minimum_size = Vector2(touch * 2.4, touch)
	palette.pressed.connect(_on_palette)
	row.add_child(palette)
	var back_button := Button.new()
	back_button.text = "UI_BACK"
	back_button.custom_minimum_size = Vector2(touch * 2.4, touch)
	back_button.pressed.connect(_on_back)
	row.add_child(back_button)
	board.focus_neighbor_right = board.get_path_to(palette)
	palette.focus_neighbor_left = palette.get_path_to(board)
	palette.focus_neighbor_right = palette.get_path_to(back_button)
	back_button.focus_neighbor_left = back_button.get_path_to(palette)
	# Down from the bottom row reaches the Leaderboard button; up or down from it returns to the Heroes.
	for i: int in buttons.size():
		if i + columns >= buttons.size():
			buttons[i].focus_neighbor_bottom = buttons[i].get_path_to(board)
	if not buttons.is_empty():
		board.focus_neighbor_top = board.get_path_to(buttons[0])
		board.focus_neighbor_bottom = board.get_path_to(buttons[0])
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
