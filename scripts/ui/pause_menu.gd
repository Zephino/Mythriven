class_name PauseMenu
extends CanvasLayer
## The pause menu (Esc on PC, Start on a gamepad, the pause button on touch):
## Resume, the Codex, Settings, Auto-summon (fires a full god when 30+ enemies
## are on screen or a boss is present), and Quit run (back to the title; keeps 10%
## of the run's gold from 5:00, none before). The run
## timer stops while it's open (GAME_DESIGN.md: Pauses and turns). It doesn't
## open over the level-up screen, a chest reveal, or a god choice.
## Online (owner request 10/31/2026): a solo run can Invite friends (a code)
## or Open to public, and becomes a co-op game hosted here without stopping;
## the host can then switch between public and friends-only at any time.

## Screens that, while open, keep the pause menu from opening.
var blockers: Array[CanvasLayer] = []
var gods: GodManager

var _panel: PanelContainer
var _resume: Button
var _auto: CheckButton
var _buttons: Array[Control] = []
var _online: VBoxContainer
## True when this menu paused the game (a solo run), so closing it unpauses
## even if the run has gone online in the meantime.
var _paused_here: bool = false


func _ready() -> void:
	layer = 70
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	title.text = "UI_PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_resume = _add_button(box, "UI_RESUME", close)
	_add_button(box, "UI_CODEX", _on_codex)
	_add_button(box, "UI_SETTINGS", _on_settings)
	var auto := CheckButton.new()
	auto.text = "UI_AUTO_SUMMON"
	auto.custom_minimum_size.y = Data.cfg_float("ui.min_touch_target_px")
	auto.button_pressed = Settings.flag("auto_summon")
	auto.toggled.connect(_on_auto_summon)
	box.add_child(auto)
	_buttons.append(auto)
	_auto = auto
	_online = VBoxContainer.new()
	box.add_child(_online)
	_add_button(box, "UI_QUIT_RUN", _on_quit)
	Net.changed.connect(_build_online)
	_link_focus()
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	get_viewport().set_input_as_handled()
	if visible:
		close()
	else:
		open()


func open() -> void:
	if visible or GameAuthority.run == null or GameAuthority.run.ended or (get_tree().paused and not Net.in_run()):
		return
	for blocker: CanvasLayer in blockers:
		if blocker != null and blocker.visible:
			return
	visible = true
	# Co-op: the pause menu is only an overlay; the game keeps running (GAME_DESIGN.md: Fairness rules).
	_paused_here = not Net.in_run()
	if _paused_here:
		get_tree().paused = true
	_build_online()
	_resume.grab_focus()


func close() -> void:
	if not visible:
		return
	visible = false
	if _paused_here:
		_paused_here = false
		get_tree().paused = false


func _on_auto_summon(on: bool) -> void:
	Settings.change("auto_summon", on)
	if gods != null:
		gods.auto_summon = on


func _on_settings() -> void:
	var settings := SettingsScreen.new()
	settings.closed.connect(_on_settings_closed)
	add_child(settings)


func _on_settings_closed() -> void:
	_auto.set_pressed_no_signal(Settings.flag("auto_summon"))
	_resume.grab_focus()


func _on_codex() -> void:
	var codex := CodexScreen.new()
	codex.closed.connect(_resume.grab_focus)
	add_child(codex)


## Invite friends / Open to public (solo), or the game code and a public ↔
## friends-only switch (hosting). Nothing while playing in someone else's game.
func _build_online() -> void:
	if _online == null or not visible:
		return
	for child: Node in _online.get_children():
		child.queue_free()
	if OnlineConfig.lobby_url() == "" and Net.service_override == null:
		return
	if not Net.active():
		_add_online_button("UI_INVITE_FRIENDS", func() -> void: Net.host_running_game(false))
		_add_online_button("UI_OPEN_TO_PUBLIC", func() -> void: Net.host_running_game(true))
	elif Net.state == Net.State.CONNECTING:
		_add_online_line(tr("UI_GOING_ONLINE"))
	elif Net.is_host():
		_add_online_line(tr("UI_COOP_CODE") % Net.code)
		_add_online_line(tr("UI_ONLINE_PUBLIC" if Net.public_game else "UI_ONLINE_FRIENDS"))
		_add_online_button("UI_MAKE_PRIVATE" if Net.public_game else "UI_MAKE_PUBLIC", func() -> void: Net.set_public(not Net.public_game))


func _add_online_button(key: String, on_pressed: Callable) -> void:
	var button := Button.new()
	button.text = key
	button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 3.0, Data.cfg_float("ui.min_touch_target_px"))
	button.pressed.connect(on_pressed)
	_online.add_child(button)
	_link_focus.call_deferred()


## Up / down (keyboard, D-pad) moves through every button in order, wrapping.
func _link_focus() -> void:
	var order: Array[Control] = []
	for button: Control in _buttons:
		if button == _buttons.back():
			for online: Node in _online.get_children():
				if online is Button and not online.is_queued_for_deletion():
					order.append(online)
		order.append(button)
	var count: int = order.size()
	for i: int in count:
		order[i].focus_neighbor_top = order[i].get_path_to(order[(i - 1 + count) % count])
		order[i].focus_neighbor_bottom = order[i].get_path_to(order[(i + 1) % count])


func _add_online_line(text: String) -> void:
	var line := Label.new()
	line.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	line.text = text
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_online.add_child(line)


## Quitting keeps 10% of the run's gold from 5:00, none before (Banking).
func _on_quit() -> void:
	Meta.quit_run()
	if Net.active():
		# Leaving a co-op run (if this is the host, it ends for everyone).
		Net.send(LobbyService.HOST_ID, [NetMsg.BYE])
		Net.leave()
	GameAuthority.selected_hero_id = ""
	Meta.next_screen = "title"
	get_tree().paused = false
	get_tree().reload_current_scene()


func _add_button(box: VBoxContainer, key: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = key
	button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 3.0, Data.cfg_float("ui.min_touch_target_px"))
	button.pressed.connect(on_pressed)
	box.add_child(button)
	_buttons.append(button)
	return button
