class_name GodChoiceScreen
extends CanvasLayer
## Binding a third god (GAME_DESIGN.md: Binding and summoning): asks which
## bound god to release, or to decline. Pauses the game while open. Keyboard,
## gamepad, and touch work; the first choice is focused.

var gods: GodManager

var _box: VBoxContainer
var _title: Label
var _player: Player
var _god_id: String = ""


func _ready() -> void:
	layer = 42
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := SafeAreaBox.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	root.add_child(panel)
	_box = VBoxContainer.new()
	panel.add_child(_box)
	_title = Label.new()
	_title.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(_title)
	visible = false


func is_open() -> bool:
	return visible


func ask(player: Player, god_id: String) -> void:
	_player = player
	_god_id = god_id
	for child: Node in _box.get_children():
		if child != _title:
			child.queue_free()
	_title.text = tr("UI_GOD_CHOICE_TITLE") % tr(str(GodRules.find(god_id).get("name_key", "")))
	var buttons: Array[Button] = []
	var bound: Array = gods.gods_of(player)
	for index: int in bound.size():
		buttons.append(_add_button(tr("UI_GOD_RELEASE") % tr(str(bound[index]["god"].get("name_key", ""))), index))
	buttons.append(_add_button(tr("UI_GOD_DECLINE"), -1))
	for i: int in buttons.size():
		buttons[i].focus_neighbor_top = buttons[i].get_path_to(buttons[(i - 1 + buttons.size()) % buttons.size()])
		buttons[i].focus_neighbor_bottom = buttons[i].get_path_to(buttons[(i + 1) % buttons.size()])
	visible = true
	get_tree().paused = true
	buttons[0].grab_focus()


func _add_button(text: String, release_index: int) -> Button:
	var button := Button.new()
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	button.text = text
	button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 4.0, Data.cfg_float("ui.min_touch_target_px"))
	button.pressed.connect(_choose.bind(release_index))
	_box.add_child(button)
	return button


func _choose(release_index: int) -> void:
	visible = false
	get_tree().paused = false
	if release_index >= 0 and is_instance_valid(_player):
		gods.bind(_player, _god_id, release_index)
