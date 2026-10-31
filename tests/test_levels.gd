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
		# A level still being built (coming_soon) is checked fully once it's released.
		if bool(level.get("coming_soon", false)):
			continue
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


func test_pack_2_levels_open_from_their_sister_and_only_when_released() -> void:
	SaveGame.use_test_file(TEST_SAVE)
	var underworld: Dictionary = _level("the_underworld").duplicate(true)
	assert_false(LevelRules.is_unlocked(underworld), "locked at first")
	LevelRules.note_boss("aegean_shore", "achilles", 1)
	assert_false(bool(LevelRules.progress("the_underworld").get("unlocked", false)), "Pack 1's 20:00 boss doesn't open Pack 2")
	LevelRules.note_boss("aegean_shore", "kronos", 2)
	assert_true(bool(LevelRules.progress("the_underworld").get("unlocked", false)), "Kronos opens the Underworld")
	underworld["coming_soon"] = true
	assert_false(LevelRules.is_unlocked(underworld), "but not while it's still being built")
	underworld.erase("coming_soon")
	assert_true(LevelRules.is_unlocked(underworld))
	assert_almost_eq(LevelScaling.pack("hp_mult", underworld), 1.2, 0.001, "Pack 2 enemies are tougher")
	assert_almost_eq(LevelScaling.pack("hp_mult", _level("aegean_shore")), 1.0, 0.001)


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


func test_cerberus_loses_a_head_each_phase() -> void:
	_start("the_underworld")
	var cerberus: CerberusBoss = _bosses.spawn_boss("cerberus", 0) as CerberusBoss
	assert_not_null(cerberus)
	assert_eq(cerberus.heads(), 3)
	assert_eq(cerberus.art_id(), "cerberus")
	_enemies.hp[cerberus.slot] = _enemies.max_hp[cerberus.slot] * 0.5
	cerberus._process(0.01)
	assert_eq(cerberus.heads(), 2, "the howling head falls")
	assert_false(PixelArt.boss(cerberus.art_id()).is_empty(), "and his picture shows two heads")
	_enemies.hp[cerberus.slot] = _enemies.max_hp[cerberus.slot] * 0.1
	cerberus._process(0.01)
	assert_eq(cerberus.heads(), 1)
	assert_false(PixelArt.boss(cerberus.art_id()).is_empty())


func test_thanatos_marks_a_hero_and_hitting_him_breaks_it() -> void:
	_start("the_underworld")
	var thanatos: ThanatosBoss = _bosses.spawn_boss("thanatos", 1) as ThanatosBoss
	_player.god_mode = false
	thanatos.target = _player
	thanatos.signature(10.0)
	assert_eq(thanatos.marked, _player.player_id, "marked for death")
	thanatos.modify_hit(thanatos.cancel_needed(_player) + 1.0, _player, Vector2.ZERO)
	thanatos.signature(0.1)
	assert_eq(thanatos.marked, -1, "hit hard enough: the mark breaks")
	var hp_before: float = _player.hp
	thanatos.signature(20.0)
	thanatos.signature(20.0)
	assert_lt(_player.hp, hp_before, "left alone, the mark lands")
	_player.hero = HeroRules.find("heracles")
	var heracles_need: float = thanatos.cancel_needed(_player)
	_player.hero = {}
	assert_almost_eq(heracles_need, thanatos.cancel_needed(_player) * 0.5, 0.01, "Heracles breaks it twice as easily")


func test_typhons_heads_strike_from_all_round_the_arena() -> void:
	_start("the_underworld")
	var typhon: TyphonBoss = _bosses.spawn_boss("typhon", 2) as TyphonBoss
	typhon.target = _player
	var before: int = GameAuthority.enemy_shots.count()
	typhon.signature(10.0)
	assert_gt(GameAuthority.enemy_shots.count(), before + 3, "a volley closes in from every side")
	_enemies.hp[typhon.slot] = _enemies.max_hp[typhon.slot] * 0.5
	typhon._process(0.01)
	_player.position = _bosses.arena_center + Vector2(120, 0)
	var at: Vector2 = _player.position
	typhon.signature(1.0)
	assert_ne(_player.position, at, "the storm sweeps the Hero round")


func test_hrungnir_shrugs_off_harm_until_lightning_cracks_him() -> void:
	_start("jotunheim")
	var hrungnir: HrungnirBoss = _bosses.spawn_boss("hrungnir", 0) as HrungnirBoss
	assert_not_null(hrungnir)
	assert_lt(hrungnir.modify_hit(100.0, _player, Vector2.ZERO), 50.0, "stone: most harm is shrugged off")
	hrungnir.on_element_hit("lightning")
	assert_almost_eq(hrungnir.modify_hit(100.0, _player, Vector2.ZERO), 100.0, 0.01, "Lightning cracks the stone")
	hrungnir.signature(10.0)
	assert_lt(hrungnir.modify_hit(100.0, _player, Vector2.ZERO), 50.0, "and it closes again")


func test_thrym_steals_a_weapon_and_his_hoard_gives_it_back() -> void:
	_start("jotunheim")
	GameAuthority.give_weapon(_player, "great_club")
	var thrym: ThrymBoss = _bosses.spawn_boss("thrym", 1) as ThrymBoss
	thrym.target = _player
	thrym.signature(8.5)
	assert_eq(_player.weapons.size(), 0, "he steals it")
	assert_eq(thrym.stolen.size(), 1)
	_player.position = thrym.stolen[0]["at"]
	thrym.signature(0.1)
	assert_eq(_player.weapons.size(), 1, "reach his hoard and take it back")


func test_ymir_splits_into_frost_shapes() -> void:
	_start("jotunheim")
	var ymir: YmirBoss = _bosses.spawn_boss("ymir", 2) as YmirBoss
	ymir.signature(10.0)
	assert_eq(ymir.shapes.size(), 2, "two rime shapes beside the real Ymir")


func test_the_green_knight_picks_up_his_head_once() -> void:
	_start("avalons_shadow")
	var knight: GreenKnightBoss = _bosses.spawn_boss("green_knight", 0) as GreenKnightBoss
	assert_not_null(knight)
	var slot: int = knight.slot
	var lethal: float = _enemies.hp[slot] + 10.0
	knight.modify_hit(lethal, _player, Vector2.ZERO)
	assert_true(knight.headless, "the beheading blow")
	assert_eq(knight.art_id(), "green_knight_headless")
	assert_gt(_enemies.hp[slot] - lethal, 0.0, "he fights on")
	assert_almost_eq(float(knight.phase()["attack_every_s"]), 1.6, 0.01, "and faster")


func test_mordreds_host_halves_harm_until_they_fall() -> void:
	_start("avalons_shadow")
	var mordred: MordredBoss = _bosses.spawn_boss("mordred", 1) as MordredBoss
	mordred.signature(0.1)
	assert_eq(mordred.host.size(), 5, "five knights ride out")
	assert_almost_eq(mordred.modify_hit(100.0, _player, Vector2.ZERO), 50.0, 0.01)
	for knight: Variant in mordred.host.duplicate():
		_enemies.remove_quietly(int(knight))
	assert_almost_eq(mordred.modify_hit(100.0, _player, Vector2.ZERO), 100.0, 0.01)


func test_twrch_trwyth_drops_his_three_treasures_on_guard_breaks() -> void:
	_start("avalons_shadow")
	var boar: TwrchTrwythBoss = _bosses.spawn_boss("twrch_trwyth", 2) as TwrchTrwythBoss
	for _i: int in 4:
		boar.guard_break()
	assert_eq(boar.treasures_left, 0, "only three treasures between his ears")


func test_brambles_spring_up_and_slow_the_hero() -> void:
	_start("avalons_shadow")
	var brambles := Hazard.create(_level("avalons_shadow")["hazard"]) as HazardStrikes
	_world.add_child(brambles)
	brambles.begin(_level("avalons_shadow")["hazard"])
	brambles._strike(_player.position)
	brambles._process(0.016)
	assert_lt(_player.slow_zone_mult, 1.0, "caught in the thorns")
	_player.position = Vector2(2000, 0)
	brambles._process(0.016)
	assert_eq(_player.slow_zone_mult, 1.0)


func test_humbabas_radiances_must_be_stripped_first_and_wind_strips_faster() -> void:
	_start("the_land_between_the_rivers")
	var humbaba: HumbabaBoss = _bosses.spawn_boss("humbaba", 0) as HumbabaBoss
	assert_not_null(humbaba)
	assert_eq(humbaba.modify_hit(50.0, _player, Vector2.ZERO), 0.0, "the radiance takes the blow")
	assert_eq(humbaba.radiances, 7)
	humbaba.on_element_hit("wind")
	humbaba.modify_hit(40.0, _player, Vector2.ZERO)
	assert_eq(humbaba.radiances, 6, "Wind tears it away twice as fast")
	humbaba.guard_break()
	assert_eq(humbaba.radiances, 5, "a Guard Break strips one too")
	for _i: int in 5:
		humbaba.strip_radiance()
	assert_almost_eq(humbaba.modify_hit(50.0, _player, Vector2.ZERO), 50.0, 0.01, "bare at last")


func test_the_bull_of_heaven_opens_pits_that_stay_and_slow() -> void:
	_start("the_land_between_the_rivers")
	var bull: BullOfHeavenBoss = _bosses.spawn_boss("bull_of_heaven", 1) as BullOfHeavenBoss
	bull.target = _player
	bull.signature(5.0)
	assert_eq(bull.pits.size(), 3, "his snort opens pits")
	_player.position = bull.pits[0]["pos"]
	bull.signature(0.1)
	assert_lt(_player.slow_zone_mult, 1.0, "standing in a pit slows")
	_player.position = Vector2(5000, 0)
	bull.signature(0.1)
	assert_eq(_player.slow_zone_mult, 1.0)
	bull.signature(10.0)
	assert_gt(bull.pits.size(), 0, "the pits stay")


func test_tiamat_brings_forth_her_brood_and_her_waves_push() -> void:
	_start("the_land_between_the_rivers")
	var tiamat: TiamatBoss = _bosses.spawn_boss("tiamat", 2) as TiamatBoss
	var before: int = _enemies.active_count()
	tiamat.signature(4.0)
	assert_gt(_enemies.active_count(), before, "her brood")
	assert_eq(tiamat.waves.size(), 1, "a wave rises")
	var wave: Dictionary = tiamat.waves[0]
	_player.position = tiamat.wave_front(wave) - Vector2(wave["dir"]) * 10.0
	var at: Vector2 = _player.position
	var hp: float = _player.hp
	tiamat._roll(0.05)
	assert_ne(_player.position, at, "the wave pushes")
	assert_lt(_player.hp, hp, "and hurts")


func test_floods_slow_and_put_out_fire() -> void:
	_start("the_land_between_the_rivers")
	var flood := Hazard.create(_level("the_land_between_the_rivers")["hazard"]) as HazardStrikes
	_world.add_child(flood)
	flood.begin(_level("the_land_between_the_rivers")["hazard"])
	_player.statuses.timers["burn"] = 3.0
	flood._strike(_player.position + Vector2(80, 0))
	flood._process(0.016)
	assert_lt(_player.slow_zone_mult, 1.0, "wading in the long flood band")
	assert_false(_player.statuses.has("burn"), "the water puts the fire out")


func _as_hero(hero_id: String) -> void:
	_player.hero = _player.hero.duplicate()
	_player.hero["id"] = hero_id


func test_pack_2_boss_secrets() -> void:
	_start("the_underworld")
	_as_hero("orpheus")
	var cerberus: CerberusBoss = _bosses.spawn_boss("cerberus", 0) as CerberusBoss
	assert_eq(cerberus.secret_earned(), "the_lulled_hound", "Orpheus, never bitten")
	GameAuthority.player_damaged.emit(_player, 5.0, "cerberus")
	assert_eq(cerberus.secret_earned(), "", "bitten once: no secret")
	GameAuthority.end_scene()
	_start("jotunheim")
	var thrym: ThrymBoss = _bosses.spawn_boss("thrym", 1) as ThrymBoss
	thrym.taken_back = 3
	assert_eq(thrym.secret_earned(), "the_brides_veil")
	var hrungnir: HrungnirBoss = _bosses.spawn_boss("hrungnir", 0) as HrungnirBoss
	hrungnir.on_element_hit("fire")
	assert_eq(hrungnir.secret_earned(), "")
	hrungnir.on_element_hit("lightning")
	assert_eq(hrungnir.secret_earned(), "the_whetstone", "the last blow was Lightning")


func test_avalon_and_rivers_boss_secrets() -> void:
	_start("avalons_shadow")
	var knight: GreenKnightBoss = _bosses.spawn_boss("green_knight", 0) as GreenKnightBoss
	assert_eq(knight.secret_earned(), "", "he must pick up his head first")
	knight.headless = true
	GameAuthority.player_damaged.emit(_player, 5.0, "green_knight")
	assert_eq(knight.secret_earned(), "the_green_girdle", "only a nick")
	GameAuthority.player_damaged.emit(_player, 5.0, "green_knight")
	assert_eq(knight.secret_earned(), "")
	_as_hero("king_arthur")
	var mordred: MordredBoss = _bosses.spawn_boss("mordred", 1) as MordredBoss
	assert_eq(mordred.secret_earned(), "camlann")
	GameAuthority.end_scene()
	_start("the_land_between_the_rivers")
	_as_hero("gilgamesh")
	var humbaba: HumbabaBoss = _bosses.spawn_boss("humbaba", 0) as HumbabaBoss
	for _i: int in 7:
		humbaba.strip_radiance()
	assert_eq(humbaba.secret_earned(), "", "Shamash must be bound too")


func test_pack_2_secret_passives() -> void:
	_start("the_land_between_the_rivers")
	_player.passives["green_girdle"] = 1
	GameAuthority.damage_player(_player, _player.max_hp * 5.0, "test")
	assert_true(_player.alive, "the girdle keeps him from death")
	assert_almost_eq(_player.hp, 1.0, 0.01)
	_player.invulnerable_s = 0.0
	GameAuthority.damage_player(_player, _player.max_hp * 5.0, "test")
	assert_false(_player.alive, "but only once per level")
	GameAuthority.end_scene()
	_start("the_land_between_the_rivers")
	_player.passives["pomegranate_seed"] = 2
	_player.hp = 10.0
	SecretPassives.on_boss_defeated()
	assert_almost_eq(_player.hp, 10.0 + _player.max_hp * 0.12, 0.01, "6% per level after a boss")
	_player.passives["plant_of_youth"] = 2
	assert_almost_eq(SecretPassives.regen_pct(_player), 0.3, 0.001)
	for secret: String in ["the_lulled_hound", "the_pomegranate", "the_brides_veil", "the_whetstone", "the_green_girdle",
			"camlann", "the_plant_of_youth", "the_thirteen_winds"]:
		var data: Dictionary = SecretRules.find(secret)
		assert_false(data.is_empty(), secret)
		var reward: Dictionary = data["reward"]
		if str(reward["type"]) == "passive":
			assert_false(LevelUpRules.passive_data(str(reward["id"])).is_empty(), secret + "'s passive exists")
		else:
			assert_false(Rewards.cosmetic(str(reward["id"])).is_empty(), secret + "'s cosmetic exists")


func test_pohjola_opens_from_ymir_and_is_harder() -> void:
	var level: Dictionary = _level("pohjola")
	assert_eq(str(level["unlock"]["level"]), "jotunheim")
	assert_eq(int(level["act"]), 3)
	assert_almost_eq(float((Data.cfg("enemies.pack_difficulty") as Dictionary)["3"]["hp_mult"]), 1.4, 0.001)


func test_the_elk_of_hiisi_must_be_slowed_before_it_takes_harm() -> void:
	_start("pohjola")
	var elk: ElkOfHiisiBoss = _bosses.spawn_boss("elk_of_hiisi", 0) as ElkOfHiisiBoss
	assert_not_null(elk)
	assert_lt(elk.modify_hit(100.0, _player, Vector2.ZERO), 50.0, "running free, it shrugs off harm")
	_enemies.statuses.apply(elk.slot, "chill", 1.0, false)
	assert_almost_eq(elk.modify_hit(100.0, _player, Vector2.ZERO), 100.0, 0.01, "slowed, it takes full damage")
	var at: Vector2 = elk.position_now()
	_enemies.statuses.chill[elk.slot] = 0.0
	elk.target = _player
	elk._sprint_in = 0.0
	elk.signature(0.2)
	assert_ne(elk.position_now(), at, "it sprints")


func test_iku_turso_dives_and_breaks_the_ice() -> void:
	_start("pohjola")
	var turso: IkuTursoBoss = _bosses.spawn_boss("iku_turso", 1) as IkuTursoBoss
	turso.target = _player
	turso.signature(4.5)
	assert_gt(turso.under_s, 0.0, "he dives")
	assert_eq(turso.modify_hit(100.0, _player, Vector2.ZERO), 0.0, "he can't be hurt under the ice")
	var hp: float = _player.hp
	turso.signature(3.0)
	assert_eq(turso.holes.size(), 1, "the ice breaks where he rises")
	assert_lt(_player.hp, hp, "and he hurts whoever stands there")
	turso.signature(0.1)
	assert_lt(_player.slow_zone_mult, 1.0, "the open water slows")


func test_louhi_hides_the_sun_then_becomes_the_eagle() -> void:
	_start("pohjola")
	var louhi: LouhiBoss = _bosses.spawn_boss("louhi", 2) as LouhiBoss
	assert_eq(louhi.art_id(), "louhi")
	louhi.phase_index = 1
	assert_true(louhi.is_dark(), "the sun is hidden")
	louhi.phase_index = 2
	assert_false(louhi.is_dark())
	assert_eq(louhi.art_id(), "louhi_eagle", "the great eagle")


func test_the_dragon_of_the_third_labour_hides_in_darkness() -> void:
	_start("mazandaran")
	var dragon: DragonThirdLabourBoss = _bosses.spawn_boss("dragon_third_labour", 0) as DragonThirdLabourBoss
	assert_not_null(dragon)
	_player.position = dragon.position_now() + Vector2(600, 0)
	assert_false(dragon.is_seen(), "far from any Hero, it is hidden")
	assert_lt(dragon.modify_hit(100.0, _player, Vector2.ZERO), 50.0)
	dragon.on_element_hit("holy")
	assert_true(dragon.is_seen(), "Holy light shows it")
	assert_almost_eq(dragon.modify_hit(100.0, _player, Vector2.ZERO), 100.0, 0.01)
	dragon.signature(5.0)
	_player.position = dragon.position_now() + Vector2(40, 0)
	assert_true(dragon.is_seen(), "so does standing close")


func test_the_witch_hides_among_decoys_and_a_hit_shows_her_face() -> void:
	_start("mazandaran")
	var witch: WitchFourthLabourBoss = _bosses.spawn_boss("witch_fourth_labour", 1) as WitchFourthLabourBoss
	assert_eq(witch.art_id(), "witch_fourth_labour_disguised")
	witch.signature(4.0)
	assert_eq(witch.decoys.size(), 3, "three travellers who look just like her")
	witch.modify_hit(10.0, _player, Vector2.ZERO)
	assert_eq(witch.art_id(), "witch_fourth_labour", "her true face")


func test_the_white_divs_cave_cracks_into_pits() -> void:
	_start("mazandaran")
	var white: WhiteDivBoss = _bosses.spawn_boss("white_div", 2) as WhiteDivBoss
	white.target = _player
	white.signature(6.0)
	assert_eq(white.pits.size(), 2)


func test_the_simurgh_comes_when_a_feather_burns() -> void:
	_start("mazandaran")
	var simurgh := SimurghCall.new()
	_world.add_child(simurgh)
	for _i: int in 3:
		GameAuthority.elite_killed.emit(_player.position, {}, false)
	assert_eq(simurgh.count(_player), 3, "elites drop her feathers")
	_player.hp = _player.max_hp * 0.1
	simurgh._process(0.1)
	assert_almost_eq(_player.hp, _player.max_hp, 0.01, "she heals fully")
	assert_eq(simurgh.count(_player), 2, "one feather burned")


func test_zmeys_heads_regrow_unless_seared_with_fire() -> void:
	_start("the_slavic_wilds")
	var zmey: ZmeyGorynychBoss = _bosses.spawn_boss("zmey_gorynych", 0) as ZmeyGorynychBoss
	assert_not_null(zmey)
	assert_eq(zmey.modify_hit(100.0, _player, Vector2.ZERO), 0.0, "the heads take the blows")
	zmey.on_element_hit("physical")
	zmey.modify_hit(1000.0, _player, Vector2.ZERO)
	assert_eq(zmey.heads_on(), 2, "a head falls")
	zmey.signature(7.0)
	assert_eq(zmey.heads_on(), 3, "and grows back")
	for _i: int in 3:
		zmey.on_element_hit("fire")
		zmey.modify_hit(1000.0, _player, Vector2.ZERO)
	zmey.signature(10.0)
	assert_eq(zmey.heads_on(), 0, "seared necks never grow back")
	assert_almost_eq(zmey.modify_hit(100.0, _player, Vector2.ZERO), 100.0, 0.01, "now the body takes the blows")


func test_baba_yagas_hut_stalks_and_stomps() -> void:
	_start("the_slavic_wilds")
	var yaga: BabaYagaBoss = _bosses.spawn_boss("baba_yaga", 1) as BabaYagaBoss
	yaga.target = _player
	yaga.signature(0.1)
	_player.position = yaga.hut
	var hp: float = _player.hp
	yaga.signature(3.0)
	assert_lt(_player.hp, hp, "the hut stamps on you")


func test_koschei_cannot_die_until_his_egg_breaks() -> void:
	_start("the_slavic_wilds")
	var koschei: KoscheiBoss = _bosses.spawn_boss("koschei", 2) as KoscheiBoss
	koschei.signature(0.1)
	assert_ne(koschei.egg, Vector2.INF, "his death lies somewhere on the map")
	var hp: float = _enemies.hp[koschei.slot]
	assert_almost_eq(koschei.modify_hit(hp * 10.0, _player, Vector2.ZERO), hp - 1.0, 0.01, "deathless")
	_player.position = koschei.egg
	koschei.signature(0.1)
	assert_true(koschei.mortal, "the needle snaps")
	assert_gt(koschei.modify_hit(hp * 10.0, _player, Vector2.ZERO), hp)


func test_wandering_lights_draw_monsters_in() -> void:
	_start("the_slavic_wilds")
	var lights := Hazard.create(_level("the_slavic_wilds")["hazard"]) as HazardLights
	_world.add_child(lights)
	lights.begin(_level("the_slavic_wilds")["hazard"])
	assert_eq(lights.lights.size(), 3)
	var slot: int = _enemies.spawn("grey_wolf", lights.lights[0] + Vector2(80, 0))
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	var before: float = _enemies.positions[slot].distance_to(lights.lights[0])
	lights._process(0.2)
	assert_lt(_enemies.positions[slot].distance_to(lights.lights[0]), before, "drawn toward the light")


func test_tsuchigumos_webs_hold_and_fire_burns_them() -> void:
	_start("the_land_of_legends")
	var spider: TsuchigumoBoss = _bosses.spawn_boss("tsuchigumo", 0) as TsuchigumoBoss
	spider.target = _player
	spider.signature(4.0)
	assert_eq(spider.webs.size(), 2)
	_player.position = spider.webs[0]["pos"]
	spider.signature(0.1)
	assert_gt(_player.rooted_s, 0.0, "stuck fast in the web")
	spider.on_element_hit("fire")
	assert_eq(spider.webs.size(), 0, "fire burns every web")


func test_benkei_holds_the_bridge_and_dies_standing() -> void:
	_start("the_land_of_legends")
	var benkei: BenkeiBoss = _bosses.spawn_boss("benkei", 1) as BenkeiBoss
	_player.position = _bosses.arena_center + Vector2(0, 200)
	benkei.signature(0.1)
	assert_lt(_player.slow_zone_mult, 1.0, "the river slows")
	_player.position = _bosses.arena_center
	benkei.signature(0.1)
	assert_eq(_player.slow_zone_mult, 1.0, "the bridge does not")
	benkei.phase_index = 2
	assert_lt(benkei.modify_hit(100.0, _player, Vector2.ZERO), 50.0, "his standing death")
	assert_eq(str(benkei.data.get("unlocks_hero", "")), "benkei")


func test_shuten_doji_lurches_and_water_slows_him() -> void:
	_start("the_land_of_legends")
	var shuten: ShutenDojiBoss = _bosses.spawn_boss("shuten_doji", 2) as ShutenDojiBoss
	var at: Vector2 = shuten.position_now()
	shuten.signature(1.7)
	shuten.signature(0.2)
	assert_ne(shuten.position_now(), at, "he lurches")
	shuten.on_element_hit("water")
	assert_true(_enemies.statuses.has(shuten.slot, "chill"), "water slows him")


func test_pack_3_boss_secrets() -> void:
	_start("pohjola")
	_as_hero("vainamoinen")
	var louhi: LouhiBoss = _bosses.spawn_boss("louhi", 2) as LouhiBoss
	assert_eq(louhi.secret_earned(), "the_sampo")
	var elk: ElkOfHiisiBoss = _bosses.spawn_boss("elk_of_hiisi", 0) as ElkOfHiisiBoss
	assert_eq(elk.secret_earned(), "the_ski_chase", "caught at once")
	elk.age = 100.0
	assert_eq(elk.secret_earned(), "")
	GameAuthority.end_scene()
	_start("the_slavic_wilds")
	var zmey: ZmeyGorynychBoss = _bosses.spawn_boss("zmey_gorynych", 0) as ZmeyGorynychBoss
	assert_eq(zmey.secret_earned(), "seared_necks")
	zmey.on_element_hit("physical")
	zmey.modify_hit(1000.0, _player, Vector2.ZERO)
	zmey.signature(7.0)
	assert_eq(zmey.secret_earned(), "", "a head grew back")
	GameAuthority.end_scene()
	_start("the_land_of_legends")
	_as_hero("yoshitsune")
	var benkei: BenkeiBoss = _bosses.spawn_boss("benkei", 1) as BenkeiBoss
	assert_eq(benkei.secret_earned(), "a_thousand_swords")
	var shuten: ShutenDojiBoss = _bosses.spawn_boss("shuten_doji", 2) as ShutenDojiBoss
	shuten.on_element_hit("water")
	assert_eq(shuten.secret_earned(), "poisoned_sake")
	for secret: String in ["the_sampo", "the_ski_chase", "zals_feathers", "the_seventh_labour", "seared_necks", "the_needle",
			"a_thousand_swords", "poisoned_sake"]:
		var reward: Dictionary = SecretRules.find(secret)["reward"]
		if str(reward["type"]) == "passive":
			assert_false(LevelUpRules.passive_data(str(reward["id"])).is_empty(), secret)
		else:
			assert_false(Rewards.cosmetic(str(reward["id"])).is_empty(), secret)
