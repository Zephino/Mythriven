extends GutTest
## Phase 15 Heroes: King Arthur (Shield Wall, the Scabbard, summon shield),
## Atalanta (The Race, bow pierce), and Odysseus (traps and a decoy).

var _parent: Node2D
var _enemies: EnemyManager


func before_each() -> void:
	SaveGame.use_test_file("user://test_heroes_save.json")
	GameAuthority.start_run("aegean_shore")
	_parent = add_child_autofree(WorldRoot.new())
	_enemies = EnemyManager.new()
	_parent.add_child(_enemies)
	_enemies.setup()
	_enemies.set_process(false)
	GameAuthority.enemies = _enemies


func after_each() -> void:
	GameAuthority.end_scene()
	SaveGame.use_test_file("")


func _hero(hero_id: String) -> Player:
	var player: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, hero_id)
	player.kit.set_process(false)
	return player


func test_arthur_raises_his_shield_when_still_and_ignores_burning() -> void:
	var player: Player = _hero("king_arthur")
	var slot: int = _enemies.spawn("satyr_skirmisher", Vector2(30, 0))
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	player.velocity = Vector2.ZERO
	player.kit._process(0.5)
	assert_true(player.kit.get("raised"))
	assert_true(player.kit.blocks_shot(Vector2(20, 0)), "a shot from the front")
	assert_false(player.kit.blocks_shot(Vector2(-20, 0)), "not from behind")
	assert_almost_eq(player.kit.incoming_damage_at(10.0, Vector2(30, 0)), 5.0, 0.01, "contact from the front is halved")
	var hp: float = player.hp
	GameAuthority.damage_player_over_time(player, 5.0)
	assert_eq(player.hp, hp, "the Scabbard: no damage over time")
	assert_ne(slot, -1)


func test_arthur_summon_shield_soaks_damage() -> void:
	var player: Player = _hero("king_arthur")
	player.kit.on_summon()
	var shield: float = player.max_hp * 0.2
	assert_almost_eq(player.kit.incoming_damage_at(shield - 1.0, Vector2.INF), 0.0, 0.01)
	assert_almost_eq(player.kit.incoming_damage_at(5.0, Vector2.INF), 4.0, 0.01)


func test_atalanta_wins_the_race_for_xp_and_speed() -> void:
	var player: Player = _hero("atalanta")
	assert_eq(player.kit.extra_pierce(WeaponInstance.new(GameAuthority.find_weapon("huntress_bow"), player)), 1)
	player.kit.set("_next_in", 0.0)
	player.kit._process(0.01)
	var marker: Vector2 = player.kit.get("marker")
	assert_ne(marker, Vector2.INF, "a golden marker appears")
	player.position = marker
	player.kit._process(0.01)
	assert_gt(float(player.kit.get("haste_left")), 0.0)
	assert_gt(player.kit.speed_mult(), 1.0)
	assert_gt(player.kit.charge_bonus(), 0.0, "Divine Link: hasted summons charge faster")


func test_odysseus_lays_traps_and_his_decoy_draws_enemies() -> void:
	var player: Player = _hero("odysseus")
	player.velocity = Vector2.ZERO
	player.kit._process(1.1)
	assert_eq((player.kit.get("traps") as PackedVector2Array).size(), 1)
	var slot: int = _enemies.spawn("satyr_skirmisher", Vector2(5, 0))
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	var hp: float = _enemies.hp[slot]
	player.kit._process(0.01)
	assert_lt(_enemies.hp[slot], hp, "the trap springs")
	player.kit.set("_disguise_in", 0.0)
	player.kit._process(0.01)
	assert_ne(_enemies.movement.lure_pos, Vector2.INF, "the decoy lures enemies")


func test_excalibur_strikes_holy_every_third_swing() -> void:
	var player: Player = _hero("king_arthur")
	var excalibur: WeaponInstance = player.weapons[0] if not player.weapons.is_empty() else GameAuthority.give_weapon(player, "excalibur")
	excalibur.attacks_made = 2
	assert_eq(excalibur.element(), Elements.PHYSICAL)
	excalibur.attacks_made = 3
	assert_eq(excalibur.element(), "holy")
