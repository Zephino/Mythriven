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
	# Random spots can fall close together: keep the second mushroom well away from the first.
	mother.sprouts[1]["pos"] = Vector2(mother.sprouts[0]["pos"]) + Vector2(150, 0)
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


func test_logis_wildfire_spreads_and_burns() -> void:
	_start("utgard")
	assert_eq(str(_level("utgard")["unlock"]["boss"]), "erlking")
	var fire: MyceliumBoss = _bosses.spawn_boss("logi", 0) as MyceliumBoss
	fire.signature(2.1)
	assert_gt(fire.threads.size(), 0, "the fire spreads")
	_player.position = fire.threads[0]
	fire.signature(1.1)
	assert_true(_player.statuses.has("burn"), "and burns")


func test_hugi_is_always_ahead() -> void:
	_start("utgard")
	var thought: HugiBoss = _bosses.spawn_boss("hugi", 1) as HugiBoss
	_player.velocity = Vector2(100, 0)
	thought.get_ahead_of(_player)
	assert_gt(thought.position_now().x, _player.position.x, "ahead, where you're heading")


func test_utgarda_lokis_illusions_shield_him() -> void:
	_start("utgard")
	var king: UtgardaLokiBoss = _bosses.spawn_boss("utgarda_loki", 2) as UtgardaLokiBoss
	king.raise_copies()
	assert_eq(king.copies_standing(), 3)
	assert_almost_eq(king.modify_hit(100.0, _player, Vector2.ZERO), 25.0, 0.01, "blows strike air")
	for slot: int in king.copies.duplicate():
		_enemies.remove_quietly(slot)
	assert_eq(king.copies_standing(), 0)
	assert_almost_eq(king.modify_hit(100.0, _player, Vector2.ZERO), 100.0, 0.01)


func test_the_questing_beast_drives_heroes_back() -> void:
	_start("logres")
	assert_eq(str(_level("logres")["unlock"]["boss"]), "queen_of_elfame")
	var beast: QuestingBeastBoss = _bosses.spawn_boss("questing_beast", 0) as QuestingBeastBoss
	_player.position = beast.position_now() + Vector2(60, 0)
	beast.bay()
	beast.signature(0.3)
	assert_gt(_player.position.distance_to(beast.position_now()), 60.0, "driven back")


func test_morgan_heals_until_her_scabbard_is_taken() -> void:
	_start("logres")
	var morgan: MorganLeFayBoss = _bosses.spawn_boss("morgan_le_fay", 1) as MorganLeFayBoss
	_enemies.hp[morgan.slot] = _enemies.max_hp[morgan.slot] * 0.5
	morgan.signature(1.0)
	assert_gt(_enemies.hp[morgan.slot], _enemies.max_hp[morgan.slot] * 0.5, "she heals")
	assert_eq(morgan.cap_lethal(50.0), 0.0, "no blood lost")
	morgan.drop()
	_player.position = morgan.scabbard
	morgan.signature(0.1)
	assert_eq(morgan.taken, 1)
	var hp: float = _enemies.hp[morgan.slot]
	morgan.signature(1.0)
	assert_eq(_enemies.hp[morgan.slot], hp, "no more healing")
	assert_eq(morgan.cap_lethal(50.0), 50.0)


func test_vortigerns_tower_shelters_him_until_it_falls() -> void:
	_start("logres")
	var king: VortigernBoss = _bosses.spawn_boss("vortigern", 2) as VortigernBoss
	king.signature(0.1)
	_enemies.positions[king.slot] = king.tower
	assert_almost_eq(king.modify_hit(100.0, _player, Vector2.ZERO), 40.0, 0.01, "sheltered by the tower")
	king.on_element_hit("fire")
	assert_eq(king.falls, 1, "fire brings it down")
	assert_almost_eq(king.modify_hit(100.0, _player, Vector2.ZERO), 100.0, 0.01)
	king.signature(6.1)
	assert_true(king.standing, "rebuilt")


func test_pack_8_boss_secrets() -> void:
	_start("ghorvast")
	var drummer: WarDrummerBoss = _bosses.spawn_boss("war_drummer", 0) as WarDrummerBoss
	assert_eq(drummer.secret_earned(), "the_silent_drum")
	drummer.beats = 6
	assert_eq(drummer.secret_earned(), "")
	var lord: WarlordBoss = _bosses.spawn_boss("warlord", 2) as WarlordBoss
	lord.torn = 3
	assert_eq(lord.secret_earned(), "the_fallen_banner")
	GameAuthority.end_scene()
	_start("knossos")
	var king: MinosBoss = _bosses.spawn_boss("minos", 1) as MinosBoss
	assert_eq(king.secret_earned(), "unjudged")
	king.sentences = 1
	assert_eq(king.secret_earned(), "")
	var bull_man: AsterionBoss = _bosses.spawn_boss("asterion", 2) as AsterionBoss
	assert_eq(bull_man.secret_earned(), "ariadnes_thread")
	GameAuthority.end_scene()
	_start("utgard")
	var thought: HugiBoss = _bosses.spawn_boss("hugi", 1) as HugiBoss
	assert_eq(thought.secret_earned(), "faster_than_thought")
	var giant: UtgardaLokiBoss = _bosses.spawn_boss("utgarda_loki", 2) as UtgardaLokiBoss
	giant.raised = 9
	assert_eq(giant.secret_earned(), "seeing_through")
	GameAuthority.end_scene()
	_start("logres")
	var morgan: MorganLeFayBoss = _bosses.spawn_boss("morgan_le_fay", 1) as MorganLeFayBoss
	morgan.taken = 3
	assert_eq(morgan.secret_earned(), "the_scabbard_regained")
	var usurper: VortigernBoss = _bosses.spawn_boss("vortigern", 2) as VortigernBoss
	usurper.signature(0.1)
	_enemies.positions[usurper.slot] = usurper.tower
	usurper.on_element_hit("fire")
	usurper.signature(6.1)
	_enemies.positions[usurper.slot] = usurper.tower
	usurper.on_element_hit("fire")
	assert_eq(usurper.secret_earned(), "the_burning_tower")
	for secret: String in ["the_silent_drum", "the_fallen_banner", "unjudged", "ariadnes_thread", "faster_than_thought",
			"seeing_through", "the_scabbard_regained", "the_burning_tower"]:
		var reward: Dictionary = SecretRules.find(secret)["reward"]
		if str(reward["type"]) == "passive":
			assert_false(LevelUpRules.passive_data(str(reward["id"])).is_empty(), secret)
		else:
			assert_false(Rewards.cosmetic(str(reward["id"])).is_empty(), secret)


func test_lemnos_is_pack_9_with_forge_smoke() -> void:
	var level: Dictionary = _level("lemnos")
	assert_eq(int(level["act"]), 11)
	assert_eq(str(level["unlock"]["boss"]), "asterion")
	assert_eq(str(level["hazard"]["player_status"]), "burn")
	assert_eq(tr("PACK_11_NAME"), "Pack 9: Gears and Plunder")


func test_the_bulls_of_aeetes_breathe_burning_ground() -> void:
	_start("lemnos")
	var bulls: AeetesBullsBoss = _bosses.spawn_boss("aeetes_bulls", 0) as AeetesBullsBoss
	_player.position = bulls.position_now() + Vector2(90, 0)
	bulls.breathe()
	assert_eq(bulls.flames.size(), 18)
	var hp: float = _player.hp
	bulls.signature(0.6)
	assert_lt(_player.hp, hp, "the fire burns")


func test_the_gold_and_silver_hounds_trade_weaknesses() -> void:
	_start("lemnos")
	var hounds: GoldSilverHoundsBoss = _bosses.spawn_boss("gold_silver_hounds", 1) as GoldSilverHoundsBoss
	hounds.on_element_hit("lightning")
	assert_almost_eq(hounds.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "gold fears lightning")
	hounds.signature(6.1)
	assert_false(hounds.gold)
	hounds.on_element_hit("lightning")
	assert_almost_eq(hounds.modify_hit(10.0, _player, Vector2.ZERO), 2.5, 0.01, "silver shrugs it off")


func test_talos_throws_heats_and_shows_his_nail() -> void:
	_start("lemnos")
	var giant: TalosBoss = _bosses.spawn_boss("talos", 2) as TalosBoss
	_player.position = giant.position_now() + Vector2(300, 0)
	giant.signature(4.1)
	assert_gt(giant.boulders.size(), 0, "a boulder thrown")
	var hp: float = _player.hp
	giant.signature(1.3)
	assert_lt(_player.hp, hp, "and lands")
	giant.heat_up()
	assert_eq(giant.art_id(), "talos_hot")
	giant.signature(4.1)
	assert_gt(giant.nail_s, 0.0, "the nail shows")
	assert_almost_eq(giant.modify_hit(10.0, _player, Vector2.ZERO), 25.0, 0.01)


func test_the_ratel_goblin_tumbles_hurry_skurry() -> void:
	_start("the_goblin_market")
	assert_eq(str(_level("the_goblin_market")["unlock"]["boss"]), "vortigern")
	var ratel: RatelGoblinBoss = _bosses.spawn_boss("ratel_goblin", 0) as RatelGoblinBoss
	var at: Vector2 = ratel.position_now()
	ratel.tumble()
	ratel.signature(0.4)
	assert_gt(ratel.position_now().distance_to(at), 60.0, "off it tumbles")


func test_the_snail_goblin_leaves_slime() -> void:
	_start("the_goblin_market")
	var snail: SnailGoblinBoss = _bosses.spawn_boss("snail_goblin", 1) as SnailGoblinBoss
	snail.signature(0.5)
	assert_gt(snail.slime.size(), 0)
	_player.position = snail.slime[0]["pos"]
	snail.signature(0.05)
	assert_lt(_player.slow_zone_mult, 1.0, "the slime slows")


func test_the_goblin_merchants_crowd_round() -> void:
	_start("the_goblin_market")
	var merchants: GoblinMerchantsBoss = _bosses.spawn_boss("goblin_merchants", 2) as GoblinMerchantsBoss
	assert_eq(merchants.surround(_player), 10, "a ring of goblins")


func test_the_sea_serpent_rises_in_humps() -> void:
	_start("libertalia")
	assert_eq(str(_level("libertalia")["unlock"]["boss"]), "warlord")
	var serpent: SeaSerpentBoss = _bosses.spawn_boss("sea_serpent", 0) as SeaSerpentBoss
	serpent.rise_across(_player.position)
	assert_eq(serpent.humps.size(), 7)
	var hp: float = _player.hp
	serpent.signature(1.7)
	assert_lt(_player.hp, hp, "a hump rises under you")


func test_missons_broadside_fires_down_lanes() -> void:
	_start("libertalia")
	var captain: MissonBoss = _bosses.spawn_boss("misson", 1) as MissonBoss
	captain.broadside()
	assert_eq(captain.lanes.size(), 4)
	_player.position = captain.lanes[0]["pos"]
	var hp: float = _player.hp
	captain.signature(1.5)
	assert_lt(_player.hp, hp, "caught in a lane")


func test_the_krakens_arms_and_whirlpool() -> void:
	_start("libertalia")
	var beast: KrakenBoss = _bosses.spawn_boss("kraken", 2) as KrakenBoss
	beast.raise_arms()
	assert_eq(beast.slams.size(), 3, "one under the Hero, two near")
	var hp: float = _player.hp
	beast.signature(1.3)
	assert_lt(_player.hp, hp, "an arm slams down")
	_player.position = beast.position_now() + Vector2(300, 0)
	beast.whirlpool()
	beast.signature(1.0)
	assert_lt(_player.position.distance_to(beast.position_now()), 300.0, "dragged in")


func test_kaliko_pops_up_out_of_his_tunnels() -> void:
	_start("the_hollow_hills")
	assert_eq(str(_level("the_hollow_hills")["unlock"]["boss"]), "utgarda_loki")
	var steward: KalikoBoss = _bosses.spawn_boss("kaliko", 0) as KalikoBoss
	steward.signature(4.1)
	assert_eq(steward.holes.size(), 3)
	assert_gt(steward.below_s, 0.0, "down a hole")
	assert_eq(steward.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "can't be hurt below")
	steward.signature(2.1)
	assert_eq(steward.pops, 1, "and up again")
	assert_true(steward.holes.has(steward.position_now()), "out of a hole")


func test_the_giant_with_the_hammer_keeps_the_beat() -> void:
	_start("the_hollow_hills")
	var giant: HammerGiantBoss = _bosses.spawn_boss("hammer_giant", 1) as HammerGiantBoss
	giant.aim = Vector2.RIGHT
	_player.position = giant.position_now() + Vector2(100, 0)
	assert_true(giant.on_strip(_player.position))
	var hp: float = _player.hp
	giant.hammer_falls()
	assert_lt(_player.hp, hp, "the hammer falls")
	assert_false(giant.on_strip(giant.position_now() + Vector2(0, 100)), "beside the strip is safe")


func test_the_nome_king_makes_ornaments_and_fears_eggs() -> void:
	_start("the_hollow_hills")
	var king: NomeKingBoss = _bosses.spawn_boss("nome_king", 2) as NomeKingBoss
	king.make_ornament(_player)
	assert_gt(_player.rooted_s, 0.0, "an ornament")
	king.lay_egg()
	_player.position = king.eggs[0]
	king.signature(0.1)
	assert_eq(king.frights, 1, "an egg!")
	assert_almost_eq(king.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01)


func test_pack_9_boss_secrets() -> void:
	_start("lemnos")
	var bulls: AeetesBullsBoss = _bosses.spawn_boss("aeetes_bulls", 0) as AeetesBullsBoss
	assert_eq(bulls.secret_earned(), "medeas_ointment")
	var giant: TalosBoss = _bosses.spawn_boss("talos", 2) as TalosBoss
	assert_eq(giant.secret_earned(), "", "the nail is hidden")
	giant.nail_s = 1.0
	assert_eq(giant.secret_earned(), "the_nail")
	GameAuthority.end_scene()
	_start("the_goblin_market")
	var snail: SnailGoblinBoss = _bosses.spawn_boss("snail_goblin", 1) as SnailGoblinBoss
	assert_eq(snail.secret_earned(), "lizzies_errand")
	snail.age = 61.0
	assert_eq(snail.secret_earned(), "")
	var merchants: GoblinMerchantsBoss = _bosses.spawn_boss("goblin_merchants", 2) as GoblinMerchantsBoss
	merchants.rings = 3
	assert_eq(merchants.secret_earned(), "no_thanks")
	GameAuthority.end_scene()
	_start("libertalia")
	var captain: MissonBoss = _bosses.spawn_boss("misson", 1) as MissonBoss
	assert_eq(captain.secret_earned(), "the_free_sailor")
	var beast: KrakenBoss = _bosses.spawn_boss("kraken", 2) as KrakenBoss
	assert_eq(beast.secret_earned(), "not_an_island")
	GameAuthority.end_scene()
	_start("the_hollow_hills")
	var hammer: HammerGiantBoss = _bosses.spawn_boss("hammer_giant", 1) as HammerGiantBoss
	assert_eq(hammer.secret_earned(), "between_the_blows")
	var king: NomeKingBoss = _bosses.spawn_boss("nome_king", 2) as NomeKingBoss
	king.frights = 3
	assert_eq(king.secret_earned(), "billinas_eggs")
	for secret: String in ["medeas_ointment", "the_nail", "lizzies_errand", "no_thanks", "the_free_sailor",
			"not_an_island", "between_the_blows", "billinas_eggs"]:
		var reward: Dictionary = SecretRules.find(secret)["reward"]
		if str(reward["type"]) == "passive":
			assert_false(LevelUpRules.passive_data(str(reward["id"])).is_empty(), secret)
		else:
			assert_false(Rewards.cosmetic(str(reward["id"])).is_empty(), secret)


func test_pack_10_boss_secrets() -> void:
	_start("hyperborea")
	var thief: ArimaspianBoss = _bosses.spawn_boss("arimaspian_chieftain", 0) as ArimaspianBoss
	assert_eq(thief.secret_earned(), "nothing_stolen")
	thief.thefts = 1
	assert_eq(thief.secret_earned(), "")
	var griffin: GriffinMatriarchBoss = _bosses.spawn_boss("griffin_matriarch", 2) as GriffinMatriarchBoss
	assert_eq(griffin.secret_earned(), "the_unrobbed_nest")
	griffin.swoops = 3
	assert_eq(griffin.secret_earned(), "")
	GameAuthority.end_scene()
	_start("the_empyrean")
	var bear: GreatBearBoss = _bosses.spawn_boss("great_bear", 1) as GreatBearBoss
	assert_eq(bear.secret_earned(), "the_bear_sets")
	bear.age = 61.0
	assert_eq(bear.secret_earned(), "")
	var hunter: OrionBoss = _bosses.spawn_boss("orion", 2) as OrionBoss
	assert_eq(hunter.secret_earned(), "", "he can see")
	hunter.blind_s = 1.0
	assert_eq(hunter.secret_earned(), "the_sunrise")
	GameAuthority.end_scene()
	_start("the_glass_mountain")
	var ravens: SevenRavensBoss = _bosses.spawn_boss("seven_ravens", 0) as SevenRavensBoss
	ravens.killed = 14
	assert_eq(ravens.secret_earned(), "seven_brothers")
	var queen: SnowQueenBoss = _bosses.spawn_boss("snow_queen", 2) as SnowQueenBoss
	queen.spells_broken = 2
	assert_eq(queen.secret_earned(), "eternity")
	GameAuthority.end_scene()
	_start("demos_oneiron")
	var mimic: MorpheusBoss = _bosses.spawn_boss("morpheus", 1) as MorpheusBoss
	assert_eq(mimic.secret_earned(), "your_own_face")
	mimic.mirrored = 30.0
	assert_eq(mimic.secret_earned(), "")
	var dread: PhobetorBoss = _bosses.spawn_boss("phobetor", 2) as PhobetorBoss
	assert_eq(dread.secret_earned(), "the_gate_of_horn")
	for secret: String in ["nothing_stolen", "the_unrobbed_nest", "the_bear_sets", "the_sunrise", "seven_brothers",
			"eternity", "your_own_face", "the_gate_of_horn"]:
		var reward: Dictionary = SecretRules.find(secret)["reward"]
		if str(reward["type"]) == "passive":
			assert_false(LevelUpRules.passive_data(str(reward["id"])).is_empty(), secret)
		else:
			assert_false(Rewards.cosmetic(str(reward["id"])).is_empty(), secret)


func test_pack_11_boss_secrets() -> void:
	_start("ashkarrow")
	var warden: ChainWardenBoss = _bosses.spawn_boss("chain_warden", 0) as ChainWardenBoss
	assert_eq(warden.secret_earned(), "unchained")
	warden.caught = 1
	assert_eq(warden.secret_earned(), "")
	var lord: LordOfAshkarrowBoss = _bosses.spawn_boss("lord_of_ashkarrow", 2) as LordOfAshkarrowBoss
	assert_eq(lord.secret_earned(), "")
	for i: int in 4:
		lord.douse(i)
	assert_eq(lord.secret_earned(), "the_cold_hearth", "all four out at once")
	GameAuthority.end_scene()
	_start("dinas_emrys")
	var magician: FeastMagicianBoss = _bosses.spawn_boss("feast_magician", 1) as FeastMagicianBoss
	assert_eq(magician.secret_earned(), "wide_awake")
	var dragon: WhiteDragonBoss = _bosses.spawn_boss("white_dragon", 2) as WhiteDragonBoss
	dragon.sleeps = 3
	assert_eq(dragon.secret_earned(), "the_dragons_sleep")
	GameAuthority.end_scene()
	_start("atlantis")
	var bull: PoseidonsBullBoss = _bosses.spawn_boss("poseidons_bull", 0) as PoseidonsBullBoss
	bull.noosed = 3
	assert_eq(bull.secret_earned(), "staves_and_nooses")
	var king: AtlasKingBoss = _bosses.spawn_boss("atlas_king", 2) as AtlasKingBoss
	king.walls_broken = 6
	assert_eq(king.secret_earned(), "the_three_walls")
	GameAuthority.end_scene()
	_start("ginnungagap")
	var cow: AudhumlaBoss = _bosses.spawn_boss("audhumla", 0) as AudhumlaBoss
	assert_eq(cow.secret_earned(), "the_hungry_cow")
	cow.licked = _enemies.max_hp[cow.slot] * 0.06
	assert_eq(cow.secret_earned(), "")
	var herald: VoidHeraldBoss = _bosses.spawn_boss("void_herald", 2) as VoidHeraldBoss
	herald.shatters = 4
	assert_eq(herald.secret_earned(), "where_rime_meets_fire")
	for secret: String in ["unchained", "the_cold_hearth", "wide_awake", "the_dragons_sleep", "staves_and_nooses",
			"the_three_walls", "the_hungry_cow", "where_rime_meets_fire"]:
		var reward: Dictionary = SecretRules.find(secret)["reward"]
		if str(reward["type"]) == "passive":
			assert_false(LevelUpRules.passive_data(str(reward["id"])).is_empty(), secret)
		else:
			assert_false(Rewards.cosmetic(str(reward["id"])).is_empty(), secret)


func test_hyperborea_is_pack_10() -> void:
	var level: Dictionary = _level("hyperborea")
	assert_eq(int(level["act"]), 12)
	assert_eq(str(level["unlock"]["boss"]), "talos")
	assert_eq(tr("PACK_12_NAME"), "Pack 10: The Heavens")


func test_the_arimaspian_steals_gold_and_drops_it() -> void:
	_start("hyperborea")
	var chief: ArimaspianBoss = _bosses.spawn_boss("arimaspian_chieftain", 0) as ArimaspianBoss
	GameAuthority.run.gold = 20.0
	GameAuthority.player_damaged.emit(_player, 5.0, "arimaspian_chieftain")
	assert_almost_eq(GameAuthority.run.gold, 15.0, 0.01, "stolen")
	chief.guard_break()
	assert_almost_eq(GameAuthority.run.gold, 20.0, 0.5, "dropped again")


func test_the_six_month_sleeper_naps() -> void:
	_start("hyperborea")
	var sleeper: SixMonthSleeperBoss = _bosses.spawn_boss("six_month_sleeper", 1) as SixMonthSleeperBoss
	sleeper.signature(8.1)
	assert_true(sleeper.asleep)
	assert_almost_eq(sleeper.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "asleep, hurt double")
	sleeper.signature(5.1)
	assert_false(sleeper.asleep, "and awake")


func test_the_griffin_matriarch_nests_and_swoops() -> void:
	_start("hyperborea")
	var griffin: GriffinMatriarchBoss = _bosses.spawn_boss("griffin_matriarch", 2) as GriffinMatriarchBoss
	griffin.signature(6.1)
	assert_eq(griffin.state, "nest")
	for k: int in 10:
		griffin.signature(0.5)
	assert_eq(griffin.state, "sky", "up into the sky")
	assert_eq(griffin.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "out of reach")
	var hp: float = _player.hp
	griffin.signature(2.1)
	griffin.signature(1.1)
	assert_eq(griffin.swoops, 1)
	assert_lt(_player.hp, hp, "the swoop")


func test_the_scorpion_stings_and_leaves_venom() -> void:
	_start("the_empyrean")
	assert_eq(str(_level("the_empyrean")["unlock"]["boss"]), "kraken")
	var scorpion: ScorpionBoss = _bosses.spawn_boss("scorpion", 0) as ScorpionBoss
	scorpion.signature(3.1)
	assert_eq(scorpion.stings.size(), 1, "the tail strikes")
	scorpion.signature(1.1)
	assert_eq(scorpion.struck, 1)
	assert_true(_player.statuses.has("poison"))
	assert_eq(scorpion.pools.size(), 1, "a pool of venom")


func test_the_great_bear_circles_the_pole() -> void:
	_start("the_empyrean")
	var bear: GreatBearBoss = _bosses.spawn_boss("great_bear", 1) as GreatBearBoss
	bear.signature(0.1)
	var a: Vector2 = bear.position_now()
	bear.signature(1.0)
	assert_ne(bear.position_now(), a, "she never stops")
	assert_almost_eq(bear.position_now().distance_to(_bosses.arena_center), 150.0, 1.0, "on her circle")


func test_orion_is_struck_blind() -> void:
	_start("the_empyrean")
	var hunter: OrionBoss = _bosses.spawn_boss("orion", 2) as OrionBoss
	var before: int = _enemies.active_count()
	hunter.signature(3.1)
	assert_eq(_enemies.active_count(), before + 2, "his two hounds")
	hunter.go_blind()
	assert_almost_eq(hunter.modify_hit(10.0, _player, Vector2.ZERO), 15.0, 0.01, "blind, easier to hurt")


func test_the_seven_ravens_scatter_and_gather() -> void:
	_start("the_glass_mountain")
	assert_eq(str(_level("the_glass_mountain")["unlock"]["boss"]), "goblin_merchants")
	var ravens: SevenRavensBoss = _bosses.spawn_boss("seven_ravens", 0) as SevenRavensBoss
	ravens.scatter()
	assert_eq(ravens.ravens.size(), 7)
	assert_eq(ravens.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "scattered, it can't be hurt")
	var hp: float = _enemies.hp[ravens.slot]
	_enemies.remove_quietly(ravens.ravens[0])
	ravens.signature(0.1)
	assert_eq(ravens.killed, 1)
	assert_lt(_enemies.hp[ravens.slot], hp, "each raven lost hurts it")
	ravens.signature(6.1)
	assert_eq(ravens.scattered_s, 0.0, "gathered again")


func test_old_rinkrank_climbs_his_ladder() -> void:
	_start("the_glass_mountain")
	var old: RinkrankBoss = _bosses.spawn_boss("rinkrank", 1) as RinkrankBoss
	old.climb()
	assert_eq(old.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "out of reach")
	old.signature(0.3)
	assert_gt(old.shards.size(), 0, "glass thrown down")
	var hp: float = _player.hp
	old.signature(1.0)
	assert_lt(_player.hp, hp)


func test_the_snow_queens_kiss_and_the_word() -> void:
	_start("the_glass_mountain")
	var queen: SnowQueenBoss = _bosses.spawn_boss("snow_queen", 2) as SnowQueenBoss
	queen.kiss(_player)
	assert_gt(_player.rooted_s, 0.0, "frozen by her kiss")
	for k: int in 4:
		queen.gather_piece()
	assert_eq(queen.spells_broken, 1, "the word is made")
	assert_gt(queen.broken_s, 0.0)


func test_phantasos_becomes_rock_and_water() -> void:
	_start("demos_oneiron")
	assert_eq(str(_level("demos_oneiron")["unlock"]["boss"]), "nome_king")
	assert_eq(str(_level("demos_oneiron")["hazard"]["type"]), "lights")
	var shaper: PhantasosBoss = _bosses.spawn_boss("phantasos", 0) as PhantasosBoss
	shaper.signature(0.1)
	assert_eq(shaper.art_id(), "phantasos_rock")
	assert_almost_eq(shaper.modify_hit(100.0, _player, Vector2.ZERO), 25.0, 0.01, "rock")
	shaper.signature(5.0)
	assert_eq(shaper.art_id(), "phantasos_water")


func test_morpheus_turns_blows_back() -> void:
	_start("demos_oneiron")
	var mimic: MorpheusBoss = _bosses.spawn_boss("morpheus", 1) as MorpheusBoss
	var hp: float = _player.hp
	mimic.modify_hit(40.0, _player, Vector2.ZERO)
	assert_lt(_player.hp, hp, "a share comes back")
	assert_almost_eq(mimic.mirrored, 6.0, 0.01)


func test_phobetor_takes_nightmare_shapes() -> void:
	_start("demos_oneiron")
	var dread: PhobetorBoss = _bosses.spawn_boss("phobetor", 2) as PhobetorBoss
	dread.signature(0.1)
	assert_eq(dread.art_id(), "phobetor_beast")
	dread.signature(6.0)
	assert_eq(dread.art_id(), "phobetor_bird")
	assert_eq(dread.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "the bird is out of reach")
	dread.signature(0.6)
	assert_gt(dread.marks.size(), 0, "it strikes from above")
	dread.signature(6.0)
	assert_eq(dread.art_id(), "phobetor_serpent")


func test_ashkarrow_is_pack_11() -> void:
	var level: Dictionary = _level("ashkarrow")
	assert_eq(int(level["act"]), 13)
	assert_eq(str(level["unlock"]["boss"]), "griffin_matriarch")
	assert_eq(tr("PACK_13_NAME"), "Pack 11: The Abyss")
	assert_true((level["local_gods"] as Array).is_empty(), "a realm has no local gods")


func test_the_chain_warden_drags_a_hero_in() -> void:
	_start("ashkarrow")
	var warden: ChainWardenBoss = _bosses.spawn_boss("chain_warden", 0) as ChainWardenBoss
	var far: float = _player.position.distance_to(warden.position_now())
	warden.signature(3.1)
	assert_ne(warden.aim, Vector2.INF, "the line is marked")
	var hp: float = _player.hp
	warden.signature(1.0)
	assert_eq(warden.caught, 1)
	assert_lt(_player.hp, hp)
	assert_lt(_player.position.distance_to(warden.position_now()), far, "dragged in")


func test_the_ash_colossus_feeds_on_fire_and_cracks_in_the_cold() -> void:
	_start("ashkarrow")
	var giant: AshColossusBoss = _bosses.spawn_boss("ash_colossus", 1) as AshColossusBoss
	_enemies.hp[giant.slot] -= 100.0
	var hp: float = _enemies.hp[giant.slot]
	giant.on_element_hit("fire")
	assert_eq(giant.modify_hit(40.0, _player, Vector2.ZERO), 0.0, "fire does no harm")
	assert_gt(_enemies.hp[giant.slot], hp, "it feeds it")
	giant.on_element_hit("ice")
	assert_almost_eq(giant.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "cracked by the cold")
	giant.signature(3.1)
	giant.on_element_hit("")
	assert_almost_eq(giant.modify_hit(10.0, _player, Vector2.ZERO), 10.0, 0.01, "the crack closes")


func test_the_lord_of_ashkarrows_braziers() -> void:
	_start("ashkarrow")
	var lord: LordOfAshkarrowBoss = _bosses.spawn_boss("lord_of_ashkarrow", 2) as LordOfAshkarrowBoss
	assert_eq(lord.lit_count(), 4)
	assert_almost_eq(lord.modify_hit(100.0, _player, Vector2.ZERO), 28.0, 0.01, "four braziers shield him")
	_player.position = lord.braziers[0]["pos"]
	lord.signature(0.8)
	lord.signature(0.8)
	assert_eq(lord.lit_count(), 3, "put out")
	assert_eq(lord.doused, 1)
	_player.position = Vector2(9999, 9999)
	lord.signature(10.1)
	assert_eq(lord.lit_count(), 4, "lit again")


func test_the_coraniaid_hear_blows_coming() -> void:
	_start("dinas_emrys")
	assert_eq(str(_level("dinas_emrys")["unlock"]["boss"]), "orion")
	var folk: CoraniaidBoss = _bosses.spawn_boss("coraniaid", 0) as CoraniaidBoss
	assert_eq(folk.pools.size(), 3)
	var at: Vector2 = folk.position_now()
	assert_eq(folk.modify_hit(10.0, _player, Vector2.ZERO), 0.0, "heard it, stepped aside")
	assert_ne(folk.position_now(), at)
	assert_almost_eq(folk.modify_hit(10.0, _player, Vector2.ZERO), 10.0, 0.01, "not again so soon")
	_enemies.positions[folk.slot] = folk.pools[0]
	folk.signature(2.1)
	assert_almost_eq(folk.modify_hit(10.0, _player, Vector2.ZERO), 30.0, 0.01, "in the insect-water")


func test_the_magician_of_the_feast_plays_the_heroes_asleep() -> void:
	_start("dinas_emrys")
	var magician: FeastMagicianBoss = _bosses.spawn_boss("feast_magician", 1) as FeastMagicianBoss
	_player.position = Vector2(5000, 5000)
	magician.signature(6.1)
	assert_ne(magician.playing_in, INF, "the music is coming")
	magician.signature(2.1)
	assert_gt(_player.rooted_s, 0.0, "asleep")
	_player.rooted_s = 0.0
	_player.position = magician.tubs[0]
	magician.signature(12.1)
	magician.signature(2.1)
	assert_eq(_player.rooted_s, 0.0, "the cold water keeps you awake")
	assert_eq(magician.sleepers, 1)


func test_the_white_dragon_drinks_the_mead_and_sleeps() -> void:
	_start("dinas_emrys")
	var dragon: WhiteDragonBoss = _bosses.spawn_boss("white_dragon", 2) as WhiteDragonBoss
	assert_ne(dragon.vat, Vector2.INF)
	dragon.signature(8.1)
	assert_true(dragon.flying)
	assert_eq(dragon.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "out of reach")
	dragon.signature(1.0)
	assert_gt(dragon.marks.size(), 0, "frost from above")
	_player.position = dragon.vat
	dragon.signature(0.8)
	dragon.signature(0.8)
	assert_eq(dragon.sleeps, 1, "down to drink")
	assert_false(dragon.flying)
	assert_almost_eq(dragon.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "asleep, hurt double")


func test_poseidons_bull_charges_and_is_noosed() -> void:
	_start("atlantis")
	assert_eq(str(_level("atlantis")["unlock"]["boss"]), "snow_queen")
	var bull: PoseidonsBullBoss = _bosses.spawn_boss("poseidons_bull", 0) as PoseidonsBullBoss
	bull.signature(0.1)
	assert_eq(bull.nooses.size(), 2, "nooses lie about")
	bull.signature(2.0)
	assert_ne(bull.aim, Vector2.INF, "a charge is marked")
	_player.position = bull.nooses[0]
	bull.signature(0.1)
	assert_eq(bull.noosed, 1)
	assert_eq(bull.aim, Vector2.INF, "held fast, no charge")
	assert_almost_eq(bull.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01)


func test_gadeirus_raises_rings_of_sea() -> void:
	_start("atlantis")
	var twin: GadeirusBoss = _bosses.spawn_boss("gadeirus", 1) as GadeirusBoss
	twin.signature(2.1)
	assert_eq(twin.rings.size(), 1)
	var hp: float = _player.hp
	for k: int in 30:
		twin.signature(0.1)
	assert_eq(twin.caught, 1, "the ring passed over the Hero once")
	assert_lt(_player.hp, hp)
	assert_true(_player.statuses.has("soaked"))


func test_atlas_stands_behind_three_walls() -> void:
	_start("atlantis")
	var king: AtlasKingBoss = _bosses.spawn_boss("atlas_king", 2) as AtlasKingBoss
	assert_eq(king.walls_up(), 3)
	var wall: float = king.walls[0]
	assert_eq(king.modify_hit(wall + 1.0, _player, Vector2.ZERO), 0.0, "the brass wall takes it")
	assert_eq(king.walls_up(), 2)
	king.modify_hit(wall + 1.0, _player, Vector2.ZERO)
	king.modify_hit(wall + 1.0, _player, Vector2.ZERO)
	assert_eq(king.walls_up(), 0, "all three down")
	assert_almost_eq(king.modify_hit(10.0, _player, Vector2.ZERO), 10.0, 0.01, "now he can be hurt")
	king.signature(20.1)
	assert_eq(king.walls_up(), 3, "they rise again")
	_enemies.hp[king.slot] = _enemies.max_hp[king.slot] * 0.1
	king._update_phase()
	assert_true(king.sinking, "the island sinks")
	king.signature(1.6)
	assert_gt(king.marks.size(), 0)


func test_audhumla_licks_the_salt_rime() -> void:
	_start("ginnungagap")
	assert_eq(str(_level("ginnungagap")["unlock"]["boss"]), "phobetor")
	var cow: AudhumlaBoss = _bosses.spawn_boss("audhumla", 0) as AudhumlaBoss
	assert_eq(cow.blocks.size(), 3)
	_enemies.hp[cow.slot] -= 200.0
	_enemies.positions[cow.slot] = cow.blocks[0]
	_player.position = Vector2(9999, 9999)
	var hp: float = _enemies.hp[cow.slot]
	cow.signature(1.0)
	assert_true(cow.licking)
	assert_gt(_enemies.hp[cow.slot], hp, "the salt heals her")
	_player.position = cow.blocks[1]
	cow.signature(1.0)
	cow.signature(1.1)
	assert_eq(cow.broken, 1, "a block broken")
	assert_eq(cow.blocks.size(), 2)


func test_bergelmir_rides_the_flood_of_blood() -> void:
	_start("ginnungagap")
	var giant: BergelmirBoss = _bosses.spawn_boss("bergelmir", 1) as BergelmirBoss
	giant.signature(6.1)
	assert_eq(giant.floods, 1)
	assert_eq(giant.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "in his lúðr, out of reach")
	giant.signature(0.3)
	assert_gt(giant.marks.size(), 0, "blood wells up under the Hero")
	var hp: float = _player.hp
	giant.signature(0.9)
	assert_lt(_player.hp, hp)
	assert_true(_player.statuses.has("soaked"))
	giant.signature(5.0)
	assert_almost_eq(giant.modify_hit(10.0, _player, Vector2.ZERO), 10.0, 0.01, "the flood is over")


func test_the_herald_of_the_void_shatters_between_rime_and_fire() -> void:
	_start("ginnungagap")
	var herald: VoidHeraldBoss = _bosses.spawn_boss("void_herald", 2) as VoidHeraldBoss
	herald.signature(0.1)
	assert_eq(herald.art_id(), "void_herald_rime")
	herald.on_element_hit("ice")
	assert_eq(herald.shatters, 0, "ice does not shatter rime")
	herald.on_element_hit("fire")
	assert_eq(herald.shatters, 1, "fire shatters rime")
	assert_almost_eq(herald.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01)
	herald.on_element_hit("fire")
	assert_eq(herald.shatters, 1, "once per form")
	herald.signature(8.0)
	assert_eq(herald.art_id(), "void_herald_fire")
	herald.on_element_hit("ice")
	assert_eq(herald.shatters, 2, "ice shatters fire")
	assert_gt(herald.marks.size(), 0, "the gap opens under the farthest Hero")


func test_tir_na_nog_is_pack_12() -> void:
	var level: Dictionary = _level("tir_na_nog")
	assert_eq(int(level["act"]), 14)
	assert_eq(str(level["unlock"]["boss"]), "lord_of_ashkarrow")
	assert_eq(tr("PACK_14_NAME"), "Pack 12: Otherworlds")


func test_the_red_eared_hound_chases_the_fawn() -> void:
	_start("tir_na_nog")
	var hound: RedEaredHoundBoss = _bosses.spawn_boss("red_eared_hound", 0) as RedEaredHoundBoss
	_player.position = Vector2(9999, 9999)
	hound.signature(0.1)
	assert_ne(hound.fawn, Vector2.INF, "the fawn runs")
	_player.position = hound.fawn
	hound.signature(0.01)
	assert_eq(hound.baffled, 1, "a Hero reached it first")
	assert_almost_eq(hound.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "baffled")


func test_the_fomor_recovers_at_nightfall() -> void:
	_start("tir_na_nog")
	var giant: FomorBoss = _bosses.spawn_boss("fomor", 1) as FomorBoss
	giant.signature(0.1)
	var whole: float = _enemies.hp[giant.slot]
	_enemies.hp[giant.slot] -= giant.modify_hit(300.0, _player, Vector2.ZERO)
	giant.signature(12.0)
	assert_eq(giant.nights, 1)
	assert_almost_eq(_enemies.hp[giant.slot], whole - 300.0 + 99.0, 0.5, "a third of the day's wounds close")


func test_finvarra_carries_heroes_into_his_hill() -> void:
	_start("tir_na_nog")
	var king: FinvarraBoss = _bosses.spawn_boss("finvarra", 2) as FinvarraBoss
	assert_ne(king.hill, Vector2.INF)
	var at: Vector2 = _player.position
	king.signature(5.1)
	assert_eq(king.carried, 1)
	assert_ne(_player.position, at, "whisked away")
	assert_true(_player.statuses.has("hex"))
	_player.position = king.hill
	king.signature(1.0)
	king.signature(1.1)
	assert_eq(king.digs, 1, "dug into Knockma")
	assert_gt(king.broken_s, 0.0, "his guard breaks")


func test_the_great_black_rabbit_bounds_and_lands() -> void:
	_start("hy_brasil")
	assert_eq(str(_level("hy_brasil")["unlock"]["boss"]), "white_dragon")
	var rabbit: GreatBlackRabbitBoss = _bosses.spawn_boss("great_black_rabbit", 0) as GreatBlackRabbitBoss
	rabbit.signature(2.1)
	assert_ne(rabbit.landing, Vector2.INF, "a landing spot is marked")
	var hp: float = _player.hp
	rabbit.signature(1.0)
	assert_eq(rabbit.leaps, 1)
	assert_eq(rabbit.landed_on, 1, "it lands on the Hero")
	assert_lt(_player.hp, hp)


func test_the_necromancers_spell_breaks_by_fire() -> void:
	_start("hy_brasil")
	var mage: ObrazileNecromancerBoss = _bosses.spawn_boss("obrazile_necromancer", 1) as ObrazileNecromancerBoss
	assert_eq(mage.piles.size(), 3)
	assert_almost_eq(mage.modify_hit(100.0, _player, Vector2.ZERO), 25.0, 0.01, "the spell holds")
	mage.light(0)
	assert_almost_eq(mage.modify_hit(100.0, _player, Vector2.ZERO), 50.0, 0.01, "one fire weakens it")
	mage.light(1)
	_player.position = mage.piles[2]["pos"]
	mage.signature(0.8)
	mage.signature(0.8)
	assert_eq(mage.spells_broken, 1, "three fires break it")
	assert_gt(mage.broken_s, 0.0)
	mage.signature(12.1)
	assert_eq(mage.burning(), 0, "the fires burn out")


func test_the_flying_dutchman_is_a_phantom_by_turns() -> void:
	_start("hy_brasil")
	var ship: FlyingDutchmanBoss = _bosses.spawn_boss("flying_dutchman", 2) as FlyingDutchmanBoss
	ship.signature(0.1)
	assert_eq(ship.art_id(), "flying_dutchman_phantom")
	assert_eq(ship.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "a phantom can't be hurt")
	ship.signature(6.0)
	assert_false(ship.phantom)
	assert_almost_eq(ship.modify_hit(10.0, _player, Vector2.ZERO), 10.0, 0.01, "solid")
	ship.signature(0.6)
	assert_gt(ship.marks.size(), 0, "firing on marked spots")
	ship.letters.append(_player.position)
	ship.signature(0.1)
	assert_eq(ship.letters_taken, 1)
	assert_true(_player.statuses.has("hex"), "an ill omen")


func test_the_learned_man_keeps_to_the_shadow_side() -> void:
	_start("shadows_court")
	assert_eq(str(_level("shadows_court")["unlock"]["boss"]), "atlas_king")
	var scholar: LearnedManBoss = _bosses.spawn_boss("learned_man", 0) as LearnedManBoss
	assert_ne(scholar.lamp, Vector2.INF)
	var spot: Vector2 = scholar.shadow_spot(_player)
	assert_gt(spot.distance_to(scholar.lamp), _player.position.distance_to(scholar.lamp), "behind the Hero, away from the lamp")
	_enemies.positions[scholar.slot] = Vector2(5000, 5000)
	assert_almost_eq(scholar.modify_hit(10.0, _player, Vector2.ZERO), 10.0, 0.01, "in the dark")
	_enemies.positions[scholar.slot] = scholar.lamp
	assert_almost_eq(scholar.modify_hit(10.0, _player, Vector2.ZERO), 20.0, 0.01, "in the lamplight")


func test_the_princess_sees_in_front_but_not_behind() -> void:
	_start("shadows_court")
	var princess: ClearSightedPrincessBoss = _bosses.spawn_boss("clear_sighted_princess", 1) as ClearSightedPrincessBoss
	_player.position = princess.position_now() + Vector2(80, 0)
	princess.gaze_angle = (_player.position - princess.position_now()).angle()
	assert_true(princess.sees(_player.position))
	assert_almost_eq(princess.modify_hit(10.0, _player, Vector2.ZERO), 10.0, 0.01, "struck from the front")
	var hp: float = _player.hp
	princess.signature(0.5)
	assert_eq(princess.seen, 1)
	assert_lt(_player.hp, hp)
	princess.gaze_angle = (princess.position_now() - _player.position).angle()
	assert_false(princess.sees(_player.position), "behind her")
	assert_almost_eq(princess.modify_hit(10.0, _player, Vector2.ZERO), 15.0, 0.01, "struck from behind")


func test_the_shadow_tears_off_the_heroes_shadows() -> void:
	_start("shadows_court")
	var master: TheShadowBoss = _bosses.spawn_boss("the_shadow", 2) as TheShadowBoss
	master.signature(4.1)
	assert_eq(master.torn, 1)
	assert_eq(master.standing_shadows(), 1, "the Hero's shadow rises")
	assert_almost_eq(master.modify_hit(10.0, _player, Vector2.ZERO), 5.0, 0.01, "shielded by it")
	_enemies.remove_quietly(master.shadows[0])
	assert_eq(master.standing_shadows(), 0)
	assert_almost_eq(master.modify_hit(10.0, _player, Vector2.ZERO), 10.0, 0.01)


func test_every_boss_has_a_picture_under_its_own_name() -> void:
	# The banter portrait and the codex use the boss's own name, even for bosses whose look changes.
	for entry: Variant in Data.get_file(BossManager.FILE):
		if entry is Dictionary:
			assert_false(PixelArt.boss(str(entry.get("enemy", entry.get("id", "")))).is_empty(), str(entry.get("id", "")))
