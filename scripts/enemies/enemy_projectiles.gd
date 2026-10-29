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


func _draw() -> void:
	var outline := Color.html(Data.cfg_string("enemies.shot_outline_color"))
	for i: int in _capacity:
		if _active[i] == 0:
			continue
		draw_circle(_pos[i], _radius[i] + 1.5, outline)
		draw_circle(_pos[i], _radius[i], _color[i])


func _remove(i: int) -> void:
	if _active[i] == 0:
		return
	_active[i] = 0
	if _owner_kind[i] == BOSS:
		_boss_count -= 1
	else:
		_regular_count -= 1
