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


func test_the_witches_hex_whoever_they_strike() -> void:
	_start("the_brocken")
	assert_eq(str(_level("the_brocken")["unlock"]["boss"]), "roc")
	var ride := Hazard.create(_level("the_brocken")["hazard"]) as HazardStrikes
	_world.add_child(ride)
	ride.begin(_level("the_brocken")["hazard"])
	ride._strike(_player.position)
	assert_true(_player.statuses.has("hex"), "hexed")


func test_the_brocken_spectre_stands_opposite() -> void:
	_start("the_brocken")
	var spectre: BrockenSpectreBoss = _bosses.spawn_boss("brocken_spectre", 0) as BrockenSpectreBoss
	spectre.target = _player
	_player.position = _bosses.arena_center + Vector2(100, 0)
	for k: int in 20:
		spectre.signature(0.5)
	assert_lt(spectre.position_now().distance_to(_bosses.arena_center - Vector2(100, 0)), 2.0, "mirrored through the middle")


func test_baubo_rides_and_calls_witches() -> void:
	_start("the_brocken")
	var baubo: WildHuntBoss = _bosses.spawn_boss("baubo", 1) as WildHuntBoss
	baubo.target = _player
	var before: int = _enemies.active_count()
	baubo.signature(2.6)
	assert_eq(_enemies.active_count(), before + 2, "two witches follow her")


func test_black_annis_goes_home_heals_and_springs() -> void:
	_start("the_brocken")
	var annis: BlackAnnisBoss = _bosses.spawn_boss("black_annis", 2) as BlackAnnisBoss
	_enemies.hp[annis.slot] = _enemies.max_hp[annis.slot] * 0.5
	annis.signature(7.1)
	assert_eq(annis.state, "home")
	for k: int in 20:
		if annis.state == "spring":
			break
		annis.signature(0.25)
	assert_gt(_enemies.hp[annis.slot], _enemies.max_hp[annis.slot] * 0.5, "she heals in her bower")
	assert_eq(annis.state, "spring")
	_player.position = annis._spring_to
	var hp: float = _player.hp
	for k: int in 10:
		annis.signature(0.1)
	assert_eq(annis.springs, 1)
	assert_lt(_player.hp, hp, "her claws")


func test_pack_5_boss_secrets() -> void:
	_start("erebus")
	var eater: EurynomosBoss = _bosses.spawn_boss("eurynomos", 1) as EurynomosBoss
	assert_eq(eater.secret_earned(), "nothing_to_eat")
	eater.devoured = 10
	assert_eq(eater.secret_earned(), "", "he ate too well")
	var hunt: WildHuntBoss = _bosses.spawn_boss("wild_hunt", 2) as WildHuntBoss
	assert_eq(hunt.secret_earned(), "the_last_horn")
	hunt.rides = 8
	assert_eq(hunt.secret_earned(), "")
	GameAuthority.end_scene()
	_start("the_brocken")
	var baubo: WildHuntBoss = _bosses.spawn_boss("baubo", 1) as WildHuntBoss
	assert_eq(baubo.secret_earned(), "", "Baubo shares the ride, not the secret")
	var spectre: BrockenSpectreBoss = _bosses.spawn_boss("brocken_spectre", 0) as BrockenSpectreBoss
	assert_eq(spectre.secret_earned(), "the_glory")
	spectre.age = 61.0
	assert_eq(spectre.secret_earned(), "")
	var annis: BlackAnnisBoss = _bosses.spawn_boss("black_annis", 2) as BlackAnnisBoss
	assert_eq(annis.secret_earned(), "the_empty_bower")
	GameAuthority.end_scene()
	_start("karnstein")
	var varney: VarneyBoss = _bosses.spawn_boss("varney", 0) as VarneyBoss
	assert_eq(varney.secret_earned(), "", "not yet beaten that way")
	varney.finished = true
	assert_eq(varney.secret_earned(), "the_moon_blocked")
	var carmilla: CarmillaBoss = _bosses.spawn_boss("carmilla", 2) as CarmillaBoss
	assert_eq(carmilla.secret_earned(), "lauras_charm")
	carmilla.appear_beside(_player)
	assert_eq(carmilla.secret_earned(), "", "bitten")
	GameAuthority.end_scene()
	_start("ossory")
	var wolf: BisclavretBoss = _bosses.spawn_boss("bisclavret", 0) as BisclavretBoss
	wolf.turned = 2
	assert_eq(wolf.secret_earned(), "the_kings_mercy")
	var beast: GevaudanBoss = _bosses.spawn_boss("gevaudan", 2) as GevaudanBoss
	assert_eq(beast.secret_earned(), "out_of_the_undergrowth")
	for secret: String in ["nothing_to_eat", "the_last_horn", "the_moon_blocked", "lauras_charm", "the_kings_mercy",
			"out_of_the_undergrowth", "the_glory", "the_empty_bower"]:
		var reward: Dictionary = SecretRules.find(secret)["reward"]
		if str(reward["type"]) == "passive":
			assert_false(LevelUpRules.passive_data(str(reward["id"])).is_empty(), secret)
		else:
			assert_false(Rewards.cosmetic(str(reward["id"])).is_empty(), secret)


func test_nidavellir_is_pack_6_with_molten_runs() -> void:
	var level: Dictionary = _level("nidavellir")
	assert_eq(int(level["act"]), 8)
	assert_eq(str(level["unlock"]["boss"]), "gevaudan")
	assert_eq(str(level["hazard"]["look"]), "heat")
	assert_eq(tr("PACK_8_NAME"), "Pack 6: The Deep Below")


func test_gullinbursti_gallops_leaving_golden_light() -> void:
	_start("nidavellir")
	var boar: MorvarchBoss = _bosses.spawn_boss("gullinbursti", 0) as MorvarchBoss
	boar.target = _player
	var at: Vector2 = boar.position_now()
	boar.signature(2.6)
	boar.signature(0.3)
	assert_ne(boar.position_now(), at, "it runs")
	assert_gt(boar.foam.size(), 0, "a trail of golden light")


func test_brokkr_at_the_bellows() -> void:
	_start("nidavellir")
	var smith: BrokkrBoss = _bosses.spawn_boss("brokkr", 1) as BrokkrBoss
	smith.start_work()
	smith.signature(4.1)
	assert_eq(smith.forged, 1, "left alone, the hammer is made")
	assert_gt(smith.hammer_s, 0.0)
	smith.start_work()
	smith.modify_hit(_enemies.max_hp[smith.slot] * 0.06, _player, Vector2.ZERO)
	assert_eq(smith.spoiled, 1, "stung, the forging fails")
	assert_eq(smith.working_s, 0.0)


func test_andvaris_ring_breaks_his_guard_and_curses() -> void:
	_start("nidavellir")
	var dwarf: AndvariBoss = _bosses.spawn_boss("andvari", 2) as AndvariBoss
	dwarf.drop_ring()
	_player.position = dwarf.ring
	dwarf.signature(0.1)
	assert_eq(dwarf.taken, 1)
	assert_gt(dwarf.broken_s, 0.0, "his guard breaks")
	assert_true(_player.statuses.has("hex"), "the curse")


func test_alviss_turns_to_stone_in_the_daylight() -> void:
	_start("svartalfheim")
	assert_eq(str(_level("svartalfheim")["unlock"]["boss"]), "wild_hunt")
	var dwarf: AlvissBoss = _bosses.spawn_boss("alviss", 0) as AlvissBoss
	dwarf.beams.append({"pos": dwarf.position_now(), "drift": Vector2.ZERO})
	dwarf.signature(0.1)
	assert_eq(dwarf.art_id(), "alviss_stone", "stone")
	assert_almost_eq(dwarf.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "and brittle")
	dwarf.signature(4.1)
	assert_eq(dwarf.art_id(), "alviss")


func test_fjalar_and_galars_vats_heal_until_tipped() -> void:
	_start("svartalfheim")
	var brothers: FjalarAndGalarBoss = _bosses.spawn_boss("fjalar_and_galar", 1) as FjalarAndGalarBoss
	brothers.brew()
	assert_eq(brothers.vats.size(), 3)
	_enemies.hp[brothers.slot] = _enemies.max_hp[brothers.slot] * 0.5
	var hp: float = _enemies.hp[brothers.slot]
	_player.position = brothers.vats[0]["pos"]
	brothers.signature(0.6)
	assert_gt(_enemies.hp[brothers.slot], hp, "the mead heals them")
	brothers.signature(0.6)
	assert_eq(brothers.tipped, 1, "a vat tipped")
	assert_eq(brothers.vats.size(), 2)


func test_alberich_vanishes_until_his_cloak_is_torn() -> void:
	_start("svartalfheim")
	var dwarf: AlberichBoss = _bosses.spawn_boss("alberich", 2) as AlberichBoss
	_player.position = dwarf.position_now() + Vector2(300, 0)
	dwarf.signature(6.1)
	assert_gt(dwarf.cloaked_s, 0.0)
	assert_eq(dwarf.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "unseen, unhurt")
	_player.position = dwarf.position_now()
	dwarf.signature(0.1)
	assert_eq(dwarf.torn, 1)
	assert_gt(dwarf.broken_s, 0.0, "his guard breaks")


func test_mycendra_spore_clouds_poison() -> void:
	var level: Dictionary = _level("mycendra")
	assert_eq(str(level["unlock"]["boss"]), "carmilla")
	assert_eq(str(level["hazard"]["player_status"]), "poison")


func test_the_great_puffball_bursts_as_it_is_hurt() -> void:
	_start("mycendra")
	var puff: PuffballBoss = _bosses.spawn_boss("great_puffball", 0) as PuffballBoss
	_player.position = puff.position_now()
	_enemies.hp[puff.slot] = _enemies.max_hp[puff.slot] * 0.75
	puff.signature(0.1)
	assert_eq(puff.bursts, 2, "a burst for each tenth lost (90% and 80%)")
	assert_true(_player.statuses.has("poison"))


func test_the_mycelium_spreads_and_holds() -> void:
	_start("mycendra")
	var web: MyceliumBoss = _bosses.spawn_boss("mycelium", 1) as MyceliumBoss
	web.signature(2.1)
	assert_eq(web.threads.size(), 1)
	_player.position = web.threads[0]
	web.signature(0.1)
	assert_lt(_player.slow_zone_mult, 1.0, "the threads hold")
	web.on_origin_shifted(Vector2(100, 0), Vector2i.ZERO)
	assert_eq(web.threads[0], _player.position - Vector2(100, 0), "and move with the world")


func test_the_spore_mothers_mushrooms_burst_unless_stamped() -> void:
	_start("mycendra")
	var mother: SporeMotherBoss = _bosses.spawn_boss("spore_mother", 2) as SporeMotherBoss
	mother.sprout()
	mother.sprout()
	_player.position = mother.sprouts[0]["pos"]
	mother.signature(0.7)
	assert_eq(mother.stamped, 1, "stamped out")
	mother.signature(5.0)
	assert_gt(mother.burst_count, 0, "the other one burst")


func test_the_gold_digging_ant_chases_the_thief() -> void:
	_start("the_myrmidon_hive")
	assert_eq(str(_level("the_myrmidon_hive")["unlock"]["boss"]), "black_annis")
	var ant: GoldAntBoss = _bosses.spawn_boss("great_gold_ant", 0) as GoldAntBoss
	ant.dig()
	var gold: float = GameAuthority.run.gold
	_player.position = ant.heaps[0]
	ant.signature(0.1)
	assert_gt(GameAuthority.run.gold, gold, "the gold is yours")
	assert_eq(ant.thief, _player, "and so is the ant")
	var far: float = ant.position_now().distance_to(_player.position)
	ant.signature(0.5)
	assert_lt(ant.position_now().distance_to(_player.position), far, "it runs you down")


func test_myrmex_ploughs_furrows() -> void:
	_start("the_myrmidon_hive")
	var girl: MorvarchBoss = _bosses.spawn_boss("myrmex", 1) as MorvarchBoss
	girl.target = _player
	girl.signature(2.6)
	girl.signature(0.3)
	assert_gt(girl.foam.size(), 0, "a furrow")


func test_the_ant_queen_is_fed_by_her_carriers() -> void:
	_start("the_myrmidon_hive")
	var queen: AntQueenBoss = _bosses.spawn_boss("ant_queen", 2) as AntQueenBoss
	_enemies.hp[queen.slot] = _enemies.max_hp[queen.slot] * 0.5
	var hp: float = _enemies.hp[queen.slot]
	queen.send_carriers()
	queen._send_in = 999.0
	assert_eq(queen.carriers.size(), 3)
	_enemies.remove_quietly(queen.carriers[0])
	for k: int in 60:
		queen.signature(0.25)
	assert_eq(queen.delivered, 2, "two carriers reach her (one was killed)")
	assert_gt(_enemies.hp[queen.slot], hp, "and the gold heals her")


func test_the_bonus_level_and_the_finale_are_listed_after_the_packs() -> void:
	var order: Array[Dictionary] = LevelRules.in_list_order()
	var ids: Array = order.map(func(l: Dictionary) -> String: return str(l["id"]))
	assert_eq(ids[ids.size() - 2], "the_realm_of_the_ten_suns")
	assert_eq(ids[ids.size() - 1], "the_crossroads")
	assert_lt(ids.find("erebus"), ids.find("the_realm_of_the_ten_suns"), "Pack 5 comes before the bonus level")


func test_pack_6_boss_secrets() -> void:
	_start("nidavellir")
	var smith: BrokkrBoss = _bosses.spawn_boss("brokkr", 1) as BrokkrBoss
	assert_eq(smith.secret_earned(), "")
	smith.spoiled = 3
	assert_eq(smith.secret_earned(), "the_flys_sting")
	var dwarf: AndvariBoss = _bosses.spawn_boss("andvari", 2) as AndvariBoss
	assert_eq(dwarf.secret_earned(), "the_ring_refused")
	dwarf.taken = 1
	assert_eq(dwarf.secret_earned(), "", "someone took it")
	GameAuthority.end_scene()
	_start("svartalfheim")
	var alviss: AlvissBoss = _bosses.spawn_boss("alviss", 0) as AlvissBoss
	alviss.petrified = 3
	assert_eq(alviss.secret_earned(), "the_dawn")
	var alberich: AlberichBoss = _bosses.spawn_boss("alberich", 2) as AlberichBoss
	alberich.torn = 2
	assert_eq(alberich.secret_earned(), "the_tarnkappe")
	GameAuthority.end_scene()
	_start("mycendra")
	var puff: PuffballBoss = _bosses.spawn_boss("great_puffball", 0) as PuffballBoss
	assert_eq(puff.secret_earned(), "clean_air")
	_player.position = puff.position_now()
	puff.burst()
	assert_eq(puff.secret_earned(), "", "breathed the spores")
	var mother: SporeMotherBoss = _bosses.spawn_boss("spore_mother", 2) as SporeMotherBoss
	mother.stamped = 10
	assert_eq(mother.secret_earned(), "the_stamping")
	GameAuthority.end_scene()
	_start("the_myrmidon_hive")
	var ant: GoldAntBoss = _bosses.spawn_boss("great_gold_ant", 0) as GoldAntBoss
	ant.thefts = 3
	assert_eq(ant.secret_earned(), "the_gold_thief")
	var queen: AntQueenBoss = _bosses.spawn_boss("ant_queen", 2) as AntQueenBoss
	assert_eq(queen.secret_earned(), "the_starved_queen")
	queen.delivered = 3
	assert_eq(queen.secret_earned(), "")
	for secret: String in ["the_flys_sting", "the_ring_refused", "the_dawn", "the_tarnkappe", "clean_air", "the_stamping",
			"the_gold_thief", "the_starved_queen"]:
		var reward: Dictionary = SecretRules.find(secret)["reward"]
		if str(reward["type"]) == "passive":
			assert_false(LevelUpRules.passive_data(str(reward["id"])).is_empty(), secret)
		else:
			assert_false(Rewards.cosmetic(str(reward["id"])).is_empty(), secret)


func test_alfheim_is_pack_7_with_elf_shot() -> void:
	var level: Dictionary = _level("alfheim")
	assert_eq(int(level["act"]), 9)
	assert_eq(str(level["unlock"]["boss"]), "andvari")
	assert_eq(str(level["hazard"]["player_status"]), "shock")
	assert_eq(tr("PACK_9_NAME"), "Pack 7: The Wild Green")


func test_the_erlkings_daughter_strikes_who_leaves_the_dance() -> void:
	_start("alfheim")
	var daughter: ErlkingDaughterBoss = _bosses.spawn_boss("erlking_daughter", 0) as ErlkingDaughterBoss
	daughter.invite(_player)
	daughter.signature(3.1)
	assert_eq(daughter.danced, 1, "a whole dance: no harm")
	daughter.invite(_player)
	var hp: float = _player.hp
	_player.position += Vector2(200, 0)
	daughter.signature(0.1)
	assert_eq(daughter.struck, 1, "stepped out")
	assert_lt(_player.hp, hp)


func test_volundr_flies_out_of_reach_and_drops_strikes() -> void:
	_start("alfheim")
	var smith: VolundrBoss = _bosses.spawn_boss("volundr", 1) as VolundrBoss
	smith.take_wing()
	assert_eq(smith.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "out of reach")
	smith.signature(0.4)
	assert_gt(smith.marks.size(), 0, "a strike is marked under the Hero")
	var hp: float = _player.hp
	smith.signature(1.1)
	assert_lt(_player.hp, hp, "and lands")


func test_the_erlking_draws_a_hero_to_him() -> void:
	_start("alfheim")
	var king: ErlkingBoss = _bosses.spawn_boss("erlking", 2) as ErlkingBoss
	_player.position = king.position_now() + Vector2(200, 0)
	king.lure(_player)
	king.signature(1.0)
	assert_lt(_player.position.distance_to(king.position_now()), 200.0, "drawn toward him")


func test_elfame_has_glamour_and_fairy_rings() -> void:
	var level: Dictionary = _level("elfame")
	assert_eq(str(level["unlock"]["boss"]), "alberich")
	assert_eq(str(level["ground_patches"]["kind"]), "teleport")


func test_hold_tam_lin_fast_to_free_him() -> void:
	_start("elfame")
	var knight: TamLinBoss = _bosses.spawn_boss("tam_lin", 0) as TamLinBoss
	var first: String = knight.art_id()
	_player.position = knight.position_now()
	var hp: float = _player.hp
	for k: int in 9:
		knight.signature(0.5)
	assert_ne(knight.art_id(), first, "he changes shape")
	assert_lt(_player.hp, hp, "his shapes burn")
	assert_eq(knight.freed, 1, "held through a whole change")
	assert_gt(knight.broken_s, 0.0)


func test_the_elf_knights_horn_and_lullaby() -> void:
	_start("elfame")
	var knight: ElfKnightBoss = _bosses.spawn_boss("the_elf_knight", 1) as ElfKnightBoss
	_player.position = knight.position_now() + Vector2(200, 0)
	knight.modify_hit(1.0, _player, Vector2.ZERO)
	knight.signature(3.0)
	knight.modify_hit(1.0, _player, Vector2.ZERO)
	knight.signature(2.1)
	assert_eq(knight.horns, 1)
	knight.signature(0.5)
	assert_lt(_player.position.distance_to(knight.position_now()), 200.0, "the horn draws you")
	knight.signature(4.1)
	assert_true(knight.asleep, "lulled to sleep")
	assert_almost_eq(knight.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "the waking blow")
	assert_false(knight.asleep)


func test_the_fruit_of_elfland_heals_and_binds() -> void:
	_start("elfame")
	var queen: QueenOfElfameBoss = _bosses.spawn_boss("queen_of_elfame", 2) as QueenOfElfameBoss
	queen.grow_fruit()
	_player.hp = _player.max_hp * 0.5
	_player.position = queen.fruit[0]
	queen.signature(0.1)
	assert_eq(queen.eaten, 1)
	assert_gt(_player.hp, _player.max_hp * 0.5, "healed")


func test_arcadia_stampede_and_the_hind_bounds_away() -> void:
	_start("arcadia")
	assert_eq(str(_level("arcadia")["unlock"]["boss"]), "spore_mother")
	var hind: CeryneianHindBoss = _bosses.spawn_boss("ceryneian_hind", 0) as CeryneianHindBoss
	_player.position = hind.position_now() + Vector2(30, 0)
	hind.signature(0.1)
	assert_eq(hind.bounds, 1)
	assert_gt(hind.position_now().distance_to(_player.position), 90.0, "it bounds far away")


func test_the_erymanthian_boar_sticks_in_the_snow() -> void:
	_start("arcadia")
	var boar: ErymanthianBoarBoss = _bosses.spawn_boss("erymanthian_boar", 1) as ErymanthianBoarBoss
	boar.target = _player
	boar.signature(0.1)
	assert_eq(boar.drifts.size(), 4)
	boar.drifts[0] = boar.position_now()
	boar.gallop_s = 0.5
	boar.signature(0.05)
	assert_eq(boar.stuck_count, 1, "stuck fast")
	assert_gt(boar.stuck_s, 0.0)


func test_zeus_strikes_lycaon_too() -> void:
	_start("arcadia")
	var king: LycaonBoss = _bosses.spawn_boss("lycaon", 2) as LycaonBoss
	_player.position = king.position_now() + Vector2(300, 0)
	var his: float = _enemies.hp[king.slot]
	var mine: float = _player.hp
	king.call_down()
	king.signature(1.3)
	assert_eq(king.self_struck, 1, "the bolt under him")
	assert_lt(_enemies.hp[king.slot], his)
	assert_lt(_player.hp, mine, "and the bolt under the Hero")
	king._on_phase_started(2)
	assert_eq(king.art_id(), "lycaon_wolf")


func test_karkinos_shell_turns_blows_from_the_front() -> void:
	_start("lerna")
	assert_eq(str(_level("lerna")["unlock"]["boss"]), "ant_queen")
	var crab: KarkinosBoss = _bosses.spawn_boss("karkinos", 0) as KarkinosBoss
	crab.facing = Vector2.RIGHT
	_player.position = crab.position_now() + Vector2(40, 0)
	var front: float = crab.modify_hit(100.0, _player, Vector2.ZERO)
	_player.position = crab.position_now() + Vector2(-40, 0)
	var back: float = crab.modify_hit(100.0, _player, Vector2.ZERO)
	assert_lt(front, back, "the shell turns frontal blows")


func test_echions_stone_turns_the_sown_men_on_each_other() -> void:
	_start("lerna")
	var sown: EchionBoss = _bosses.spawn_boss("echion", 1) as EchionBoss
	sown.raise_sown_men()
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	sown.place_stone()
	_player.position = sown.stone
	sown.signature(0.1)
	assert_eq(sown.thrown, 1)
	var charmed: int = 0
	for slot: int in _enemies.active.size():
		if _enemies.active[slot] != 0 and _enemies.charmed[slot] != 0:
			charmed += 1
	assert_eq(charmed, 4, "every sown man turns")


func test_the_hydra_grows_heads_fire_sears_and_the_last_head_must_be_buried() -> void:
	_start("lerna")
	var hydra: HydraBoss = _bosses.spawn_boss("hydra", 2) as HydraBoss
	hydra.signature(0.1)
	assert_eq(hydra.heads, 9)
	hydra.signature(8.0)
	assert_eq(hydra.heads, 10, "a head grows back")
	hydra.on_element_hit("fire")
	assert_eq(hydra.heads, 9, "fire sears a neck")
	var hp: float = _enemies.hp[hydra.slot]
	assert_almost_eq(hydra.modify_hit(hp * 3.0, _player, Vector2.ZERO), hp - 1.0, 0.01, "the immortal head")
	assert_ne(hydra.rock, Vector2.INF, "the rock appears")
	_player.position = hydra.rock
	hydra.signature(0.8)
	hydra.signature(0.8)
	assert_true(hydra.buried)
	assert_false(hydra.is_alive(), "buried, it dies")


func test_pack_7_boss_secrets() -> void:
	_start("alfheim")
	var daughter: ErlkingDaughterBoss = _bosses.spawn_boss("erlking_daughter", 0) as ErlkingDaughterBoss
	daughter.danced = 3
	assert_eq(daughter.secret_earned(), "the_full_dance")
	daughter.struck = 1
	assert_eq(daughter.secret_earned(), "", "stepped out once")
	var king: ErlkingBoss = _bosses.spawn_boss("erlking", 2) as ErlkingBoss
	assert_eq(king.secret_earned(), "home_before_dawn")
	GameAuthority.end_scene()
	_start("elfame")
	var knight: TamLinBoss = _bosses.spawn_boss("tam_lin", 0) as TamLinBoss
	knight.freed = 3
	assert_eq(knight.secret_earned(), "janets_hold")
	var queen: QueenOfElfameBoss = _bosses.spawn_boss("queen_of_elfame", 2) as QueenOfElfameBoss
	assert_eq(queen.secret_earned(), "true_thomas")
	queen.eaten = 1
	assert_eq(queen.secret_earned(), "")
	GameAuthority.end_scene()
	_start("arcadia")
	var hind: CeryneianHindBoss = _bosses.spawn_boss("ceryneian_hind", 0) as CeryneianHindBoss
	assert_eq(hind.secret_earned(), "the_years_chase")
	var wolf_king: LycaonBoss = _bosses.spawn_boss("lycaon", 2) as LycaonBoss
	wolf_king.self_struck = 3
	assert_eq(wolf_king.secret_earned(), "zeus_judgement")
	GameAuthority.end_scene()
	_start("lerna")
	var sown: EchionBoss = _bosses.spawn_boss("echion", 1) as EchionBoss
	sown.thrown = 3
	assert_eq(sown.secret_earned(), "the_thrown_stone")
	var hydra: HydraBoss = _bosses.spawn_boss("hydra", 2) as HydraBoss
	hydra.seared = 5
	assert_eq(hydra.secret_earned(), "iolaus_brands")
	for secret: String in ["the_full_dance", "home_before_dawn", "janets_hold", "true_thomas", "the_years_chase",
			"zeus_judgement", "the_thrown_stone", "iolaus_brands"]:
		var reward: Dictionary = SecretRules.find(secret)["reward"]
		if str(reward["type"]) == "passive":
			assert_false(LevelUpRules.passive_data(str(reward["id"])).is_empty(), secret)
		else:
			assert_false(Rewards.cosmetic(str(reward["id"])).is_empty(), secret)


func test_ghorvast_is_pack_8_with_fire_arrows() -> void:
	var level: Dictionary = _level("ghorvast")
	assert_eq(int(level["act"]), 10)
	assert_eq(str(level["unlock"]["boss"]), "hydra")
	assert_eq(str(level["hazard"]["player_status"]), "burn")
	assert_eq(tr("PACK_10_NAME"), "Pack 8: Warlords")


func test_the_war_drummer_calls_orcs_faster_when_hurt() -> void:
	_start("ghorvast")
	var drummer: WarDrummerBoss = _bosses.spawn_boss("war_drummer", 0) as WarDrummerBoss
	var whole: float = drummer.beat_every()
	var before: int = _enemies.active_count()
	drummer.beat()
	assert_eq(_enemies.active_count(), before + 3, "orcs come to the drum")
	_enemies.hp[drummer.slot] = _enemies.max_hp[drummer.slot] * 0.2
	assert_lt(drummer.beat_every(), whole, "faster when hurt")


func test_the_pit_champion_rages_then_is_spent() -> void:
	_start("ghorvast")
	var champ: PitChampionBoss = _bosses.spawn_boss("pit_champion", 1) as PitChampionBoss
	champ.modify_hit(_enemies.max_hp[champ.slot] * 0.09, _player, Vector2.ZERO)
	assert_gt(champ.berserk_s, 0.0, "berserk")
	champ.signature(5.1)
	assert_gt(champ.spent_s, 0.0, "then spent")
	assert_almost_eq(champ.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "and takes double damage")


func test_the_warlords_banner_shields_him_until_torn_down() -> void:
	_start("ghorvast")
	var lord: WarlordBoss = _bosses.spawn_boss("warlord", 2) as WarlordBoss
	lord.plant()
	assert_almost_eq(lord.modify_hit(100.0, _player, Vector2.ZERO), 30.0, 0.01, "the banner shields him")
	_player.position = lord.banner
	lord.signature(0.8)
	lord.signature(0.8)
	assert_eq(lord.torn, 1)
	assert_almost_eq(lord.modify_hit(100.0, _player, Vector2.ZERO), 100.0, 0.01)


func test_the_cretan_bull_is_dazed_when_it_misses() -> void:
	_start("knossos")
	assert_eq(str(_level("knossos")["unlock"]["boss"]), "lycaon")
	var bull: CretanBullBoss = _bosses.spawn_boss("cretan_bull", 0) as CretanBullBoss
	bull.target = _player
	_player.position = bull.position_now() + Vector2(0, 400)
	bull.signature(2.6)
	bull.signature(0.7)
	bull.signature(0.1)
	assert_eq(bull.misses, 1, "it charged and missed")
	assert_gt(bull.dazed_s, 0.0, "dazed")
	assert_almost_eq(bull.modify_hit(10.0, _player, Vector2.ZERO), 15.0, 0.01)


func test_minos_condemns_the_hero_who_keeps_away() -> void:
	_start("knossos")
	var king: MinosBoss = _bosses.spawn_boss("minos", 1) as MinosBoss
	_player.position = king.position_now() + Vector2(300, 0)
	king.condemn_farthest()
	assert_eq(king.condemned, _player)
	var hp: float = _player.hp
	king.signature(1.0)
	assert_lt(_player.hp, hp, "the sentence hurts")
	_player.position = king.position_now() + Vector2(40, 0)
	king.signature(0.1)
	assert_null(king.condemned, "judged, the sentence ends")


func test_asterion_rushes_thrice_then_is_winded() -> void:
	_start("knossos")
	var bull_man: AsterionBoss = _bosses.spawn_boss("asterion", 2) as AsterionBoss
	_player.position = bull_man.position_now() + Vector2(400, 0)
	bull_man.signature(5.1)
	assert_gt(bull_man.rush_s, 0.0, "the first rush")
	for k: int in 20:
		bull_man.signature(0.25)
		if bull_man.winded_s > 0.0:
			break
	assert_gt(bull_man.winded_s, 0.0, "winded after three")
	_player.position = bull_man.position_now() + Vector2(30, 0)
	assert_almost_eq(bull_man.modify_hit(10.0, _player, Vector2.ZERO), 15.0, 0.01, "fists up close")
