class_name EnemyManager
extends Node2D
## All enemies, as pooled data in arrays instead of nodes (GAME_DESIGN.md:
## Tech stack). Moves them toward the nearest player, keeps them from
## stacking (push-apart at 30 Hz through the spatial hash, up to 8
## neighbours), deals contact damage once per 0.5 s per touching enemy (no
## invulnerability frames), ticks their statuses 5 times a second, and draws
## them all with one MultiMesh, coloured by element and tinted by status.
## Nothing is created or freed during play: slots are reused. Movement types
## are in enemy_movement.gd and elite modifiers in elite_state.gd.

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
var max_hp := PackedFloat32Array()
var radius := PackedFloat32Array()
var kind := PackedInt32Array()
var contact_timer := PackedFloat32Array()
var flash_timer := PackedFloat32Array()
## A colour that replaces the type's colour for one slot (alpha 0 = none), e.g. a god in a Duel.
var tint_override := PackedColorArray()
## Status effects for every slot (Burn, Chill/Freeze, Shock, Soaked, Poison, Smite, Hex).
var statuses: EnemyStatuses
var movement: EnemyMovement
var elites: EliteState

var _free: PackedInt32Array = PackedInt32Array()
var _active_count: int = 0
var _max_radius: float = 0.0
var _separation_timer: float = 0.0
var _status_timer: float = 0.0
var _multimesh: MultiMesh
# Per-type values cached from enemies.json so the per-frame loops stay fast.
var _type_speed := PackedFloat32Array()
var _type_color: Array[Color] = []
var _type_movement := PackedInt32Array()


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
		_type_movement.append(EnemyMovement.code_of(str(entry.get("movement", "chaser"))))
		var element_id: String = str(entry.get("element", ""))
		_type_color.append(Elements.color(element_id) if element_id != "" else Color.html(str(entry["placeholder_color"])))
	active.resize(capacity)
	positions.resize(capacity)
	knockback.resize(capacity)
	hp.resize(capacity)
	max_hp.resize(capacity)
	radius.resize(capacity)
	kind.resize(capacity)
	contact_timer.resize(capacity)
	flash_timer.resize(capacity)
	tint_override.resize(capacity)
	statuses = EnemyStatuses.new(capacity)
	movement = EnemyMovement.new(capacity)
	elites = EliteState.new(capacity)
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
	var elapsed: float = GameAuthority.run.arc_s() if GameAuthority.run != null else 0.0
	# Bosses have their own HP per boss; time and level growth apply to the rest.
	var growth: float = 1.0 if bool(data.get("boss", false)) else LevelScaling.hp_mult(LevelScaling.current_level()) * RunArc.hp_mult(elapsed)
	max_hp[slot] = float(data["hp"]) * growth
	hp[slot] = max_hp[slot]
	radius[slot] = float(data["radius_px"])
	contact_timer[slot] = 0.0
	flash_timer[slot] = 0.0
	tint_override[slot] = Color(0, 0, 0, 0)
	statuses.clear(slot)
	statuses.cc_limited[slot] = 1 if bool(data.get("elite", false)) else 0
	elites.clear(slot)
	var rng: RandomNumberGenerator = GameAuthority.run.rng.spawns if GameAuthority.run != null else RandomNumberGenerator.new()
	movement.reset(slot, _type_movement[kind[slot]], data.get("behavior", {}), rng)
	return slot


## Returns a slot to the pool. Call through GameAuthority.kill_enemy.
func despawn(slot: int) -> void:
	if active[slot] == 0:
		return
	active[slot] = 0
	_active_count -= 1
	_free[_active_count] = slot
	_multimesh.set_instance_transform_2d(slot, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))


## Removes an enemy without a kill (a flyer that has crossed the screen): no XP, no count.
func remove_quietly(slot: int) -> void:
	despawn(slot)


func type_of(slot: int) -> Dictionary:
	return types[kind[slot]]


func movement_code(slot: int) -> int:
	return _type_movement[kind[slot]]


## Current move speed: type speed slowed by Chill/Freeze/stuns, raised by Hasted.
func speed_of(slot: int) -> float:
	return _type_speed[kind[slot]] * statuses.speed_mult(slot) * elites.speed_mult(slot) * (GameAuthority.run.enemy_speed_mult if GameAuthority.run != null else 1.0)


## Multiplier on the damage this enemy deals (Hex, and difficulty from player level).
func damage_mult(slot: int) -> float:
	return statuses.outgoing_damage_mult(slot) * LevelScaling.damage_mult(LevelScaling.current_level())


func is_elite(slot: int) -> bool:
	return bool(types[kind[slot]].get("elite", false))


## Elites and bosses are preferred by `targeted` weapons (Phase 10+).
func is_priority(slot: int) -> bool:
	return bool(types[kind[slot]].get("priority_target", false))


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
	movement.step(self, delta)
	elites.tick(self, delta)
	_separation_timer -= delta
	if _separation_timer <= 0.0:
		_separation_timer = 1.0 / Data.cfg_float("performance.separation_hz")
		hash_grid.rebuild(positions, active)
		_separate()
	_status_timer -= delta
	if _status_timer <= 0.0:
		var step: float = 1.0 / Data.cfg_float("performance.status_tick_hz")
		_status_timer += step
		statuses.tick(step, active, GameAuthority.hits.damage_over_time)
	_contact(delta)
	_draw_instances(delta)


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
				GameAuthority.damage_player(player, float(data["contact_damage"]) * damage_mult(i), str(data["id"]), positions[i])
				# Skadi's Blessing: enemies that touch you are Chilled.
				var touch_status: String = str(player.god_flags.get("contact_status", ""))
				if touch_status != "":
					statuses.apply(i, touch_status)
				GameAuthority.status_player_from_enemy(player, str(data.get("element", "")))


func nearest_player(from: Vector2) -> Player:
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
	var tint_strength: float = Data.cfg_float("enemies.status_tint_strength")
	for i: int in capacity:
		if active[i] == 0:
			continue
		var size: float = radius[i] * 2.0
		_multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2(size, size), 0.0, positions[i]))
		var color: Color = tint_override[i] if tint_override[i].a > 0.0 else _type_color[kind[i]]
		var tint: Color = statuses.tint(i)
		if tint.a > 0.0:
			color = color.lerp(tint, tint_strength)
		var wind_up: Color = movement.override_color(self, i)
		if wind_up.a > 0.0:
			color = wind_up
		if flash_timer[i] > 0.0:
			flash_timer[i] -= delta
			color = flash_color
		_multimesh.set_instance_color(i, color)
