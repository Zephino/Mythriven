class_name LevelUpScreen
extends CanvasLayer
## Level-up screen (GAME_DESIGN.md: Level-up choices; Pauses and turns).
## Pauses the game (the run timer stops) and shows 3–4 cards. Closing it
## without picking banks the level-up for later: open it again with Tab, the
## level badge, or Y/Triangle. When the build is maxed and Auto-collect is on,
## level-ups resolve instantly without pausing. Solo only; co-op turns come
## with co-op (Phase 20). With tokens from the Wandering Trader, Reroll
## draws new cards and Banish removes the next picked item from all future
## level-ups this run.

const AUTO_COLLECT_OPTIONS: PackedStringArray = ["off", "gold", "heal", "smart"]

var _panel: PanelContainer
var _card_buttons: Array[Button] = []
var _auto_collect: OptionButton
var _bank_button: Button
var _reroll_button: Button
var _banish_button: Button
var _banish_mode: bool = false
var _offer: Array[Dictionary] = []
var _tier_sound: AudioStreamPlayer


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	visible = false
	# A distinct sound when a spell reaches its next tier (placeholder tone).
	_tier_sound = AudioStreamPlayer.new()
	_tier_sound.stream = PickupAudio.make_blip(Data.cfg_float("pickups.tier_sound_hz"), Data.cfg_float("pickups.tier_sound_length_s"))
	_tier_sound.volume_db = Data.cfg_float("pickups.sound_volume_db")
	add_child(_tier_sound)
	GameAuthority.level_up_ready.connect(_on_level_up_ready)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("level_badge"):
		get_viewport().set_input_as_handled()
		if visible:
			close()
		else:
			try_open()


func is_open() -> bool:
	return visible


## Opens the screen if a level-up is waiting (after auto-collecting maxed ones).
func try_open() -> void:
	var player: Player = GameAuthority.local_player()
	var run: RunState = GameAuthority.run
	if player == null or not player.alive or run == null or run.ended:
		return
	_auto_collect_maxed(player)
	if run.unspent_level_ups <= 0:
		close()
		return
	visible = true
	get_tree().paused = true
	_show_offer(player)


func close() -> void:
	visible = false
	get_tree().paused = false


func _on_level_up_ready(_run: RunState) -> void:
	if not visible:
		try_open()


## Maxed level-ups resolve instantly when Auto-collect is on.
func _auto_collect_maxed(player: Player) -> void:
	var run: RunState = GameAuthority.run
	while run.unspent_level_ups > 0 and LevelUpRules.is_maxed(player):
		var card: Dictionary = LevelUpRules.auto_collect_card(GameAuthority.auto_collect, player)
		if card.is_empty():
			return
		GameAuthority.apply_card(player, card)


func _show_offer(player: Player) -> void:
	_offer = GameAuthority.current_offer(player)
	var shown: Array[Control] = []
	for i: int in _card_buttons.size():
		var button: Button = _card_buttons[i]
		button.visible = i < _offer.size()
		if button.visible:
			button.text = CardText.full(_offer[i])
			shown.append(button)
	_reroll_button.visible = GameAuthority.run.reroll_tokens > 0
	_reroll_button.text = tr("UI_REROLL") % GameAuthority.run.reroll_tokens
	_banish_button.visible = GameAuthority.run.banish_tokens > 0
	_banish_button.text = tr("UI_BANISH_ON" if _banish_mode else "UI_BANISH") % GameAuthority.run.banish_tokens
	for extra: Button in [_reroll_button, _banish_button]:
		if extra.visible:
			shown.append(extra)
	shown.append(_auto_collect)
	shown.append(_bank_button)
	_link_focus(shown)
	shown[0].grab_focus()


func _on_card_pressed(index: int) -> void:
	var player: Player = GameAuthority.local_player()
	if player == null or index >= _offer.size():
		return
	var kind: String = str(_offer[index]["kind"])
	if _banish_mode and kind in [LevelUpRules.WEAPON_NEW, LevelUpRules.WEAPON_UP, LevelUpRules.PASSIVE_NEW, LevelUpRules.PASSIVE_UP]:
		_banish_mode = false
		GameAuthority.run.banish_tokens -= 1
		GameAuthority.run.banished.append(str(_offer[index]["id"]))
		GameAuthority.run.current_offer.clear()
		_show_offer(player)
		return
	if CardText.is_tier_change(_offer[index]):
		_tier_sound.play()
	GameAuthority.apply_card(player, _offer[index])
	if GameAuthority.run.unspent_level_ups > 0:
		_auto_collect_maxed(player)
	if GameAuthority.run.unspent_level_ups > 0:
		_show_offer(player)
	else:
		close()


func _on_auto_collect_selected(index: int) -> void:
	GameAuthority.auto_collect = AUTO_COLLECT_OPTIONS[index]
	Settings.change("auto_collect", GameAuthority.auto_collect)
	var player: Player = GameAuthority.local_player()
	if player != null and visible and LevelUpRules.is_maxed(player):
		_auto_collect_maxed(player)
		if GameAuthority.run.unspent_level_ups <= 0:
			close()


func _build() -> void:
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
	title.text = "UI_LEVEL_UP_TITLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	for i: int in Data.cfg_int("level_up.cards_high_luck"):
		var button := Button.new()
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(touch * 5.0, touch * 1.5)
		button.pressed.connect(_on_card_pressed.bind(i))
		box.add_child(button)
		_card_buttons.append(button)
	var auto_row := HBoxContainer.new()
	box.add_child(auto_row)
	var auto_label := Label.new()
	auto_label.text = "UI_AUTO_COLLECT"
	auto_row.add_child(auto_label)
	_auto_collect = OptionButton.new()
	_auto_collect.custom_minimum_size.y = touch
	for option: String in AUTO_COLLECT_OPTIONS:
		_auto_collect.add_item("UI_AUTO_COLLECT_" + option.to_upper())
	_auto_collect.select(maxi(AUTO_COLLECT_OPTIONS.find(GameAuthority.auto_collect), 0))
	_auto_collect.item_selected.connect(_on_auto_collect_selected)
	auto_row.add_child(_auto_collect)
	_reroll_button = Button.new()
	_reroll_button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_reroll_button.custom_minimum_size.y = touch
	_reroll_button.pressed.connect(_on_reroll)
	box.add_child(_reroll_button)
	_banish_button = Button.new()
	_banish_button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_banish_button.custom_minimum_size.y = touch
	_banish_button.pressed.connect(_on_banish)
	box.add_child(_banish_button)
	_bank_button = Button.new()
	_bank_button.text = "UI_BANK_LEVEL_UP"
	_bank_button.custom_minimum_size.y = touch
	_bank_button.pressed.connect(close)
	box.add_child(_bank_button)


func _on_reroll() -> void:
	var player: Player = GameAuthority.local_player()
	if player == null or GameAuthority.run.reroll_tokens <= 0:
		return
	GameAuthority.run.reroll_tokens -= 1
	GameAuthority.run.current_offer.clear()
	_show_offer(player)


## The next weapon or passive card picked is banished instead of taken.
func _on_banish() -> void:
	var player: Player = GameAuthority.local_player()
	if player != null and GameAuthority.run.banish_tokens > 0:
		_banish_mode = not _banish_mode
		_show_offer(player)


## Arrow keys / D-pad move through the visible cards and buttons, wrapping around.
func _link_focus(controls: Array[Control]) -> void:
	var count: int = controls.size()
	for i: int in count:
		var control: Control = controls[i]
		control.focus_mode = Control.FOCUS_ALL
		control.focus_neighbor_top = control.get_path_to(controls[(i - 1 + count) % count])
		control.focus_neighbor_bottom = control.get_path_to(controls[(i + 1) % count])
