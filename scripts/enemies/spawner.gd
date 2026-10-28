class_name EnemySpawner
extends Node
## Spawns enemies in a ring just outside each player's visible screen, in
## single enemies or swarm packs, and moves enemies left far behind (more than
## 2 screens from every player) to the ring ahead instead of deleting them
## (GAME_DESIGN.md: Spawning). Phase 4 uses a steady placeholder rate; the
## per-minute wave tables arrive in Phase 10.

var enemies: EnemyManager
var auto_spawn: bool = true

var _spawn_budget: float = 0.0
var _recycle_timer: float = 0.0


func _ready() -> void:
	auto_spawn = Data.cfg_bool("enemies.auto_spawn_enabled")


func _process(delta: float) -> void:
	if auto_spawn:
		var rate: float = Data.cfg_float("enemies.auto_spawn_per_s") * LevelScaling.spawn_mult(LevelScaling.current_level())
		_spawn_budget += rate * delta
		while _spawn_budget >= 1.0:
			_spawn_budget -= 1.0
			_auto_spawn_once()
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


## Moves enemies that are far from every player to the ring ahead of the nearest one.
func recycle() -> void:
	if enemies == null:
		return
	var limit: float = view_size().x * Data.cfg_float("enemies.recycle_distance_screens")
	var limit_sq: float = limit * limit
	for i: int in enemies.capacity:
		if enemies.active[i] == 0:
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


func _auto_spawn_once() -> void:
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
