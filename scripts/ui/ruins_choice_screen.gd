class_name RuinsChoiceScreen
extends CanvasLayer
## Ancient Ruins reward (GAME_DESIGN.md: Regions and POIs): after holding the
## circle, choose a weapon or passive level, a heal, or gold. Pauses the game;
## keyboard, gamepad, and touch work.

var _box: VBoxContainer


func _ready() -> void:
	layer = 41
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
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
	visible = false


func is_open() -> bool:
	return visible


func offer(player: Player, gold_amount: float) -> void:
	for child: Node in _box.get_children():
		child.queue_free()
	var title := Label.new()
	title.text = "RUINS_TITLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(title)
	var buttons: Array[Button] = []
	var upgrades: Array[Dictionary] = []
	for card: Dictionary in LevelUpRules.item_cards(player):
		if card["kind"] == LevelUpRules.WEAPON_UP or card["kind"] == LevelUpRules.PASSIVE_UP:
			upgrades.append(card)
	if not upgrades.is_empty():
		var card: Dictionary = upgrades[GameAuthority.run.rng.loot.randi_range(0, upgrades.size() - 1)]
		buttons.append(_button(tr("RUINS_UPGRADE") % CardText.title(card), _take.bind(player, "upgrade", card)))
	buttons.append(_button(tr("RUINS_HEAL"), _take.bind(player, "heal", {})))
	buttons.append(_button(tr("RUINS_GOLD") % roundi(gold_amount), _take.bind(player, "gold", {"amount": gold_amount})))
	var count: int = buttons.size()
	for i: int in count:
		buttons[i].focus_neighbor_top = buttons[i].get_path_to(buttons[(i - 1 + count) % count])
		buttons[i].focus_neighbor_bottom = buttons[i].get_path_to(buttons[(i + 1) % count])
	visible = true
	get_tree().paused = true
	buttons[0].grab_focus()


func _take(player: Player, choice: String, card: Dictionary) -> void:
	visible = false
	get_tree().paused = false
	if not is_instance_valid(player):
		return
	match choice:
		"upgrade":
			var kind: String = "weapon_up" if card["kind"] == LevelUpRules.WEAPON_UP else "passive_up"
			ChestRules.apply(player, {"rewards": [{"kind": kind, "id": card["id"], "from": card["from"], "to": card["to"]}]})
		"heal":
			GameAuthority.heal_player(player, player.max_hp)
		"gold":
			GameAuthority.collect_gold(player, float(card.get("amount", 0.0)))


func _button(text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	button.text = text
	button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 5.0, Data.cfg_float("ui.min_touch_target_px"))
	button.pressed.connect(on_pressed)
	_box.add_child(button)
	return button
