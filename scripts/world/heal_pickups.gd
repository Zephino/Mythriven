class_name HealPickups
extends Node2D
## Ambrosia (GAME_DESIGN.md: XP, leveling, pickups / Special pickups): heals
## 30 HP. Enemies sometimes drop one. Like XP orbs it flies to a player inside
## their pickup radius, but only to a player who is hurt, so it's never
## wasted. A small fixed pool; when full, the oldest is reused.

var _capacity: int = 0
var _next: int = 0
var _active := PackedByteArray()
var _pos := PackedVector2Array()
var _speed := PackedFloat32Array()
var _multimesh: MultiMesh
var _texture: Texture2D

## Co-op: the host tells the joining players about each Ambrosia (CoopHost).
signal dropped(at: Vector2)


func setup() -> void:
	add_to_group("heal_pickups")
	z_index = -1
	_capacity = Data.cfg_int("pickups.ambrosia_pool")
	_active.resize(_capacity)
	_pos.resize(_capacity)
	_speed.resize(_capacity)
	_multimesh = PlaceholderArt.make_multimesh(_capacity)
	var drawer := MultiMeshInstance2D.new()
	drawer.multimesh = _multimesh
	# Its picture (owner request 10/31/2026), tinted by its colour.
	_texture = PixelArt.pickup_texture("ambrosia")
	drawer.texture = _texture
	drawer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(drawer)


func count() -> int:
	var total: int = 0
	for i: int in _capacity:
		total += _active[i]
	return total


func drop(at: Vector2) -> void:
	if _capacity <= 0:
		return
	dropped.emit(at)
	var slot: int = _next
	_next = (_next + 1) % _capacity
	_active[slot] = 1
	_pos[slot] = at
	_speed[slot] = 0.0
	var size: float = Data.cfg_float("pickups.ambrosia_size_px")
	_multimesh.set_instance_transform_2d(slot, Transform2D(0.0, PixelArt.pickup_scale(_texture, size), 0.0, at))
	_multimesh.set_instance_color(slot, Color.html(Data.cfg_string("pickups.ambrosia_color")))


## Each kill has a small chance to drop Ambrosia (rolled on the run's loot generator).
func on_enemy_killed(_slot: int, _enemy_type: Dictionary, at: Vector2, _killer: Player) -> void:
	if GameAuthority.run != null and not Net.is_client() and GameAuthority.run.rng.loot.randf() < Data.cfg_float("pickups.ambrosia_drop_chance"):
		drop(at)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in _capacity:
		if _active[i] != 0:
			_pos[i] -= shift_px
			_update_instance(i)


func _process(delta: float) -> void:
	var accel: float = Data.cfg_float("xp.fly_accel_px_s2")
	for i: int in _capacity:
		if _active[i] == 0:
			continue
		var player: Player = _nearest_hurt_player(_pos[i])
		if player == null:
			_speed[i] = 0.0
			continue
		var offset: Vector2 = player.position - _pos[i]
		var dist: float = offset.length()
		if _speed[i] <= 0.0 and dist > player.stats.pickup_radius():
			continue
		if dist <= player.body_radius + maxf(_speed[i], 1.0) * delta:
			_active[i] = 0
			_multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))
			GameAuthority.heal_player(player, Data.cfg_float("pickups.ambrosia_heal"))
			continue
		_speed[i] = maxf(_speed[i], Data.cfg_float("xp.fly_speed_px_s")) + accel * delta
		_pos[i] += offset / dist * _speed[i] * delta
		_update_instance(i)


func _update_instance(slot: int) -> void:
	var size: float = Data.cfg_float("pickups.ambrosia_size_px")
	_multimesh.set_instance_transform_2d(slot, Transform2D(0.0, PixelArt.pickup_scale(_texture, size), 0.0, _pos[slot]))


func _nearest_hurt_player(from: Vector2) -> Player:
	var best: Player = null
	var best_sq: float = INF
	for player: Player in GameAuthority.players:
		if player.alive and player.hp < player.max_hp and player.position.distance_squared_to(from) < best_sq:
			best_sq = player.position.distance_squared_to(from)
			best = player
	return best
