class_name GodButtons
extends CanvasLayer
## The two god buttons (GAME_DESIGN.md: Binding and summoning): one per bound
## god in the bottom-right corner, each with a meter ring around its portrait
## (a placeholder colour circle) that glows when full. Tap one to summon; on
## PC it's Q / E, on a gamepad LB / RB. While a Resonance is ready, a
## Resonance button appears above them and both rings pulse together. Their
## size follows the touch-control size setting; they move to the bottom-left
## when the joystick is set to the right side only, and stay clear of phone notches.

var gods: GodManager
var resonance: ResonanceManager

var _root: Control
var _buttons: Array[Button] = []
var _resonance_button: Button
var _rings: Node2D


func _ready() -> void:
	layer = 12
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var size: float = Data.cfg_float("ui.god_button_min_px")
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	for index: int in 3:
		var button := Button.new()
		button.add_to_group(TouchJoystick.BLOCKERS)
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(size, size)
		button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		button.position = Vector2(-margin_px - size * (2 - index) - margin_px * (1 - index), -margin_px - size)
		button.pressed.connect(_on_pressed.bind(index))
		_root.add_child(button)
		_buttons.append(button)
	_resonance_button = Button.new()
	_resonance_button.add_to_group(TouchJoystick.BLOCKERS)
	_resonance_button.text = "UI_RESONANCE_BUTTON"
	_resonance_button.focus_mode = Control.FOCUS_NONE
	_resonance_button.custom_minimum_size = Vector2(size, size * 0.6)
	_resonance_button.visible = false
	_resonance_button.pressed.connect(_on_resonance_pressed)
	_root.add_child(_resonance_button)
	_rings = Node2D.new()
	_rings.draw.connect(_draw_rings)
	_root.add_child(_rings)


func button_center(index: int) -> Vector2:
	var button: Button = _buttons[index]
	return button.global_position + button.size * 0.5


func _process(_delta: float) -> void:
	var player: Player = GameAuthority.local_player()
	var count: int = gods.gods_of(player).size() if player != null and gods != null else 0
	var size: float = _size()
	for index: int in 3:
		var button: Button = _buttons[index]
		button.visible = index < count
		button.custom_minimum_size = Vector2(size, size)
		button.size = button.custom_minimum_size
		button.position = _slot_position(index, size)
		if button.visible:
			var god: Dictionary = gods.gods_of(player)[index]["god"]
			# The god's face (owner request 10/31/2026), or their initial without art.
			var god_id: String = str(god.get("id", ""))
			if button.get_meta("god", "") != god_id:
				button.set_meta("god", god_id)
				button.icon = UiTheme.god_face(god_id, Data.cfg_int("ui.portrait_scale"))
				button.expand_icon = button.icon != null
				button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				button.text = "" if button.icon != null else tr(str(god.get("name_key", ""))).left(1)
	# The Resonance button exists only while it can be used, just above the god buttons.
	_resonance_button.visible = player != null and resonance != null and resonance.ready_for(player)
	if _resonance_button.visible:
		var between: Vector2 = (_slot_position(0, size) + _slot_position(1, size) + Vector2(size, 0.0)) * 0.5
		_resonance_button.position = Vector2(between.x - _resonance_button.size.x * 0.5,
				between.y - _resonance_button.size.y - Data.cfg_float("ui.screen_margin_px"))
	_rings.queue_redraw()


func _size() -> float:
	return Data.cfg_float("ui.god_button_min_px") * Settings.control_scale()


## Top-left corner of god button `index` (0, 1, or 2 for the hidden shrine's third slot, on the inner side),
## inside the safe area.
func _slot_position(index: int, size: float) -> Vector2:
	var safe: Rect2 = SafeArea.rect(get_viewport())
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var y: float = safe.end.y - margin_px - size
	if Settings.text("joystick_side") == "right":
		return Vector2(safe.position.x + margin_px + (size + margin_px) * index, y)
	var place: int = index if index < 2 else -1
	return Vector2(safe.end.x - margin_px - size * (2 - place) - margin_px * (1 - place), y)


func _on_resonance_pressed() -> void:
	var player: Player = GameAuthority.local_player()
	if player != null and resonance != null:
		resonance.fire(player)


func _on_pressed(index: int) -> void:
	var player: Player = GameAuthority.local_player()
	if player != null and gods != null:
		gods.summon(player, index)


func _draw_rings() -> void:
	var player: Player = GameAuthority.local_player()
	if player == null or gods == null:
		return
	var slots: Array = gods.gods_of(player)
	for index: int in slots.size():
		var center: Vector2 = button_center(index)
		var radius: float = _size() * 0.45
		var color := Color.html(str(slots[index]["god"].get("placeholder_color", "#ffffff")))
		var fill: float = float(slots[index]["meter"])
		_rings.draw_circle(center, radius * 0.7, Color(color, 0.55))
		_rings.draw_arc(center, radius, 0.0, TAU, 32, Color(0, 0, 0, 0.5), 5.0)
		_rings.draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * fill, 32, color, 5.0)
		if fill >= 1.0:
			# Both buttons pulse together while a Resonance is ready.
			var speed: float = 12.0 if _resonance_button.visible else 6.0
			var pulse: float = 0.5 + 0.5 * sin(GameAuthority.run.elapsed_s * speed)
			_rings.draw_arc(center, radius + 4.0, 0.0, TAU, 32, Color(1, 1, 1, pulse), 2.0)
