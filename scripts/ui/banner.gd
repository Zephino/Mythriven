class_name Banner
extends CanvasLayer
## A short announcement across the top-middle of the screen (Age changes,
## hazards, "New recipe discovered", Resonances, events, and achievements,
## secrets, and unlocks earned during the run). Lines
## queue up and show one at a time; the game never pauses for them.

const GROUP := "banner"

var _label: Label
var _queue: PackedStringArray = []
var _left: float = 0.0


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group(GROUP)
	var root := SafeAreaBox.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_label = Label.new()
	_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_label.offset_top = Data.cfg_float("ui.banner_offset_px")
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", Data.cfg_int("ui.banner_font_px"))
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", Data.cfg_int("ui.banner_outline_px"))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.visible = false
	root.add_child(_label)
	# Achievements, secrets, and unlocks earned during the run (Phase 15).
	Meta.earned.connect(show_text)


## Queues one already-translated line.
func show_text(text: String) -> void:
	_queue.append(text)
	if not _label.visible:
		_next()


func current_text() -> String:
	return _label.text if _label.visible else ""


func _process(delta: float) -> void:
	if not _label.visible:
		return
	_left -= delta
	_label.modulate.a = clampf(_left / 0.4, 0.0, 1.0)
	if _left <= 0.0:
		_next()


func _next() -> void:
	if _queue.is_empty():
		_label.visible = false
		return
	_label.text = _queue[0]
	_queue.remove_at(0)
	_label.visible = true
	_left = Data.cfg_float("ui.banner_s")
