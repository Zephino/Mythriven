extends GutTest
## Phase 11: gods (shrines, binding, Blessings, meters, Patronage, summons,
## trials, Divine Links).

var _parent: Node2D
var _enemies: EnemyManager
var _gods: GodManager
var _summons: SummonLayer
var _player: Player


func before_each() -> void:
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
	_summons = SummonLayer.new()
	_parent.add_child(_summons)
	_gods = GodManager.new()
	_gods.summons = _summons
	_parent.add_child(_gods)
	_player = _hero("heracles")


func after_each() -> void:
	GameAuthority.end_scene()


func _hero(hero_id: String) -> Player:
	var player: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, hero_id)
	player.kit.set_process(false)
	player.stats.base["crit"] = 0.0
	return player


func test_all_eight_launch_gods_load_with_a_trigger_and_summon() -> void:
	var ids: PackedStringArray = []
	for god: Dictionary in GodRules.all():
		ids.append(str(god["id"]))
		assert_ne(str((god["trigger"] as Dictionary).get("type", "")), "")
		assert_ne(str((god["summon"] as Dictionary).get("effect", "")), "")
	for god_id: String in ["tyche", "cernunnos", "thor", "skadi", "sekhmet", "poseidon", "ra", "morrigan"]:
		assert_true(ids.has(god_id), "%s is a launch god" % god_id)


func test_shrines_never_offer_bound_gods_or_rare_gods_before_8_minutes() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var level: Dictionary = GameAuthority.run.level_data
	for _i: int in 200:
		var picked: String = GodRules.pick_for_shrine(level, PackedStringArray(["tyche", "thor"]), 60.0, rng)
		assert_false(picked in ["tyche", "thor", "poseidon", "morrigan"], "picked %s" % picked)
	var rare_seen: bool = false
	for _i: int in 300:
		rare_seen = rare_seen or GodRules.pick_for_shrine(level, PackedStringArray(), 600.0, rng) in ["poseidon", "morrigan"]
	assert_true(rare_seen, "rare gods appear after 8:00")


func test_binding_applies_the_blessing_and_releasing_removes_it() -> void:
	var hp_before: float = _player.max_hp
	assert_true(_gods.bind(_player, "skadi"))
	assert_almost_eq(_player.max_hp, hp_before * 1.2, 0.5)
	_gods.release(_player, 0)
	assert_almost_eq(_player.max_hp, hp_before, 0.5)


func test_two_slots_then_a_choice_is_needed() -> void:
	assert_true(_gods.bind(_player, "tyche"))
	assert_true(_gods.bind(_player, "thor"))
	assert_false(_gods.bind(_player, "ra"), "a third god needs a release choice")
	assert_true(_gods.bind(_player, "ra", 0))
	assert_eq(_gods.bound_ids(_player), PackedStringArray(["thor", "ra"]))


func test_meters_fill_from_their_triggers_and_patronage_speeds_them() -> void:
	_gods.bind(_player, "poseidon")
	for _i: int in 200:
		GameAuthority.enemy_killed.emit(0, {}, Vector2.ZERO, _player)
	var greek: float = _gods.meter(_player, 0)
	assert_almost_eq(greek, 200.0 / 500.0 * 1.15, 0.01, "Heracles is Greek: +15% with Poseidon")
	var tomoe: Player = _hero("tomoe_gozen")
	assert_almost_eq(GodRules.charge_mult(tomoe, GodRules.find("poseidon")), 1.08, 0.001, "no Japanese launch god: +8% with all")


func test_both_god_buttons_work_independently() -> void:
	_gods.bind(_player, "tyche")
	_gods.bind(_player, "ra")
	_gods.set_meter(_player, 0, 1.0)
	_gods.set_meter(_player, 1, 0.5)
	assert_false(_gods.summon(_player, 1), "half a meter can't summon")
	assert_true(_gods.summon(_player, 0))
	assert_eq(_gods.meter(_player, 0), 0.0)
	assert_eq(_gods.meter(_player, 1), 0.5)


func test_every_summon_runs_and_finishes() -> void:
	for k: int in 30:
		_enemies.spawn("satyr_skirmisher", Vector2(40 + k * 3, 0))
	for god: Dictionary in GodRules.all():
		_summons.run(god, _player)
	assert_gt(_summons.active_count(), 0)
	for _i: int in 80:
		_summons._process(0.1)
	assert_eq(_summons.active_count(), 0)


func test_sekhmet_makes_fire_always_burn() -> void:
	_gods.bind(_player, "sekhmet")
	var slot: int = _enemies.spawn("satyr_skirmisher", Vector2(50, 0))
	GameAuthority.damage_enemy(slot, 1.0, _player, Vector2.ZERO, "fire", 0.0)
	assert_true(_enemies.statuses.has(slot, "burn"))


func test_thor_chains_every_tenth_projectile() -> void:
	_gods.bind(_player, "thor")
	var chains: int = 0
	for _i: int in 30:
		if Blessings.next_projectile_chains(_player):
			chains += 1
	assert_eq(chains, 3)


func test_fated_enemies_take_double_damage() -> void:
	var slot: int = _enemies.spawn("draugr_brute", Vector2(50, 0))
	_enemies.statuses.apply_fated(slot, 6.0, 1.0)
	assert_almost_eq(_enemies.statuses.damage_taken_mult(slot), 2.0, 0.001)


func test_heracles_summons_empower_his_next_three_slams() -> void:
	_gods.bind(_player, "tyche")
	_gods.set_meter(_player, 0, 1.0)
	_gods.summon(_player, 0)
	assert_eq(int(_player.kit.get("empowered_slams")), 3)


func test_each_trial_can_be_won_and_failed() -> void:
	var patterns := PatternRunner.new()
	_parent.add_child(patterns)
	var shrines := Shrines.new()
	shrines.gods = _gods
	_parent.add_child(shrines)
	shrines.set_process(false)
	var trial := GodTrial.new()
	trial.shrines = shrines
	trial.patterns = patterns
	_parent.add_child(trial)
	trial.set_process(false)
	watch_signals(trial)
	for god_id: String in ["thor", "sekhmet", "skadi"]:
		for win: bool in [true, false]:
			_player.position = Vector2.ZERO
			var shrine: Dictionary = shrines.add(Vector2.ZERO, god_id)
			trial.begin(shrine, _player)
			assert_true(trial.active)
			if win:
				match trial.kind:
					"trial_duel":
						GameAuthority.kill_enemy(_enemies_with_type("trial_avatar"), _player)
					"trial_endurance":
						trial.time_left = 0.01
					"trial_chase":
						trial.touches = 3
			else:
				_player.position = Vector2(trial.ring_radius * 3.0, 0.0)
				trial.time_left = 0.01
			trial._process(0.05)
			assert_false(trial.active, "%s ended" % god_id)
			assert_signal_emitted_with_parameters(trial, "finished", [win, god_id])
			if win:
				assert_true(_gods.bound_ids(_player).has(god_id), "%s bound after winning" % god_id)
				_gods.release(_player, _gods.bound_ids(_player).find(god_id))


func test_a_boss_calls_off_a_trial_and_trials_wait_for_the_fight_to_end() -> void:
	var spawner := EnemySpawner.new()
	spawner.enemies = _enemies
	_parent.add_child(spawner)
	spawner.set_process(false)
	var shrines := Shrines.new()
	shrines.gods = _gods
	_parent.add_child(shrines)
	shrines.set_process(false)
	var trial := GodTrial.new()
	trial.shrines = shrines
	trial.patterns = add_child_autofree(PatternRunner.new())
	trial.spawner = spawner
	shrines.trial = trial
	_parent.add_child(trial)
	trial.set_process(false)
	watch_signals(trial)
	var shrine: Dictionary = shrines.add(Vector2.ZERO, "thor")
	trial.begin(shrine, _player)
	GameAuthority.run.boss_arena_active = true
	spawner.rate_mult = 0.25
	trial._process(0.05)
	assert_false(trial.active, "the boss calls the trial off")
	assert_signal_not_emitted(trial, "finished", "called off isn't won or failed")
	assert_true(shrines.shrines.has(shrine), "the shrine waits for later")
	assert_eq(spawner.rate_mult, 0.25, "the boss fight keeps its spawn rate")
	assert_eq(_enemies_with_type("trial_avatar"), -1, "the duel avatar leaves")
	shrines._touch(shrine, _player, 0.1)
	assert_false(trial.active, "no trial starts during a boss fight")
	GameAuthority.run.boss_arena_active = false
	shrines._touch(shrine, _player, 0.1)
	assert_true(trial.active, "after the fight the trial can start")


func _enemies_with_type(type_id: String) -> int:
	for i: int in _enemies.capacity:
		if _enemies.active[i] != 0 and str(_enemies.type_of(i)["id"]) == type_id:
			return i
	return -1


func test_in_coop_a_trial_waits_for_everyone_in_the_ring_and_everyone_earns_the_god() -> void:
	var shrines := Shrines.new()
	shrines.gods = _gods
	_parent.add_child(shrines)
	shrines.set_process(false)
	var trial := GodTrial.new()
	trial.shrines = shrines
	trial.patterns = add_child_autofree(PatternRunner.new())
	_parent.add_child(trial)
	trial.set_process(false)
	var friend: Player = GameAuthority.spawn_player(_parent, Vector2(5000, 0), null, false, "heracles", 7)
	var shrine: Dictionary = shrines.add(Vector2.ZERO, "sekhmet")
	_player.position = Vector2.ZERO
	trial.begin(shrine, _player)
	assert_true(trial.gathering, "waits for the friend")
	trial._process(0.5)
	assert_true(trial.gathering, "still waiting while the friend is outside the ring")
	assert_eq(trial.kind, "trial_endurance")
	friend.position = Vector2(10, 0)
	trial._process(0.05)
	assert_false(trial.gathering, "everyone is in: the trial starts")
	assert_true(trial.active)
	trial.time_left = 0.01
	trial._process(0.05)
	assert_true(_gods.bound_ids(_player).has("sekhmet"), "the starter earns the god")
	assert_true(_gods.bound_ids(friend).has("sekhmet"), "and so does everyone who took part")


func test_a_coop_trial_is_called_off_if_not_everyone_comes() -> void:
	var shrines := Shrines.new()
	shrines.gods = _gods
	_parent.add_child(shrines)
	shrines.set_process(false)
	var trial := GodTrial.new()
	trial.shrines = shrines
	trial.patterns = add_child_autofree(PatternRunner.new())
	_parent.add_child(trial)
	trial.set_process(false)
	GameAuthority.spawn_player(_parent, Vector2(5000, 0), null, false, "heracles", 7)
	var shrine: Dictionary = shrines.add(Vector2.ZERO, "sekhmet")
	trial.begin(shrine, _player)
	trial._process(Data.cfg_float("gods.trial_gather_s") + 1.0)
	assert_false(trial.active, "called off")
	assert_true(shrines.shrines.has(shrine), "the shrine stays, so it can be tried again")
