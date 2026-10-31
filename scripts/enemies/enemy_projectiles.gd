class_name EnemyProjectiles
extends Node2D
## Enemy and boss projectiles as pooled data (GAME_DESIGN.md: Readability
## caps; Bosses / fairness rules). Regular enemies may have at most 20 shots
## in the air; bosses have their own, larger budget. Shots have a dark
## outline and draw above player effects. A shot hits a player once, then
## it's gone. Each shot remembers where it started, so a boss can send its
## shots back along their paths (Kronos).

const BOSS := 1
const REGULAR := 0

var _capacity: int = 0
var _active := PackedByteArray()
var _owner_kind := PackedByteArray()
var _pos := PackedVector2Array()
var _vel := PackedVector2Array()
var _origin := PackedVector2Array()
var _radius := PackedFloat32Array()
var _damage := PackedFloat32Array()
var _age := PackedFloat32Array()
var _source := PackedStringArray()
var _color: Array[Color] = []
var _element := PackedStringArray()
var _regular_count: int = 0
var _boss_count: int = 0


## A shot was fired, or all shots changed at once (co-op tells the joining players).
signal fired(at: Vector2, velocity: Vector2, shot_radius: float, damage: float, source_id: String, element: String, owner_kind: int)
signal bulk(op: String, args: Array)


func setup() -> void:
	z_index = 20
	_capacity = Data.cfg_int("effect_budgets.max_enemy_projectiles") + Data.cfg_int("effect_budgets.max_boss_projectiles")
	_active.resize(_capacity)
	_owner_kind.resize(_capacity)
	_pos.resize(_capacity)
	_vel.resize(_capacity)
	_origin.resize(_capacity)
	_radius.resize(_capacity)
	_damage.resize(_capacity)
	_age.resize(_capacity)
	_source.resize(_capacity)
	_color.resize(_capacity)
	_element.resize(_capacity)


func count() -> int:
	return _regular_count + _boss_count


## Fires one shot. Returns false when that budget is full (the shot is skipped).
func fire(at: Vector2, velocity: Vector2, shot_radius: float, damage: float, source_id: String, element: String,
		owner_kind: int = REGULAR) -> bool:
	if owner_kind == REGULAR and _regular_count >= Data.cfg_int("effect_budgets.max_enemy_projectiles"):
		return false
	if owner_kind == BOSS and _boss_count >= Data.cfg_int("effect_budgets.max_boss_projectiles"):
		return false
	var i: int = _active.find(0)
	if i == -1:
		return false
	_active[i] = 1
	_owner_kind[i] = owner_kind
	_pos[i] = at
	_origin[i] = at
	_vel[i] = velocity
	_radius[i] = shot_radius
	_damage[i] = damage
	_age[i] = 0.0
	_source[i] = source_id
	_color[i] = Elements.color(element) if element != "" else Color.html(Data.cfg_string("enemies.shot_color"))
	_element[i] = element
	if owner_kind == BOSS:
		_boss_count += 1
	else:
		_regular_count += 1
	fired.emit(at, velocity, shot_radius, damage, source_id, element, owner_kind)
	return true


## Sends every boss shot back toward where it was fired from.
func rewind_boss_shots() -> void:
	bulk.emit("rewind", [])
	for i: int in _capacity:
		if _active[i] != 0 and _owner_kind[i] == BOSS:
			var back: Vector2 = _origin[i] - _pos[i]
			if back.length() > 1.0:
				_vel[i] = back.normalized() * _vel[i].length()
				_age[i] = 0.0


## Removes every shot (a boss's clean slate, or the end of a fight).
func clear_all(owner_kind: int = -1) -> void:
	bulk.emit("clear", [owner_kind])
	for i: int in _capacity:
		if _active[i] != 0 and (owner_kind == -1 or _owner_kind[i] == owner_kind):
			_remove(i)
	queue_redraw()


## Removes shots inside a circle (a statue blocks them). Returns how many.
func block_circle(center: Vector2, block_radius: float) -> int:
	var blocked: int = 0
	for i: int in _capacity:
		if _active[i] != 0 and _pos[i].distance_to(center) <= block_radius + _radius[i]:
			_remove(i)
			blocked += 1
	if blocked > 0:
		bulk.emit("block", [center.x, center.y, block_radius])
	return blocked


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in _capacity:
		_pos[i] -= shift_px
		_origin[i] -= shift_px


func _process(delta: float) -> void:
	if count() == 0:
		return
	var life: float = Data.cfg_float("enemies.shot_lifetime_s")
	# Small hurtbox: about 40% of the Hero's sprite (contact damage uses the full body).
	var hurtbox: float = Data.cfg_float("player.placeholder_size_px") * 0.5 * Data.cfg_float("bosses.player_projectile_hurtbox_ratio")
	for i: int in _capacity:
		if _active[i] == 0:
			continue
		_age[i] += delta
		_pos[i] += _vel[i] * delta
		if _age[i] >= life:
			_remove(i)
			continue
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(_pos[i]) <= _radius[i] + hurtbox:
				# King Arthur's shield blocks it; the Mirrored Shield may send it back.
				var blocked: bool = player.kit != null and player.kit.blocks_shot(_pos[i])
				if not blocked and not SecretPassives.reflects(player, _pos[i], _damage[i]):
					GameAuthority.damage_player(player, _damage[i], _source[i], _pos[i])
				_remove(i)
				break
	queue_redraw()


## Each shot keeps its dark outline (GAME_DESIGN.md: Readable bullets) and looks like its element (owner request
## 10/31/2026): a fading trail behind it, a bright core, and its element's mark: a flame tail, an ice point, sparks,
## a ripple, a rough stone, a shadow core, rays of light or a curl of wind.
func _draw() -> void:
	var outline := Color.html(Data.cfg_string("enemies.shot_outline_color"))
	var trail: int = Data.cfg_int("enemies.shot_trail_steps")
	var pulse: float = Time.get_ticks_msec() * 0.01
	for i: int in _capacity:
		if _active[i] == 0:
			continue
		var at: Vector2 = _pos[i]
		var r: float = _radius[i]
		var color: Color = _color[i]
		var back: Vector2 = -_vel[i].normalized()
		var spin: float = _vel[i].angle()
		for k: int in range(trail, 0, -1):
			draw_circle(at + back * r * 0.9 * k, r * (1.0 - 0.22 * k), Color(color, 0.45 / k))
		match _element[i]:
			"fire":                                             # a tail of flame behind it
				draw_colored_polygon(PackedVector2Array([at + back * r * 2.6, at + back.orthogonal() * (r + 1.5),
						at - back.orthogonal() * (r + 1.5)]), outline)
				draw_colored_polygon(PackedVector2Array([at + back * r * 2.2, at + back.orthogonal() * r,
						at - back.orthogonal() * r]), color)
			"ice":                                              # a point of ice leading the way
				var tip: Vector2 = at - back * r * 1.9
				var shape := PackedVector2Array([tip, at + back.orthogonal() * r, at + back * r * 1.2, at - back.orthogonal() * r])
				draw_colored_polygon(PackedVector2Array([tip - back * 1.5, at + back.orthogonal() * (r + 1.5),
						at + back * (r * 1.2 + 1.5), at - back.orthogonal() * (r + 1.5)]), outline)
				draw_colored_polygon(shape, color)
				draw_line(tip, at + back * r * 0.6, Color(1, 1, 1, 0.8), 1.0)
				continue
			"earth":                                            # a rough tumbling stone
				var rock := PackedVector2Array()
				var edge := PackedVector2Array()
				for k: int in 6:
					var d: Vector2 = Vector2.from_angle(pulse * 0.4 + TAU * k / 6.0)
					var bump: float = 1.0 if k % 2 == 0 else 0.8
					rock.append(at + d * r * bump)
					edge.append(at + d * (r * bump + 1.5))
				draw_colored_polygon(edge, outline)
				draw_colored_polygon(rock, color)
				draw_circle(at - Vector2(r, r) * 0.3, r * 0.3, Color(color.lightened(0.3), 1.0))
				continue
		draw_circle(at, r + 1.5, outline)
		draw_circle(at, r, color)
		match _element[i]:
			"lightning":                                        # sparks crackling off it
				for k: int in 3:
					var d: Vector2 = Vector2.from_angle(pulse * 2.0 + TAU * k / 3.0)
					draw_line(at + d * r, at + d.rotated(0.5) * (r + 3.0), Color(1, 1, 0.8), 1.0)
			"water":                                            # a ripple round it
				draw_arc(at, r * 0.6, spin, spin + PI, 8, Color(1, 1, 1, 0.7), 1.0)
			"dark":                                             # a black heart
				draw_circle(at, r * 0.5, Color(0.08, 0.02, 0.12))
			"holy":                                             # little rays
				for k: int in 4:
					var d: Vector2 = Vector2.from_angle(pulse + TAU * k / 4.0)
					draw_line(at + d * (r + 1.0), at + d * (r + 3.5), Color(1, 1, 0.85), 1.0)
			"wind":                                             # a curl
				draw_arc(at, r * 0.6, pulse * 3.0, pulse * 3.0 + PI * 1.3, 8, Color(1, 1, 1, 0.85), 1.0)
		draw_circle(at - Vector2(r, r) * 0.25, r * 0.35, Color(color.lightened(0.6), 1.0))


func _remove(i: int) -> void:
	if _active[i] == 0:
		return
	_active[i] = 0
	if _owner_kind[i] == BOSS:
		_boss_count -= 1
	else:
		_regular_count -= 1
