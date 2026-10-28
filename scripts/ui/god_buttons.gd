class_name GodButtons
extends CanvasLayer
## The two god buttons (GAME_DESIGN.md: Binding and summoning): one per bound
## god in the bottom-right corner, each with a meter ring around its portrait
## (a placeholder colour circle) that glows when full. Tap one to summon; on
## PC it's Q / E, on a gamepad LB / RB. Phase 12 adds the Resonance button
## between them while both meters are full.

var gods: GodManager

var _root: Control
var _buttons: Array[Button] = []
var _rings: Node2D


func _ready() -> void:
	layer = 12
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var size: float = Data.cfg_float("ui.god_button_min_px")
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	for index: int in 2:
		var button := Button.new()
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(size, size)
		button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		button.position = Vector2(-margin_px - size * (2 - index) - margin_px * (1 - index), -margin_px - size)
		button.pressed.connect(_on_pressed.bind(index))
		_root.add_child(button)
		_buttons.append(button)
	_rings = Node2D.new()
	_rings.draw.connect(_draw_rings)
	_root.add_child(_rings)


func button_center(index: int) -> Vector2:
	var button: Button = _buttons[index]
	return button.global_position + button.size * 0.5


func _process(_delta: float) -> void:
	var player: Player = GameAuthority.local_player()
	var count: int = gods.gods_of(player).size() if player != null and gods != null else 0
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var size: float = Data.cfg_float("ui.god_button_min_px")
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	for index: int in 2:
		var button: Button = _buttons[index]
		button.visible = index < count
		button.position = Vector2(screen.x - margin_px - size * (2 - index) - margin_px * (1 - index), screen.y - margin_px - size)
		if button.visible:
			var god: Dictionary = gods.gods_of(player)[index]["god"]
			button.text = tr(str(god.get("name_key", ""))).left(1)
	_rings.queue_redraw()


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
		var radius: float = Data.cfg_float("ui.god_button_min_px") * 0.45
		var color := Color.html(str(slots[index]["god"].get("placeholder_color", "#ffffff")))
		var fill: float = float(slots[index]["meter"])
		_rings.draw_circle(center, radius * 0.7, Color(color, 0.55))
		_rings.draw_arc(center, radius, 0.0, TAU, 32, Color(0, 0, 0, 0.5), 5.0)
		_rings.draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * fill, 32, color, 5.0)
		if fill >= 1.0:
			var pulse: float = 0.5 + 0.5 * sin(GameAuthority.run.elapsed_s * 6.0)
			_rings.draw_arc(center, radius + 4.0, 0.0, TAU, 32, Color(1, 1, 1, pulse), 2.0)
