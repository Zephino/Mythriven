extends GutTest
## Phases 16–18: the other Pack 1 levels (their data, the hazard library's
## weather and ground patches, and each boss's signature mechanic).

const TEST_SAVE := "user://test_levels_save.json"

var _world: WorldRoot
var _enemies: EnemyManager
var _bosses: BossManager
var _player: Player


func _start(level_id: String) -> void:
	SaveGame.use_test_file(TEST_SAVE)
	GameAuthority.start_run(level_id)
	_world = add_child_autofree(WorldRoot.new())
	_enemies = EnemyManager.new()
	_world.add_child(_enemies)
	_enemies.setup()
	_enemies.set_process(false)
	GameAuthority.enemies = _enemies
	var effects := EffectLayer.new()
	_world.add_child(effects)
	effects.setup()
	var shots := EnemyProjectiles.new()
	_world.add_child(shots)
	shots.setup()
	shots.set_process(false)
	GameAuthority.enemy_shots = shots
	_player = GameAuthority.spawn_player(_world, Vector2.ZERO, null, true)
	_bosses = BossManager.new()
	_bosses.world = _world
	_world.add_child(_bosses)


func after_each() -> void:
	GameAuthority.end_scene()
	SaveGame.use_test_file("")
	DirAccess.remove_absolute(TEST_SAVE)


func _level(level_id: String) -> Dictionary:
	return GameAuthority.find_level(level_id)


func test_every_level_has_waves_bosses_and_a_hazard_that_all_exist() -> void:
	for level: Dictionary in LevelRules.all():
		var id: String = str(level["id"])
		var table: Dictionary = RunArc.wave_table(level)
		assert_false(table.is_empty(), "%s has a wave table" % id)
		for row: Dictionary in table.get("rows", []):
			for type_id: String in (row.get("singles", {}) as Dictionary):
				assert_false(DeathRecap._enemy(type_id).is_empty(), "%s: %s exists" % [id, type_id])
			for pack: Dictionary in row.get("packs", []):
				assert_false(DeathRecap._enemy(str(pack["type"])).is_empty(), "%s: %s exists" % [id, pack["type"]])
			for group: Dictionary in row.get("groups", []):
				assert_false(DeathRecap._enemy(str(group["type"])).is_empty(), "%s: %s exists" % [id, group["type"]])
		for boss_id: Variant in (level.get("bosses", {}) as Dictionary).values():
			assert_false(BossManager.find(str(boss_id)).is_empty(), "%s: boss %s" % [id, boss_id])
			assert_true(BossManager.SCRIPTS.has(str(boss_id)), "%s has a signature script" % boss_id)
		assert_false((level.get("hazard", {}) as Dictionary).is_empty(), "%s has a hazard" % id)
		for god_id: Variant in level.get("local_gods", []):
			assert_false(GodRules.find(str(god_id)).is_empty(), "%s: local god %s" % [id, god_id])


func test_beating_the_aegean_20_00_boss_opens_the_rest_of_act_one() -> void:
	SaveGame.use_test_file(TEST_SAVE)
	assert_false(LevelRules.is_unlocked(_level("midgards_edge")))
	LevelRules.note_boss("aegean_shore", "achilles", 1)
	assert_true(LevelRules.is_unlocked(_level("midgards_edge")))


func test_the_blizzard_pushes_and_veils_then_pauses_in_a_boss_arena() -> void:
	_start("midgards_edge")
	var weather := Hazard.create(_level("midgards_edge")["hazard"]) as HazardWeather
	_world.add_child(weather)
	weather.begin(_level("midgards_edge")["hazard"])
	for _i: int in 30:
		weather._process(0.1)
	var before: Vector2 = _player.position
	weather._process(0.5)
	assert_ne(_player.position, before, "the wind pushes the Hero")
	assert_gt(weather.strength(), 0.9)
	weather.paused = true
	for _i: int in 30:
		weather._process(0.1)
	assert_eq(weather.strength(), 0.0, "hazards pause during boss arenas")


func test_frozen_ponds_make_the_hero_slide() -> void:
	_start("midgards_edge")
	var patches := GroundPatches.new()
	patches.setup(_level("midgards_edge")["ground_patches"])
	_world.add_child(patches)
	patches.patches.append({"pos": Vector2.ZERO, "radius": 40.0, "pair": -1})
	patches._process(0.016)
	assert_gt(_player.ground_grip_per_s, 0.0)
	_player.velocity = Vector2.RIGHT * 100.0
	_player.step(Vector2.UP, 0.1)
	assert_gt(_player.velocity.x, 0.0, "still sliding right after steering up")


func test_fenrir_is_held_by_his_chains_until_he_breaks_free() -> void:
	_start("midgards_edge")
	var fenrir: FenrirBoss = _bosses.spawn_boss("fenrir", 0) as FenrirBoss
	assert_not_null(fenrir)
	_player.position = fenrir.anchor + Vector2(600, 0)
	for _i: int in 120:
		fenrir._process(0.05)
	assert_lte(fenrir.position_now().distance_to(fenrir.anchor), fenrir.reach + 0.5, "the chains hold him")
	_enemies.hp[fenrir.slot] = _enemies.max_hp[fenrir.slot] * 0.2
	fenrir._process(0.05)
	assert_eq(fenrir.reach, -1.0, "free in the last phase")


func test_fenrir_gives_tyrs_oath_when_beaten_below_30_percent_health() -> void:
	_start("midgards_edge")
	var fenrir: FenrirBoss = _bosses.spawn_boss("fenrir", 0) as FenrirBoss
	_player.hp = _player.max_hp * 0.2
	assert_eq(fenrir.secret_earned(), "tyrs_oath")
	_player.hp = _player.max_hp
	assert_eq(fenrir.secret_earned(), "")


func test_loki_splits_into_copies_that_burst_when_struck() -> void:
	_start("midgards_edge")
	var loki: LokiBoss = _bosses.spawn_boss("loki", 1) as LokiBoss
	_enemies.hp[loki.slot] = _enemies.max_hp[loki.slot] * 0.5
	loki._process(0.05)
	loki._process(1.0)
	var copies: Array[int] = []
	for i: int in _enemies.capacity:
		if _enemies.active[i] != 0 and str(_enemies.type_of(i)["id"]) == "loki_illusion":
			copies.append(i)
	assert_eq(copies.size(), 3)
	GameAuthority.kill_enemy(copies[0], _player)
	assert_true(loki.patterns.busy(), "the copy bursts into fire")


func test_surtrs_fire_closes_in_and_burns_outside() -> void:
	_start("midgards_edge")
	var surtr: SurtrBoss = _bosses.spawn_boss("surtr", 2) as SurtrBoss
	var full: float = surtr.burn_radius()
	surtr._fight_s = 1000.0
	assert_lt(surtr.burn_radius(), full)
	_player.position = _bosses.arena_center + Vector2(surtr.burn_radius() + 20.0, 0)
	var hp: float = _player.hp
	surtr._burn_tick = 0.0
	surtr.signature(0.01)
	assert_lt(_player.hp, hp, "standing in the fire hurts")


func test_quicksand_slows_and_fairy_rings_carry_you_to_their_pair() -> void:
	_start("the_two_lands")
	var sand := GroundPatches.new()
	sand.setup(_level("the_two_lands")["ground_patches"])
	_world.add_child(sand)
	sand.patches.append({"pos": Vector2.ZERO, "radius": 40.0, "pair": -1})
	sand._process(0.016)
	assert_lt(_player.ground_speed_mult, 1.0)
	var rings := GroundPatches.new()
	rings.setup(_level("the_misty_isles")["ground_patches"])
	_world.add_child(rings)
	rings.patches.append({"pos": Vector2.ZERO, "radius": 30.0, "pair": 1})
	rings.patches.append({"pos": Vector2(500, 0), "radius": 30.0, "pair": 0})
	rings._teleport(_player, 0)
	assert_eq(_player.position, Vector2(500, 0))


func test_ammits_scale_tips_with_every_hit_and_she_devours() -> void:
	_start("the_two_lands")
	var ammit: AmmitBoss = _bosses.spawn_boss("ammit", 0) as AmmitBoss
	_enemies.hp[ammit.slot] = _enemies.max_hp[ammit.slot] * 0.5
	ammit._process(0.01)
	assert_true(ammit.scale_active())
	GameAuthority.damage_player(_player, 200.0, "test")
	assert_eq(ammit.tipped, 1.0)
	ammit.signature(0.01)
	assert_eq(ammit.tipped, 0.0, "she devours and the scale resets")


func test_set_brings_a_sandstorm_and_pulling_cyclones() -> void:
	_start("the_two_lands")
	var set_boss: SetBoss = _bosses.spawn_boss("set", 1) as SetBoss
	_enemies.hp[set_boss.slot] = _enemies.max_hp[set_boss.slot] * 0.2
	set_boss._process(0.01)
	assert_not_null(set_boss._storm, "the sandstorm veils the screen")
	set_boss.cyclones.append({"pos": _player.position + Vector2(40, 0), "dir": Vector2.ZERO, "left": 5.0})
	var before: Vector2 = _player.position
	set_boss._tick_cyclones(0.2)
	assert_gt(_player.position.x, before.x, "the cyclone pulls")


func test_apep_swallows_ra_and_freeing_him_finds_the_suns_return() -> void:
	_start("the_two_lands")
	var gods := GodManager.new()
	gods.summons = SummonLayer.new()
	_world.add_child(gods.summons)
	_world.add_child(gods)
	gods.bind(_player, "ra")
	var apep: ApepBoss = _bosses.spawn_boss("apep", 2) as ApepBoss
	_enemies.hp[apep.slot] = _enemies.max_hp[apep.slot] * 0.5
	apep._process(0.01)
	assert_eq(apep.swallowed, "ra")
	assert_false(gods.bound_ids(_player).has("ra"))
	for _i: int in 10:
		apep._orb_t = 0.1
		apep.modify_hit(1.0, _player, Vector2.ZERO)
	assert_true(gods.bound_ids(_player).has("ra"), "freed after 10 hits on the glowing orb")
	assert_eq(apep.secret_earned(), "the_suns_return")


func test_scathach_names_each_technique_and_repeats_it_faster() -> void:
	_start("the_misty_isles")
	var scathach: ScathachBoss = _bosses.spawn_boss("scathach", 0) as ScathachBoss
	scathach._next_attack()
	var first: Dictionary = scathach.cast.duplicate()
	assert_true(str(first["name_key"]).begins_with("CAST_SCATHACH"))
	scathach._next_attack()
	scathach._next_attack()
	assert_eq(scathach.cast["name_key"], first["name_key"])
	assert_lt(float(scathach.cast["cast_s"]), float(first["cast_s"]), "faster the second time")


func test_ferdiad_blocks_from_the_front_and_the_ford_slows() -> void:
	_start("the_misty_isles")
	var ferdiad: FerdiadBoss = _bosses.spawn_boss("ferdiad", 1) as FerdiadBoss
	var at: Vector2 = ferdiad.position_now()
	ferdiad.facing = Vector2.RIGHT
	_player.position = at + Vector2(40, 0)
	assert_lt(ferdiad.modify_hit(100.0, _player, Vector2.ZERO), 50.0, "horn-skin blocks the front")
	_player.position = at + Vector2(-40, 0)
	assert_eq(ferdiad.modify_hit(100.0, _player, Vector2.ZERO), 100.0, "not from behind")
	_player.position = ferdiad.ford_center
	ferdiad.signature(0.01)
	assert_lt(_player.slow_zone_mult, 1.0)
	_player.hero = HeroRules.find("cu_chulainn")
	assert_eq(ferdiad.secret_earned(), "the_ford")


func test_balors_eye_is_blocked_by_stone_and_counts_hits_on_the_eye() -> void:
	_start("the_misty_isles")
	var balor: BalorBoss = _bosses.spawn_boss("balor", 2) as BalorBoss
	_enemies.hp[balor.slot] = _enemies.max_hp[balor.slot] * 0.5
	balor._process(0.01)
	assert_eq(balor.stones.size(), 4)
	var eye: Vector2 = balor.position_now()
	var stone: Vector2 = balor.stones[0]
	assert_true(balor._shielded(eye, stone + (stone - eye).normalized() * 40.0), "a stone breaks the line of sight")
	balor._open_left = 3.0
	var guard: float = balor.guard
	balor.on_hit(10.0, 1.0, _player, Vector2.ZERO)
	assert_almost_eq(balor.guard - guard, 30.0, 0.01, "hits on the open eye fill the gauge ×3")
	assert_eq(balor.eye_hits, 1)
