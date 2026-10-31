class_name Shrines
extends Node2D
## Shrines (GAME_DESIGN.md: Finding gods; Shrine types). One appears about
## every 3 minutes, 1.5–2 screens from the player, with an arrow at the edge
## of the screen, and vanishes after 90 s if ignored. Its look matches the
## god's pantheon (Greek temple, Norse runestone, Egyptian obelisk, Celtic
## stone circle; placeholder shapes). When the god is first seen it says a
## line. Peaceful shrines bind after standing at them for 2 s; trial shrines
## start a Duel, Endurance, or Chase trial. Hidden shrines (Phase 14) use add().
## Co-op: each player who touches a peaceful shrine while it lasts binds their
## own copy of the god (GAME_DESIGN.md: Fairness rules).

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
	CoopMirror.attach(self, "shrines")


## Places a shrine for `god_id` at `at` (or picks a god when "").
func add(at: Vector2, god_id: String = "", hidden: bool = false) -> Dictionary:
	var run: RunState = GameAuthority.run
	if god_id == "":
		god_id = GodRules.pick_for_shrine(run.level_data, _taken_ids(), run.elapsed_s, run.rng.world, hidden)
	var god: Dictionary = GodRules.find(god_id)
	if god.is_empty():
		return {}
	var seed_value: int = run.rng.world.randi()
	var shrine: Dictionary = {"god_id": god_id, "god": god, "pos": at, "left": Data.cfg_float("gods.shrine_lifetime_s"),
			"progress": 0.0, "seen": false, "hidden": hidden, "progress_by": {}, "bound_by": [], "seed": seed_value,
			"layout": ShrineLayout.make(seed_value, str(god.get("pantheon", "")))}
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
	for shrine: Dictionary in shrines.duplicate():
		if trial != null and trial.active and trial.shrine == shrine:
			continue
		shrine["left"] = float(shrine["left"]) - delta
		if float(shrine["left"]) <= 0.0:
			shrines.erase(shrine)
			continue
		for player: Player in GameAuthority.players:
			if not shrines.has(shrine):
				break
			if player.alive and not (shrine["bound_by"] as Array).has(player.player_id):
				_check_player(shrine, player, delta)
		var most: float = 0.0
		for value: Variant in (shrine["progress_by"] as Dictionary).values():
			most = maxf(most, float(value))
		shrine["progress"] = most
	queue_redraw()
	_arrows.queue_redraw()


func _check_player(shrine: Dictionary, player: Player, delta: float) -> void:
	var dist: float = player.position.distance_to(shrine["pos"])
	if player.is_local and not bool(shrine["seen"]) and dist <= _view().size.x * 0.5:
		shrine["seen"] = true
		if banter != null:
			banter.say_line(GodRules.line("found", str(shrine["god_id"]), ""))
	if dist > Data.cfg_float("gods.shrine_radius_px") + player.body_radius:
		(shrine["progress_by"] as Dictionary).erase(player.player_id)
		return
	_touch(shrine, player, delta)


func _touch(shrine: Dictionary, player: Player, delta: float) -> void:
	var kind: String = str((shrine["god"].get("shrine", {}) as Dictionary).get("type", "peaceful"))
	if kind == "peaceful":
		var progress: Dictionary = shrine["progress_by"]
		progress[player.player_id] = float(progress.get(player.player_id, 0.0)) + delta
		if float(progress[player.player_id]) >= Data.cfg_float("gods.peaceful_bind_s"):
			offer_binding(shrine, player)
	elif trial != null and not trial.active and not GameAuthority.run.boss_arena_active:
		trial.begin(shrine, player)


## Binds the shrine's god, asking which god to release when both slots are full.
func offer_binding(shrine: Dictionary, player: Player) -> void:
	if GameAuthority.players.size() > 1:
		# Co-op: the shrine stays for the other players.
		(shrine["bound_by"] as Array).append(player.player_id)
		(shrine["progress_by"] as Dictionary).erase(player.player_id)
	else:
		shrines.erase(shrine)
	if not gods.is_full(player):
		gods.bind(player, str(shrine["god_id"]))
		return
	if choice != null:
		choice.ask(player, str(shrine["god_id"]))


# --- Co-op (CoopMirror) ------------------------------------------------------------------

func net_capture() -> Variant:
	var out: Array = []
	for shrine: Dictionary in shrines:
		out.append([str(shrine["god_id"]), shrine["pos"], float(shrine["left"]), float(shrine["progress"]), bool(shrine["hidden"]),
				int(shrine.get("seed", 0))])
	return out


func net_apply(state: Variant) -> void:
	shrines.clear()
	for row: Variant in state:
		var god: Dictionary = GodRules.find(str(row[0]))
		if not god.is_empty():
			var seed_value: int = int(row[5]) if (row as Array).size() > 5 else 0
			shrines.append({"god_id": str(row[0]), "god": god, "pos": row[1], "left": float(row[2]), "progress": float(row[3]),
				"seen": true, "hidden": bool(row[4]), "progress_by": {}, "bound_by": [], "seed": seed_value,
				"layout": ShrineLayout.make(seed_value, str(god.get("pantheon", "")))})
	_arrows.queue_redraw()


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
		# A shrine built from its people's parts round the altar, the god on their throne or walking about inside
		# (owner request 10/31/2026; ShrineLayout). Gods without art keep the plain altar and a coloured dot.
		var art: Dictionary = PixelArt.god(str(shrine.get("god_id", god.get("id", ""))))
		var parts: Dictionary = PixelArt.find("shrines/" + str(god.get("pantheon", "")))
		if art.is_empty() or parts.is_empty() or not shrine.has("layout"):
			_draw_altar(at, god, color)
			if not art.is_empty():
				PixelArt.draw_standing(self, art, at + Vector2(0, Data.cfg_float("gods.throne_feet_px")), false, Color.WHITE,
						false, 0.0, "seated")
			else:
				draw_circle(at, 4.0, color)
		else:
			_draw_temple(at, shrine["layout"], parts, art)
		var progress: float = float(shrine["progress"]) / maxf(Data.cfg_float("gods.peaceful_bind_s"), 0.01)
		if progress > 0.0:
			draw_arc(at, Data.cfg_float("gods.shrine_radius_px"), -PI * 0.5, -PI * 0.5 + TAU * progress, 32, color, 3.0)
		else:
			draw_arc(at, Data.cfg_float("gods.shrine_radius_px"), 0.0, TAU, 32, Color(color, 0.4), 1.0)


## Floor first, then walls, columns, altar, decorations, throne and god from the back to the front, so nearer things
## cover farther ones.
func _draw_temple(at: Vector2, layout: Dictionary, parts: Dictionary, art: Dictionary) -> void:
	var frames: Dictionary = parts["frames"]
	for tile: Array in layout["floor"]:
		var floor_frames: Array = frames["floor"]
		draw_texture(floor_frames[int(tile[1]) % floor_frames.size()], at + Vector2(tile[0]))
	var items: Array = []
	for item: Dictionary in layout["objects"]:
		items.append([Vector2(item["at"]).y, item])
	var seconds: float = GameAuthority.run.elapsed_s if GameAuthority.run != null else 0.0
	var walk: Dictionary = {} if bool(layout["sits"]) else ShrineLayout.walker(layout, seconds, Data.cfg_float("gods.temple_walk_speed_px"))
	items.append([Vector2(layout["throne"]).y, {"part": "throne"}])
	if not walk.is_empty():
		items.append([Vector2(walk["feet"]).y, {"part": "god"}])
	items.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for entry: Array in items:
		var item: Dictionary = entry[1]
		match str(item["part"]):
			"throne":
				PixelArt.draw_standing(self, art, at + Vector2(layout["throne"]), false, Color.WHITE, false, 0.0,
						"seated" if bool(layout["sits"]) else "throne")
			"god":
				PixelArt.draw_standing(self, art, at + Vector2(walk["feet"]), bool(walk["left"]), Color.WHITE, true,
						float(walk["stride"]))
			_:
				var texture: ImageTexture = (frames[str(item["part"])] as Array)[0]
				draw_texture(texture, at + Vector2(item["at"]) - Vector2(texture.get_width() * 0.5, texture.get_height()))


## The altar's stones, in the style of the god's people.
func _draw_altar(at: Vector2, god: Dictionary, color: Color) -> void:
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
