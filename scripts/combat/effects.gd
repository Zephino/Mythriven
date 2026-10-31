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


## An expanding ring (quakes, bursts).
func spawn_ring(at: Vector2, ring_radius: float, color: Color, share: bool = false) -> void:
	_spawn(KIND_RING, at, 0.0, ring_radius, 0.0, color)
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


## Co-op (joining player): an effect the host shared.
func spawn_from_host(effect_kind: int, at: Vector2, angle: float, size: float, spread: float, color: Color) -> void:
	_spawn(effect_kind, at, angle, size, spread, color)


## Shows a reaction as an expanding ring in its colour.
func on_reaction(reaction_id: String, at: Vector2, reach: float, _by: Player) -> void:
	var color: Color = Color.html(str(Elements.reaction(reaction_id).get("color", "#ffffff")))
	spawn_ring(at, maxf(reach, Data.cfg_float("effects.min_reaction_ring_px")), color)


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
		var t: float = clampf(_age[i] / _duration[i], 0.0, 1.0)
		var color: Color = _color[i]
		color.a *= 1.0 - t
		if _kind[i] == KIND_SWING:
			_draw_swing(i, t)
		elif _kind[i] == KIND_JAB:
			_draw_jab(i, t)
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
