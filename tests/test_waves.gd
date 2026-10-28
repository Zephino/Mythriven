extends GutTest
## Phase 10: the run arc (Ages, HP growth), the Aegean wave table, movement
## types, and elites (modifiers, shields, splitting, diminishing crowd control).

var _parent: Node2D
var _enemies: EnemyManager
var _player: Player


func before_each() -> void:
	GameAuthority.start_run("aegean_shore")
	_parent = add_child_autofree(Node2D.new())
	_enemies = EnemyManager.new()
	_parent.add_child(_enemies)
	_enemies.setup()
	_enemies.set_process(false)
	GameAuthority.enemies = _enemies
	_player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true)
	_player.stats.base["crit"] = 0.0


func after_each() -> void:
	GameAuthority.end_scene()


func test_ages_follow_the_run_arc() -> void:
	assert_eq(RunArc.age_at(0.0), RunArc.DUSK)
	assert_eq(RunArc.age_at(599.0), RunArc.DUSK)
	assert_eq(RunArc.age_at(600.0), RunArc.NIGHT)
	assert_eq(RunArc.age_at(1200.0), RunArc.DEEP_NIGHT)
	assert_eq(RunArc.age_at(1800.0), RunArc.UNRAVELING)


func test_enemy_hp_grows_from_x1_to_x3_by_30_minutes_then_holds() -> void:
	assert_almost_eq(RunArc.hp_mult(0.0), 1.0, 0.001)
	assert_almost_eq(RunArc.hp_mult(900.0), 2.0, 0.001)
	assert_almost_eq(RunArc.hp_mult(1800.0), 3.0, 0.001)
	assert_almost_eq(RunArc.hp_mult(3600.0), 3.0, 0.001)


func test_wave_rows_change_by_minute_and_name_real_enemies() -> void:
	var table: Dictionary = RunArc.wave_table(GameAuthority.run.level_data)
	assert_false(table.is_empty(), "the Aegean Shore has a wave table")
	assert_eq(float(RunArc.wave_row(table, 0.0)["from_min"]), 0.0)
	assert_eq(float(RunArc.wave_row(table, 659.0)["from_min"]), 10.0)
	assert_gt(float(RunArc.wave_row(table, 1500.0)["spawns_per_s"]), float(RunArc.wave_row(table, 0.0)["spawns_per_s"]))
	for type_id: String in _types_in(table):
		assert_true(_enemies.type_index.has(type_id), "%s is in enemies.json" % type_id)


func test_every_movement_type_appears_in_the_aegean_waves() -> void:
	var movements: Dictionary = {}
	for type_id: String in _types_in(RunArc.wave_table(GameAuthority.run.level_data)):
		movements[str(_enemies.types[_enemies.type_index[type_id]]["movement"])] = true
	for movement: String in ["chaser", "swarm", "brute", "flyer", "caster", "encircler", "bomber"]:
		assert_true(movements.has(movement), "%s appears" % movement)


func test_flyers_cross_the_screen_and_leave_without_a_kill() -> void:
	var slot: int = _enemies.spawn("shade_flyer", Vector2(-200, 0))
	_enemies.movement.dir[slot] = Vector2.RIGHT
	_enemies.movement.step(_enemies, 0.5)
	assert_gt(_enemies.positions[slot].x, -200.0)
	_enemies.movement.timer[slot] = 0.01
	_enemies.movement.step(_enemies, 0.1)
	assert_eq(_enemies.active[slot], 0)
	assert_eq(GameAuthority.run.kills, 0)


func test_casters_stop_at_range_and_fire_after_a_glow() -> void:
	var shots := EnemyProjectiles.new()
	_parent.add_child(shots)
	shots.setup()
	shots.set_process(false)
	GameAuthority.enemy_shots = shots
	var slot: int = _enemies.spawn("siren_caster", Vector2(100, 0))
	_enemies.movement.timer[slot] = 0.4
	_enemies.movement.step(_enemies, 0.01)
	assert_eq(_enemies.movement.state[slot], EnemyMovement.WINDING, "glows before firing")
	assert_almost_eq(_enemies.positions[slot].x, 100.0, 0.5, "stands still in range")
	_enemies.movement.step(_enemies, 0.5)
	assert_eq(shots.count(), 1)


func test_bombers_explode_after_their_fuse() -> void:
	var slot: int = _enemies.spawn("muspel_spark_bomber", Vector2(20, 0))
	_enemies.movement.step(_enemies, 0.01)
	assert_eq(_enemies.movement.state[slot], EnemyMovement.WINDING)
	var hp_before: float = _player.hp
	_enemies.movement.step(_enemies, 1.1)
	assert_eq(_enemies.active[slot], 0)
	assert_lt(_player.hp, hp_before)


func test_elite_crowd_control_diminishes_then_becomes_immune() -> void:
	var elite: int = _enemies.spawn("minotaur", Vector2(300, 0))
	var st: EnemyStatuses = _enemies.statuses
	assert_almost_eq(st.cc_duration(elite, 2.0), 2.0, 0.001)
	assert_almost_eq(st.cc_duration(elite, 2.0), 1.0, 0.001)
	assert_almost_eq(st.cc_duration(elite, 2.0), 0.5, 0.001)
	assert_almost_eq(st.cc_duration(elite, 2.0), 0.0, 0.001, "immune after three")
	var normal: int = _enemies.spawn("satyr_skirmisher", Vector2(-300, 0))
	for _i: int in 4:
		assert_almost_eq(st.cc_duration(normal, 2.0), 2.0, 0.001)


func test_warded_shield_takes_damage_first_and_holy_breaks_it() -> void:
	var slot: int = _enemies.spawn("minotaur", Vector2(300, 0))
	_enemies.elites.setup(slot, PackedStringArray(["warded"]), _enemies.max_hp[slot])
	var shield: float = _enemies.elites.shield[slot]
	assert_almost_eq(shield, _enemies.max_hp[slot] * 0.3, 0.01)
	GameAuthority.damage_enemy(slot, 50.0, _player, Vector2.ZERO, "physical")
	assert_almost_eq(_enemies.hp[slot], _enemies.max_hp[slot], 0.01, "HP untouched while shielded")
	assert_lt(_enemies.elites.shield[slot], shield)
	GameAuthority.damage_enemy(slot, 5.0, _player, Vector2.ZERO, "holy")
	assert_eq(_enemies.elites.shield[slot], 0.0)


func test_splitting_elites_leave_three_smaller_copies_that_do_not_split_again() -> void:
	watch_signals(GameAuthority)
	var slot: int = _enemies.spawn("minotaur", Vector2(300, 0))
	_enemies.elites.setup(slot, PackedStringArray(["splitting"]), _enemies.max_hp[slot])
	var full_hp: float = _enemies.max_hp[slot]
	GameAuthority.kill_enemy(slot, _player)
	assert_eq(_enemies.active_count(), 3)
	assert_signal_emitted_with_parameters(GameAuthority, "elite_killed", [Vector2(300, 0), _enemies.types[_enemies.type_index["minotaur"]], false])
	for i: int in _enemies.capacity:
		if _enemies.active[i] != 0:
			assert_eq(_enemies.elites.is_copy[i], 1)
			assert_lt(_enemies.max_hp[i], full_hp)
			GameAuthority.kill_enemy(i, _player)
	assert_eq(_enemies.active_count(), 0)


func test_elites_get_two_modifiers_in_deep_night() -> void:
	assert_eq(RunArc.elite_modifier_count(300.0), 1)
	assert_eq(RunArc.elite_modifier_count(1300.0), 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var mods: PackedStringArray = EliteState.roll(2, rng)
	assert_eq(mods.size(), 2)
	assert_ne(mods[0], mods[1])


func test_hasted_elites_move_faster() -> void:
	var slot: int = _enemies.spawn("minotaur", Vector2(300, 0))
	var normal: float = _enemies.speed_of(slot)
	_enemies.elites.setup(slot, PackedStringArray(["hasted"]), _enemies.max_hp[slot])
	assert_almost_eq(_enemies.speed_of(slot), normal * 1.5, 0.01)


func _types_in(table: Dictionary) -> Array[String]:
	var found: Array[String] = []
	for row: Dictionary in table.get("rows", []):
		for type_id: String in (row.get("singles", {}) as Dictionary).keys():
			found.append(type_id)
		for pack: Dictionary in row.get("packs", []):
			found.append(str(pack["type"]))
		for group: Dictionary in row.get("groups", []):
			found.append(str(group["type"]))
	for type_id: Variant in (table.get("elites", {}) as Dictionary).get("types", []):
		found.append(str(type_id))
	return found
