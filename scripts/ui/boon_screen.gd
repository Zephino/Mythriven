class_name BoonScreen
extends CanvasLayer
## Milestone Boons (GAME_DESIGN.md: Run arc / Milestone rewards): after each
## Age's boss falls, choose 1 of 3 rare run-wide effects (boons.json). Pauses
## the game while open; keyboard, gamepad, and touch work.

const FILE := "boons.json"

var _box: VBoxContainer
var _title: Label
var _taken: PackedStringArray = []


func _ready() -> void:
	add_to_group("boon_screen")
	add_to_group(CoopChoices.MODAL)
	layer = 44
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
	_title.text = "UI_CHOOSE_BOON"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(_title)
	visible = false


func is_open() -> bool:
	return visible


static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	return found


## Applies a Boon's effects to `player` (also used by tests).
static func apply(player: Player, boon: Dictionary) -> void:
	var effects: Dictionary = boon.get("effects", {})
	for key: String in effects:
		var value: float = float(effects[key])
		match key:
			"extra_projectiles":
				player.extra_projectiles += int(value)
			"xp_mult":
				GameAuthority.run.xp_mult += value
			"heal_pct":
				pass
			_:
				player.stats.add_bonus(key, value)
	player.refresh_stats()
	if effects.has("heal_pct"):
		GameAuthority.heal_player(player, player.max_hp * float(effects["heal_pct"]))


## Shows 3 Boons not taken yet this run.
func offer() -> void:
	var player: Player = GameAuthority.local_player()
	if player == null or not player.alive:
		return
	var pool: Array[Dictionary] = []
	for boon: Dictionary in all():
		if not _taken.has(str(boon["id"])):
			pool.append(boon)
	if pool.is_empty():
		return
	for child: Node in _box.get_children():
		if child != _title:
			child.queue_free()
	var rng: RandomNumberGenerator = GameAuthority.run.rng.loot
	var buttons: Array[Button] = []
	for _k: int in mini(Data.cfg_int("bosses.boon_choices"), pool.size()):
		var boon: Dictionary = pool.pop_at(rng.randi_range(0, pool.size() - 1))
		var button := Button.new()
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text = "%s\n%s" % [tr(str(boon["name_key"])), tr(str(boon["desc_key"]))]
		button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 5.0, Data.cfg_float("ui.min_touch_target_px") * 1.4)
		button.pressed.connect(_choose.bind(player, boon))
		_box.add_child(button)
		buttons.append(button)
	for i: int in buttons.size():
		buttons[i].focus_neighbor_top = buttons[i].get_path_to(buttons[(i - 1 + buttons.size()) % buttons.size()])
		buttons[i].focus_neighbor_bottom = buttons[i].get_path_to(buttons[(i + 1) % buttons.size()])
	visible = true
	get_tree().paused = true
	buttons[0].grab_focus()


func _choose(player: Player, boon: Dictionary) -> void:
	visible = false
	get_tree().paused = false
	_taken.append(str(boon["id"]))
	if Net.is_client():
		CoopChoices.choose("boon", str(boon["id"]))
		return
	if is_instance_valid(player):
		apply(player, boon)
