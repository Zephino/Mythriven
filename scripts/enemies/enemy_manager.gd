class_name EnemyManager
extends Node2D
## All enemies, as pooled data in arrays instead of nodes (GAME_DESIGN.md:
## Tech stack). Moves them toward the nearest player, keeps them from
## stacking (push-apart at 30 Hz through the spatial hash, up to 8
## neighbours), deals contact damage once per 0.5 s per touching enemy (no
## invulnerability frames), and draws them all with one MultiMesh.
## Nothing is created or freed during play: slots are reused.

const ENEMIES_FILE := "enemies.json"

var capacity: int = 0
var hash_grid: SpatialHash
var types: Array[Dictionary] = []
var type_index: Dictionary = {}

# One entry per pooled slot.
var active := PackedByteArray()
var positions := PackedVector2Array()
var knockback := PackedVector2Array()
var hp := PackedFloat32Array()
var radius := PackedFloat32Array()
var kind := PackedInt32Array()
var contact_timer := PackedFloat32Array()
var flash_timer := PackedFloat32Array()

var _free: PackedInt32Array = PackedInt32Array()
var _active_count: int = 0
var _max_radius: float = 0.0
var _separation_timer: float = 0.0
var _multimesh: MultiMesh
# Per-type values cached from enemies.json so the per-frame loops stay fast.
var _type_speed := PackedFloat32Array()
var _type_color: Array[Color] = []


func setup() -> void:
	process_priority = 1
	capacity = Data.cfg_int("performance.enemy_cap")
	hash_grid = SpatialHash.new(Data.cfg_float("performance.spatial_hash_cell_px"))
	var listed: Variant = Data.get_file(ENEMIES_FILE)
	for entry: Variant in (listed if listed is Array else []):
		type_index[str(entry["id"])] = types.size()
		types.append(entry)
		_max_radius = maxf(_max_radius, float(entry["radius_px"]))
		_type_speed.append(float(entry["speed"]))
		_type_color.append(Color.html(str(entry["placeholder_color"])))
	active.resize(capacity)
	positions.resize(capacity)
	knockback.resize(capacity)
	hp.resize(capacity)
	radius.resize(capacity)
	kind.resize(capacity)
	contact_timer.resize(capacity)
	flash_timer.resize(capacity)
	_free.resize(capacity)
	for i: int in capacity:
		_free[i] = capacity - 1 - i
	_multimesh = PlaceholderArt.make_multimesh(capacity)
	var drawer := MultiMeshInstance2D.new()
	drawer.multimesh = _multimesh
	drawer.texture = PlaceholderArt.circle_texture(Data.cfg_int("enemies.placeholder_texture_px"))
	add_child(drawer)


func active_count() -> int:
	return _active_count


func free_slots() -> int:
	return capacity - _active_count


func max_radius() -> float:
	return _max_radius


## Puts an enemy of type `type_id` into a free slot. Returns the slot or -1 when full.
## Call through GameAuthority.spawn_enemy so co-op can run it on the host only.
func spawn(type_id: String, at: Vector2) -> int:
	if _active_count >= capacity or not type_index.has(type_id):
		return -1
	var slot: int = _free[_active_count]
	var data: Dictionary = types[type_index[type_id]]
	_active_count += 1
	active[slot] = 1
	kind[slot] = type_index[type_id]
	positions[slot] = at
	knockback[slot] = Vector2.ZERO
	hp[slot] = float(data["hp"])
	radius[slot] = float(data["radius_px"])
	contact_timer[slot] = 0.0
	flash_timer[slot] = 0.0
	return slot


## Returns a slot to the pool. Call through GameAuthority.kill_enemy.
func despawn(slot: int) -> void:
	if active[slot] == 0:
		return
	active[slot] = 0
	_active_count -= 1
	_free[_active_count] = slot
	_multimesh.set_instance_transform_2d(slot, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))


func type_of(slot: int) -> Dictionary:
	return types[kind[slot]]


func query(center: Vector2, query_radius: float) -> PackedInt32Array:
	return hash_grid.query(center, query_radius, positions, active)


func nearest(center: Vector2, max_range: float) -> int:
	return hash_grid.nearest(center, max_range, positions, active)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in capacity:
		if active[i] != 0:
			positions[i] -= shift_px
	hash_grid.rebuild(positions, active)


func _process(delta: float) -> void:
	_move(delta)
	_separation_timer -= delta
	if _separation_timer <= 0.0:
		_separation_timer = 1.0 / Data.cfg_float("performance.separation_hz")
		hash_grid.rebuild(positions, active)
		_separate()
	_contact(delta)
	_draw_instances(delta)


func _move(delta: float) -> void:
	var decay: float = exp(-Data.cfg_float("enemies.knockback_decay") * delta)
	for i: int in capacity:
		if active[i] == 0:
			continue
		var target: Player = _nearest_player(positions[i])
		var step := Vector2.ZERO
		if target != null:
			var to_player: Vector2 = target.position - positions[i]
			if to_player.length_squared() > 1.0:
				step = to_player.normalized() * _type_speed[kind[i]] * delta
		positions[i] += step + knockback[i] * delta
		knockback[i] *= decay


## Pushes overlapping enemies apart; bigger enemies push smaller ones aside.
## Each enemy checks at most `separation_max_neighbors` neighbours.
func _separate() -> void:
	var max_neighbors: int = Data.cfg_int("performance.separation_max_neighbors")
	for i: int in capacity:
		if active[i] == 0:
			continue
		var checked: int = 0
		var mass_i: float = radius[i] * radius[i]
		for j: int in query(positions[i], radius[i] + _max_radius):
			if j == i:
				continue
			checked += 1
			if checked > max_neighbors:
				break
			var offset: Vector2 = positions[i] - positions[j]
			var min_dist: float = radius[i] + radius[j]
			var dist: float = offset.length()
			if dist >= min_dist:
				continue
			var away: Vector2 = offset / dist if dist > 0.001 else Vector2.RIGHT.rotated(float(i))
			var mass_j: float = radius[j] * radius[j]
			positions[i] += away * (min_dist - dist) * (mass_j / (mass_i + mass_j))
		_push_out_of_players(i)


## Enemies can't stand inside a player, so crowds form a ring around them.
func _push_out_of_players(i: int) -> void:
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		var offset: Vector2 = positions[i] - player.position
		var min_dist: float = radius[i] + player.body_radius
		var dist: float = offset.length()
		if dist < min_dist:
			var away: Vector2 = offset / dist if dist > 0.001 else Vector2.RIGHT
			positions[i] = player.position + away * min_dist


## Each touching enemy damages the player once per contact interval, on its own timer.
func _contact(delta: float) -> void:
	var interval: float = Data.cfg_float("combat.contact_damage_interval_s")
	var margin: float = Data.cfg_float("enemies.contact_margin_px")
	for i: int in capacity:
		if active[i] != 0 and contact_timer[i] > 0.0:
			contact_timer[i] -= delta
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		var reach: float = player.body_radius + _max_radius + margin
		for i: int in query(player.position, reach + Data.cfg_float("enemies.contact_query_slack_px")):
			if contact_timer[i] > 0.0:
				continue
			if positions[i].distance_to(player.position) <= player.body_radius + radius[i] + margin:
				contact_timer[i] = interval
				var data: Dictionary = types[kind[i]]
				GameAuthority.damage_player(player, float(data["contact_damage"]), str(data["id"]))


func _nearest_player(from: Vector2) -> Player:
	var best: Player = null
	var best_sq: float = INF
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		var dist_sq: float = player.position.distance_squared_to(from)
		if dist_sq < best_sq:
			best_sq = dist_sq
			best = player
	return best


func _draw_instances(delta: float) -> void:
	var flash_color := Color.html(Data.cfg_string("enemies.hit_flash_color"))
	for i: int in capacity:
		if active[i] == 0:
			continue
		var size: float = radius[i] * 2.0
		_multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2(size, size), 0.0, positions[i]))
		var color: Color = _type_color[kind[i]]
		if flash_timer[i] > 0.0:
			flash_timer[i] -= delta
			color = flash_color
		_multimesh.set_instance_color(i, color)
