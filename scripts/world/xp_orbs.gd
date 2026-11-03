class_name XpOrbs
extends Node2D
## XP orbs (GAME_DESIGN.md: XP, leveling, pickups). Enemies drop small (1),
## medium (5), or large (25) orbs. Orbs inside a player's pickup radius fly
## to them. Above 300 orbs on the ground, distant orbs merge into bigger
## ones. Orbs left lying fade away after xp.orb_life_s, blinking in their last moments (owner request 11/03/2026);
## when the pool is full a new orb takes the place of the oldest one lying on the ground and carries its XP, so new
## orbs always appear where enemies fall. Pooled data drawn with one MultiMesh: nothing is created during play.

var pickup_audio: PickupAudio = null

var _capacity: int = 0
var _active := PackedByteArray()
var _pos := PackedVector2Array()
var _value := PackedFloat32Array()
var _speed := PackedFloat32Array()
var _flying := PackedByteArray()
## How long each orb has lain on the ground.
var _age := PackedFloat32Array()
var _count: int = 0
var _merge_timer: float = 0.0
var _multimesh: MultiMesh
var _texture: Texture2D
# Orb tiers (small / medium / large) cached from config.
var _tier_values := PackedFloat32Array()
var _tier_sizes := PackedFloat32Array()
var _tier_colors: Array[Color] = []


func setup() -> void:
	z_index = -1
	_capacity = Data.cfg_int("xp.orb_pool")
	_active.resize(_capacity)
	_pos.resize(_capacity)
	_value.resize(_capacity)
	_speed.resize(_capacity)
	_flying.resize(_capacity)
	_age.resize(_capacity)
	var sizes: Array = Data.cfg("xp.orb_size_px")
	var colors: Array = Data.cfg("xp.orb_colors")
	for value: Variant in Data.cfg("xp.orb_values"):
		_tier_values.append(float(value))
	for i: int in _tier_values.size():
		_tier_sizes.append(float(sizes[mini(i, sizes.size() - 1)]))
		_tier_colors.append(Color.html(str(colors[mini(i, colors.size() - 1)])))
	_multimesh = PlaceholderArt.make_multimesh(_capacity)
	var drawer := MultiMeshInstance2D.new()
	drawer.multimesh = _multimesh
	# Its picture (owner request 10/31/2026), tinted by its colour.
	_texture = PixelArt.pickup_texture("xp_gem")
	drawer.texture = _texture
	drawer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(drawer)


func count() -> int:
	return _count


## Drops an orb worth `value` XP. If the pool is full, the new orb takes the place of the oldest one lying on the
## ground and carries its XP too, so new orbs always appear and no XP is lost.
func drop(at: Vector2, value: float) -> void:
	var slot: int = _active.find(0)
	if slot == -1:
		slot = _oldest_lying()
		if slot == -1:
			_add_to_nearest(at, value)
			return
		value += _value[slot]
	else:
		_count += 1
	_active[slot] = 1
	_pos[slot] = at
	_value[slot] = value
	_speed[slot] = 0.0
	_flying[slot] = 0
	_age[slot] = 0.0
	_update_instance(slot)


## The orb that has lain on the ground longest (not one already flying to a player), or -1.
func _oldest_lying() -> int:
	var best: int = -1
	var best_age: float = -1.0
	for i: int in _capacity:
		if _active[i] != 0 and _flying[i] == 0 and _age[i] > best_age:
			best_age = _age[i]
			best = i
	return best


## How visible a pickup is as it ages: fully, then blinking in its last decay_blink_s, so it's clear it's going.
static func decay_alpha(age: float, life: float) -> float:
	if life <= 0.0:
		return 1.0
	var left: float = life - age
	if left > Data.cfg_float("pickups.decay_blink_s"):
		return 1.0
	return Data.cfg_float("pickups.decay_blink_alpha") if int(left * Data.cfg_float("pickups.decay_blink_hz") * 2.0) % 2 == 0 else 1.0


## Debug "magnet": every orb flies to the nearest player (like a Lodestone Shard).
func pull_all() -> void:
	for i: int in _capacity:
		if _active[i] != 0:
			_flying[i] = 1


func on_enemy_killed(_slot: int, enemy_type: Dictionary, at: Vector2, _killer: Player) -> void:
	var run: RunState = GameAuthority.run
	var mult: float = run.drop_mult() * run.xp_mult if run != null else 1.0
	drop(at, float(enemy_type.get("xp", 0.0)) * mult)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in _capacity:
		if _active[i] != 0:
			_pos[i] -= shift_px
			_update_instance(i)


func _process(delta: float) -> void:
	var accel: float = Data.cfg_float("xp.fly_accel_px_s2")
	var start_speed: float = Data.cfg_float("xp.fly_speed_px_s")
	var life: float = Data.cfg_float("xp.orb_life_s")
	for i: int in _capacity:
		if _active[i] == 0:
			continue
		if _flying[i] == 0 and life > 0.0:                                               # lying orbs fade away
			_age[i] += delta
			if _age[i] >= life:
				_remove(i)
				continue
			if life - _age[i] <= Data.cfg_float("pickups.decay_blink_s"):
				_update_instance(i)
		var player: Player = _nearest_player(_pos[i])
		if player == null:
			continue
		var offset: Vector2 = player.position - _pos[i]
		var dist: float = offset.length()
		if _flying[i] == 0 and dist <= player.stats.pickup_radius():
			_flying[i] = 1
			_speed[i] = start_speed
		if _flying[i] == 0:
			continue
		if dist <= player.body_radius + _speed[i] * delta:
			_collect(i, player)
			continue
		_speed[i] += accel * delta
		_pos[i] += offset / dist * _speed[i] * delta
		_update_instance(i)
	_merge_timer -= delta
	if _merge_timer <= 0.0:
		_merge_timer = Data.cfg_float("xp.merge_check_s")
		if _count > Data.cfg_int("xp.orb_merge_threshold"):
			merge_distant()


## Merges orbs far from every player into one orb per coarse grid cell.
func merge_distant() -> void:
	var far: float = Data.cfg_float("xp.merge_far_px")
	var cell_px: float = Data.cfg_float("xp.merge_cell_px")
	var keepers: Dictionary = {}
	for i: int in _capacity:
		if _active[i] == 0 or _flying[i] != 0:
			continue
		var player: Player = _nearest_player(_pos[i])
		if player != null and player.position.distance_to(_pos[i]) < far:
			continue
		var cell := Vector2i(floori(_pos[i].x / cell_px), floori(_pos[i].y / cell_px))
		if not keepers.has(cell):
			keepers[cell] = i
			continue
		var keeper: int = keepers[cell]
		_value[keeper] += _value[i]
		_age[keeper] = minf(_age[keeper], _age[i])                                     # the merged orb lasts as long as the newest
		_update_instance(keeper)
		_remove(i)


func _collect(slot: int, player: Player) -> void:
	var value: float = _value[slot]
	_remove(slot)
	GameAuthority.collect_xp(player, value)
	if pickup_audio != null:
		pickup_audio.on_pickup()


func _remove(slot: int) -> void:
	_active[slot] = 0
	_count -= 1
	_multimesh.set_instance_transform_2d(slot, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))


func _add_to_nearest(at: Vector2, value: float) -> void:
	var best: int = -1
	var best_sq: float = INF
	for i: int in _capacity:
		if _active[i] != 0 and _pos[i].distance_squared_to(at) < best_sq:
			best_sq = _pos[i].distance_squared_to(at)
			best = i
	if best != -1:
		_value[best] += value
		_update_instance(best)


## Size and colour show the orb's tier: small, medium, or large.
func _update_instance(slot: int) -> void:
	var tier: int = 0
	for t: int in _tier_values.size():
		if _value[slot] >= _tier_values[t]:
			tier = t
	var size: float = _tier_sizes[tier]
	_multimesh.set_instance_transform_2d(slot, Transform2D(0.0, PixelArt.pickup_scale(_texture, size), 0.0, _pos[slot]))
	var colour: Color = _tier_colors[tier]
	colour.a *= decay_alpha(_age[slot], Data.cfg_float("xp.orb_life_s")) if _flying[slot] == 0 else 1.0
	_multimesh.set_instance_color(slot, colour)


func _nearest_player(from: Vector2) -> Player:
	var best: Player = null
	var best_sq: float = INF
	for player: Player in GameAuthority.players:
		if (player.alive or player.shade) and player.position.distance_squared_to(from) < best_sq:
			best_sq = player.position.distance_squared_to(from)
			best = player
	return best
