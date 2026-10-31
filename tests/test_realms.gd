extends GutTest
## Packs 5-13: the fantasy realms after the finale (docs/PACK_5_PLAN.md and on): each realm's data, hazard and
## each boss's signature mechanic.

const TEST_SAVE := "user://test_realms_save.json"

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


func test_erebus_opens_from_nidhoggr_and_is_pack_5() -> void:
	var level: Dictionary = _level("erebus")
	assert_eq(int(level["act"]), 7)
	assert_eq(str(level["unlock"]["boss"]), "nidhoggr")
	assert_true((level["local_gods"] as Array).is_empty(), "a realm has no local gods")
	assert_eq(tr("PACK_7_NAME"), "Pack 5: Gothic Night")


func test_the_graves_of_erebus_grasp_and_hurt() -> void:
	_start("erebus")
	var graves := Hazard.create(_level("erebus")["hazard"]) as HazardStrikes
	_world.add_child(graves)
	graves.begin(_level("erebus")["hazard"])
	graves._strike(_player.position)
	var hp: float = _player.hp
	graves._process(0.5)
	assert_lt(_player.slow_zone_mult, 1.0, "the hands hold")
	assert_lt(_player.hp, hp, "and hurt")


func test_empusa_changes_shape() -> void:
	_start("erebus")
	var empusa: EmpusaBoss = _bosses.spawn_boss("empusa", 0) as EmpusaBoss
	empusa.signature(0.1)
	var speed: float = float(empusa.data["move_speed"])
	empusa.signature(6.0)
	assert_eq(empusa.art_id(), "empusa_bull", "now a bull")
	assert_almost_eq(empusa.modify_hit(100.0, _player, Vector2.ZERO), 50.0, 0.01, "the bull is armoured")
	empusa.signature(6.0)
	assert_eq(empusa.art_id(), "empusa_dog", "now a dog")
	assert_gt(float(empusa.data["move_speed"]), speed, "the dog is fast")


func test_eurynomos_devours_the_dead_near_him() -> void:
	_start("erebus")
	var eater: EurynomosBoss = _bosses.spawn_boss("eurynomos", 1) as EurynomosBoss
	_enemies.hp[eater.slot] = _enemies.max_hp[eater.slot] * 0.5
	var hp: float = _enemies.hp[eater.slot]
	for k: int in 3:
		GameAuthority.spawn_enemy("hunt_hound", eater.position_now() + Vector2(20 + k * 5, 0))
	var far: int = GameAuthority.spawn_enemy("hunt_hound", eater.position_now() + Vector2(400, 0))
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	assert_eq(eater.devour(), 3, "the three close by")
	assert_gt(_enemies.hp[eater.slot], hp, "and heals")
	assert_eq(_enemies.active[far], 1, "the far one is spared")


func test_the_wild_hunt_rides_and_looses_its_hounds() -> void:
	_start("erebus")
	var hunt: WildHuntBoss = _bosses.spawn_boss("wild_hunt", 2) as WildHuntBoss
	hunt.target = _player
	var before: int = _enemies.active_count()
	var at: Vector2 = hunt.position_now()
	hunt.signature(2.6)
	hunt.signature(0.3)
	assert_ne(hunt.position_now(), at, "it rides")
	assert_eq(hunt.rides, 1)
	assert_eq(_enemies.active_count(), before + 3, "and looses three hounds")


func test_karnstein_languor_wastes() -> void:
	var level: Dictionary = _level("karnstein")
	assert_eq(str(level["unlock"]["boss"]), "dahut")
	assert_eq(str(level["hazard"]["player_status"]), "poison")


func test_varney_rises_unless_the_moonlight_is_blocked() -> void:
	_start("karnstein")
	var varney: VarneyBoss = _bosses.spawn_boss("varney", 0) as VarneyBoss
	_player.position = varney.position_now() + Vector2(300, 0)
	var hp: float = _enemies.hp[varney.slot]
	assert_almost_eq(varney.modify_hit(hp * 2.0, _player, Vector2.ZERO), hp - 1.0, 0.01, "the blow only lays him down")
	assert_gt(varney.fallen_s, 0.0, "fallen in the moonlight")
	varney.signature(5.0)
	assert_true(varney.risen, "and he rises")
	assert_true(varney.is_alive())
	GameAuthority.end_scene()
	_start("karnstein")
	varney = _bosses.spawn_boss("varney", 0) as VarneyBoss
	varney.fall()
	_player.position = varney.position_now()
	varney.signature(0.1)
	assert_true(varney.finished, "a Hero blocks the light")
	assert_false(varney.is_alive(), "he stays dead")


func test_ruthven_drains_whoever_stays_close() -> void:
	_start("karnstein")
	var lord: RuthvenBoss = _bosses.spawn_boss("ruthven", 1) as RuthvenBoss
	_player.position = lord.position_now() + Vector2(60, 0)
	_enemies.hp[lord.slot] = _enemies.max_hp[lord.slot] * 0.5
	var mine: float = _player.hp
	var his: float = _enemies.hp[lord.slot]
	lord.signature(7.0)
	assert_eq(lord.victim, _player)
	lord.signature(1.0)
	assert_lt(_player.hp, mine, "drained")
	assert_gt(_enemies.hp[lord.slot], his, "and he heals")
	_player.position = lord.position_now() + Vector2(600, 0)
	lord.signature(0.1)
	assert_null(lord.victim, "stepping away breaks it")


func test_carmilla_comes_out_of_the_mist_and_becomes_a_cat() -> void:
	_start("karnstein")
	var carmilla: CarmillaBoss = _bosses.spawn_boss("carmilla", 2) as CarmillaBoss
	_player.position = carmilla.position_now() + Vector2(400, 0)
	carmilla.appear_beside(_player)
	assert_lt(carmilla.position_now().distance_to(_player.position), 60.0, "beside the Hero")
	assert_true(_player.statuses.has("poison"), "her bite wastes")
	carmilla._on_phase_started(2)
	assert_eq(carmilla.art_id(), "carmilla_cat")


func test_the_full_moon_speeds_the_monsters() -> void:
	_start("ossory")
	assert_eq(str(_level("ossory")["unlock"]["boss"]), "sinmara")
	var moon := Hazard.create(_level("ossory")["hazard"]) as HazardWeather
	_world.add_child(moon)
	moon.begin(_level("ossory")["hazard"])
	var slot: int = _enemies.spawn("wolf", Vector2(200, 0))
	var before: float = _enemies.speed_of(slot)
	for k: int in 10:
		moon._process(0.5)
	assert_gt(_enemies.speed_of(slot), before, "the wolves run faster under the moon")
	moon.queue_free()


func test_bisclavret_turns_back_on_his_clothes() -> void:
	_start("ossory")
	var wolf: BisclavretBoss = _bosses.spawn_boss("bisclavret", 0) as BisclavretBoss
	wolf.hide_clothes()
	_player.position = wolf.clothes
	wolf.signature(1.0)
	wolf.signature(1.0)
	assert_eq(wolf.art_id(), "bisclavret_man", "a man again")
	assert_almost_eq(wolf.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "and hurt twice as hard")
	wolf.signature(7.0)
	assert_eq(wolf.art_id(), "bisclavret", "then a wolf")


func test_melions_pack_shields_him() -> void:
	_start("ossory")
	var melion: MelionBoss = _bosses.spawn_boss("melion", 1) as MelionBoss
	var bare: float = melion.modify_hit(100.0, _player, Vector2.ZERO)
	melion.call_pack()
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	assert_eq(melion.pack_near(), 4)
	assert_lt(melion.modify_hit(100.0, _player, Vector2.ZERO), bare, "his wolves shield him")


func test_the_beast_hides_and_pounces() -> void:
	_start("ossory")
	var beast: GevaudanBoss = _bosses.spawn_boss("gevaudan", 2) as GevaudanBoss
	beast.target = _player
	beast.signature(6.1)
	assert_eq(beast.state, "hidden")
	assert_eq(beast.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "it can't be hurt in cover")
	beast.signature(3.1)
	assert_eq(beast.state, "stirring")
	var hp: float = _player.hp
	beast.signature(1.1)
	assert_eq(beast.pounces, 1)
	assert_lt(_player.hp, hp, "it springs on the Hero")
