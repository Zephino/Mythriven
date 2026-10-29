extends GutTest
## Phase 6: XP curve, level-up cards, the capped pickup sound chain, XP orb
## merging, and the run log.

var _parent: Node2D
var _player: Player


func before_each() -> void:
	GameAuthority.start_run("aegean_shore")
	_parent = add_child_autofree(Node2D.new())
	_player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true)
	GameAuthority.give_weapon(_player, "great_club")


func after_each() -> void:
	GameAuthority.end_scene()


func test_xp_curve_starts_at_5_and_grows_by_a_step_and_a_percentage() -> void:
	assert_eq(LevelUpRules.xp_to_next(1), 5.0)
	var previous: float = LevelUpRules.xp_to_next(1)
	for level: int in range(2, 30):
		var needed: float = LevelUpRules.xp_to_next(level)
		assert_true(needed >= previous, "level %d should not need less XP" % level)
		previous = needed
	var step: float = Data.cfg_float("xp.step_per_level")
	var growth: float = Data.cfg_float("xp.growth_per_level")
	assert_gt(step, 0.0)
	assert_almost_eq(LevelUpRules.xp_to_next(21), (5.0 + step * 20.0) * pow(1.0 + growth, 20), 1.0)


func test_collecting_xp_queues_level_ups() -> void:
	watch_signals(GameAuthority)
	GameAuthority.collect_xp(_player, LevelUpRules.xp_to_next(1) + LevelUpRules.xp_to_next(2))
	assert_eq(GameAuthority.run.level, 3)
	assert_eq(GameAuthority.run.unspent_level_ups, 2)
	assert_signal_emitted(GameAuthority, "level_up_ready")


func test_offer_has_three_distinct_useful_cards() -> void:
	for _i: int in 20:
		var offer: Array[Dictionary] = LevelUpRules.build_offer(_player, GameAuthority.run.rng.loot)
		assert_eq(offer.size(), 3)
		var seen: Dictionary = {}
		for card: Dictionary in offer:
			var key: String = "%s:%s" % [card["kind"], card["id"]]
			assert_false(seen.has(key), "no duplicate cards")
			seen[key] = true


func test_high_luck_gives_a_fourth_card() -> void:
	_player.stats.add_bonus("luck", Data.cfg_float("level_up.high_luck_threshold"))
	assert_eq(LevelUpRules.build_offer(_player, GameAuthority.run.rng.loot).size(), 4)


func test_maxed_items_are_never_offered_and_maxed_builds_get_gold_and_heal() -> void:
	var guard: int = 0
	while not LevelUpRules.is_maxed(_player) and guard < 500:
		guard += 1
		GameAuthority.apply_card(_player, LevelUpRules.item_cards(_player)[0])
	assert_true(LevelUpRules.is_maxed(_player))
	for weapon: WeaponInstance in _player.weapons:
		assert_eq(weapon.level, weapon.max_level())
	var kinds: Array = []
	for card: Dictionary in LevelUpRules.build_offer(_player, GameAuthority.run.rng.loot):
		kinds.append(card["kind"])
	assert_has(kinds, LevelUpRules.GOLD)
	assert_has(kinds, LevelUpRules.HEAL)


func test_smart_auto_collect_heals_when_low() -> void:
	_player.hp = _player.max_hp * 0.2
	assert_eq(LevelUpRules.auto_collect_card("smart", _player)["kind"], LevelUpRules.HEAL)
	_player.hp = _player.max_hp
	assert_eq(LevelUpRules.auto_collect_card("smart", _player)["kind"], LevelUpRules.GOLD)
	assert_true(LevelUpRules.auto_collect_card("off", _player).is_empty())


func test_passive_card_raises_its_stat() -> void:
	var before: float = _player.stats.might()
	GameAuthority.apply_card(_player, {"kind": LevelUpRules.PASSIVE_NEW, "id": "belt_of_strength", "from": 0, "to": 1, "amount": 0.0})
	assert_eq(int(_player.passives["belt_of_strength"]), 1)
	assert_gt(_player.stats.might(), before)


func test_pickup_chain_climbs_caps_and_resets() -> void:
	var chain := PickupChain.new()
	var steps: Array[int] = []
	for i: int in 15:
		steps.append(chain.on_pickup(i * 0.1))
	assert_eq(steps[0], 0)
	assert_eq(steps[5], 5)
	assert_eq(steps[11], 11, "12th note is the top step")
	assert_eq(steps[14], 11, "then it holds the top note")
	assert_eq(chain.on_pickup(1.4 + 0.7), 0, "resets after 0.6 s without a pickup")


func test_pickup_chain_rate_limit() -> void:
	var chain := PickupChain.new()
	var played: int = 0
	for i: int in 300:
		if chain.on_pickup(i * 0.001) >= 0:
			played += 1
	assert_eq(played, chain.per_second, "hundreds of orbs at once play at most 20 sounds per second")


func test_distant_orbs_merge_without_losing_xp() -> void:
	var orbs := XpOrbs.new()
	_parent.add_child(orbs)
	orbs.setup()
	orbs.set_process(false)
	var far: float = Data.cfg_float("xp.merge_far_px") * 3.0
	for i: int in 50:
		orbs.drop(Vector2(far + (i % 5), far + floorf(i / 5.0)), 1.0)
	orbs.merge_distant()
	assert_eq(orbs.count(), 1)
	assert_almost_eq(float(orbs._value[orbs._active.find(1)]), 50.0, 0.001)


func test_run_log_has_time_cause_and_build() -> void:
	_player.cause_of_death = "placeholder_chaser"
	GameAuthority.run.elapsed_s = 123.4
	var log_data: Dictionary = RunLog.to_dictionary(GameAuthority.run, GameAuthority.players)
	assert_eq(log_data["time_s"], 123.4)
	var first: Dictionary = (log_data["players"] as Array)[0]
	assert_eq(first["cause_of_death"], "placeholder_chaser")
	assert_eq((first["weapons"] as Array)[0]["id"], "great_club")
	var path: String = RunLog.write(GameAuthority.run, GameAuthority.players)
	assert_true(FileAccess.file_exists(path))
	DirAccess.remove_absolute(path)


func test_ambrosia_heals_only_hurt_players_and_not_above_max() -> void:
	var heals := HealPickups.new()
	_parent.add_child(heals)
	heals.setup()
	heals.set_process(false)
	heals.drop(_player.position)
	heals._process(0.016)
	assert_eq(heals.count(), 1, "a player at full HP leaves the Ambrosia on the ground")
	_player.hp = _player.max_hp - 10.0
	heals._process(0.016)
	assert_eq(heals.count(), 0, "a hurt player picks it up")
	assert_eq(_player.hp, _player.max_hp, "healing never goes above Max HP")


func test_more_enemies_every_5_levels_and_tougher_every_10() -> void:
	assert_eq(LevelScaling.spawn_mult(4), 1.0)
	assert_eq(LevelScaling.spawn_mult(5), 1.25)
	assert_eq(LevelScaling.spawn_mult(12), 1.5)
	assert_eq(LevelScaling.hp_mult(9), 1.0)
	assert_eq(LevelScaling.hp_mult(10), 1.5)
	assert_eq(LevelScaling.damage_mult(20), 1.5)
