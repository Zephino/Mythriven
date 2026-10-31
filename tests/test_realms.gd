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
