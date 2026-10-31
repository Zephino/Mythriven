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
var _scroll: ScrollContainer
var _top_slot: HBoxContainer
## Set when this page is shown inside another (a Hall of Legends tab): that page holds its rows and redraws it.
var _host: MenuScreen = null


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
	# Wide pages (lists with details, cards) use more of the screen, but never more than there is.
	var room: float = get_viewport().get_visible_rect().size.x - margin_px * 2.0
	column.custom_minimum_size = Vector2(minf(page_width(), room), 0)
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
	# Room in the title bar for a page's own tabs or buttons (the Hall's tabs), rebuilt with the page.
	_top_slot = HBoxContainer.new()
	_top_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_top_slot.add_theme_constant_override("separation", 2)
	_top_slot.visible = false
	top.add_child(_top_slot)
	_back = Button.new()
	_back.text = "UI_BACK"
	_back.custom_minimum_size = Vector2(touch * 2.0, touch)
	_back.pressed.connect(close)
	_back.visible = has_back()
	top.add_child(_back)
	var scroll := ScrollContainer.new()
	_scroll = scroll
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


## How wide the page is: the narrow column, or wider for pages of cards and lists with details
## (owner decisions 10/31/2026: list + detail pages, item cards, the Hall's tabs).
func page_width() -> float:
	return Data.cfg_float("ui.menu_column_px")


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
	if _host != null:
		_host.refresh()
		return
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED if shows_logo() else ScrollContainer.SCROLL_MODE_AUTO
	_rows.size_flags_vertical = Control.SIZE_FILL
	for child: Node in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	for child: Node in _top_slot.get_children():
		_top_slot.remove_child(child)
		child.queue_free()
	_top_slot.visible = false
	_title.visible = true
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


## Shows this page inside `host` (a Hall of Legends tab), building into `rows`.
func embed(host: MenuScreen, rows: VBoxContainer) -> void:
	_host = host
	_rows = rows
	_buttons = host._buttons
	_scroll = host._scroll
	if _title == null:
		_title = Label.new()
		add_child(_title)


## A row of tabs; the chosen one is lit. `on_pick(index)` is called when another is pressed.
## `enabled` (optional) greys out tabs that can't be opened yet.
## `in_title_bar` puts them in the title bar in place of the page's title.
func add_tabs(labels: PackedStringArray, chosen: int, on_pick: Callable, enabled: Array = [], in_title_bar: bool = false) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 2)
	for i: int in labels.size():
		var tab := Button.new()
		tab.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		tab.text = labels[i]
		tab.toggle_mode = true
		tab.button_pressed = i == chosen
		tab.disabled = i < enabled.size() and not bool(enabled[i])
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.custom_minimum_size = Vector2(0, Data.cfg_float("ui.menu_tab_px"))
		tab.clip_text = true
		flat_button(tab, i == chosen)
		tab.pressed.connect(func() -> void:
			if i == chosen:
				tab.button_pressed = true
				return
			on_pick.call(i))
		row.add_child(tab)
		_buttons.append(tab)
	if in_title_bar:
		_title.visible = false
		_top_slot.visible = true
		_top_slot.add_child(row)
	else:
		_rows.add_child(row)
	return row


## An item card: picture on the left; a name, then short lines; on the right an optional note (a level) and a button
## (a price). `dim` greys the whole card (locked).
func add_card(picture: Texture2D, title: String, lines: PackedStringArray, note: String = "", action: String = "",
		on_pressed: Callable = Callable(), enabled: bool = true, dim: bool = false, hidden: bool = false) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", card_style())
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if dim:
		card.modulate = Color(1, 1, 1, Data.cfg_float("ui.menu_locked_dim"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	card.add_child(row)
	if picture != null:
		var box := picture_box(picture, Data.cfg_float("ui.menu_card_picture_px"))
		if hidden:
			box.self_modulate = Color(0, 0, 0, 0.85)       # a dark shape until it's met
		row.add_child(box)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_theme_constant_override("separation", 0)
	row.add_child(texts)
	var head := HBoxContainer.new()
	texts.add_child(head)
	head.add_theme_constant_override("separation", 10)
	var name_label := heading(title)
	name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	head.add_child(name_label)
	if note != "":
		var note_label := small(note)
		note_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		note_label.size_flags_vertical = Control.SIZE_SHRINK_END
		head.add_child(note_label)
	for line: String in lines:
		texts.add_child(small(line))
	if action != "":
		var button := Button.new()
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.text = action
		button.disabled = not enabled
		button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 2.2, Data.cfg_float("ui.min_touch_target_px"))
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if on_pressed.is_valid():
			button.pressed.connect(on_pressed)
		row.add_child(button)
		_buttons.append(button)
	_rows.add_child(card)
	return card


## Another button on a card (beside its first): for example Swift Mode on a level.
func add_card_button(card: PanelContainer, text: String, on_pressed: Callable, enabled: bool = true) -> Button:
	var button := Button.new()
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	button.text = text
	button.disabled = not enabled
	button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 2.2, Data.cfg_float("ui.min_touch_target_px"))
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(on_pressed)
	card.get_child(0).add_child(button)
	_buttons.append(button)
	return button


## A setting: its name on the left, its value on a button on the right that steps it.
func add_setting(label: String, value: String, on_pressed: Callable, enabled: bool = true) -> Button:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_label := Label.new()
	name_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text = label
	row.add_child(name_label)
	var button := Button.new()
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	button.text = value
	button.disabled = not enabled
	button.custom_minimum_size = Vector2(Data.cfg_float("ui.menu_setting_value_px"), Data.cfg_float("ui.menu_tab_px"))
	button.pressed.connect(on_pressed)
	row.add_child(button)
	_rows.add_child(row)
	_buttons.append(button)
	return button


## An explanation in the softer, smaller text (help under a heading, what a button does).
func add_note(text: String) -> Label:
	var label := small(text)
	_rows.add_child(label)
	return label


## A heading between groups on a page (Heroes, Weapons, Secrets...).
func add_section(text: String) -> Label:
	var label := heading(text)
	label.add_theme_font_size_override("font_size", roundi(ThemeDB.get_default_theme().default_font_size * Data.cfg_float("ui.menu_section_scale")))
	_rows.add_child(label)
	return label


## A section heading inside a list (the pantheons in the Compendium's list).
func add_list_heading(list: VBoxContainer, text: String) -> void:
	var label := heading(text)
	label.add_theme_font_size_override("font_size", roundi(ThemeDB.get_default_theme().default_font_size * Data.cfg_float("ui.menu_small_scale")))
	list.add_child(label)


## A list on the left and a detail panel on the right, each scrolling on its own (the page itself doesn't scroll).
## Returns [list VBoxContainer, detail VBoxContainer].
func add_split() -> Array:
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if _host != null:
		_host._rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 6)
	_rows.add_child(split)
	var boxes: Array = []
	for k: int in 2:
		var scroll := ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if k == 0:
			scroll.custom_minimum_size = Vector2(Data.cfg_float("ui.menu_list_px"), 0)
		else:
			scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", card_style())
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		split.add_child(panel)
		panel.add_child(scroll)
		var box := VBoxContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_theme_constant_override("separation", 2 if k == 0 else 4)
		scroll.add_child(box)
		boxes.append(box)
	return boxes


## One entry in a list (picture and name); `on_pressed` shows its details.
func add_list_item(list: VBoxContainer, picture: Texture2D, text: String, on_pressed: Callable, dim: bool = false) -> Button:
	var item := Button.new()
	item.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	item.text = text
	item.icon = picture
	item.alignment = HORIZONTAL_ALIGNMENT_LEFT
	item.toggle_mode = true
	item.clip_text = true
	item.custom_minimum_size = Vector2(0, Data.cfg_float("ui.menu_tab_px"))
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.add_theme_constant_override("icon_max_width", int(Data.cfg_float("ui.menu_list_icon_px")))
	item.expand_icon = true
	flat_button(item, false)
	if dim:
		item.modulate = Color(1, 1, 1, Data.cfg_float("ui.menu_locked_dim"))
	item.pressed.connect(func() -> void:
		for other: Node in list.get_children():
			if other is Button:
				(other as Button).set_pressed_no_signal(other == item)
		on_pressed.call())
	list.add_child(item)
	_buttons.append(item)
	return item


## Shows a list entry's picture as a dark shape (not met or not unlocked yet).
func silhouette(item: Button) -> void:
	for state: String in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color", "icon_hover_pressed_color"]:
		item.add_theme_color_override(state, Color(0, 0, 0, 0.85))


## A detail panel's contents: a big picture, the name, short facts, then the longer text.
func fill_detail(detail: VBoxContainer, picture: Texture2D, title: String, facts: PackedStringArray, story: PackedStringArray) -> void:
	for child: Node in detail.get_children():
		detail.remove_child(child)
		child.queue_free()
	if picture != null:
		var holder := CenterContainer.new()
		holder.add_child(picture_box(picture, Data.cfg_float("ui.menu_detail_picture_px")))
		detail.add_child(holder)
	var name_label := heading(title)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.add_child(name_label)
	for fact: String in facts:
		var line := small(fact)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		detail.add_child(line)
	if not story.is_empty():
		detail.add_child(HSeparator.new())
	for paragraph: String in story:
		var line := Label.new()
		line.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.text = paragraph
		detail.add_child(line)


## A slimmer look for tabs and list entries than the framed buttons: a soft dark box, lit gold when chosen
## (`chosen`, or pressed in a list), in the smaller text.
func flat_button(button: Button, chosen: bool) -> void:
	var gold := Color.html(Data.cfg_string("ui.menu_heading_color"))
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		var lit: bool = chosen or state == "pressed" or state == "hover_pressed"
		style.bg_color = Color(gold.r, gold.g, gold.b, 0.22) if lit else Color(0, 0, 0, 0.35 if state != "hover" else 0.2)
		style.border_color = gold if lit else Color(1, 1, 1, 0.1)
		style.border_width_bottom = 2 if lit else 1
		style.set_content_margin_all(4)
		style.content_margin_left = 8
		button.add_theme_stylebox_override(state, style)
	button.add_theme_color_override("font_color", gold if chosen else Color.html(Data.cfg_string("ui.menu_small_color")))
	button.add_theme_color_override("font_pressed_color", gold)
	button.add_theme_color_override("font_hover_pressed_color", gold)
	button.add_theme_font_size_override("font_size", roundi(ThemeDB.get_default_theme().default_font_size * Data.cfg_float("ui.menu_tab_scale")))


## A picture scaled to fit a square of `side` pixels, crisp (pixel art).
func picture_box(picture: Texture2D, side: float) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = picture
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.custom_minimum_size = Vector2(side, side)
	rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return rect


## A name in the menus' gold.
func heading(text: String) -> Label:
	var label := Label.new()
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = text
	label.add_theme_color_override("font_color", Color.html(Data.cfg_string("ui.menu_heading_color")))
	label.add_theme_font_size_override("font_size", roundi(ThemeDB.get_default_theme().default_font_size * Data.cfg_float("ui.menu_heading_scale")))
	return label


## Smaller, softer text for facts and descriptions.
func small(text: String) -> Label:
	var label := Label.new()
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = text
	label.add_theme_color_override("font_color", Color.html(Data.cfg_string("ui.menu_small_color")))
	label.add_theme_font_size_override("font_size", roundi(ThemeDB.get_default_theme().default_font_size * Data.cfg_float("ui.menu_small_scale")))
	return label


## The soft box behind a card or a list.
func card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.28)
	style.border_color = Color(1, 1, 1, 0.12)
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(6)
	return style


## Opens another menu on top of this one; focus comes back when it closes.
func open_child(screen: MenuScreen) -> void:
	if _host != null:
		_host.open_child(screen)
		return
	screen.closed.connect(_on_child_closed)
	add_child(screen)
	screen.layer = layer + 1


## Opens one of the run's own screens on top (the Codex, the leaderboard),
## which close themselves and emit `closed`.
func open_overlay(screen: CanvasLayer) -> void:
	if _host != null:
		_host.open_overlay(screen)
		return
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
