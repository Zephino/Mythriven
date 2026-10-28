extends GutTest
## Phase 4: pooling, the spatial hash, no stacking, and contact damage with
## no invulnerability frames.

const CHASER := "placeholder_chaser"

var _parent: Node
var _enemies: EnemyManager


func before_each() -> void:
	_parent = add_child_autofree(Node2D.new())
	_enemies = EnemyManager.new()
	_parent.add_child(_enemies)
	_enemies.setup()
	_enemies.set_process(false)
	GameAuthority.enemies = _enemies


func after_each() -> void:
	for player: Player in GameAuthority.players.duplicate():
		GameAuthority.remove_player(player)
	GameAuthority.enemies = null


func test_spatial_hash_finds_only_nearby_points() -> void:
	var grid := SpatialHash.new(64.0)
	var points := PackedVector2Array([Vector2(0, 0), Vector2(30, 0), Vector2(500, 500)])
	var on := PackedByteArray([1, 1, 1])
	grid.rebuild(points, on)
	var found: PackedInt32Array = grid.query(Vector2(10, 0), 40.0, points, on)
	assert_eq(found.size(), 2)
	assert_eq(grid.nearest(Vector2(28, 0), 100.0, points, on), 1)
	on[1] = 0
	assert_eq(grid.nearest(Vector2(28, 0), 100.0, points, on), 0, "inactive slots are skipped")


func test_pool_never_exceeds_cap_and_reuses_slots() -> void:
	for i: int in _enemies.capacity:
		assert_ne(_enemies.spawn(CHASER, Vector2(i, 0)), -1)
	assert_eq(_enemies.spawn(CHASER, Vector2.ZERO), -1, "full pool refuses new enemies")
	_enemies.despawn(7)
	assert_eq(_enemies.spawn(CHASER, Vector2.ZERO), 7, "a freed slot is reused")
	assert_eq(_enemies.active_count(), _enemies.capacity)


func test_overlapping_enemies_are_pushed_apart() -> void:
	var a: int = _enemies.spawn(CHASER, Vector2(0, 0))
	var b: int = _enemies.spawn(CHASER, Vector2(2, 0))
	for _i: int in 5:
		_enemies._process(0.05)
	var min_dist: float = _enemies.radius[a] + _enemies.radius[b]
	assert_almost_eq(_enemies.positions[a].distance_to(_enemies.positions[b]), min_dist, 0.5)


func test_contact_damage_once_per_interval_without_iframes() -> void:
	var player: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true)
	var start_hp: float = player.hp
	var damage: float = float(_enemies.types[_enemies.type_index[CHASER]]["contact_damage"])
	_enemies.spawn(CHASER, Vector2(player.body_radius + 2.0, 0))
	_enemies.spawn(CHASER, Vector2(-player.body_radius - 2.0, 0))
	_enemies._process(0.01)
	assert_almost_eq(player.hp, start_hp - damage * 2.0, 0.01, "both touching enemies hit at once")
	_enemies._process(0.1)
	assert_almost_eq(player.hp, start_hp - damage * 2.0, 0.01, "each enemy waits for its own timer")
	_enemies._process(Data.cfg_float("combat.contact_damage_interval_s"))
	assert_almost_eq(player.hp, start_hp - damage * 4.0, 0.01)


func test_standing_still_surrounded_kills_the_player() -> void:
	var player: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true)
	for i: int in 8:
		_enemies.spawn(CHASER, Vector2.from_angle(TAU * i / 8.0) * 12.0)
	for _i: int in 200:
		_enemies._process(0.05)
	assert_false(player.alive)
	assert_eq(player.cause_of_death, CHASER)


func test_player_damage_uses_armor_and_minimum() -> void:
	assert_eq(Damage.to_player(10.0, 3.0, 1.0), 7.0)
	assert_eq(Damage.to_player(2.0, 5.0, 1.0), 1.0)
