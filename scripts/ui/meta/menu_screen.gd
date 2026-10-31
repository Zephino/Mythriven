class_name MenuScreen
extends CanvasLayer
## Base for the full-screen menus outside a run (Phase 15): the title, the
## Hall of Legends and its pages, and level select. Over the session's painted
## backdrop (MenuBackdrop), a narrow framed column in the middle of the screen
## (owner decision 10/31/2026: no full-width buttons) holds a title bar with a
## Back button, then a scrolling list of lines and buttons that each page fills
## in build(); the title screen also shows the logo above it. Keyboard,
## gamepad, and touch all work: arrow keys / D-pad move between buttons, Esc /
## B goes back, and the first button is focused.

signal closed

var _rows: VBoxContainer
var _back: Button
var _title: Label
var _buttons: Array[Control] = []
var _column: PanelContainer
var _corners: HBoxContainer


func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	var touch: float = Data.cfg_float("ui.min_touch_target_px")
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var backdrop := MenuBackdrop.new()
	backdrop.show_heroes = shows_heroes()
	root.add_child(backdrop)
	# Contents stay clear of phone notches; the backdrop fills the whole screen.
	var safe := SafeAreaBox.new()
	root.add_child(safe)
	var outer := VBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, int(margin_px))
	safe.add_child(outer)
	if shows_logo():
		var logo := TextureRect.new()
		var art: Dictionary = PixelArt.find("menu/logo")
		if not art.is_empty():
			logo.texture = PixelArt.frame(art, false, 0.0)
		logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.custom_minimum_size = Vector2(0, Data.cfg_float("ui.menu_logo_px"))
		outer.add_child(logo)
	# The narrow column in the middle.
	var middle := HBoxContainer.new()
	middle.alignment = BoxContainer.ALIGNMENT_CENTER
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(middle)
	var column := PanelContainer.new()
	column.custom_minimum_size = Vector2(Data.cfg_float("ui.menu_column_px"), 0)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL if not shows_logo() else Control.SIZE_SHRINK_CENTER
	middle.add_child(column)
	_column = column
	var box := VBoxContainer.new()
	column.add_child(box)
	_corners = HBoxContainer.new()
	outer.add_child(_corners)
	var top := HBoxContainer.new()
	top.visible = not shows_logo()            # the title screen has the logo instead of a title bar
	box.add_child(top)
	_title = Label.new()
	_title.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_title)
	_back = Button.new()
	_back.text = "UI_BACK"
	_back.custom_minimum_size = Vector2(touch * 2.0, touch)
	_back.pressed.connect(close)
	_back.visible = has_back()
	top.add_child(_back)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if shows_logo():
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_rows)
	refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and has_back() and is_top():
		get_viewport().set_input_as_handled()
		close()


## False for screens with no way back (the title).
func has_back() -> bool:
	return true


## The title screen shows the logo above its column, and the Heroes on the backdrop.
func shows_logo() -> bool:
	return false


func shows_heroes() -> bool:
	return false


## Small text in the bottom corners of the screen, outside the column (gold, the version).
func set_corners(left: String, right: String) -> void:
	for child: Node in _corners.get_children():
		child.queue_free()
	for k: int in 2:
		var label := Label.new()
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		label.text = left if k == 0 else right
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if k == 0 else HORIZONTAL_ALIGNMENT_RIGHT
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		label.add_theme_constant_override("outline_size", 4)
		_corners.add_child(label)


## True when no other menu is open on top of this one.
func is_top() -> bool:
	for child: Node in get_children():
		if child is CanvasLayer and (child as CanvasLayer).visible:
			return false
	return true


## Rebuilds the page (after a purchase or a toggle).
func refresh() -> void:
	for child: Node in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	_buttons.clear()
	if _back.visible:
		_buttons.append(_back)
	build()
	_link_focus()


## Pages fill themselves in here with set_title, add_line, and add_button.
func build() -> void:
	pass


func set_title(text: String) -> void:
	_title.text = text


## A centred row of pictures (the Heroes on the title screen).
func add_pictures(textures: Array[Texture2D]) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for texture: Texture2D in textures:
		var picture := TextureRect.new()
		picture.texture = texture
		picture.stretch_mode = TextureRect.STRETCH_KEEP
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		row.add_child(picture)
	_rows.add_child(row)
	return row


func add_line(text: String) -> Label:
	var row := Label.new()
	row.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.text = text
	_rows.add_child(row)
	return row


func add_button(text: String, on_pressed: Callable, enabled: bool = true) -> Button:
	var button := Button.new()
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.text = text
	button.disabled = not enabled
	button.custom_minimum_size = Vector2(0, Data.cfg_float("ui.menu_button_px"))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(on_pressed)
	_rows.add_child(button)
	_buttons.append(button)
	return button


## A text box (for example a code to type). Part of the focus order.
## `question` is what a phone browser's typing pop-up asks (see WebTextInput).
func add_input(placeholder: String, max_length: int, question: String = "") -> LineEdit:
	var input := LineEdit.new()
	input.placeholder_text = placeholder
	input.max_length = max_length
	input.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 5.0, Data.cfg_float("ui.min_touch_target_px"))
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.virtual_keyboard_enabled = true
	WebTextInput.attach(input, question)
	_rows.add_child(input)
	_buttons.append(input)
	return input


## Opens another menu on top of this one; focus comes back when it closes.
func open_child(screen: MenuScreen) -> void:
	screen.closed.connect(_on_child_closed)
	add_child(screen)
	screen.layer = layer + 1


## Opens one of the run's own screens on top (the Codex, the leaderboard),
## which close themselves and emit `closed`.
func open_overlay(screen: CanvasLayer) -> void:
	screen.connect("closed", _on_child_closed)
	add_child(screen)
	screen.layer = layer + 5


func close() -> void:
	closed.emit()
	queue_free()


func _on_child_closed() -> void:
	refresh()


func tr_key(key: String) -> String:
	return TranslationServer.translate(key)


func _link_focus() -> void:
	var count: int = _buttons.size()
	for i: int in count:
		_buttons[i].focus_neighbor_top = _buttons[i].get_path_to(_buttons[(i - 1 + count) % count])
		_buttons[i].focus_neighbor_bottom = _buttons[i].get_path_to(_buttons[(i + 1) % count])
	# Start on the first enabled button (not a text box, which would pop up the keyboard).
	for button: Control in _buttons:
		if button != _back and button is Button and not (button as Button).disabled:
			focus_later(button)
			return
	if count > 0:
		focus_later(_buttons[0])


## Focuses `control` once the page is built (if it's still on screen by then).
func focus_later(control: Control) -> void:
	_focus_now.call_deferred(control)


## Untyped: the button may have been freed by a refresh before this runs.
func _focus_now(control: Variant) -> void:
	if is_instance_valid(control) and (control as Control).is_inside_tree():
		(control as Control).grab_focus()
