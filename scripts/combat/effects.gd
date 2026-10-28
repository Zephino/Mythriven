class_name EffectLayer
extends Node2D
## Short placeholder visuals for attacks (swing arcs, quake rings), drawn by
## one node from a fixed ring buffer. When the buffer is full the oldest
## effect is recycled (GAME_DESIGN.md: Effect budgets), so nothing is created
## or freed during play.

const GROUP := "effect_layer"
const KIND_ARC := 0
const KIND_RING := 1
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


func setup() -> void:
	z_index = 5
	add_to_group(GROUP)
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


## A filled pie-slice swing from `at`, facing `angle`, `spread` radians wide.
func spawn_arc(at: Vector2, angle: float, arc_radius: float, spread: float, color: Color) -> void:
	_spawn(KIND_ARC, at, angle, arc_radius, spread, color)


## An expanding ring (quakes, bursts).
func spawn_ring(at: Vector2, ring_radius: float, color: Color) -> void:
	_spawn(KIND_RING, at, 0.0, ring_radius, 0.0, color)


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
		if _kind[i] == KIND_ARC:
			var points := PackedVector2Array([_pos[i]])
			for s: int in ARC_SEGMENTS + 1:
				var a: float = _angle[i] - _spread[i] * 0.5 + _spread[i] * s / ARC_SEGMENTS
				points.append(_pos[i] + Vector2.from_angle(a) * _radius[i])
			draw_colored_polygon(points, color)
		else:
			draw_arc(_pos[i], _radius[i] * (0.4 + 0.6 * t), 0.0, TAU, RING_SEGMENTS, color, 2.0)
