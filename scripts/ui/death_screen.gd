class_name DeathScreen
extends CanvasLayer
## The results screen, shown when every player has fallen: the death recap
## (DeathRecap: what felled you, your build, progress, new unlocks) and one
## tip; the leaderboard (type a name, Submit score, or view the board); Retry
## (same Hero and level), Change Hero, and the Hall of Legends.

var _panel: PanelContainer
var _summary: Label
var _tip: Label
var _name: LineEdit
var _submit: Button
var _board_status: Label
var _change_hero: Button
var _title_button: Button
var _retry: Button
var _controls: Array[Control] = []
var _client: LeaderboardClient
var _entry: Dictionary = {}


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_client = LeaderboardClient.new()
	add_child(_client)
	_client.score_sent.connect(_on_score_sent)
	var touch: float = Data.cfg_float("ui.min_touch_target_px")
	var root := SafeAreaBox.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	root.add_child(_panel)
	var box := VBoxContainer.new()
	_panel.add_child(box)
	var title := Label.new()
	title.text = "UI_FALLEN_TITLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(touch * 9.0, Data.cfg_float("ui.recap_height_px"))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_summary = Label.new()
	_summary.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_summary)
	_tip = Label.new()
	_tip.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip.custom_minimum_size.x = touch * 9.0
	_tip.add_theme_color_override("font_color", Color.html(Data.cfg_string("ui.tip_color")))
	box.add_child(_tip)
	_name = LineEdit.new()
	_name.placeholder_text = "UI_LB_NAME_HINT"
	_name.max_length = Data.cfg_int("leaderboard.max_name_length")
	_name.custom_minimum_size = Vector2(touch * 5.0, touch)
	_name.text_submitted.connect(_on_submit.unbind(1))
	box.add_child(_name)
	WebTextInput.attach(_name)
	_submit = _add_button(box, "UI_LB_SUBMIT", _on_submit)
	_board_status = Label.new()
	_board_status.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_board_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_board_status.custom_minimum_size.x = touch * 5.0
	box.add_child(_board_status)
	_add_button(box, "UI_LEADERBOARD", _on_view_board)
	_retry = _add_button(box, "UI_RETRY", _on_retry)
	_change_hero = _add_button(box, "UI_CHANGE_HERO", _on_change_hero)
	_add_button(box, "UI_HALL_OF_LEGENDS", _on_hall)
	_title_button = _add_button(box, "UI_BACK_TO_TITLE", _on_title)
	visible = false


## Shows the screen with one line of summary per entry. `entry` is this run's
## score (LeaderboardEntry.build); `can_submit` is false when it can't go on the board.
func show_summary(lines: PackedStringArray, entry: Dictionary = {}, can_submit: bool = false, tip: String = "") -> void:
	if Net.in_run():
		# Co-op: this player's recap plus a team summary; scores are for solo runs.
		lines.append_array(team_lines())
		can_submit = false
		_retry.visible = false
		_change_hero.visible = false
	_summary.text = "\n".join(lines)
	_tip.text = tr("RECAP_TIP") % tip if tip != "" else ""
	_entry = entry
	var allowed: bool = can_submit and not entry.is_empty()
	_name.visible = allowed
	_submit.visible = allowed
	_name.text = LeaderboardEntry.load_name()
	if Net.in_run():
		_board_status.text = tr("UI_LB_COOP")
	elif not allowed:
		_board_status.text = tr("UI_LB_DEBUG_USED") if not entry.is_empty() else ""
	elif LeaderboardClient.is_local():
		_board_status.text = tr("UI_LB_LOCAL_NOTE")
		_submit.disabled = false
	else:
		_board_status.text = ""
	_link_focus()
	visible = true
	(_retry if _retry.visible else _title_button).grab_focus()


func _on_submit() -> void:
	if _submit.disabled or not _submit.visible:
		return
	var player_name: String = LeaderboardEntry.clean_name(_name.text)
	if player_name.is_empty():
		_board_status.text = tr("UI_LB_NEED_NAME")
		_name.grab_focus()
		return
	_name.text = player_name
	LeaderboardEntry.save_name(player_name)
	_entry["name"] = player_name
	_submit.disabled = true
	_board_status.text = tr("UI_LB_SENDING")
	_client.send(_entry)


func _on_score_sent(accepted: bool, error: String) -> void:
	if error != "":
		_board_status.text = tr("UI_LB_SEND_FAILED") % error
		_submit.disabled = false
		return
	if LeaderboardClient.is_local():
		_board_status.text = tr("UI_LB_SAVED_LOCAL") if accepted else tr("UI_LB_NOT_PLACED_LOCAL")
	else:
		_board_status.text = tr("UI_LB_SENT") if accepted else tr("UI_LB_NOT_PLACED")


func _on_view_board() -> void:
	var screen := LeaderboardScreen.new()
	screen.closed.connect(_retry.grab_focus)
	add_child(screen)


func _on_change_hero() -> void:
	GameAuthority.selected_hero_id = ""
	Meta.next_screen = "hero_select"
	_on_retry()


## Back to the title screen (in co-op this also leaves the game).
func _on_title() -> void:
	GameAuthority.selected_hero_id = ""
	Meta.next_screen = "title"
	_on_retry()


func _on_hall() -> void:
	GameAuthority.selected_hero_id = ""
	Meta.next_screen = "hall"
	_on_retry()


func _on_retry() -> void:
	get_tree().paused = false
	if Net.active():
		# A co-op run ends here for this player (the host leaving ends it for everyone).
		Net.leave()
		GameAuthority.selected_hero_id = ""
	get_tree().reload_current_scene()


## Co-op team summary: every player's Hero and how they ended.
static func team_lines() -> PackedStringArray:
	var out: PackedStringArray = [TranslationServer.translate("RECAP_TEAM")]
	for player: Player in GameAuthority.players:
		var hero_name: String = TranslationServer.translate(str(player.hero.get("name_key", "")))
		var ended: String = "RECAP_TEAM_SHADE" if player.shade else ("RECAP_TEAM_STANDING" if player.alive else "RECAP_TEAM_FELL")
		out.append(TranslationServer.translate("RECAP_TEAM_LINE") % [player.player_id, hero_name, TranslationServer.translate(ended),
			player.revives_used])
	return out


func _add_button(box: VBoxContainer, key: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = key
	button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 3.0, Data.cfg_float("ui.min_touch_target_px"))
	button.pressed.connect(on_pressed)
	box.add_child(button)
	return button


## Arrow keys / D-pad move through the visible controls in order, wrapping around.
func _link_focus() -> void:
	_controls.clear()
	for child: Node in _name.get_parent().get_children():
		if (child is Button or child is LineEdit) and (child as Control).visible:
			_controls.append(child)
	var count: int = _controls.size()
	for i: int in count:
		var control: Control = _controls[i]
		control.focus_neighbor_top = control.get_path_to(_controls[(i - 1 + count) % count])
		control.focus_neighbor_bottom = control.get_path_to(_controls[(i + 1) % count])
