extends GutTest
## Phase 12: Divine Resonances (pairs, Harmony, the Resonance summon) and
## divine infusions (templates, Empowered, automatic names, chests).

const TEST_PROFILE := "user://test_save_scratch.json"

var _parent: Node2D
var _enemies: EnemyManager
var _gods: GodManager
var _resonance: ResonanceManager
var _layer: ResonanceLayer
var _player: Player


func before_each() -> void:
	SaveGame.use_test_file(TEST_PROFILE)
	DirAccess.remove_absolute(TEST_PROFILE)
	GameAuthority.start_run("aegean_shore")
	_parent = add_child_autofree(Node2D.new())
	_enemies = EnemyManager.new()
	_parent.add_child(_enemies)
	_enemies.setup()
	_enemies.set_process(false)
	GameAuthority.enemies = _enemies
	var effects := EffectLayer.new()
	_parent.add_child(effects)
	effects.setup()
	_layer = ResonanceLayer.new()
	_layer.ground = GroundEffects.new()
	_parent.add_child(_layer.ground)
	_parent.add_child(_layer)
	_gods = GodManager.new()
	_gods.summons = _layer
	_gods.ground = _layer.ground
	_parent.add_child(_gods)
	_resonance = ResonanceManager.new()
	_resonance.gods = _gods
	_resonance.layer = _layer
	_parent.add_child(_resonance)
	_gods.resonance = _resonance
	_player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, "cu_chulainn")
	_player.kit.set_process(false)


func after_each() -> void:
	GameAuthority.end_scene()
	DirAccess.remove_absolute(TEST_PROFILE)
	SaveGame.use_test_file("")


func test_the_launch_and_pack_2_resonances_pair_existing_gods() -> void:
	var all: Array[Dictionary] = ResonanceManager.all()
	assert_eq(all.size(), 12, "five at launch, four from Pack 2, three from Pack 3")
	for resonance: Dictionary in all:
		for god_id: Variant in resonance["gods"]:
			assert_false(GodRules.find(str(god_id)).is_empty(), "%s exists" % god_id)
	assert_eq(str(ResonanceManager.find_pair("skadi", "sekhmet")["id"]), "sun_and_snow", "order doesn't matter")
	assert_true(ResonanceManager.find_pair("tyche", "thor").is_empty(), "not every pair resonates")


func test_resonance_needs_a_compatible_pair_and_both_meters_full() -> void:
	_gods.bind(_player, "sekhmet")
	_gods.bind(_player, "skadi")
	_gods.set_meter(_player, 0, 1.0)
	_gods.set_meter(_player, 1, 0.5)
	assert_false(_resonance.ready_for(_player), "one meter isn't full")
	assert_false(_resonance.fire(_player))
	_gods.set_meter(_player, 1, 1.0)
	assert_true(_resonance.ready_for(_player))
	assert_true(_resonance.fire(_player))
	assert_eq(_gods.meter(_player, 0), 0.0, "uses both meters")
	assert_eq(_gods.meter(_player, 1), 0.0)
	_gods.release(_player, 1)
	_gods.bind(_player, "tyche")
	_gods.set_meter(_player, 0, 1.0)
	_gods.set_meter(_player, 1, 1.0)
	assert_false(_resonance.ready_for(_player), "Sekhmet and Tyche don't resonate")


func test_harmony_is_on_only_while_both_gods_are_bound_and_discovery_is_recorded_once() -> void:
	_gods.bind(_player, "poseidon")
	_gods.bind(_player, "thor")
	assert_eq(int(_player.god_flags.get(ResonanceManager.HARMONY + "chain_bonus_targets", 0)), 1)
	assert_true(Profile.get_list(EvolutionRules.CODEX_SECTION, ResonanceManager.PROFILE_KEY).has("storm_over_the_sea"))
	_gods.release(_player, 0)
	assert_false(_player.god_flags.has(ResonanceManager.HARMONY + "chain_bonus_targets"))


func test_every_resonance_summon_runs_and_finishes() -> void:
	for k: int in 30:
		_enemies.spawn("satyr_skirmisher", Vector2(30 + k * 4, 0))
	for resonance: Dictionary in ResonanceManager.all():
		_layer.run_resonance(resonance, _player)
	for _i: int in 120:
		_layer._process(0.1)
	assert_eq(_layer.active_count(), 0)


func test_infused_weapon_names_build_automatically() -> void:
	var spear := WeaponInstance.new(GameAuthority.find_weapon("gae_bolg"), _player)
	spear.level = spear.max_level()
	Infusions.infuse(spear, "thor")
	assert_eq(Infusions.display_name(spear), "%s %s" % [TranslationServer.translate("INFUSION_PREFIX_THUNDER"),
			TranslationServer.translate("WEAPON_GAE_BOLG_NAME")])
	assert_eq(spear.element(), "lightning")
	var barbs := WeaponInstance.new(GameAuthority.find_weapon("thirty_barbs"), _player)
	Infusions.infuse(barbs, "skadi")
	assert_eq(Infusions.display_name(barbs), str(TranslationServer.translate("WEAPON_WINTER_BARBS_NAME")), "override")


func test_a_god_of_the_same_element_empowers_instead() -> void:
	var ember := WeaponInstance.new(GameAuthority.find_weapon("ember"), _player)
	ember.level = ember.max_level()
	var plain: float = ember.status_chance()
	Infusions.infuse(ember, "sekhmet")
	assert_true(ember.empowered)
	assert_eq(ember.element(), "fire")
	assert_almost_eq(ember.status_chance(), minf(maxf(plain, 0.6) * 1.5, 1.0), 0.001)


func test_chests_infuse_a_top_level_weapon_with_a_bound_god() -> void:
	var spear: WeaponInstance = GameAuthority.give_weapon(_player, "gae_bolg")
	spear.level = spear.max_level()
	_gods.bind(_player, "thor")
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var plan: Dictionary = ChestRules.build(_player, rng)
	assert_eq(plan["tier"], ChestRules.GOLD)
	assert_eq(plan["rewards"][0]["kind"], "infusion")
	ChestRules.apply(_player, plan)
	assert_eq(spear.infusion, "thor")
	assert_true(Infusions.candidates(_player).is_empty(), "one infusion per weapon")


func test_pack_2_harmonies() -> void:
	_gods.bind(_player, "hecate")
	_gods.bind(_player, "persephone")
	var slot: int = _enemies.spawn("satyr_skirmisher", Vector2(30, 0))
	_enemies.statuses.apply(slot, "hex")
	_player.hp = 10.0
	Blessings.on_kill(_player, slot)
	assert_gt(_player.hp, 10.0, "Torch in the Dark: a Hexed kill heals")
	_gods.release(_player, 1)
	_gods.release(_player, 0)
	_gods.bind(_player, "enki")
	_gods.bind(_player, "shamash")
	assert_almost_eq(float(_player.god_flags.get(ResonanceManager.HARMONY + "holy_vs_soaked_mult", 1.0)), 1.3, 0.001)
	_gods.release(_player, 1)
	_gods.release(_player, 0)
	_gods.bind(_player, "odin")
	_gods.bind(_player, "freyja")
	_player.god_flags[ResonanceManager.HARMONY + "rise_on_kill_chance"] = 1.0
	var before: int = _enemies.active_count()
	_resonance._on_enemy_killed(-1, {"id": "satyr_skirmisher"}, Vector2(50, 0), _player)
	assert_eq(_enemies.active_count(), before + 1, "The Chosen Slain: the fallen rises")


func test_the_chosen_slain_and_thryms_wedding() -> void:
	var weak: int = _enemies.spawn("satyr_skirmisher", Vector2(30, 0))
	_enemies.hp[weak] = 1.0
	var strong: int = _enemies.spawn("satyr_skirmisher", Vector2(-30, 0))
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	_layer.run_resonance(ResonanceManager.find_id("chosen_slain"), _player)
	assert_eq(_enemies.active[strong], 1, "the strong are spared")
	assert_true(_enemies.active[weak] == 0 or _enemies.charmed[weak] != 0, "the weak fall")
	var near: int = _enemies.spawn("troll", Vector2(40, 0))
	_enemies.hp[near] = 100000.0
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	_layer.run_resonance(ResonanceManager.find_id("thryms_wedding"), _player)
	assert_gt(_enemies.statuses.stun[near], 0.0, "the hammer stuns")


func test_pack_3_resonances() -> void:
	_gods.bind(_player, "ukko")
	_gods.bind(_player, "ilmatar")
	assert_gt(float(_player.god_flags.get(ResonanceManager.HARMONY + "summon_shot_shield_s", 0.0)), 0.0)
	_layer.run_resonance(ResonanceManager.find_id("airmaidens_prayer"), _player)
	assert_gt(_player.shot_shield_s, 0.0, "the World Egg's shell")
	var slot: int = _enemies.spawn("troll", Vector2(40, 0))
	_enemies.hp[slot] = 100000.0
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	_layer.run_resonance(ResonanceManager.find_id("thunder_and_earth"), _player)
	assert_gt(_enemies.statuses.stun[slot], 0.0, "bound by the threads")
