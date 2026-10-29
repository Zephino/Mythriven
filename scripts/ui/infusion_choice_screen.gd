class_name InfusionChoiceScreen
extends CanvasLayer
## When two bound gods could infuse a chest's weapon, the player picks one
## (GAME_DESIGN.md: Divine infusions). Each button shows the god and the name
## the weapon would get. Pauses the game; keyboard, gamepad, and touch work.

var _box: VBoxContainer
var _title: Label
var _weapon: WeaponInstance


func _ready() -> void:
	layer = 43
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


## `choice` is {"weapon": WeaponInstance, "gods": [god ids]} from ChestRules.
func ask(choice: Dictionary) -> void:
	_weapon = choice["weapon"]
	for child: Node in _box.get_children():
		if child != _title:
			child.queue_free()
	_title.text = tr("UI_INFUSION_CHOICE_TITLE") % tr(_weapon.name_key())
	var buttons: Array[Button] = []
	for god_id: Variant in choice.get("gods", []):
		var preview := WeaponInstance.new(_weapon.data, null)
		Infusions.infuse(preview, str(god_id))
		var button := Button.new()
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.text = tr("UI_INFUSION_OPTION") % [tr(str(GodRules.find(str(god_id)).get("name_key", ""))), Infusions.display_name(preview)]
		button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 5.0, Data.cfg_float("ui.min_touch_target_px"))
		button.pressed.connect(_choose.bind(str(god_id)))
		_box.add_child(button)
		buttons.append(button)
	for i: int in buttons.size():
		buttons[i].focus_neighbor_top = buttons[i].get_path_to(buttons[(i - 1 + buttons.size()) % buttons.size()])
		buttons[i].focus_neighbor_bottom = buttons[i].get_path_to(buttons[(i + 1) % buttons.size()])
	visible = true
	get_tree().paused = true
	if not buttons.is_empty():
		buttons[0].grab_focus()


func _choose(god_id: String) -> void:
	visible = false
	get_tree().paused = false
	var recipe: Dictionary = Infusions.infuse(_weapon, god_id)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if Infusions.discover(recipe) and banner != null:
		banner.show_text(tr("CODEX_NEW_INFUSION") % Infusions.display_name(_weapon))
