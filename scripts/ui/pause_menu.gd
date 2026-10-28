class_name PauseMenu
extends CanvasLayer
## The pause menu (Esc on PC, Start on a gamepad, the pause button on touch):
## Resume, the Codex, and Quit run (back to Hero select). The run timer stops
## while it's open (GAME_DESIGN.md: Pauses and turns). It doesn't open over the
## level-up screen or a chest reveal. More settings arrive with Phase 19.

## Screens that, while open, keep the pause menu from opening.
var blockers: Array[CanvasLayer] = []

var _panel: PanelContainer
var _resume: Button
var _buttons: Array[Control] = []


func _ready() -> void:
	layer = 70
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
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
	_add_button(box, "UI_QUIT_RUN", _on_quit)
	var count: int = _buttons.size()
	for i: int in count:
		_buttons[i].focus_neighbor_top = _buttons[i].get_path_to(_buttons[(i - 1 + count) % count])
		_buttons[i].focus_neighbor_bottom = _buttons[i].get_path_to(_buttons[(i + 1) % count])
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
	if visible or GameAuthority.run == null or GameAuthority.run.ended or get_tree().paused:
		return
	for blocker: CanvasLayer in blockers:
		if blocker != null and blocker.visible:
			return
	visible = true
	get_tree().paused = true
	_resume.grab_focus()


func close() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = false


func _on_codex() -> void:
	var codex := CodexScreen.new()
	codex.closed.connect(_resume.grab_focus)
	add_child(codex)


func _on_quit() -> void:
	GameAuthority.selected_hero_id = ""
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
