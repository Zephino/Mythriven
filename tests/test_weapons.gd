extends GutTest
## Phase 5: smart targeting and Heracles' Great Club.

const CHASER := "placeholder_chaser"

var _parent: Node2D
var _enemies: EnemyManager
var _combat: CombatSystem
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
	_combat = CombatSystem.new()
	_combat.enemies = _enemies
	_combat.effects = effects
	_parent.add_child(_combat)
	_combat.set_process(false)
	_player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true)
	_player.god_mode = true


func after_each() -> void:
	GameAuthority.end_scene()


func _refresh_hash() -> void:
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)


func test_melee_targets_nearest_enemy_even_behind_the_player() -> void:
	_player.facing = Vector2.RIGHT
	var behind: int = _enemies.spawn(CHASER, Vector2(-30, 0))
	_enemies.spawn(CHASER, Vector2(200, 0))
	_refresh_hash()
	var aim: Dictionary = Targeting.pick(Targeting.MELEE, _player, 60.0, _enemies, GameAuthority.run.rng.combat)
	assert_eq(aim["target"], behind)
	assert_almost_eq((aim["direction"] as Vector2).x, -1.0, 0.0001)


func test_melee_with_no_enemy_uses_facing() -> void:
	_player.facing = Vector2.UP
	var aim: Dictionary = Targeting.pick(Targeting.MELEE, _player, 60.0, _enemies, GameAuthority.run.rng.combat)
	assert_eq(aim["direction"], Vector2.UP)
	assert_true(aim["fire"])


func test_targeted_does_not_fire_without_a_target() -> void:
	_enemies.spawn(CHASER, Vector2(500, 0))
	_refresh_hash()
	var aim: Dictionary = Targeting.pick(Targeting.TARGETED, _player, 100.0, _enemies, GameAuthority.run.rng.combat)
	assert_false(aim["fire"])


func test_range_switch_and_directional() -> void:
	_player.facing = Vector2.LEFT
	_enemies.spawn(CHASER, Vector2(20, 0))
	_refresh_hash()
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	assert_true(Targeting.pick(Targeting.RANGE_SWITCH, _player, 300.0, _enemies, rng)["melee"])
	assert_eq(Targeting.pick(Targeting.DIRECTIONAL, _player, 300.0, _enemies, rng)["direction"], Vector2.LEFT)
	assert_eq(Targeting.pick(Targeting.AURA, _player, 300.0, _enemies, rng)["target"], -1)


func test_club_hits_enemy_behind_while_running_away() -> void:
	var club: WeaponInstance = GameAuthority.give_weapon(_player, "great_club")
	_player.facing = Vector2.RIGHT
	_player.velocity = Vector2.RIGHT * 100.0
	var behind: int = _enemies.spawn(CHASER, Vector2(-30, 0))
	_refresh_hash()
	var start_hp: float = _enemies.hp[behind]
	_combat._process(0.016)
	assert_eq(club.attacks_made, 1)
	assert_lt(_enemies.hp[behind], start_hp, "the enemy behind was hit")


func test_club_does_not_hit_enemies_outside_the_arc() -> void:
	GameAuthority.give_weapon(_player, "great_club")
	var front: int = _enemies.spawn(CHASER, Vector2(30, 0))
	var opposite: int = _enemies.spawn(CHASER, Vector2(-40, 0))
	_refresh_hash()
	var opposite_hp: float = _enemies.hp[opposite]
	_combat._process(0.016)
	assert_lt(_enemies.hp[front], 10.0)
	assert_eq(_enemies.hp[opposite], opposite_hp)


func test_killing_an_enemy_frees_its_slot_and_counts() -> void:
	var slot: int = _enemies.spawn(CHASER, Vector2(10, 0))
	GameAuthority.damage_enemy(slot, 1000.0, _player, Vector2.ZERO, "physical")
	assert_eq(_enemies.active[slot], 0)
	assert_eq(GameAuthority.run.kills, 1)


func test_damage_numbers_pool_does_not_grow() -> void:
	var numbers := DamageNumbers.new()
	_parent.add_child(numbers)
	numbers.setup()
	var before: int = numbers.get_child_count()
	for i: int in before * 3:
		numbers.show_number(i, Vector2.ZERO, "crit" if i % 7 == 0 else "normal")
	assert_eq(numbers.get_child_count(), before)


func test_the_bronze_spear_thrusts_through_a_line_of_enemies() -> void:
	var spear: WeaponInstance = GameAuthority.give_weapon(_player, "bronze_spear")
	var near: int = _enemies.spawn(CHASER, Vector2(30, 0))
	var far: int = _enemies.spawn(CHASER, Vector2(80, 0))
	var aside: int = _enemies.spawn(CHASER, Vector2(0, 80))
	_refresh_hash()
	var near_hp: float = _enemies.hp[near]
	var far_hp: float = _enemies.hp[far]
	var aside_hp: float = _enemies.hp[aside]
	_combat._process(0.016)
	assert_eq(spear.attacks_made, 1)
	assert_true(_was_hit(near, near_hp), "the nearest enemy is hit")
	assert_true(_was_hit(far, far_hp), "and the one behind it, in the same line")
	assert_false(_was_hit(aside, aside_hp), "but not one off to the side")


func test_the_phalanx_thrusts_all_round_and_comes_from_the_spear_and_aegis() -> void:
	var recipe: Dictionary = GameAuthority.find_weapon("bronze_spear").get("evolution", {})
	assert_eq(recipe.get("passive", ""), "bronze_aegis", "Bronze Spear + Bronze Aegis")
	assert_eq(recipe.get("into", ""), "phalanx", "evolves into the Phalanx")
	GameAuthority.give_weapon(_player, "phalanx")
	var right: int = _enemies.spawn(CHASER, Vector2(40, 0))
	var left: int = _enemies.spawn(CHASER, Vector2(-40, 0))
	_refresh_hash()
	var right_hp: float = _enemies.hp[right]
	var left_hp: float = _enemies.hp[left]
	_combat._process(0.016)
	assert_true(_was_hit(right, right_hp), "the target is hit")
	assert_true(_was_hit(left, left_hp), "and so is an enemy on the far side: a ring of spears")


func _was_hit(slot: int, hp_before: float) -> bool:
	return _enemies.active[slot] == 0 or _enemies.hp[slot] < hp_before
