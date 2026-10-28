class_name HeroSelect
extends CanvasLayer
## Hero select (GAME_DESIGN.md: Screens / Hero select): each Hero with their
## tradition, role, stats, Legend Trait, passive, and signature weapon. Picking
## one starts the run. The Leaderboard button shows the shared board.
## Keyboard, gamepad, and touch all work; the first Hero is focused when the
## screen opens.

signal hero_chosen(hero_id: String)


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	var touch: float = Data.cfg_float("ui.min_touch_target_px")
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var background := ColorRect.new()
	background.color = Color.html(Data.cfg_string("heroes.select_background"))
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
	title.text = "UI_CHOOSE_HERO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var grid := GridContainer.new()
	grid.columns = Data.cfg_int("heroes.select_columns")
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(grid)
	var buttons: Array[Control] = []
	for hero: Dictionary in HeroRules.unlocked():
		var button := Button.new()
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(touch * 4.0, touch * 3.0)
		button.text = describe(hero)
		button.pressed.connect(_on_pressed.bind(str(hero["id"])))
		grid.add_child(button)
		buttons.append(button)
	_link_focus(buttons, grid.columns)
	var board := Button.new()
	board.text = "UI_LEADERBOARD"
	board.custom_minimum_size = Vector2(touch * 3.0, touch)
	board.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	board.pressed.connect(_on_view_board.bind(board))
	box.add_child(board)
	# Down from the bottom row reaches the Leaderboard button; up or down from it returns to the Heroes.
	for i: int in buttons.size():
		if i + grid.columns >= buttons.size():
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
