extends Node
## Main scene (Phase 1: empty). Shows a translation test label, the build
## version in the corner, and any data errors found at startup. Later phases
## replace the test label with the real game.

var _test_label: Label
var _version_label: Label
var _error_label: Label


func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")

	# Text set to a key is translated automatically and follows pseudo-localization.
	_test_label = Label.new()
	_test_label.text = "UI_TEST_LABEL"
	_test_label.set_anchors_preset(Control.PRESET_CENTER)
	_test_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_test_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	_test_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_test_label)

	_version_label = Label.new()
	_version_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_version_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, int(margin_px))
	_version_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_version_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(_version_label)

	_error_label = Label.new()
	_error_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_error_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_error_label.offset_left = margin_px
	_error_label.offset_top = margin_px
	_error_label.offset_right = -margin_px
	_error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	root.add_child(_error_label)

	Localization.changed.connect(_refresh)
	Data.reloaded.connect(_refresh)
	_refresh()


func _refresh() -> void:
	_version_label.text = tr("UI_VERSION_LABEL") % ProjectSettings.get_setting("application/config/version", "")
	var lines: PackedStringArray = []
	for err: Dictionary in Data.errors:
		lines.append(JsonValidator.describe(err))
	if not lines.is_empty():
		lines.insert(0, tr("UI_DATA_ERRORS_TITLE"))
	_error_label.text = "\n".join(lines)
