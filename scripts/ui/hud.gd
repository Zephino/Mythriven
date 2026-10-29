class_name Hud
extends CanvasLayer
## In-game HUD (GAME_DESIGN.md: Screens / In-game HUD): the XP bar across the
## top, the run timer, kills, the level badge (banked level-ups; tap to open
## the level-up screen), run gold, a pause button for touch screens, and a
## line from the Hero's Legend Trait (for Heracles, his current Labor). The
## timer shows the personal best for this Hero and level until it's passed.

var level_up_screen: LevelUpScreen
var pause_menu: PauseMenu

var _xp_bar: ProgressBar
var _timer_label: Label
var _kills_label: Label
var _gold_label: Label
var _badge: Button
var _trait_label: Label
## Personal best for this Hero and level (-1 until looked up) and whether this run passed it.
var _best_s: float = -1.0
var _passed_best: bool = false


func _ready() -> void:
	layer = 10
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var root := SafeAreaBox.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_xp_bar = ProgressBar.new()
	_xp_bar.show_percentage = false
	_xp_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_xp_bar.custom_minimum_size.y = Data.cfg_float("ui.xp_bar_height_px")
	_xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_xp_bar)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	row.offset_top = Data.cfg_float("ui.xp_bar_height_px") + margin_px * 0.5
	row.offset_left = margin_px
	row.offset_right = -margin_px
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(row)
	_badge = Button.new()
	_badge.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_badge.custom_minimum_size = Vector2.ONE * Data.cfg_float("ui.min_touch_target_px")
	_badge.focus_mode = Control.FOCUS_NONE
	_badge.pressed.connect(_on_badge_pressed)
	row.add_child(_badge)
	_timer_label = _make_label()
	row.add_child(_timer_label)
	_kills_label = _make_label()
	row.add_child(_kills_label)
	_gold_label = _make_label()
	row.add_child(_gold_label)
	var pause := Button.new()
	pause.text = "UI_PAUSE_BUTTON"
	pause.custom_minimum_size = Vector2.ONE * Data.cfg_float("ui.min_touch_target_px")
	pause.focus_mode = Control.FOCUS_NONE
	pause.pressed.connect(func() -> void:
		if pause_menu != null:
			pause_menu.open())
	row.add_child(pause)
	_trait_label = Label.new()
	_trait_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_trait_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_trait_label.offset_top = row.offset_top + Data.cfg_float("ui.min_touch_target_px")
	_trait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_trait_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_trait_label)


func _process(_delta: float) -> void:
	var run: RunState = GameAuthority.run
	if run == null:
		return
	_xp_bar.max_value = LevelUpRules.xp_to_next(run.level)
	_xp_bar.value = run.xp
	_timer_label.text = _timer_text(run)
	_kills_label.text = tr("UI_KILLS") % run.kills
	_gold_label.text = tr("UI_GOLD") % roundi(run.gold)
	var player: Player = GameAuthority.local_player()
	_trait_label.text = player.kit.hud_text() if player != null and player.kit != null else ""
	if run.unspent_level_ups > 0:
		_badge.text = tr("UI_LEVEL_BADGE_BANKED") % [run.level, run.unspent_level_ups]
	else:
		_badge.text = tr("UI_LEVEL_BADGE") % run.level


func _make_label() -> Label:
	var label := Label.new()
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.custom_minimum_size.x = Data.cfg_float("ui.min_touch_target_px") * 1.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _on_badge_pressed() -> void:
	if level_up_screen != null:
		level_up_screen.try_open()


## The run timer with the personal-best marker for this Hero and level; a
## short flourish (a banner) plays the moment it's passed.
func _timer_text(run: RunState) -> String:
	if _best_s < 0.0:
		var player: Player = GameAuthority.local_player()
		var hero_id: String = str(player.hero.get("id", "")) if player != null else ""
		_best_s = Records.best(hero_id, str(run.level_data.get("id", "")), run.swift)
	var time: String = TextFormat.run_time(run.elapsed_s)
	if _best_s <= 0.0:
		return time
	if run.elapsed_s > _best_s:
		if not _passed_best:
			_passed_best = true
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null:
				banner.show_text(tr("UI_NEW_BEST_BANNER"))
		return time
	return tr("UI_TIMER_BEST") % [time, TextFormat.run_time(_best_s)]
