extends GutTest
## Phase 13: the Aegean Shore bosses (timing, arena, Guard gauge, phases,
## signatures, telegraphs, rewards, Achilles' unlock), Boons, and the Unraveling.

const TEST_PROFILE := "user://test_save_scratch.json"

var _world: WorldRoot
var _enemies: EnemyManager
var _shots: EnemyProjectiles
var _bosses: BossManager
var _player: Player


func before_each() -> void:
	SaveGame.use_test_file(TEST_PROFILE)
	DirAccess.remove_absolute(TEST_PROFILE)
	GameAuthority.start_run("aegean_shore")
	_world = add_child_autofree(WorldRoot.new())
	_enemies = EnemyManager.new()
	_world.add_child(_enemies)
	_enemies.setup()
	_enemies.set_process(false)
	GameAuthority.enemies = _enemies
	var effects := EffectLayer.new()
	_world.add_child(effects)
	effects.setup()
	_shots = EnemyProjectiles.new()
	_world.add_child(_shots)
	_shots.setup()
	_shots.set_process(false)
	GameAuthority.enemy_shots = _shots
	_player = GameAuthority.spawn_player(_world, Vector2.ZERO, null, true)
	_player.stats.base["crit"] = 0.0
	_bosses = BossManager.new()
	_bosses.world = _world
	_world.add_child(_bosses)


func after_each() -> void:
	GameAuthority.end_scene()
	DirAccess.remove_absolute(TEST_PROFILE)
	SaveGame.use_test_file("")


func test_bosses_spawn_on_time_even_if_the_last_is_alive() -> void:
	GameAuthority.run.elapsed_s = 600.0
	_bosses._process(0.016)
	assert_eq(_bosses.active_count(), 1)
	var first_radius: float = _bosses.arena_radius
	assert_true(GameAuthority.run.boss_arena_active)
	GameAuthority.run.elapsed_s = 1200.0
	_bosses._process(0.016)
	assert_eq(_bosses.active_count(), 2, "Medusa and Achilles fight at once")
	assert_gt(_bosses.arena_radius, first_radius, "the arena grows to hold both")


func test_clean_slate_bursts_regular_enemies() -> void:
	for k: int in 10:
		_enemies.spawn("satyr_skirmisher", Vector2(30 + k * 5, 0))
	_bosses.spawn_boss("medusa", 0)
	assert_eq(_enemies.active_count(), 1, "only the boss is left")
	assert_eq(GameAuthority.run.kills, 10)


func test_guard_gauge_breaks_and_weakness_fills_it_twice_as_fast() -> void:
	var boss: BossController = _bosses.spawn_boss("medusa", 0)
	boss.on_hit(100.0, 1.5, _player, Vector2.ZERO)
	assert_almost_eq(boss.guard, 100.0 * Data.cfg_float("bosses.guard_weakness_fill_mult"), 0.01)
	boss.cast = {"name_key": "CAST_SERPENT_HAIR"}
	var max_before: float = boss.guard_max
	boss.on_hit(boss.guard_max, 1.0, _player, Vector2.ZERO)
	assert_gt(boss.broken_s, 0.0, "Guard Break")
	assert_true(boss.cast.is_empty(), "the cast is cancelled")
	assert_gt(_enemies.statuses.stun[boss.slot], 0.0, "stunned")
	assert_gt(boss.guard_max, max_before, "refills more slowly")
	assert_almost_eq(boss.on_hit(10.0, 1.0, _player, Vector2.ZERO), 15.0, 0.01, "+50% damage while broken")


func test_phases_follow_hp_thresholds() -> void:
	var boss: BossController = _bosses.spawn_boss("kronos", 2)
	_enemies.hp[boss.slot] = _enemies.max_hp[boss.slot] * 0.5
	boss._update_phase()
	assert_eq(boss.phase_index, 1)
	_enemies.hp[boss.slot] = _enemies.max_hp[boss.slot] * 0.2
	boss._update_phase()
	assert_eq(boss.phase_index, 2)


func test_achilles_heel_front_and_back() -> void:
	var boss: BossController = _bosses.spawn_boss("achilles", 1)
	_enemies.positions[boss.slot] = Vector2.ZERO
	boss.facing = Vector2.RIGHT
	_player.position = Vector2(50, 0)
	assert_almost_eq(boss.modify_hit(100.0, _player, Vector2.ZERO), 20.0, 0.01, "−80% from the front")
	_player.position = Vector2(-50, 0)
	assert_almost_eq(boss.modify_hit(100.0, _player, Vector2.ZERO), 200.0, 0.01, "×2 from behind")


func test_defeating_achilles_unlocks_him_and_saves_at_once() -> void:
	assert_false(_unlocked_ids().has("achilles"))
	var boss: BossController = _bosses.spawn_boss("achilles", 1)
	GameAuthority.kill_enemy(boss.slot, _player)
	boss._process(0.016)
	assert_true(SaveGame.list(HeroRules.UNLOCKS_SECTION).has("achilles"), "saved in the save file")
	assert_true(_unlocked_ids().has("achilles"))
	assert_false(GameAuthority.run.boss_arena_active, "the arena ends with the last boss")


func test_medusa_petrifies_only_those_moving_toward_her() -> void:
	var boss: MedusaBoss = _bosses.spawn_boss("medusa", 0) as MedusaBoss
	_enemies.positions[boss.slot] = Vector2.ZERO
	var sig: Dictionary = boss.data["signature"]
	_player.position = Vector2(100, 0)
	boss.set("_gaze_dir", Vector2.RIGHT)
	_player.velocity = Vector2(50, 0)
	boss._fire_gaze(sig)
	assert_eq(_player.rooted_s, 0.0, "moving away is safe")
	_player.velocity = Vector2(-50, 0)
	boss._fire_gaze(sig)
	assert_gt(_player.rooted_s, 0.0, "moving toward her petrifies")


func test_every_attack_pattern_is_telegraphed_before_it_hurts() -> void:
	var runner := PatternRunner.new()
	_world.add_child(runner)
	var min_s: float = float((Data.cfg("bosses.telegraph_s") as Array)[0])
	for pattern_id: String in (Data.cfg("patterns") as Dictionary).keys():
		if pattern_id.begins_with("_") or pattern_id == "summon_adds":
			continue
		runner.clear()
		_player.position = Vector2(80, 0)
		var hp_before: float = _player.hp
		var total: float = runner.run({"pattern": pattern_id, "count": 5}, Vector2.ZERO, _player.position, "dark", "test", 1.0)
		assert_gte(total, min_s, "%s telegraphs at least %.1f s" % [pattern_id, min_s])
		runner._process(min_s * 0.9)
		assert_eq(_shots.count(), 0, "%s fired no shots yet" % pattern_id)
		assert_eq(_player.hp, hp_before, "%s hurt no one yet" % pattern_id)
		_shots.clear_all()


func test_unraveling_ring_shrinks_ten_percent_a_minute_and_hurts_outside() -> void:
	var ring := Unraveling.new()
	_world.add_child(ring)
	ring.begin()
	var start: float = ring.radius()
	GameAuthority.run.elapsed_s += 60.0
	assert_almost_eq(ring.radius(), start * 0.9, 0.5)
	_player.position = ring.center + Vector2(start * 2.0, 0.0)
	var hp_before: float = _player.hp
	ring._process(0.6)
	assert_lt(_player.hp, hp_before)


func test_boons_change_the_run() -> void:
	var ember: WeaponInstance = GameAuthority.give_weapon(_player, "ember")
	var count_before: int = int(ember.stats().get("count", 1))
	BoonScreen.apply(_player, {"effects": {"extra_projectiles": 1}})
	assert_eq(int(ember.stats().get("count", 1)), count_before + 1)
	assert_eq(BoonScreen.all().size(), 6)


func _unlocked_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for hero: Dictionary in HeroRules.unlocked():
		ids.append(str(hero["id"]))
	return ids
