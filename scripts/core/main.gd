extends Node
## Main scene. Builds the run: the endless ground (Phase 3), one local
## player that moves with keyboard, gamepad, or the touch joystick (Phase 2),
## and a camera that follows it. Also shows the Phase 1 translation test label,
## the build version in the corner, and any data errors found at startup.

var _test_label: Label
var _version_label: Label
var _error_label: Label


func _ready() -> void:
	var joystick := VirtualJoystick.new()
	_build_world(joystick)
	_build_ui(joystick)


func _build_world(joystick: VirtualJoystick) -> void:
	var run: RunState = GameAuthority.start_run(Data.cfg_string("run.default_level"))
	var world := WorldRoot.new()
	world.name = "World"
	add_child(world)
	var chunks := ChunkManager.new()
	world.add_child(chunks)
	chunks.setup(run.level, run.seed_value)
	world.origin_shifted.connect(chunks.on_origin_shifted)

	var input := PlayerInput.new()
	input.joystick = joystick
	var player: Player = GameAuthority.spawn_player(world, Vector2.ZERO, input, true)
	chunks.update_chunks()
	chunks.build_all_now()

	var camera := GameCamera.new()
	camera.target = player
	world.add_child(camera)

	if OS.is_debug_build():
		var grid: Node2D = preload("res://scripts/world/debug_grid.gd").new()
		world.add_child(grid)
		var actions: Node = preload("res://scripts/core/debug_actions.gd").new()
		actions.set("world", world)
		actions.set("chunks", chunks)
		actions.set("grid", grid)
		actions.set("camera", camera)
		add_child(actions)


func _build_ui(joystick: VirtualJoystick) -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	root.add_child(joystick)
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")

	# Text set to a key is translated automatically and follows pseudo-localization.
	# Bottom-centre, so it doesn't cover the player in the middle of the screen.
	_test_label = Label.new()
	_test_label.text = "UI_TEST_LABEL"
	_test_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, int(margin_px))
	_test_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_test_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
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
