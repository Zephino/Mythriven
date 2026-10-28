class_name Compass
extends CanvasLayer
## The compass (GAME_DESIGN.md: Regions and POIs): an icon at the edge of the
## screen for each point of interest within 4 screens that isn't on screen.
## Until it's within 2 screens it shows "?" instead of its type.

var pois: PoiManager

var _canvas: Node2D


func _ready() -> void:
	layer = 9
	_canvas = Node2D.new()
	_canvas.draw.connect(_draw_icons)
	add_child(_canvas)


func _process(_delta: float) -> void:
	_canvas.queue_redraw()


func _draw_icons() -> void:
	var player: Player = GameAuthority.local_player()
	if pois == null or player == null or GameAuthority.run == null:
		return
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var view: Vector2 = screen / maxf(Data.cfg_float("camera.zoom"), 0.01)
	var camera: Camera2D = get_viewport().get_camera_2d()
	var center: Vector2 = camera.get_screen_center_position() if camera != null else player.position
	var margin: float = Data.cfg_float("ui.min_touch_target_px") * 0.5
	var font: Font = ThemeDB.fallback_font
	for poi: Dictionary in pois.nearby:
		if pois.state_of(poi) != "":
			continue
		var at: Vector2 = pois.to_local_px(poi["pos"])
		if Rect2(center - view * 0.5, view).has_point(at):
			continue
		var dir: Vector2 = (at - center).normalized()
		var half: Vector2 = screen * 0.5 - Vector2(margin, margin)
		var scale: float = minf(half.x / maxf(absf(dir.x), 0.001), half.y / maxf(absf(dir.y), 0.001))
		var spot: Vector2 = screen * 0.5 + dir * scale
		var revealed: bool = at.distance_to(player.position) <= view.x * Data.cfg_float("world.compass_reveal_screens")
		var data: Dictionary = PoiRules.find(str(poi["id"]))
		var color := Color.html(str(data.get("icon_color", "#ffffff"))) if revealed else Color.WHITE
		_canvas.draw_circle(spot, 12.0, Color(0, 0, 0, 0.55))
		if revealed:
			_canvas.draw_circle(spot, 7.0, color)
		else:
			_canvas.draw_string(font, spot + Vector2(-4, 6), "?", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, color)
		Shrines.draw_arrow(_canvas, spot + dir * 18.0, dir, Color(color, 0.8))
