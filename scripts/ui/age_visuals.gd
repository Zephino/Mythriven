class_name AgeVisuals
extends CanvasLayer
## How each Age looks (GAME_DESIGN.md: Run arc): a colour shift through a
## CanvasModulate tween (warm gold at Dusk, blue moonlight at Night, deeper
## at Deep Night, faded at the Unraveling), drifting embers from Night on,
## loose glowing threads at the screen edges from Deep Night, and a banner
## naming the new Age. Embers and threads are a small fixed set of points.

var world_tint: CanvasModulate

var _overlay: Node2D
var _age: String = ""
var _points := PackedVector2Array()
var _speeds := PackedFloat32Array()
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	layer = 5
	_overlay = Node2D.new()
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)
	_rng.seed = GameAuthority.run.seed_value if GameAuthority.run != null else 1
	var count: int = Data.cfg_int("run_arc.ember_count")
	_points.resize(count)
	_speeds.resize(count)
	for i: int in count:
		_points[i] = Vector2(_rng.randf(), _rng.randf())
		_speeds[i] = _rng.randf_range(0.02, 0.06)
	GameAuthority.age_changed.connect(_on_age_changed)


func _on_age_changed(age_id: String) -> void:
	var first: bool = _age == ""
	_age = age_id
	var colors: Dictionary = Data.cfg("run_arc.age_colors")
	var target := Color.html(str(colors.get(age_id, "#ffffff")))
	if world_tint != null:
		if first:
			world_tint.color = target
		else:
			create_tween().tween_property(world_tint, "color", target, Data.cfg_float("run_arc.age_fade_s"))
	if not first:
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("AGE_" + age_id.to_upper() + "_BANNER"))


func _process(delta: float) -> void:
	if RunArc.AGES.find(_age) < RunArc.AGES.find(RunArc.NIGHT):
		return
	for i: int in _points.size():
		var point: Vector2 = _points[i]
		point.y = fposmod(point.y - _speeds[i] * delta, 1.0)
		point.x = fposmod(point.x + sin(point.y * TAU * 2.0 + i) * 0.002, 1.0)
		_points[i] = point
	_overlay.queue_redraw()


func _draw_overlay() -> void:
	var index: int = RunArc.AGES.find(_age)
	if index < RunArc.AGES.find(RunArc.NIGHT):
		return
	var view: Vector2 = get_viewport().get_visible_rect().size
	var ember := Color.html(Data.cfg_string("run_arc.ember_color"))
	for i: int in _points.size():
		_overlay.draw_circle(_points[i] * view, 1.5, ember)
	if index < RunArc.AGES.find(RunArc.DEEP_NIGHT):
		return
	# Loose glowing threads drift along the screen edges.
	var thread := Color.html(Data.cfg_string("run_arc.thread_color"))
	var edge: float = Data.cfg_float("run_arc.thread_edge_px")
	for i: int in _points.size():
		var p: Vector2 = _points[i]
		var x: float = p.x * edge if i % 2 == 0 else view.x - p.x * edge
		var y: float = p.y * view.y
		_overlay.draw_line(Vector2(x, y), Vector2(x + sin(y * 0.05) * 6.0, y + 18.0), thread, 1.0)
