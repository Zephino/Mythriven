extends CanvasLayer
## Autoload "DebugMenu" (dev builds only). F1 on PC or a three-finger tap on
## mobile opens it. It always shows the version and FPS and has the Phase 1
## tests (pseudo-localization, release content gate, data validation, seeded
## RNGs). Game systems add their own test options with add_button(),
## add_check(), and add_info(); see scripts/core/debug_actions.gd.

const FIXTURE_DIR := "res://tests/fixtures/"
const FIXTURE_SCHEMAS := "fixture_schemas.json"
const GATE_FIXTURE := "gate_entries.json"
const MENU_LAYER := 100

var _panel: PanelContainer
var _box: VBoxContainer
var _fps_label: Label
var _info_label: Label
var _version_label: Label
var _result_label: Label
var _close_button: Button
var _controls: Array[Control] = []
## Each entry: {"owner": Node, "provider": Callable} returning one line of text.
var _infos: Array[Dictionary] = []
var _owners: Dictionary = {}
var _touches: Dictionary = {}
var _fps_timer: float = 0.0
var _last_action: Callable = Callable()


func _ready() -> void:
	if not OS.is_debug_build():
		set_process(false)
		set_process_input(false)
		queue_free()
		return
	layer = MENU_LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_panel.visible = false
	Localization.changed.connect(_refresh_text)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		toggle()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		_track_touch(event as InputEventScreenTouch)


func _process(delta: float) -> void:
	if not _panel.visible:
		return
	_fps_timer -= delta
	if _fps_timer <= 0.0:
		_fps_timer = Data.cfg_float("debug.fps_refresh_s")
		_fps_label.text = tr("DEBUG_FPS_LABEL") % int(Engine.get_frames_per_second())
		var lines: PackedStringArray = []
		for info: Dictionary in _infos:
			lines.append(str((info["provider"] as Callable).call()))
		_info_label.text = "\n".join(lines)


func toggle() -> void:
	_panel.visible = not _panel.visible
	if _panel.visible:
		_fps_timer = 0.0
		_refresh_text()
		_controls[0].grab_focus()


func is_open() -> bool:
	return _panel != null and _panel.visible


# --- Options added by game systems --------------------------------------------

## Adds a button; it is removed again when `source` leaves the scene tree.
func add_button(source: Node, key: String, action: Callable) -> void:
	_add_control(source, _make_button(key, action))


## Adds an on/off switch; it is removed again when `source` leaves the scene tree.
func add_check(source: Node, key: String, start_on: bool, action: Callable) -> void:
	_add_control(source, _make_check(key, start_on, action))


## Adds a line of live info (refreshed with the FPS counter).
func add_info(source: Node, provider: Callable) -> void:
	_infos.append({"owner": source, "provider": provider})
	_watch_owner(source)


## Shows text in the result area at the bottom of the menu.
func show_result(text: String) -> void:
	_last_action = Callable()
	_result_label.text = text


func _add_control(source: Node, control: BaseButton) -> void:
	control.pressed.connect(_mark_run)
	control.set_meta("debug_owner", source)
	_box.add_child(control)
	_box.move_child(control, _close_button.get_index())
	_controls.insert(_controls.find(_close_button), control)
	_link_focus()
	_watch_owner(source)


## Game-system options (god mode, gain a level, …) keep this run off the shared leaderboard.
func _mark_run() -> void:
	if GameAuthority.run != null:
		GameAuthority.run.debug_used = true


## Removes a system's options when it leaves the scene (for example on Retry).
func _watch_owner(source: Node) -> void:
	if _owners.has(source):
		return
	_owners[source] = true
	source.tree_exiting.connect(_remove_owner.bind(source), CONNECT_ONE_SHOT)


func _remove_owner(source: Node) -> void:
	_owners.erase(source)
	for control: Control in _controls.duplicate():
		if control.get_meta("debug_owner", null) == source:
			_controls.erase(control)
			control.queue_free()
	for info: Dictionary in _infos.duplicate():
		if info["owner"] == source:
			_infos.erase(info)
	_link_focus()


func _track_touch(touch: InputEventScreenTouch) -> void:
	if not touch.pressed:
		_touches.erase(touch.index)
		return
	_touches[touch.index] = true
	if _touches.size() >= Data.cfg_int("debug.menu_touch_fingers"):
		_touches.clear()
		toggle()


# --- Building the menu -------------------------------------------------------

func _build() -> void:
	var margin_px: int = Data.cfg_int("ui.screen_margin_px")
	_panel = PanelContainer.new()
	# Clear of notches and rounded corners on phones.
	_panel.position = SafeArea.rect(get_viewport()).position + Vector2(margin_px, margin_px)
	add_child(_panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, margin_px)
	_panel.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = _menu_size()
	margin.add_child(scroll)
	_box = VBoxContainer.new()
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_box)

	_box.add_child(_make_label("DEBUG_MENU_TITLE", true))
	_version_label = _make_label("", false)
	_box.add_child(_version_label)
	_fps_label = _make_label("", false)
	_box.add_child(_fps_label)
	_info_label = _make_label("", false)
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(_info_label)

	_close_button = _make_button("DEBUG_CLOSE", toggle)
	_controls = [
		_make_check("DEBUG_PSEUDO_LOC", Localization.pseudo_enabled, _on_pseudo_toggled),
		_make_check("DEBUG_SIMULATE_RELEASE", Data.simulate_release, _on_simulate_release_toggled),
		_make_button("DEBUG_GATE_TEST", _show_gate_test),
		_make_button("DEBUG_VALIDATE_FIXTURES", _on_validate_pressed),
		_make_button("DEBUG_RNG_TEST", _show_rng_test),
		_close_button,
	]
	for control: Control in _controls:
		_box.add_child(control)
	_link_focus()

	_result_label = _make_label("", false)
	_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(_result_label)


func _make_label(key: String, translate: bool) -> Label:
	var label := Label.new()
	label.text = key
	# Labels filled from code with tr() must not be translated a second time.
	if not translate:
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	return label


func _make_button(key: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = key
	button.custom_minimum_size.y = Data.cfg_float("ui.min_touch_target_px")
	button.pressed.connect(on_pressed)
	return button


func _make_check(key: String, start_on: bool, on_toggled: Callable) -> CheckButton:
	var check := CheckButton.new()
	check.text = key
	check.button_pressed = start_on
	check.custom_minimum_size.y = Data.cfg_float("ui.min_touch_target_px")
	check.toggled.connect(on_toggled)
	return check


## D-pad / arrow keys move through the controls in order and wrap around.
func _link_focus() -> void:
	var count: int = _controls.size()
	for i: int in count:
		var control: Control = _controls[i]
		control.focus_mode = Control.FOCUS_ALL
		control.focus_neighbor_top = control.get_path_to(_controls[(i - 1 + count) % count])
		control.focus_neighbor_bottom = control.get_path_to(_controls[(i + 1) % count])


func _menu_size() -> Vector2:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	return Vector2(view.x * 0.5, view.y - margin_px * 4.0)


# --- Phase 1 tests -------------------------------------------------------------

func _refresh_text() -> void:
	_version_label.text = tr("DEBUG_VERSION_LABEL") % ProjectSettings.get_setting("application/config/version", "")
	if _last_action.is_valid():
		_last_action.call()


func _on_pseudo_toggled(on: bool) -> void:
	Localization.set_pseudo(on)


func _on_simulate_release_toggled(on: bool) -> void:
	Data.simulate_release = on
	Data.reload()


func _load_fixtures() -> Dictionary:
	return DataLoader.load_set(FIXTURE_DIR, FIXTURE_SCHEMAS, Data.is_release())


## Also prints the problems to the Output panel, like a real data error would.
func _on_validate_pressed() -> void:
	_show_fixture_validation()
	DataLoader.log_result(_load_fixtures())


func _show_gate_test() -> void:
	_last_action = _show_gate_test
	var release: bool = Data.is_release()
	var gates: Dictionary = _load_fixtures()["gates"]
	var gate: Dictionary = gates.get(GATE_FIXTURE, {"kept": [], "refused": [], "warnings": []})
	var mode: String = tr("DEBUG_MODE_RELEASE") if release else tr("DEBUG_MODE_DEV")
	var lines: PackedStringArray = [tr("DEBUG_GATE_RESULT") % [
		mode, (gate["kept"] as Array).size(), (gate["refused"] as Array).size(), (gate["warnings"] as Array).size()
	]]
	for report: Dictionary in gate["refused"]:
		lines.append(ContentGate.describe(report, true))
	for report: Dictionary in gate["warnings"]:
		lines.append(ContentGate.describe(report, false))
	_result_label.text = "\n".join(lines)


func _show_fixture_validation() -> void:
	_last_action = _show_fixture_validation
	var result: Dictionary = _load_fixtures()
	var lines: PackedStringArray = []
	for err: Dictionary in result["errors"]:
		lines.append(JsonValidator.describe(err))
	for warn: Dictionary in result["warnings"]:
		lines.append(JsonValidator.describe(warn))
	_result_label.text = tr("DEBUG_VALIDATE_OK") if lines.is_empty() else "\n".join(lines)


func _show_rng_test() -> void:
	_last_action = _show_rng_test
	var seed_value: int = Data.cfg_int("debug.rng_test_seed")
	var rng := RunRng.new(seed_value)
	var lines: PackedStringArray = []
	for stream: String in RunRng.STREAMS:
		var numbers: PackedStringArray = []
		for number: int in rng.next_ints(stream, Data.cfg_int("debug.rng_test_count")):
			numbers.append(str(number))
		lines.append(tr("DEBUG_RNG_RESULT") % [seed_value, tr("DEBUG_RNG_STREAM_" + stream.to_upper()), ", ".join(numbers)])
	_result_label.text = "\n".join(lines)
