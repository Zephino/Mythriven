class_name TraderScreen
extends CanvasLayer
## The Wandering Trader (GAME_DESIGN.md: XP, leveling, pickups / Wandering
## Trader): sells items for run gold. Gold spent here isn't banked, so it's a
## real choice between surviving longer and saving for offerings.
##   Reroll token 25 · Traveler's bread 50 · Whetstone 75 · Incense 40 · Banish token 60
## Prices rise ×1.5 per Age. Opens when you walk up to the Trader; pauses the
## game; keyboard, gamepad, and touch work.

const ITEMS: PackedStringArray = ["reroll_token", "travelers_bread", "whetstone", "incense", "banish_token"]

var gods: GodManager

var _box: VBoxContainer
var _gold: Label
var _player: Player


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


## Price of an item now: the base price ×1.5 for each Age passed.
static func price(item_id: String) -> int:
	var base: float = float((Data.cfg("economy.trader_prices") as Dictionary).get(item_id, 0))
	var ages: int = RunArc.age_index(GameAuthority.run.arc_s()) if GameAuthority.run != null else 0
	return roundi(base * pow(Data.cfg_float("economy.trader_price_mult_per_age"), ages))


## Buys an item (and, for the Whetstone and Incense, applies it to `target`:
## a weapon index or a god slot). Returns false if gold is short or it can't apply.
static func buy(player: Player, item_id: String, target: int = 0) -> bool:
	var run: RunState = GameAuthority.run
	var cost: int = price(item_id)
	if run == null or run.gold < cost:
		return false
	match item_id:
		"reroll_token":
			run.reroll_tokens += 1
		"banish_token":
			run.banish_tokens += 1
		"travelers_bread":
			GameAuthority.heal_player(player, player.max_hp)
		"whetstone":
			if target < 0 or target >= player.weapons.size() or player.weapons[target].level >= player.weapons[target].max_level():
				return false
			player.weapons[target].level += 1
		"incense":
			if GameAuthority.gods == null or target >= GameAuthority.gods.gods_of(player).size():
				return false
			GameAuthority.gods.set_meter(player, target, 1.0)
	run.gold -= cost
	return true


func open_for(player: Player) -> void:
	_player = player
	visible = true
	get_tree().paused = true
	_show_main()


func _show_main() -> void:
	_clear()
	_gold = _label(tr("TRADER_TITLE") % [roundi(GameAuthority.run.gold), GameAuthority.run.reroll_tokens, GameAuthority.run.banish_tokens])
	var buttons: Array[Button] = []
	for item_id: String in ITEMS:
		var button: Button = _button(tr("TRADER_ITEM") % [tr("TRADER_" + item_id.to_upper()), price(item_id),
				tr("TRADER_" + item_id.to_upper() + "_DESC")], _pick.bind(item_id))
		button.disabled = GameAuthority.run.gold < price(item_id)
		buttons.append(button)
	buttons.append(_button(tr("UI_LEAVE"), close))
	_link(buttons)


## The Whetstone and Incense ask which weapon or god; the rest buy at once.
func _pick(item_id: String) -> void:
	if item_id == "whetstone" or item_id == "incense":
		_clear()
		_label(tr("TRADER_CHOOSE_" + item_id.to_upper()))
		var buttons: Array[Button] = []
		if item_id == "whetstone":
			for index: int in _player.weapons.size():
				var weapon: WeaponInstance = _player.weapons[index]
				var button: Button = _button(tr("TRADER_WEAPON_LEVEL") % [tr(weapon.name_key()), weapon.level], _buy.bind(item_id, index))
				button.disabled = weapon.level >= weapon.max_level()
				buttons.append(button)
		elif gods != null:
			for index: int in gods.gods_of(_player).size():
				var god: Dictionary = gods.gods_of(_player)[index]["god"]
				buttons.append(_button(tr(str(god.get("name_key", ""))), _buy.bind(item_id, index)))
		buttons.append(_button(tr("UI_BACK"), _show_main))
		_link(buttons)
		return
	_buy(item_id, 0)


func _buy(item_id: String, target: int) -> void:
	buy(_player, item_id, target)
	_show_main()


func close() -> void:
	visible = false
	get_tree().paused = false


func _clear() -> void:
	for child: Node in _box.get_children():
		child.queue_free()


func _label(text: String) -> Label:
	var label := Label.new()
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = text
	_box.add_child(label)
	return label


func _button(text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	button.text = text
	button.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 5.5, Data.cfg_float("ui.min_touch_target_px"))
	button.pressed.connect(on_pressed)
	_box.add_child(button)
	return button


func _link(buttons: Array[Button]) -> void:
	var count: int = buttons.size()
	for i: int in count:
		buttons[i].focus_neighbor_top = buttons[i].get_path_to(buttons[(i - 1 + count) % count])
		buttons[i].focus_neighbor_bottom = buttons[i].get_path_to(buttons[(i + 1) % count])
	for button: Button in buttons:
		if not button.disabled:
			button.grab_focus()
			return
