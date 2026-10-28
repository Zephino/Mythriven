extends GutTest
## Phase 14: regions and points of interest, the compass data, the Wandering
## Trader, Reroll/Banish tokens, and world events.

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


func after_each() -> void:
	GameAuthority.end_scene()


func test_the_same_seed_always_places_the_same_pois() -> void:
	var differs: bool = false
	for x: int in range(-6, 7):
		for y: int in range(-6, 7):
			var region := Vector2i(x, y)
			assert_eq(PoiRules.for_region(1234, region, RunArc.DUSK), PoiRules.for_region(1234, region, RunArc.DUSK))
			differs = differs or PoiRules.for_region(1234, region, RunArc.DUSK) != PoiRules.for_region(99, region, RunArc.DUSK)
	assert_true(differs, "another seed gives another world")


func test_about_a_third_of_regions_have_a_poi_and_lairs_keep_their_distance() -> void:
	var with_poi: int = 0
	var total: int = 0
	for x: int in range(-10, 11):
		for y: int in range(-10, 11):
			if x == 0 and y == 0:
				continue
			total += 1
			var poi: Dictionary = PoiRules.for_region(77, Vector2i(x, y), RunArc.NIGHT)
			if poi.is_empty():
				continue
			with_poi += 1
			if poi["id"] == "monsters_lair":
				assert_gte(maxi(absi(x), absi(y)), 2, "lairs aren't next to the start")
	var share: float = float(with_poi) / total
	assert_between(share, 0.25, 0.45)


func test_the_start_always_has_ruins_within_one_screen() -> void:
	for run_seed: int in [1, 2, 3]:
		var poi: Dictionary = PoiRules.for_region(run_seed, Vector2i.ZERO, RunArc.DUSK)
		assert_eq(poi["id"], "ancient_ruins")
		assert_lt((poi["pos"] as Vector2).length(), get_viewport().get_visible_rect().size.x / Data.cfg_float("camera.zoom"))


func test_trader_purchases_reduce_run_gold_and_prices_rise_each_age() -> void:
	var run: RunState = GameAuthority.run
	var ember: WeaponInstance = GameAuthority.give_weapon(_player, "ember")
	run.gold = 200.0
	assert_true(TraderScreen.buy(_player, "travelers_bread"))
	assert_eq(run.gold, 150.0)
	assert_true(TraderScreen.buy(_player, "whetstone", 0))
	assert_eq(ember.level, 2)
	assert_eq(run.gold, 75.0)
	assert_true(TraderScreen.buy(_player, "reroll_token"))
	assert_eq(run.reroll_tokens, 1)
	assert_eq(run.gold, 50.0)
	assert_false(TraderScreen.buy(_player, "banish_token"), "60 gold costs more than 50")
	assert_eq(run.gold, 50.0)
	run.elapsed_s = 600.0
	assert_eq(TraderScreen.price("travelers_bread"), 75, "×1.5 in Night")


func test_banished_items_never_come_back() -> void:
	GameAuthority.run.banished.append("frost")
	for card: Dictionary in LevelUpRules.item_cards(_player):
		assert_ne(card["id"], "frost")


func test_world_events_start_and_end() -> void:
	var spawner := EnemySpawner.new()
	spawner.enemies = _enemies
	_parent.add_child(spawner)
	spawner.set_process(false)
	var storm := HazardStrikes.new()
	_parent.add_child(storm)
	var director := RunDirector.new()
	director.spawner = spawner
	director.storm = storm
	_parent.add_child(director)
	director.set_process(false)
	var run: RunState = GameAuthority.run
	director.start_event("chaos_surge")
	assert_eq(spawner.event_mult, 2.0)
	assert_eq(run.xp_mult, 2.0)
	director._tick_events(run, 61.0)
	assert_eq(spawner.event_mult, 1.0)
	assert_eq(run.xp_mult, 1.0)
	director.start_event("divine_storm")
	assert_eq(run.god_charge_mult, 2.0)
	assert_true(storm.active)
	director._tick_events(run, 46.0)
	assert_eq(run.god_charge_mult, 1.0)
	assert_false(storm.active)


func test_dragons_hoard_breaks_after_50_kills_and_ruins_clear_after_10_s() -> void:
	var chests := ChestPickups.new()
	_parent.add_child(chests)
	chests.setup()
	var pois := PoiManager.new()
	pois.chests = chests
	_parent.add_child(pois)
	var hoard: Dictionary = pois.place("dragons_hoard", Vector2(50, 0))
	var ruins: Dictionary = pois.place("ancient_ruins", Vector2.ZERO)
	pois._process(0.01)
	for _i: int in 50:
		GameAuthority.enemy_killed.emit(0, {}, Vector2(50, 0), _player)
	assert_eq(pois.state_of(hoard), "looted")
	assert_eq(chests.count(), 1)
	for _i: int in 21:
		pois._process(0.5)
	assert_eq(pois.state_of(ruins), "cleared")
