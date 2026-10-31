class_name EnemyStatusMarks
extends Node2D
## Little marks on enemies showing their statuses (owner request 10/31/2026): flames for Burn, frost for Chill, an
## ice block when Frozen, sparks for Shock, drips for Soaked, bubbles for Poison, a halo for Smite, a dark swirl for
## Hex and stars for Stun. Drawn over the enemy pictures, only for enemies on screen, up to
## enemies.status_marks_max of them.

var enemies: EnemyManager
var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if enemies == null or enemies.statuses == null:
		return
	var view: Rect2 = get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()
	view = view.grow(Data.cfg_float("enemies.status_marks_margin_px"))
	var budget: int = Data.cfg_int("enemies.status_marks_max")
	var s: EnemyStatuses = enemies.statuses
	for i: int in enemies.capacity:
		if budget <= 0:
			return
		if enemies.active[i] == 0 or enemies.asleep[i] == 1 or enemies.drawn_elsewhere[i] == 1:
			continue
		var at: Vector2 = enemies.positions[i]
		if not view.has_point(at):
			continue
		var r: float = enemies.radius[i]
		var tall: float = enemies.sprites.height(enemies.kind[i])
		var feet: float = at.y + r
		var top: float = feet - tall if tall > 0.0 else at.y - r
		var half: float = maxf(r, 5.0)
		var phase: float = _time * 3.0 + i * 1.37
		var marked: bool = false
		if s.frozen[i] > 0.0:
			_frozen(at.x, top, feet, half)
			marked = true
		elif s.chill[i] > 0.0:
			_chill(at.x, top, feet, half, phase, s.chill_stacks[i])
			marked = true
		if s.burn[i] > 0.0:
			_burn(at.x, top, feet, half, phase)
			marked = true
		if s.shock[i] > 0.0:
			_shock(at.x, top, feet, half, i)
			marked = true
		if s.soaked[i] > 0.0:
			_soaked(at.x, top, feet, half, phase)
			marked = true
		if s.poison[i] > 0.0:
			_poison(at.x, top, feet, half, phase, s.poison_stacks[i])
			marked = true
		if s.smite[i] > 0.0:
			_halo(at.x, top, half, phase)
			marked = true
		if s.hex[i] > 0.0:
			_hex(at.x, (top + feet) * 0.5, half, phase)
			marked = true
		if s.stun[i] > 0.0:
			_stun(at.x, top, phase)
			marked = true
		if marked:
			budget -= 1


func _color(element: String, alpha: float = 1.0) -> Color:
	return Color(Elements.color(element), alpha)


## Small flames licking up from the body, flickering.
func _burn(x: float, top: float, feet: float, half: float, phase: float) -> void:
	var c: Color = _color("fire")
	var core := Color(1.0, 0.9, 0.4)
	for k: int in 3:
		var fx: float = x + (k - 1) * half * 0.6
		var lift: float = fmod(phase * 0.5 + k * 0.33, 1.0)
		var fy: float = lerpf(feet - 2.0, top + 2.0, 0.3 + lift * 0.5)
		var size: float = 2.5 * (1.0 - lift) + 1.0
		draw_colored_polygon(PackedVector2Array([Vector2(fx, fy - size * 2.2), Vector2(fx + size, fy),
				Vector2(fx - size, fy)]), c)
		draw_circle(Vector2(fx, fy - size * 0.3), size * 0.45, core)


## Frost specks drifting round; more of them with more Chill stacks.
func _chill(x: float, top: float, feet: float, half: float, phase: float, stacks: int) -> void:
	var c: Color = _color("ice")
	for k: int in clampi(stacks + 1, 2, 5):
		var a: float = phase * 0.6 + TAU * k / 5.0
		var p := Vector2(x + cos(a) * half, lerpf(top, feet, 0.5) + sin(a * 1.3) * (feet - top) * 0.35)
		draw_line(p - Vector2(1.5, 0), p + Vector2(1.5, 0), c, 1.0)
		draw_line(p - Vector2(0, 1.5), p + Vector2(0, 1.5), c, 1.0)


## A block of ice round the whole enemy, with a shine on it.
func _frozen(x: float, top: float, feet: float, half: float) -> void:
	var box := Rect2(x - half - 2.0, top - 2.0, half * 2.0 + 4.0, feet - top + 3.0)
	draw_rect(box, _color("ice", 0.35))
	draw_rect(box, _color("ice", 0.9), false, 1.0)
	draw_line(box.position + Vector2(2, 3), box.position + Vector2(5, 0) + Vector2(2, 3), Color(1, 1, 1, 0.8), 1.0)
	draw_line(box.position + Vector2(2, 3), box.position + Vector2(2, 7), Color(1, 1, 1, 0.8), 1.0)


## Sparks jumping across the body, a new zigzag a few times a second.
func _shock(x: float, top: float, feet: float, half: float, slot: int) -> void:
	var seed: int = int(_time * 8.0) + slot * 7
	var c: Color = _color("lightning")
	var mid: float = (top + feet) * 0.5
	for line: int in 2:
		var pts := PackedVector2Array()
		for k: int in 5:
			var jitter: float = float((seed * 31 + k * 17 + line * 11) % 9) - 4.0
			pts.append(Vector2(x - half - 2.0 + (half * 2.0 + 4.0) * k / 4.0, mid + jitter + (line * 2 - 1) * 3.0))
		draw_polyline(pts, c, 1.5)
		draw_polyline(pts, Color(1, 1, 0.9), 0.5)


## Drips falling off the enemy.
func _soaked(x: float, top: float, feet: float, half: float, phase: float) -> void:
	var c: Color = _color("water", 0.9)
	for k: int in 2:
		var fall: float = fmod(phase * 0.4 + k * 0.5, 1.0)
		var p := Vector2(x + (k * 2 - 1) * half * 0.5, lerpf(top + 3.0, feet, fall))
		draw_line(p, p + Vector2(0, 2), c, 1.5)


## Green bubbles rising and popping; more with more Poison stacks.
func _poison(x: float, top: float, feet: float, half: float, phase: float, stacks: int) -> void:
	var c: Color = _color("earth")
	for k: int in clampi(stacks, 1, 4):
		var rise: float = fmod(phase * 0.3 + k * 0.27, 1.0)
		var p := Vector2(x + sin(phase + k * 2.0) * half * 0.7, lerpf(feet - 4.0, top - 3.0, rise))
		draw_arc(p, 1.2 + rise, 0.0, TAU, 6, Color(c.lightened(0.2), 1.0 - rise * 0.6), 1.0)


## A halo of holy light over the head.
func _halo(x: float, top: float, half: float, phase: float) -> void:
	var c: Color = _color("holy", 0.75 + 0.25 * sin(phase * 2.0))
	draw_arc(Vector2(x, top - 3.0), maxf(half * 0.6, 3.0), PI, TAU, 10, c, 1.5)
	draw_arc(Vector2(x, top - 3.0), maxf(half * 0.6, 3.0), 0.0, PI, 10, Color(c, c.a * 0.4), 1.0)


## A dark swirl round the body.
func _hex(x: float, mid: float, half: float, phase: float) -> void:
	var c: Color = _color("dark", 0.85)
	for k: int in 2:
		var a: float = phase * 0.8 + PI * k
		draw_arc(Vector2(x, mid), half + 2.0, a, a + 1.4, 8, c, 1.5)


## Stars circling over the head.
func _stun(x: float, top: float, phase: float) -> void:
	for k: int in 3:
		var a: float = phase + TAU * k / 3.0
		var p := Vector2(x + cos(a) * 5.0, top - 4.0 + sin(a) * 1.5)
		draw_line(p - Vector2(1.5, 0), p + Vector2(1.5, 0), Color(1, 0.95, 0.5), 1.0)
		draw_line(p - Vector2(0, 1.5), p + Vector2(0, 1.5), Color(1, 0.95, 0.5), 1.0)
