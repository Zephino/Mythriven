class_name EnemyManager
extends Node2D
## All enemies, as pooled data in arrays instead of nodes (GAME_DESIGN.md:
## Tech stack). Moves them toward the nearest player, keeps them from
## stacking (push-apart at 30 Hz through the spatial hash, up to 8
## neighbours), deals contact damage once per 0.5 s per touching enemy (no
## invulnerability frames), ticks their statuses 5 times a second, and draws
## them all with one MultiMesh, coloured by element and tinted by status.
## Nothing is created or freed during play: slots are reused. Movement types
## are in enemy_movement.gd, elite modifiers in elite_state.gd, and crowding
## and contact damage in enemy_crowd.gd.
## In co-op on a joining player's device (`remote`), enemies only go where
## the host says (CoopClient): spawned into the host's slot numbers, glided
## toward the host's positions, and drawn; the host decides everything else.

const ENEMIES_FILE := "enemies.json"

## An enemy took a slot / left it (co-op tells the joining players).
signal spawned(slot: int)
signal removed(slot: int)

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
## Enemies with pixel art (EnemySprites): their own MultiMesh over the same slots; the circle is hidden for them.
var sprites := EnemySprites.new()
var _sprite_mm: MultiMesh
## Per slot: facing left (1), the last x it was at, and the distance walked (for walking frames).
var _face_left := PackedByteArray()
var _last_x := PackedFloat32Array()
var _stride := PackedFloat32Array()
# Per-type values cached from enemies.json so the per-frame loops stay fast.
var _type_speed := PackedFloat32Array()
var _type_color: Array[Color] = []
var _type_movement := PackedInt32Array()
## Types drawn by their own node (a boss with art: BossController draws it), so the pooled circle is hidden.
var _type_drawn_elsewhere := PackedByteArray()
## Slots drawn by another node for now (a god's avatar in a duel trial: GodTrial draws the god), 1 = hide the circle.
var drawn_elsewhere := PackedByteArray()
## Slots that don't move or act for now (1): the enemies outside while the party is in a shrine's dungeon.
var asleep := PackedByteArray()
## Co-op on a joining player's device (see above; EnemyRemote does the following).
var remote: bool = false:
	set(value):
		remote = value
		if value and _remote == null:
			_remote = EnemyRemote.new(capacity)
var _remote: EnemyRemote = null


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
		_type_drawn_elsewhere.append(1 if bool(entry.get("boss", false)) and not PixelArt.boss(str(entry["id"])).is_empty() else 0)
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
	drawn_elsewhere.resize(capacity)
	asleep.resize(capacity)
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
	var ids: Array = []
	for entry: Dictionary in types:
		ids.append(str(entry["id"]))
	sprites.build(ids)
	var sprite_drawer: MultiMeshInstance2D = sprites.make_drawer(capacity)
	_sprite_mm = sprite_drawer.multimesh
	add_child(sprite_drawer)
	_face_left.resize(capacity)
	_last_x.resize(capacity)
	_stride.resize(capacity)


func active_count() -> int:
	return _active_count


func free_slots() -> int:
	return capacity - _active_count


func max_radius() -> float:
	return _max_radius


## Puts an enemy of type `type_id` into a free slot. Returns the slot or -1 when full.
## Call through GameAuthority.spawn_enemy so co-op can run it on the host only.
func spawn(type_id: String, at: Vector2) -> int:
	if not type_index.has(type_id):
		return -1
	var slot: int = take_slot()
	if slot == -1:
		return -1
	var data: Dictionary = types[type_index[type_id]]
	kind[slot] = type_index[type_id]
	positions[slot] = at
	knockback[slot] = Vector2.ZERO
	var elapsed: float = GameAuthority.run.arc_s() if GameAuthority.run != null else 0.0
	# Bosses have their own HP per boss; time and level growth apply to the rest.
	var growth: float = 1.0 if bool(data.get("boss", false)) else LevelScaling.hp_mult(LevelScaling.current_level()) * RunArc.hp_mult(elapsed)
	if GameAuthority.run != null:
		growth *= GameAuthority.run.coop_boss_hp_mult if bool(data.get("boss", false)) else GameAuthority.run.coop_hp_mult
	max_hp[slot] = float(data["hp"]) * growth
	hp[slot] = max_hp[slot]
	radius[slot] = float(data["radius_px"])
	contact_timer[slot] = 0.0
	flash_timer[slot] = 0.0
	tint_override[slot] = Color(0, 0, 0, 0)
	drawn_elsewhere[slot] = 0
	asleep[slot] = 0
	_face_left[slot] = 0
	_last_x[slot] = at.x
	_stride[slot] = 0.0
	statuses.clear(slot)
	statuses.cc_limited[slot] = 1 if bool(data.get("elite", false)) else 0
	elites.clear(slot)
	var rng: RandomNumberGenerator = GameAuthority.run.rng.spawns if GameAuthority.run != null else RandomNumberGenerator.new()
	movement.reset(slot, _type_movement[kind[slot]], data.get("behavior", {}), rng)
	spawned.emit(slot)
	return slot


## Co-op (joining player): puts the host's enemy into the same slot number.
func spawn_into(slot: int, kind_id: int, at: Vector2, hp_max: float) -> void:
	if remote:
		_remote.spawn_into(self, slot, kind_id, at, hp_max)


## Co-op (joining player): where the host says this enemy is.
func correct(slot: int, at: Vector2, hp_fraction: float) -> void:
	if remote:
		_remote.correct(self, slot, at, hp_fraction)


## Takes the next free slot (or `slot` itself when it's free); returns it, or -1.
func take_slot(slot: int = -1) -> int:
	if _active_count >= capacity:
		return -1
	if slot >= 0:
		var at_free: int = _free.find(slot, _active_count)
		if at_free == -1:
			return -1
		_free[at_free] = _free[_active_count]
		_free[_active_count] = slot
	slot = _free[_active_count]
	_active_count += 1
	active[slot] = 1
	return slot


## Returns a slot to the pool. Call through GameAuthority.kill_enemy.
func despawn(slot: int) -> void:
	if active[slot] == 0:
		return
	active[slot] = 0
	_active_count -= 1
	_free[_active_count] = slot
	_multimesh.set_instance_transform_2d(slot, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))
	sprites.hide(_sprite_mm, slot)
	removed.emit(slot)


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
	if _remote != null:
		_remote.on_origin_shifted(shift_px)
	hash_grid.rebuild(positions, active)


func _process(delta: float) -> void:
	if remote:
		_remote.follow(self, delta)
		_draw_instances(delta)
		return
	movement.step(self, delta)
	elites.tick(self, delta)
	_separation_timer -= delta
	if _separation_timer <= 0.0:
		_separation_timer = 1.0 / Data.cfg_float("performance.separation_hz")
		hash_grid.rebuild(positions, active)
		EnemyCrowd.separate(self)
	_status_timer -= delta
	if _status_timer <= 0.0:
		var step: float = 1.0 / Data.cfg_float("performance.status_tick_hz")
		_status_timer += step
		statuses.tick(step, active, GameAuthority.hits.damage_over_time)
	EnemyCrowd.contact(self, delta)
	_draw_instances(delta)


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


## An enemy's own colour (its type's, or a set tint), without status or flash tints.
func base_color(slot: int) -> Color:
	return tint_override[slot] if tint_override[slot].a > 0.0 else _type_color[kind[slot]]


func _draw_instances(delta: float) -> void:
	var flash_color := Color.html(Data.cfg_string("enemies.hit_flash_color"))
	var tint_strength: float = Data.cfg_float("enemies.status_tint_strength")
	for i: int in capacity:
		if active[i] == 0:
			continue
		var art: bool = sprites.has_art(kind[i]) and _type_drawn_elsewhere[kind[i]] == 0 and drawn_elsewhere[i] == 0
		if art:
			_multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2.ZERO, 0.0, positions[i]))
			var dx: float = positions[i].x - _last_x[i]
			if absf(dx) > 0.05:
				_face_left[i] = 1 if dx < 0.0 else 0
			_stride[i] += absf(dx)
			_last_x[i] = positions[i].x
			# The tint's alpha is how strongly it shows over the picture.
			var tint := Color(0, 0, 0, 0)
			if tint_override[i].a > 0.0:
				tint = Color(tint_override[i], Data.cfg_float("enemies.art_override_tint"))
			var status: Color = statuses.tint(i)
			if status.a > 0.0:
				tint = Color(status, tint_strength)
			var wind: Color = movement.override_color(self, i)
			if wind.a > 0.0:
				tint = Color(wind, Data.cfg_float("enemies.art_wind_up_tint"))
			if flash_timer[i] > 0.0:
				flash_timer[i] -= delta
				tint = Color(flash_color, Data.cfg_float("enemies.art_hit_flash_tint"))
			sprites.place(_sprite_mm, i, kind[i], positions[i], radius[i], _face_left[i] == 1, absf(dx) > 0.02, _stride[i], tint)
			continue
		sprites.hide(_sprite_mm, i)
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
		if _type_drawn_elsewhere[kind[i]] == 1 or drawn_elsewhere[i] == 1:
			color.a = 0.0
		_multimesh.set_instance_color(i, color)
