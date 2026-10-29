class_name MenuScreen
extends CanvasLayer
## Base for the full-screen menus outside a run (Phase 15): the title, the
## Hall of Legends and its pages, and level select. A title bar with a Back
## button, then a scrolling list of lines and buttons that each page fills in
## build(). Keyboard, gamepad, and touch all work: arrow keys / D-pad move
## between buttons, Esc / B goes back, and the first button is focused.

signal closed

var _rows: VBoxContainer
var _back: Button
var _title: Label
var _buttons: Array[Control] = []


func _ready() -> void:
	layer = 80
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
	# Contents stay clear of phone notches; the background fills the whole screen.
	var safe := SafeAreaBox.new()
	root.add_child(safe)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, int(margin_px))
	safe.add_child(box)
	var top := HBoxContainer.new()
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
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.text = text
	button.disabled = not enabled
	button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 5.0, Data.cfg_float("ui.min_touch_target_px"))
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
	for button: Control in _buttons:
		if button != _back and not (button as Button).disabled:
			focus_later(button)
			return
	if count > 0:
		focus_later(_buttons[0])


## Focuses `control` once the page is built (if it's still on screen by then).
func focus_later(control: Control) -> void:
	_focus_now.call_deferred(control)


func _focus_now(control: Control) -> void:
	if is_instance_valid(control) and control.is_inside_tree():
		control.grab_focus()
