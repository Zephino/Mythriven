class_name LeaderboardScreen
extends CanvasLayer
## The shared leaderboard (owner request): the best runs from every player
## (or, until online scores are set up, the best runs on this device),
## each with their Hero, time survived, level, kills, weapons, and upgrades.
## Opens from Hero select and the death screen. Keyboard, gamepad, and touch
## all work; Close is focused first and Esc / B also closes it.

signal closed

var _client: LeaderboardClient
var _status: Label
var _rows: VBoxContainer
var _refresh: Button
var _close: Button
var _scroll: ScrollContainer


func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	_client = LeaderboardClient.new()
	add_child(_client)
	_client.board_loaded.connect(_on_board_loaded)
	_build()
	_load()


## _input, not _unhandled_input: runs before focus moves, so the list can scroll.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_close()
	elif _scroll.has_focus() and (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up")):
		# The D-pad / arrow keys scroll the list; up at the top goes back to the buttons.
		var step: int = int(Data.cfg_float("ui.min_touch_target_px"))
		if event.is_action_pressed("ui_up") and _scroll.scroll_vertical == 0:
			_close.grab_focus()
		else:
			_scroll.scroll_vertical += step if event.is_action_pressed("ui_down") else -step
		get_viewport().set_input_as_handled()


func _load() -> void:
	_status.text = tr("UI_LB_LOADING")
	_status.visible = true
	for row: Node in _rows.get_children():
		row.queue_free()
	_client.fetch()


func _on_board_loaded(entries: Array[Dictionary], error: String) -> void:
	if error != "":
		_status.text = tr("UI_LB_LOAD_FAILED") % error
		return
	_status.visible = entries.is_empty()
	_status.text = tr("UI_LB_EMPTY")
	var shown: int = mini(entries.size(), Data.cfg_int("leaderboard.rows_shown"))
	for i: int in shown:
		var row := Label.new()
		row.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.text = LeaderboardEntry.describe(i + 1, entries[i])
		_rows.add_child(row)
		if i < shown - 1:
			_rows.add_child(HSeparator.new())


func _on_close() -> void:
	closed.emit()
	queue_free()


func _build() -> void:
	var touch: float = Data.cfg_float("ui.min_touch_target_px")
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var background := ColorRect.new()
	background.color = Color.html(Data.cfg_string("heroes.select_background"))
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
	var title := Label.new()
	title.text = "UI_LEADERBOARD_LOCAL" if LeaderboardClient.is_local() else "UI_LEADERBOARD"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	_refresh = Button.new()
	_refresh.text = "UI_LB_REFRESH"
	_refresh.custom_minimum_size = Vector2(touch * 2.0, touch)
	_refresh.pressed.connect(_load)
	top.add_child(_refresh)
	_close = Button.new()
	_close.text = "UI_LB_CLOSE"
	_close.custom_minimum_size = _refresh.custom_minimum_size
	_close.pressed.connect(_on_close)
	top.add_child(_close)
	_refresh.focus_neighbor_right = _refresh.get_path_to(_close)
	_close.focus_neighbor_left = _close.get_path_to(_refresh)
	_status = Label.new()
	_status.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_status)
	_scroll = ScrollContainer.new()
	var scroll: ScrollContainer = _scroll
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.focus_mode = Control.FOCUS_ALL
	box.add_child(scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_rows)
	_close.focus_neighbor_bottom = _close.get_path_to(scroll)
	_refresh.focus_neighbor_bottom = _refresh.get_path_to(scroll)
	_close.grab_focus()
