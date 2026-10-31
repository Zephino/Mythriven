class_name EffectLayer
extends Node2D
## Short placeholder visuals for attacks (swing arcs, quake rings), drawn by
## one node from a fixed ring buffer. When the buffer is full the oldest
## effect is recycled (GAME_DESIGN.md: Effect budgets), so nothing is created
## or freed during play.

const GROUP := "effect_layer"
const KIND_ARC := 0
const KIND_RING := 1
## A weapon's picture sweeping through its swing from the Hero's hand (owner request 10/31/2026).
const KIND_SWING := 2
## A spear's picture jabbing out from the Hero's hand and drawing back (owner decision 10/31/2026: spears jab).
const KIND_JAB := 3
## A lightning bolt striking down from the sky (Spark, Tempest).
const KIND_BOLT := 4
## A dark aura swirling round the Hero (Shade, Oblivion).
const KIND_AURA := 5
## A spell's hit, in its element's style: a fire burst, ice shattering, sparks, a splash... (owner request 10/31/2026).
const KIND_BURST := 6
## An elemental reaction: its own burst (lightning arcing out, steam billowing, shards, a gust spreading).
const KIND_REACTION := 7
const ARC_SEGMENTS := 12
const RING_SEGMENTS := 24

var _capacity: int = 0
var _next: int = 0
var _active := PackedByteArray()
var _kind := PackedInt32Array()
var _pos := PackedVector2Array()
var _angle := PackedFloat32Array()
var _radius := PackedFloat32Array()
var _spread := PackedFloat32Array()
var _age := PackedFloat32Array()
var _duration := PackedFloat32Array()
var _color: Array[Color] = []
## KIND_SWING: the weapon's picture (PixelArt) for each effect, else {}.
var _art: Array[Dictionary] = []
## KIND_BURST and KIND_REACTION: the element or reaction id.
var _tag := PackedStringArray()


func setup() -> void:
	z_index = 5
	add_to_group(GROUP)
	Settings.fade_player_effect(self)
	_capacity = Data.cfg_int("effects.max_visual_effects")
	_active.resize(_capacity)
	_kind.resize(_capacity)
	_pos.resize(_capacity)
	_angle.resize(_capacity)
	_radius.resize(_capacity)
	_spread.resize(_capacity)
	_age.resize(_capacity)
	_duration.resize(_capacity)
	_color.resize(_capacity)
	_art.resize(_capacity)
	_tag.resize(_capacity)
	for i: int in _capacity:
		_art[i] = {}


## Co-op: an effect from something only the host's game runs (hazards,
## bosses, elites, infusions…), which the joining players should see too.
## Weapon swings aren't shared: each device draws every Hero's own attacks.
signal shared(effect_kind: int, at: Vector2, angle: float, size: float, spread: float, color: Color)


## A filled pie-slice swing from `at`, facing `angle`, `spread` radians wide.
## `share`: also show it on the joining players' screens in co-op.
func spawn_arc(at: Vector2, angle: float, arc_radius: float, spread: float, color: Color, share: bool = false) -> void:
	_spawn(KIND_ARC, at, angle, arc_radius, spread, color)
	if share:
		shared.emit(KIND_ARC, at, angle, arc_radius, spread, color)


## An expanding ring (quakes, bursts). `delay_s` holds it back (a hammer's shockwave waits for the hammer to land).
func spawn_ring(at: Vector2, ring_radius: float, color: Color, share: bool = false, delay_s: float = 0.0) -> void:
	var i: int = _next
	_spawn(KIND_RING, at, 0.0, ring_radius, 0.0, color)
	if _capacity > 0:
		_age[i] = -delay_s
	if share:
		shared.emit(KIND_RING, at, 0.0, ring_radius, 0.0, color)


## A weapon swinging from `at` (the Hero's hand) through `spread` radians centred on `angle`: its picture (`art`,
## PixelArt) turns about its grip from one side of the swing to the other. Each device draws its own.
func spawn_swing(at: Vector2, angle: float, spread: float, art: Dictionary, face_left: bool) -> void:
	if art.is_empty() or _capacity <= 0:
		return
	var i: int = _next
	_spawn(KIND_SWING, at, angle, 1.0 if face_left else 0.0, spread, Color.WHITE)
	_art[i] = art
	_duration[i] = Data.cfg_float("effects.swing_s")


## A spear jabbing from `at` (the Hero's hand) toward `angle`: its picture shoots forward `reach` pixels and draws
## back. Each device draws its own.
func spawn_jab(at: Vector2, angle: float, reach: float, art: Dictionary, face_left: bool) -> void:
	if art.is_empty() or _capacity <= 0:
		return
	var i: int = _next
	_spawn(KIND_JAB, at, angle, reach, 1.0 if face_left else 0.0, Color.WHITE)
	_art[i] = art
	_duration[i] = Data.cfg_float("effects.swing_s")


## A lightning bolt from the sky down onto `at` (owner request 10/31/2026: spells look like what they are).
## `big`: an evolved spell's (Tempest): a thicker bolt with forks (spread 1).
## `share`: also show it on the joining players' screens in co-op (a level's thunderstorm).
func spawn_bolt(at: Vector2, color: Color, big: bool = false, share: bool = false) -> void:
	var angle: float = randf() * TAU
	_spawn(KIND_BOLT, at, angle, Data.cfg_float("effects.bolt_height_px"), 1.0 if big else 0.0, color)
	if share:
		shared.emit(KIND_BOLT, at, angle, Data.cfg_float("effects.bolt_height_px"), 1.0 if big else 0.0, color)


## Dark wisps swirling round `at` out to `aura_radius` (Shade).
## `big`: an evolved spell's (Oblivion): a dark pool under thicker, doubled wisps (spread 1).
func spawn_aura(at: Vector2, aura_radius: float, color: Color, big: bool = false) -> void:
	_spawn(KIND_AURA, at, randf() * TAU, aura_radius, 1.0 if big else 0.0, color)


## Co-op (joining player): an effect the host shared.
func spawn_from_host(effect_kind: int, at: Vector2, angle: float, size: float, spread: float, color: Color) -> void:
	_spawn(effect_kind, at, angle, size, spread, color)


## Shows a reaction as its own burst, with a ring for its reach.
func on_reaction(reaction_id: String, at: Vector2, reach: float, _by: Player) -> void:
	var color: Color = Color.html(str(Elements.reaction(reaction_id).get("color", "#ffffff")))
	var size: float = maxf(reach, Data.cfg_float("effects.min_reaction_ring_px"))
	var i: int = _next
	_spawn(KIND_REACTION, at, randf() * TAU, size, 0.0, color)
	if _capacity > 0:
		_tag[i] = reaction_id
		_duration[i] = Data.cfg_float("effects.reaction_s")
	spawn_ring(at, size, color)


## A spell hitting at `at`: a small burst in its element's style. `big` for evolved spells.
func spawn_burst(at: Vector2, element: String, big: bool = false) -> void:
	if _capacity <= 0:
		return
	var i: int = _next
	_spawn(KIND_BURST, at, randf() * TAU, Data.cfg_float("effects.burst_px") * (1.7 if big else 1.0), 0.0, Elements.color(element))
	_tag[i] = element
	_duration[i] = Data.cfg_float("effects.burst_s")


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in _capacity:
		_pos[i] -= shift_px


func _spawn(effect_kind: int, at: Vector2, angle: float, size: float, spread: float, color: Color) -> void:
	if _capacity <= 0:
		return
	var i: int = _next
	_next = (_next + 1) % _capacity
	_active[i] = 1
	_kind[i] = effect_kind
	_pos[i] = at
	_angle[i] = angle
	_radius[i] = size
	_spread[i] = spread
	_age[i] = 0.0
	_duration[i] = Data.cfg_float("effects.attack_effect_s")
	_color[i] = color
	queue_redraw()


func _process(delta: float) -> void:
	var any: bool = false
	for i: int in _capacity:
		if _active[i] == 0:
			continue
		_age[i] += delta
		if _age[i] >= _duration[i]:
			_active[i] = 0
		any = true
	if any:
		queue_redraw()


func _draw() -> void:
	for i: int in _capacity:
		if _active[i] == 0:
			continue
		if _age[i] < 0.0:
			continue
		var t: float = clampf(_age[i] / _duration[i], 0.0, 1.0)
		var color: Color = _color[i]
		color.a *= 1.0 - t
		if _kind[i] == KIND_SWING:
			_draw_swing(i, t)
		elif _kind[i] == KIND_JAB:
			_draw_jab(i, t)
		elif _kind[i] == KIND_BOLT:
			_draw_bolt(i, t, color)
		elif _kind[i] == KIND_AURA:
			_draw_aura(i, t, color)
		elif _kind[i] == KIND_BURST:
			_draw_burst(i, t, color)
		elif _kind[i] == KIND_REACTION:
			_draw_reaction(i, t, color)
		elif _kind[i] == KIND_ARC:
			var points := PackedVector2Array([_pos[i]])
			for s: int in ARC_SEGMENTS + 1:
				var a: float = _angle[i] - _spread[i] * 0.5 + _spread[i] * s / ARC_SEGMENTS
				points.append(_pos[i] + Vector2.from_angle(a) * _radius[i])
			draw_colored_polygon(points, color)
		else:
			draw_arc(_pos[i], _radius[i] * (0.4 + 0.6 * t), 0.0, TAU, RING_SEGMENTS, color, 2.0)


## The weapon's picture is drawn tip up with its grip at the hand; turning it by (angle + a quarter turn) points it
## along `angle`. It sweeps from above down (mirrored, as the Hero is, when swinging to the left) and fades out over
## the last third.
func _draw_swing(i: int, t: float) -> void:
	var art: Dictionary = _art[i]
	var texture: ImageTexture = PixelArt.frame(art, false, 0.0)
	var grip: Vector2 = art.get("grip", texture.get_size() * 0.5)
	var left: bool = _radius[i] > 0.5
	var start: float = _angle[i] + (_spread[i] * 0.5 if left else -_spread[i] * 0.5)
	var swept: float = start + (-1.0 if left else 1.0) * _spread[i] * ease(t, 0.6)
	draw_set_transform(_pos[i], swept + PI * 0.5, Vector2(-1.0 if left else 1.0, 1.0))
	draw_texture(texture, -grip, Color(1, 1, 1, clampf((1.0 - t) * 3.0, 0.0, 1.0)))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Out fast, back slower: the grip travels along the jab, the picture pointing the way it goes.
func _draw_jab(i: int, t: float) -> void:
	var art: Dictionary = _art[i]
	var texture: ImageTexture = PixelArt.frame(art, false, 0.0)
	var grip: Vector2 = art.get("grip", texture.get_size() * 0.5)
	var out: float = ease(t / 0.35, 0.5) if t < 0.35 else 1.0 - ease((t - 0.35) / 0.65, 1.6)
	var along: Vector2 = Vector2.from_angle(_angle[i]) * _radius[i] * out
	draw_set_transform(_pos[i] + along, _angle[i] + PI * 0.5, Vector2(-1.0 if _spread[i] > 0.5 else 1.0, 1.0))
	draw_texture(texture, -grip)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## A jagged bolt from high above down to the spot (its zigzag fixed by its angle), bright core over a coloured glow,
## and a flash where it lands.
func _draw_bolt(i: int, t: float, color: Color) -> void:
	var top: Vector2 = _pos[i] + Vector2(sin(_angle[i]) * 12.0, -_radius[i])
	var points := PackedVector2Array([top])
	var steps: int = 6
	for k: int in range(1, steps):
		var along: Vector2 = top.lerp(_pos[i], float(k) / steps)
		points.append(along + Vector2(sin(_angle[i] * 7.0 + k * 2.3) * 6.0, 0.0))
	points.append(_pos[i])
	var core := Color(1.0, 1.0, 0.85, color.a)
	var big: bool = _spread[i] > 0.5
	draw_polyline(points, Color(color, color.a * 0.7), 7.0 if big else 4.0)
	draw_polyline(points, core, 2.5 if big else 1.5)
	if big:
		for k: int in [2, 4]:
			var fork: Vector2 = points[k] + Vector2((10.0 if k == 2 else -12.0) + sin(_angle[i] * 3.0) * 4.0, 14.0)
			draw_line(points[k], fork, Color(color, color.a * 0.7), 3.0)
			draw_line(points[k], fork, core, 1.0)
		draw_arc(_pos[i], 10.0 + 8.0 * t, 0.0, TAU, 16, Color(core, core.a * 0.6), 2.0)
	draw_circle(_pos[i], (9.0 if big else 6.0) * (1.0 - t) + 2.0, Color(core, core.a * 0.8))


## Wisps of shadow curling round the centre, turning as they fade.
func _draw_aura(i: int, t: float, color: Color) -> void:
	var big: bool = _spread[i] > 0.5
	if big:
		draw_circle(_pos[i], _radius[i] * (0.8 + 0.2 * t), Color(0.06, 0.02, 0.1, color.a * 0.35))
		draw_arc(_pos[i], _radius[i], 0.0, TAU, 32, Color(color.lightened(0.2), color.a * 0.8), 1.5)
	var wisps: int = 10 if big else 6
	for k: int in wisps:
		var start: float = _angle[i] + TAU * k / wisps + t * 2.0
		var r: float = _radius[i] * (0.55 + 0.45 * t)
		draw_arc(_pos[i], r, start, start + 0.7, 8, color, 3.0)
		draw_arc(_pos[i], r * 0.7, start + 0.4, start + 0.9, 6, Color(color, color.a * 0.6), 2.0)


## Each element's hit: pieces fly out from the spot and fade, shaped by the element. Directions come from the
## effect's random angle, so no two bursts look the same.
func _draw_burst(i: int, t: float, color: Color) -> void:
	var at: Vector2 = _pos[i]
	var r: float = _radius[i]
	var bright := Color(color.lightened(0.5), color.a)
	var pieces: int = 7
	match _tag[i]:
		"fire":                                                     # a puff of flame and flying embers
			draw_circle(at, r * (0.35 + 0.5 * t), Color(color, color.a * 0.6))
			draw_circle(at, r * (0.2 + 0.3 * t), Color(bright, bright.a * 0.8))
			for k: int in pieces:
				var d: Vector2 = Vector2.from_angle(_angle[i] + TAU * k / pieces)
				draw_circle(at + d * r * (0.4 + t) + Vector2(0, -r * t * 0.6), 1.5, bright)
		"ice":                                                      # shards flying out
			for k: int in pieces:
				var d: Vector2 = Vector2.from_angle(_angle[i] + TAU * k / pieces)
				var p: Vector2 = at + d * r * (0.2 + t)
				draw_line(p, p + d * 4.0, bright, 2.0)
				draw_line(p, p + d * 4.0, Color.WHITE * Color(1, 1, 1, color.a), 1.0)
		"lightning":                                                # crackling sparks
			for k: int in 5:
				var a: float = _angle[i] + TAU * k / 5.0 + t * 2.0
				var p1: Vector2 = at + Vector2.from_angle(a) * r * 0.3
				var p2: Vector2 = at + Vector2.from_angle(a + 0.4) * r * 0.65
				var p3: Vector2 = at + Vector2.from_angle(a - 0.2) * r * (0.9 + t * 0.3)
				draw_polyline(PackedVector2Array([at, p1, p2, p3]), bright, 1.5)
		"water":                                                    # a splash of drops
			draw_arc(at, r * (0.3 + 0.6 * t), 0.0, TAU, 16, Color(color, color.a * 0.6), 1.5)
			for k: int in pieces:
				var d: Vector2 = Vector2.from_angle(_angle[i] + TAU * k / pieces)
				draw_circle(at + d * r * (0.3 + 0.7 * t) + Vector2(0, r * t * t), 1.6, bright)
		"wind":                                                     # a curling puff
			for k: int in 3:
				var a: float = _angle[i] + TAU * k / 3.0 + t * 4.0
				draw_arc(at, r * (0.3 + 0.25 * k + 0.4 * t), a, a + 1.6, 8, bright, 1.5)
		"holy":                                                     # a star of light
			for k: int in 8:
				var d: Vector2 = Vector2.from_angle(_angle[i] + TAU * k / 8.0)
				var len: float = r * (0.5 + 0.6 * t) * (1.0 if k % 2 == 0 else 0.55)
				draw_line(at, at + d * len, bright, 1.5)
			draw_circle(at, 3.0 * (1.0 - t) + 1.0, Color(1, 1, 0.9, color.a))
		"dark":                                                     # shadow collapsing inward
			for k: int in pieces:
				var d: Vector2 = Vector2.from_angle(_angle[i] + TAU * k / pieces + t * 2.0)
				draw_circle(at + d * r * (1.0 - t), 2.0, Color(color.darkened(0.3), color.a))
			draw_circle(at, r * 0.3 * t, Color(0.08, 0.04, 0.12, color.a * 0.7))
		"earth":                                                    # pebbles and dust
			draw_circle(at, r * (0.3 + 0.4 * t), Color(color, color.a * 0.4))
			for k: int in 5:
				var d: Vector2 = Vector2.from_angle(_angle[i] + TAU * k / 5.0)
				draw_rect(Rect2(at + d * r * (0.3 + 0.7 * t) + Vector2(0, r * t * t) - Vector2(1.5, 1.5), Vector2(3, 3)), bright)
		"fortune":                                                  # glints of gold
			for k: int in 4:
				var p: Vector2 = at + Vector2.from_angle(_angle[i] + TAU * k / 4.0) * r * (0.3 + 0.6 * t)
				draw_line(p - Vector2(2.5, 0), p + Vector2(2.5, 0), bright, 1.0)
				draw_line(p - Vector2(0, 2.5), p + Vector2(0, 2.5), bright, 1.0)
		_:
			draw_arc(at, r * (0.4 + 0.6 * t), 0.0, TAU, 16, color, 1.5)


## Each reaction's own burst, bigger than a hit, with a flash at its heart.
func _draw_reaction(i: int, t: float, color: Color) -> void:
	var at: Vector2 = _pos[i]
	var r: float = _radius[i]
	var bright := Color(color.lightened(0.4), color.a)
	draw_circle(at, maxf(10.0 * (1.0 - t * 2.0), 0.0), Color(1, 1, 1, color.a))
	match _tag[i]:
		"conduct":                                                  # lightning arcing out through the water
			for k: int in 6:
				var a: float = _angle[i] + TAU * k / 6.0
				var pts := PackedVector2Array([at])
				for s: int in range(1, 5):
					pts.append(at + Vector2.from_angle(a + sin(k * 3.1 + s * 1.7 + t * 9.0) * 0.35) * r * s / 4.0)
				draw_polyline(pts, bright, 2.0)
		"steam_burst":                                              # billowing clouds of steam
			for k: int in 8:
				var d: Vector2 = Vector2.from_angle(_angle[i] + TAU * k / 8.0)
				draw_circle(at + d * r * (0.3 + 0.6 * t) + Vector2(0, -r * 0.3 * t), r * (0.18 + 0.12 * t),
						Color(bright, bright.a * 0.55))
		"shatter":                                                  # the ice bursting into flying shards
			for k: int in 12:
				var d: Vector2 = Vector2.from_angle(_angle[i] + TAU * k / 12.0)
				var p: Vector2 = at + d * r * (0.15 + 0.9 * t)
				draw_colored_polygon(PackedVector2Array([p + d * 6.0, p + d.orthogonal() * 2.0, p - d.orthogonal() * 2.0]), bright)
		"spread":                                                   # a gust spreading the status round
			for k: int in 4:
				var a: float = _angle[i] + TAU * k / 4.0 + t * 3.0
				draw_arc(at, r * (0.25 + 0.7 * t), a, a + 1.3, 10, bright, 2.0)
		_:
			draw_arc(at, r * (0.3 + 0.7 * t), 0.0, TAU, 24, bright, 2.0)
