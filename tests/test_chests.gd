extends GutTest
## Phase 10: chests (tiers, Luck, contents), standard evolutions, and the Codex.

const TEST_PROFILE := "user://test_save_scratch.json"

var _parent: Node2D
var _player: Player
var _rng := RandomNumberGenerator.new()


func before_each() -> void:
	SaveGame.use_test_file(TEST_PROFILE)
	DirAccess.remove_absolute(TEST_PROFILE)
	GameAuthority.start_run("aegean_shore")
	_parent = add_child_autofree(Node2D.new())
	_player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true)
	_rng.seed = 42


func after_each() -> void:
	GameAuthority.end_scene()
	DirAccess.remove_absolute(TEST_PROFILE)
	SaveGame.use_test_file("")


func test_luck_raises_the_odds_of_silver_and_gold() -> void:
	var unlucky: int = 0
	var lucky: int = 0
	for _i: int in 2000:
		if ChestRules.roll_tier(0.0, _rng) != ChestRules.BRONZE:
			unlucky += 1
		if ChestRules.roll_tier(1.0, _rng) != ChestRules.BRONZE:
			lucky += 1
	assert_gt(lucky, unlucky)


func test_big_chests_are_always_gold() -> void:
	for _i: int in 20:
		assert_eq(ChestRules.roll_tier(0.0, _rng, true), ChestRules.GOLD)


func test_a_chest_holds_as_many_upgrades_as_its_tier_plus_gold() -> void:
	GameAuthority.give_weapon(_player, "ember")
	GameAuthority.give_weapon(_player, "frost")
	GameAuthority.give_weapon(_player, "spark")
	var plan: Dictionary = ChestRules.build(_player, _rng)
	var upgrades: int = 0
	var has_gold: bool = false
	for reward: Dictionary in plan["rewards"]:
		if reward["kind"] == "weapon_up" or reward["kind"] == "passive_up":
			upgrades += 1
		has_gold = has_gold or reward["kind"] == "gold"
	assert_eq(upgrades, ChestRules.upgrades_for(plan["tier"]))
	assert_true(has_gold)
	var gold_before: float = GameAuthority.run.gold
	ChestRules.apply(_player, plan)
	assert_gt(GameAuthority.run.gold, gold_before)


func test_a_ready_weapon_evolves_at_the_next_chest_and_joins_the_codex() -> void:
	var ember: WeaponInstance = GameAuthority.give_weapon(_player, "ember")
	ember.level = ember.max_level()
	_player.passives["belt_of_strength"] = 1
	var plan: Dictionary = ChestRules.build(_player, _rng)
	assert_eq(plan["tier"], ChestRules.GOLD)
	assert_eq(plan["rewards"][0]["kind"], "evolution")
	var evolved: Array[Dictionary] = ChestRules.apply(_player, plan)
	assert_eq(ember.id(), "inferno")
	assert_true(ember.evolved)
	assert_eq(TranslationServer.translate(ember.name_key()), TranslationServer.translate("SPELL_FIRE_T4"))
	assert_true(bool(evolved[0]["new"]), "first discovery")
	assert_true(EvolutionRules.is_discovered("inferno"))
	assert_false(EvolutionRules.discover(evolved[0]), "only new once")
	for card: Dictionary in LevelUpRules.item_cards(_player):
		assert_false(card["kind"] == LevelUpRules.WEAPON_NEW and card["id"] == "ember", "Ember isn't offered again")


func test_no_evolution_without_the_paired_passive() -> void:
	var ember: WeaponInstance = GameAuthority.give_weapon(_player, "ember")
	ember.level = ember.max_level()
	assert_true(EvolutionRules.candidates(_player).is_empty())
	ember.level = ember.max_level() - 1
	_player.passives["belt_of_strength"] = 1
	assert_true(EvolutionRules.candidates(_player).is_empty(), "needs the top level too")


func test_every_recipe_has_an_evolved_weapon_about_twice_as_strong() -> void:
	var recipes: Array[Dictionary] = EvolutionRules.all_recipes()
	assert_eq(recipes.size(), 16)
	for recipe: Dictionary in recipes:
		var base: Dictionary = GameAuthority.find_weapon(str(recipe["weapon"]))
		var into: Dictionary = GameAuthority.find_weapon(str(recipe["into"]))
		assert_false(into.is_empty(), "%s exists" % recipe["into"])
		assert_false(LevelUpRules.passive_data(str(recipe["passive"])).is_empty(), "%s exists" % recipe["passive"])
		var base_damage: float = float((base["levels"] as Array).back()["damage"])
		assert_almost_eq(float(into["levels"][0]["damage"]), base_damage * 2.0, 0.6)


func test_codex_lists_every_recipe_and_hides_undiscovered_ones() -> void:
	var lines: PackedStringArray = CodexScreen.lines()
	assert_eq(lines.size(), EvolutionRules.all_recipes().size() + 3, "count line, recipes, infusions and Resonances headers")
	assert_string_contains(lines[1], "???")
	EvolutionRules.discover({"into": "labor_breaker"})
	assert_string_contains("\n".join(CodexScreen.lines()), str(TranslationServer.translate("WEAPON_LABOR_BREAKER_NAME")))
