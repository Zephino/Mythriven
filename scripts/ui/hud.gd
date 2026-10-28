class_name Hud
extends CanvasLayer
## In-game HUD (GAME_DESIGN.md: Screens / In-game HUD), Phase 6 part: the XP
## bar across the top, the run timer, kills, and the level badge. The badge
## shows banked level-ups and opens the level-up screen when tapped.

var level_up_screen: LevelUpScreen

var _xp_bar: ProgressBar
var _timer_label: Label
var _kills_label: Label
var _badge: Button


func _ready() -> void:
	layer = 10
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var root := Control.new()
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


func _process(_delta: float) -> void:
	var run: RunState = GameAuthority.run
	if run == null:
		return
	_xp_bar.max_value = LevelUpRules.xp_to_next(run.level)
	_xp_bar.value = run.xp
	_timer_label.text = TextFormat.run_time(run.elapsed_s)
	_kills_label.text = tr("UI_KILLS") % run.kills
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
