class_name GoldPickups
extends Node2D
## Gold coins (GAME_DESIGN.md: XP, leveling, pickups / Gold drops): 5% from
## normal enemies, guaranteed from elites, piles from chests and points of
## interest. Coins inside a player's pickup radius fly to them. Gold is the
## run's money: spent at the Wandering Trader or banked at the end. A small
## fixed pool; when full, the coin's value goes to the nearest coin.

var _capacity: int = 0
var _active := PackedByteArray()
var _pos := PackedVector2Array()
var _value := PackedFloat32Array()
var _speed := PackedFloat32Array()
var _flying := PackedByteArray()
var _multimesh: MultiMesh
var _texture: Texture2D

## Co-op: the host tells the joining players about every coin (CoopHost).
signal dropped(at: Vector2, value: float)
signal pulled


func setup() -> void:
	add_to_group("gold_pickups")
	z_index = -1
	_capacity = Data.cfg_int("pickups.gold_pool")
	_active.resize(_capacity)
	_pos.resize(_capacity)
	_value.resize(_capacity)
	_speed.resize(_capacity)
	_flying.resize(_capacity)
	_multimesh = PlaceholderArt.make_multimesh(_capacity)
	var drawer := MultiMeshInstance2D.new()
	drawer.multimesh = _multimesh
	# Its picture (owner request 10/31/2026), tinted by its colour.
	_texture = PixelArt.pickup_texture("gold_coin")
	drawer.texture = _texture
	drawer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(drawer)


func count() -> int:
	var total: int = 0
	for i: int in _capacity:
		total += _active[i]
	return total


func drop(at: Vector2, value: float) -> void:
	dropped.emit(at, value)
	var slot: int = _active.find(0)
	if slot == -1:
		var nearest: int = _nearest_coin(at)
		if nearest != -1:
			_value[nearest] += value
		return
	_active[slot] = 1
	_pos[slot] = at
	_value[slot] = value
	_speed[slot] = 0.0
	_flying[slot] = 0
	_update_instance(slot)


## Drops `total` gold as several coins scattered around `at` (chests, hoards).
func drop_pile(at: Vector2, total: float, coins: int) -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.loot
	for k: int in coins:
		var offset := Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(4.0, 16.0)
		drop(at + offset, total / maxf(coins, 1))


## Every coin flies to the nearest player (Tyche's Wheel of Fortune).
func pull_all() -> void:
	pulled.emit()
	for i: int in _capacity:
		if _active[i] != 0:
			_flying[i] = 1


func on_enemy_killed(_slot: int, enemy_type: Dictionary, at: Vector2, _killer: Player) -> void:
	if GameAuthority.run == null or bool(enemy_type.get("elite", false)) or Net.is_client():
		return
	var chance: float = float(enemy_type.get("gold_chance", Data.cfg_float("pickups.gold_drop_chance")))
	if GameAuthority.run.rng.loot.randf() < chance:
		drop(at, Data.cfg_float("pickups.gold_coin_value") * GameAuthority.run.drop_mult())


func on_elite_killed(at: Vector2, _enemy_type: Dictionary, is_copy: bool) -> void:
	if GameAuthority.run != null and not is_copy and not Net.is_client():
		drop_pile(at, Data.cfg_float("pickups.elite_gold"), Data.cfg_int("pickups.pile_coins"))


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
		var player: Player = _nearest_player(_pos[i])
		if player == null:
			continue
		var offset: Vector2 = player.position - _pos[i]
		var dist: float = offset.length()
		if _flying[i] == 0 and dist > player.stats.pickup_radius():
			continue
		_flying[i] = 1
		if dist <= player.body_radius + maxf(_speed[i], 1.0) * delta:
			var value: float = _value[i]
			_active[i] = 0
			_multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))
			GameAuthority.collect_gold(player, value)
			continue
		_speed[i] = maxf(_speed[i], Data.cfg_float("xp.fly_speed_px_s")) + accel * delta
		_pos[i] += offset / dist * _speed[i] * delta
		_update_instance(i)


func _update_instance(slot: int) -> void:
	var size: float = Data.cfg_float("pickups.gold_size_px")
	_multimesh.set_instance_transform_2d(slot, Transform2D(0.0, PixelArt.pickup_scale(_texture, size), 0.0, _pos[slot]))
	_multimesh.set_instance_color(slot, Color.html(Data.cfg_string("pickups.gold_color")))


func _nearest_coin(at: Vector2) -> int:
	var best: int = -1
	var best_sq: float = INF
	for i: int in _capacity:
		if _active[i] != 0 and _pos[i].distance_squared_to(at) < best_sq:
			best_sq = _pos[i].distance_squared_to(at)
			best = i
	return best


func _nearest_player(from: Vector2) -> Player:
	var best: Player = null
	var best_sq: float = INF
	for player: Player in GameAuthority.players:
		if (player.alive or player.shade) and player.position.distance_squared_to(from) < best_sq:
			best_sq = player.position.distance_squared_to(from)
			best = player
	return best
