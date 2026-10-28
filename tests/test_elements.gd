extends GutTest
## Phase 8: elements, statuses (data on pooled enemies), reactions, spell tier
## names, and player statuses from 30:00.

const CHASER := "placeholder_chaser"

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
	_player = GameAuthority.spawn_player(_parent, Vector2(-500, -500), null, true)
	_player.stats.base["crit"] = 0.0


func after_each() -> void:
	GameAuthority.end_scene()


func _spawn(at: Vector2) -> int:
	var slot: int = _enemies.spawn(CHASER, at)
	_enemies.hp[slot] = 10000.0
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	return slot


func test_weakness_and_resistance() -> void:
	var water_enemy: Dictionary = {"weak": "lightning", "resist": "fire"}
	assert_eq(Elements.multiplier(water_enemy, "lightning"), 1.5)
	assert_eq(Elements.multiplier(water_enemy, "fire"), 0.5)
	assert_eq(Elements.multiplier(water_enemy, "ice"), 1.0)
	assert_eq(Elements.multiplier({"weak": ["water", "ice"]}, "ice"), 1.5, "bosses can have two weaknesses")


func test_three_chills_freeze_and_frozen_enemies_stop() -> void:
	var slot: int = _spawn(Vector2.ZERO)
	_enemies.statuses.apply(slot, "chill")
	assert_almost_eq(_enemies.statuses.speed_mult(slot), 0.7, 0.001, "-30% per Chill stack")
	_enemies.statuses.apply(slot, "chill")
	_enemies.statuses.apply(slot, "chill")
	assert_true(_enemies.statuses.has(slot, "frozen"))
	assert_eq(_enemies.statuses.speed_mult(slot), 0.0)


func test_bosses_are_only_chilled() -> void:
	var slot: int = _spawn(Vector2.ZERO)
	for _i: int in 5:
		_enemies.statuses.apply(slot, "chill", 1.0, false)
	assert_false(_enemies.statuses.has(slot, "frozen"))


func test_poison_stacks_to_five_and_burn_ticks() -> void:
	var slot: int = _spawn(Vector2.ZERO)
	for _i: int in 8:
		_enemies.statuses.apply(slot, "poison")
	assert_eq(_enemies.statuses.poison_stacks[slot], 5)
	_enemies.statuses.apply(slot, "burn")
	var hp_before: float = _enemies.hp[slot]
	_enemies.statuses.tick(0.2, _enemies.active, GameAuthority.hits.damage_over_time)
	assert_lt(_enemies.hp[slot], hp_before, "Burn and Poison deal damage over time")


func test_weakness_hit_does_one_and_a_half_times() -> void:
	var slot: int = _spawn(Vector2.ZERO)
	var normal: float = GameAuthority.hits.hit(slot, 10.0, _player, Vector2.ZERO, "ice", 0.0)
	var weak: float = GameAuthority.hits.hit(slot, 10.0, _player, Vector2.ZERO, "lightning", 0.0)
	var resisted: float = GameAuthority.hits.hit(slot, 10.0, _player, Vector2.ZERO, "fire", 0.0)
	assert_almost_eq(weak, normal * 1.5, 0.01)
	assert_almost_eq(resisted, normal * 0.5, 0.01)


func test_shatter_doubles_physical_damage_and_ends_freeze() -> void:
	var slot: int = _spawn(Vector2.ZERO)
	var normal: float = GameAuthority.hits.hit(slot, 10.0, _player, Vector2.ZERO, "physical", 0.0)
	for _i: int in 3:
		_enemies.statuses.apply(slot, "chill")
	var shattered: float = GameAuthority.hits.hit(slot, 10.0, _player, Vector2.ZERO, "physical", 0.0)
	assert_almost_eq(shattered, normal * 2.0, 0.01)
	assert_false(_enemies.statuses.has(slot, "frozen"))


func test_fire_on_soaked_only_removes_soaked() -> void:
	var slot: int = _spawn(Vector2.ZERO)
	_enemies.statuses.apply(slot, "soaked")
	GameAuthority.hits.hit(slot, 10.0, _player, Vector2.ZERO, "fire", 1.0)
	assert_false(_enemies.statuses.has(slot, "soaked"))
	assert_false(_enemies.statuses.has(slot, "burn"), "no Burn when the hit only dried the enemy")


func test_conduct_chains_to_every_soaked_enemy_nearby() -> void:
	var first: int = _spawn(Vector2.ZERO)
	var near: int = _spawn(Vector2(30, 0))
	var dry: int = _spawn(Vector2(0, 30))
	for slot: int in [first, near]:
		_enemies.statuses.apply(slot, "soaked")
	var near_hp: float = _enemies.hp[near]
	var dry_hp: float = _enemies.hp[dry]
	watch_signals(GameAuthority)
	GameAuthority.hits.hit(first, 10.0, _player, Vector2.ZERO, "lightning", 0.0)
	assert_lt(_enemies.hp[near], near_hp, "the Soaked neighbour is hit by the chain")
	assert_eq(_enemies.hp[dry], dry_hp, "a dry neighbour is not")
	assert_signal_emitted_with_parameters(GameAuthority, "reaction_triggered", ["conduct", Vector2.ZERO, 64.0, _player])


func test_steam_burst_melts_ice() -> void:
	var slot: int = _spawn(Vector2.ZERO)
	_enemies.statuses.apply(slot, "chill")
	GameAuthority.hits.hit(slot, 10.0, _player, Vector2.ZERO, "fire", 0.0)
	assert_false(_enemies.statuses.has(slot, "chill"))


func test_spread_copies_statuses_to_up_to_four_neighbours() -> void:
	var source: int = _spawn(Vector2.ZERO)
	var others: Array[int] = []
	for i: int in 6:
		others.append(_spawn(Vector2(10 + i * 3, 0)))
	_enemies.statuses.apply(source, "burn")
	GameAuthority.hits.hit(source, 1.0, _player, Vector2.ZERO, "wind", 0.0)
	var burning: int = 0
	for slot: int in others:
		if _enemies.statuses.has(slot, "burn"):
			burning += 1
	assert_eq(burning, 4)


func test_reaction_budget_caps_reactions_per_second() -> void:
	var resolver := HitResolver.new()
	var allowed: int = 0
	for _i: int in 100:
		if resolver.take_reaction_budget():
			allowed += 1
	assert_eq(allowed, Data.cfg_int("effect_budgets.max_reactions_per_s"))


func test_spell_tier_names() -> void:
	var ember: Dictionary = GameAuthority.find_weapon("ember")
	assert_eq(WeaponInstance.name_key_at(ember, 3), "SPELL_FIRE_T1")
	assert_eq(WeaponInstance.name_key_at(ember, 4), "SPELL_FIRE_T2")
	assert_eq(WeaponInstance.name_key_at(ember, 8), "SPELL_FIRE_T3")
	assert_true(CardText.is_tier_change({"kind": LevelUpRules.WEAPON_UP, "id": "ember", "from": 3, "to": 4}))
	assert_false(CardText.is_tier_change({"kind": LevelUpRules.WEAPON_UP, "id": "ember", "from": 4, "to": 5}))


func test_players_only_get_statuses_from_30_minutes_at_half_duration() -> void:
	GameAuthority.status_player_from_enemy(_player, "fire")
	assert_false(_player.statuses.has("burn"), "no elemental statuses before 30:00")
	GameAuthority.run.elapsed_s = Data.cfg_float("combat.player_status_start_s")
	GameAuthority.status_player_from_enemy(_player, "fire")
	assert_true(_player.statuses.has("burn"))
	var full: float = float(Elements.status("burn")["duration_s"])
	assert_almost_eq(float(_player.statuses.timers["burn"]), full * 0.5, 0.001)


func test_player_chill_never_freezes_and_immunity_follows() -> void:
	for _i: int in 5:
		_player.statuses.apply("chill")
	assert_eq(_player.statuses.chill_stacks, 2)
	assert_gt(_player.statuses.speed_mult(), 0.0, "players are never frozen solid")
	_player.statuses.tick(10.0)
	assert_true(_player.statuses.is_immune(), "2 s immunity after a status ends")
	assert_false(_player.statuses.apply("burn"))
