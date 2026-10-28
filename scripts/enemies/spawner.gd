class_name EnemySpawner
extends Node
## Spawns enemies in a ring just outside each player's visible screen and
## moves enemies left far behind (more than 2 screens from every player) to
## the ring ahead instead of deleting them (GAME_DESIGN.md: Spawning). What
## spawns comes from the level's wave table (waves_<level>.json): each
## minute's rate, single enemies by weight, swarm packs, flyer groups that
## cross the screen, and encircler rings that close in. Spawns also grow with
## the player's level (LevelScaling). Without a wave table it falls back to
## the placeholder enemies.

var enemies: EnemyManager
var auto_spawn: bool = true
## Extra spawn-rate multiplier from events and boss fights (1 = normal).
var rate_mult: float = 1.0
## While not empty (boss fights), only these weak fodder types spawn, and no groups.
var fodder_only: PackedStringArray = []

var _table: Dictionary = {}
var _spawn_budget: float = 0.0
var _recycle_timer: float = 0.0
## Seconds until each group (by index in the current row) arrives again.
var _group_timers: Dictionary = {}


func _ready() -> void:
	auto_spawn = Data.cfg_bool("enemies.auto_spawn_enabled")
	if GameAuthority.run != null:
		_table = RunArc.wave_table(GameAuthority.run.level_data)


func _process(delta: float) -> void:
	if auto_spawn and GameAuthority.run != null:
		var row: Dictionary = RunArc.wave_row(_table, GameAuthority.run.elapsed_s)
		var base_rate: float = float(row.get("spawns_per_s", Data.cfg_float("enemies.auto_spawn_per_s")))
		_spawn_budget += base_rate * rate_mult * LevelScaling.spawn_mult(LevelScaling.current_level()) * delta
		while _spawn_budget >= 1.0:
			_spawn_budget -= 1.0
			_spawn_once(row)
		if fodder_only.is_empty():
			_tick_groups(row, delta)
	_recycle_timer -= delta
	if _recycle_timer <= 0.0:
		_recycle_timer = Data.cfg_float("enemies.recycle_check_s")
		recycle()


## Visible world area (window size divided by camera zoom).
func view_size() -> Vector2:
	return get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)


func ring_radius() -> float:
	return view_size().length() * 0.5 + Data.cfg_float("enemies.spawn_margin_px")


## Spawns `count` enemies spread around the ring of a random living player.
func spawn_ring(type_id: String, count: int) -> void:
	for _i: int in count:
		var player: Player = _random_player()
		if player == null:
			return
		GameAuthority.spawn_enemy(type_id, player.position + _ring_offset(_rng().randf() * TAU))


## Spawns a tight pack (swarm) at one point of the ring.
func spawn_pack(type_id: String, count: int) -> void:
	var player: Player = _random_player()
	if player == null:
		return
	var center: Vector2 = player.position + _ring_offset(_rng().randf() * TAU)
	var spread: float = Data.cfg_float("enemies.pack_spread_px")
	for _i: int in count:
		var jitter := Vector2(_rng().randf_range(-spread, spread), _rng().randf_range(-spread, spread))
		GameAuthority.spawn_enemy(type_id, center + jitter)


## A line of flyers enters at one side of the ring and crosses past the player.
func spawn_flyers(type_id: String, count: int) -> void:
	var player: Player = _random_player()
	if player == null:
		return
	var angle: float = _rng().randf() * TAU
	var start: Vector2 = player.position + _ring_offset(angle)
	var heading: Vector2 = (player.position - start).normalized().rotated(_rng().randf_range(-0.3, 0.3))
	var gap: float = Data.cfg_float("enemies.flyer_gap_px")
	for k: int in count:
		var slot: int = GameAuthority.spawn_enemy(type_id, start - heading * gap * k)
		if slot != -1:
			enemies.movement.dir[slot] = heading


## A full ring of encirclers around a player, closing in (Deep Night).
func spawn_encircle(type_id: String, count: int) -> void:
	var player: Player = _random_player()
	if player == null:
		return
	var ring: float = ring_radius() * Data.cfg_float("enemies.encircle_radius_mult")
	for k: int in count:
		GameAuthority.spawn_enemy(type_id, player.position + Vector2.from_angle(TAU * k / maxf(count, 1)) * ring)


## Spawns an elite on the ring with its modifiers. Returns its slot or -1.
func spawn_elite(type_id: String, modifier_ids: PackedStringArray) -> int:
	var player: Player = _random_player()
	if player == null:
		return -1
	var slot: int = GameAuthority.spawn_enemy(type_id, player.position + _ring_offset(_rng().randf() * TAU))
	if slot != -1:
		enemies.elites.setup(slot, modifier_ids, enemies.max_hp[slot])
	return slot


## Moves enemies that are far from every player to the ring ahead of the nearest
## one. Flyers aren't moved: they leave on their own.
func recycle() -> void:
	if enemies == null:
		return
	var limit: float = view_size().x * Data.cfg_float("enemies.recycle_distance_screens")
	var limit_sq: float = limit * limit
	for i: int in enemies.capacity:
		if enemies.active[i] == 0 or enemies.movement_code(i) == EnemyMovement.FLYER:
			continue
		var nearest: Player = null
		var nearest_sq: float = INF
		for player: Player in GameAuthority.players:
			var dist_sq: float = player.position.distance_squared_to(enemies.positions[i])
			if player.alive and dist_sq < nearest_sq:
				nearest_sq = dist_sq
				nearest = player
		if nearest == null or nearest_sq <= limit_sq:
			continue
		var ahead: float = nearest.facing.angle() if nearest.velocity != Vector2.ZERO else _rng().randf() * TAU
		var spread: float = deg_to_rad(Data.cfg_float("enemies.recycle_ahead_spread_deg"))
		enemies.positions[i] = nearest.position + _ring_offset(ahead + _rng().randf_range(-spread, spread))


func _spawn_once(row: Dictionary) -> void:
	if not fodder_only.is_empty():
		spawn_ring(fodder_only[_rng().randi_range(0, fodder_only.size() - 1)], 1)
		return
	if row.is_empty():
		_placeholder_spawn()
		return
	for pack: Variant in row.get("packs", []):
		if pack is Dictionary and _rng().randf() < float(pack.get("chance", 0.0)):
			var size: Array = pack.get("size", [1, 1])
			spawn_pack(str(pack["type"]), _rng().randi_range(int(size[0]), int(size[1])))
			return
	var type_id: String = RunArc.pick_weighted(row.get("singles", {}), _rng())
	if type_id != "":
		spawn_ring(type_id, 1)


func _tick_groups(row: Dictionary, delta: float) -> void:
	var groups: Array = row.get("groups", [])
	for index: int in groups.size():
		var group: Dictionary = groups[index]
		var key: String = "%s/%s" % [group.get("type", ""), group.get("kind", "")]
		var left: float = float(_group_timers.get(key, float(group.get("every_s", 30.0)))) - delta
		if left > 0.0:
			_group_timers[key] = left
			continue
		_group_timers[key] = float(group.get("every_s", 30.0))
		if str(group.get("kind", "")) == "encircle":
			spawn_encircle(str(group["type"]), int(group.get("size", 12)))
		else:
			spawn_flyers(str(group["type"]), int(group.get("size", 5)))


## Phase 4 behaviour, used only when a level has no wave table.
func _placeholder_spawn() -> void:
	if _rng().randf() < Data.cfg_float("enemies.swarm_pack_chance"):
		var sizes: Array = Data.cfg("enemies.swarm_pack_size")
		spawn_pack(Data.cfg_string("enemies.auto_swarm_type"), _rng().randi_range(int(sizes[0]), int(sizes[1])))
	else:
		spawn_ring(Data.cfg_string("enemies.auto_chaser_type"), 1)


func _ring_offset(angle: float) -> Vector2:
	return Vector2.from_angle(angle) * ring_radius()


func _random_player() -> Player:
	var alive: Array[Player] = []
	for player: Player in GameAuthority.players:
		if player.alive:
			alive.append(player)
	if alive.is_empty():
		return null
	return alive[_rng().randi_range(0, alive.size() - 1)]


func _rng() -> RandomNumberGenerator:
	return GameAuthority.run.rng.spawns
