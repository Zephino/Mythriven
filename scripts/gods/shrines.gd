class_name Shrines
extends Node2D
## Shrines (GAME_DESIGN.md: Finding gods; Shrine types). One appears about
## every 3 minutes, 1.5–2 screens from the player, with an arrow at the edge
## of the screen, and vanishes after 90 s if ignored. Its look matches the
## god's pantheon (Greek temple, Norse runestone, Egyptian obelisk, Celtic
## stone circle; placeholder shapes). When the god is first seen it says a
## line. Peaceful shrines bind after standing at them for 2 s; trial shrines
## start a Duel, Endurance, or Chase trial. Hidden shrines (Phase 14) use add().

signal shrine_added(shrine: Dictionary)

var gods: GodManager
var trial: GodTrial
var choice: GodChoiceScreen
var banter: BanterBubble

## Each {"god_id", "god", "pos", "left", "progress", "seen", "hidden"}.
var shrines: Array[Dictionary] = []
var _next_s: float = 0.0
var _arrows: Node2D


func _ready() -> void:
	z_index = 1
	_next_s = Data.cfg_float("gods.first_shrine_s")
	var layer := CanvasLayer.new()
	layer.layer = 9
	add_child(layer)
	_arrows = Node2D.new()
	_arrows.draw.connect(_draw_arrows)
	layer.add_child(_arrows)


## Places a shrine for `god_id` at `at` (or picks a god when "").
func add(at: Vector2, god_id: String = "", hidden: bool = false) -> Dictionary:
	var run: RunState = GameAuthority.run
	if god_id == "":
		god_id = GodRules.pick_for_shrine(run.level_data, _taken_ids(), run.elapsed_s, run.rng.world, hidden)
	var god: Dictionary = GodRules.find(god_id)
	if god.is_empty():
		return {}
	var shrine: Dictionary = {"god_id": god_id, "god": god, "pos": at, "left": Data.cfg_float("gods.shrine_lifetime_s"),
			"progress": 0.0, "seen": false, "hidden": hidden}
	shrines.append(shrine)
	shrine_added.emit(shrine)
	return shrine


## A shrine 1.5–2 screens away from a player, in a random direction.
func spawn_timed() -> Dictionary:
	var player: Player = GameAuthority.local_player()
	if player == null or GameAuthority.run == null:
		return {}
	var rng: RandomNumberGenerator = GameAuthority.run.rng.world
	var screens: Array = Data.cfg("gods.shrine_distance_screens")
	var dist: float = _view().size.x * rng.randf_range(float(screens[0]), float(screens[1]))
	return add(player.position + Vector2.from_angle(rng.randf() * TAU) * dist)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for shrine: Dictionary in shrines:
		shrine["pos"] = Vector2(shrine["pos"]) - shift_px


func _process(delta: float) -> void:
	var run: RunState = GameAuthority.run
	if run == null or run.ended:
		return
	if run.elapsed_s >= _next_s:
		_next_s = run.elapsed_s + Data.cfg_float("gods.shrine_interval_s")
		spawn_timed()
	var player: Player = GameAuthority.local_player()
	for shrine: Dictionary in shrines.duplicate():
		if trial != null and trial.active and trial.shrine == shrine:
			continue
		shrine["left"] = float(shrine["left"]) - delta
		if float(shrine["left"]) <= 0.0:
			shrines.erase(shrine)
			continue
		if player == null or not player.alive:
			continue
		var dist: float = player.position.distance_to(shrine["pos"])
		if not bool(shrine["seen"]) and dist <= _view().size.x * 0.5:
			shrine["seen"] = true
			if banter != null:
				banter.say_line(GodRules.line("found", str(shrine["god_id"]), ""))
		if dist > Data.cfg_float("gods.shrine_radius_px") + player.body_radius:
			shrine["progress"] = 0.0
			continue
		_touch(shrine, player, delta)
	queue_redraw()
	_arrows.queue_redraw()


func _touch(shrine: Dictionary, player: Player, delta: float) -> void:
	var kind: String = str((shrine["god"].get("shrine", {}) as Dictionary).get("type", "peaceful"))
	if kind == "peaceful":
		shrine["progress"] = float(shrine["progress"]) + delta
		if float(shrine["progress"]) >= Data.cfg_float("gods.peaceful_bind_s"):
			offer_binding(shrine, player)
	elif trial != null and not trial.active:
		trial.begin(shrine, player)


## Binds the shrine's god, asking which god to release when both slots are full.
func offer_binding(shrine: Dictionary, player: Player) -> void:
	shrines.erase(shrine)
	if not gods.is_full(player):
		gods.bind(player, str(shrine["god_id"]))
		return
	if choice != null:
		choice.ask(player, str(shrine["god_id"]))


func _taken_ids() -> PackedStringArray:
	var ids: PackedStringArray = gods.all_bound_ids() if gods != null else PackedStringArray()
	for shrine: Dictionary in shrines:
		ids.append(str(shrine["god_id"]))
	return ids


func _view() -> Rect2:
	var size: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	var camera: Camera2D = get_viewport().get_camera_2d()
	var center: Vector2 = camera.get_screen_center_position() if camera != null else Vector2.ZERO
	return Rect2(center - size * 0.5, size)


func _draw() -> void:
	for shrine: Dictionary in shrines:
		var at: Vector2 = shrine["pos"]
		var god: Dictionary = shrine["god"]
		var color := Color.html(str(god.get("placeholder_color", "#ffffff")))
		var stone := Color.html(Data.cfg_string("gods.shrine_stone_color"))
		match str(god.get("pantheon", "")):
			"greek":
				draw_rect(Rect2(at + Vector2(-14, -12), Vector2(28, 4)), stone)
				for x: float in [-11.0, -4.0, 3.0, 10.0]:
					draw_rect(Rect2(at + Vector2(x - 1.5, -8), Vector2(3, 14)), stone)
				draw_rect(Rect2(at + Vector2(-15, 6), Vector2(30, 3)), stone)
			"norse":
				draw_rect(Rect2(at + Vector2(-5, -16), Vector2(10, 26)), stone)
				draw_line(at + Vector2(-3, -10), at + Vector2(3, 4), color, 1.5)
			"egyptian":
				draw_colored_polygon(PackedVector2Array([at + Vector2(-5, 10), at + Vector2(5, 10), at + Vector2(3, -14),
						at + Vector2(0, -19), at + Vector2(-3, -14)]), stone)
			_:
				for k: int in 7:
					draw_circle(at + Vector2.from_angle(TAU * k / 7.0) * 14.0, 3.0, stone)
		draw_circle(at, 4.0, color)
		var progress: float = float(shrine["progress"]) / maxf(Data.cfg_float("gods.peaceful_bind_s"), 0.01)
		if progress > 0.0:
			draw_arc(at, Data.cfg_float("gods.shrine_radius_px"), -PI * 0.5, -PI * 0.5 + TAU * progress, 32, color, 3.0)
		else:
			draw_arc(at, Data.cfg_float("gods.shrine_radius_px"), 0.0, TAU, 32, Color(color, 0.4), 1.0)


## Edge-of-screen arrows pointing at shrines that are off screen.
func _draw_arrows() -> void:
	var view: Rect2 = _view()
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var margin: float = Data.cfg_float("ui.min_touch_target_px") * 0.5
	for shrine: Dictionary in shrines:
		var at: Vector2 = shrine["pos"]
		if view.has_point(at):
			continue
		var color := Color.html(str(shrine["god"].get("placeholder_color", "#ffffff")))
		var dir: Vector2 = (at - view.get_center()).normalized()
		var half: Vector2 = screen * 0.5 - Vector2(margin, margin)
		var scale: float = minf(half.x / maxf(absf(dir.x), 0.001), half.y / maxf(absf(dir.y), 0.001))
		var tip: Vector2 = screen * 0.5 + dir * scale
		draw_arrow(_arrows, tip, dir, color)


static func draw_arrow(canvas: CanvasItem, tip: Vector2, dir: Vector2, color: Color) -> void:
	var size: float = Data.cfg_float("gods.arrow_px")
	var back: Vector2 = tip - dir * size
	canvas.draw_colored_polygon(PackedVector2Array([tip, back + dir.orthogonal() * size * 0.5, back - dir.orthogonal() * size * 0.5]),
			color)
