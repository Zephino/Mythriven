extends GutTest
## Phase 15: the save file, banking gold, Omens and Swift Mode, offerings,
## unlocks, achievements, secrets, the Bestiary, and the death recap's tip.

const TEST_SAVE := "user://test_meta_save.json"

var _parent: Node2D


func before_each() -> void:
	SaveGame.use_test_file(TEST_SAVE)
	_parent = add_child_autofree(Node2D.new())


func after_each() -> void:
	GameAuthority.end_scene()
	SaveGame.use_test_file("")
	for file: String in [TEST_SAVE, TEST_SAVE + ".bak", TEST_SAVE + ".tmp"]:
		DirAccess.remove_absolute(file)


func test_quitting_before_and_after_5_00_banks_the_right_gold() -> void:
	assert_eq(Banking.banked(200.0, 299.0, true, [], false), 0, "quit before 5:00 keeps none")
	assert_eq(Banking.banked(205.0, 300.0, true, [], false), 20, "quit at 5:00 keeps 10%, rounded down")
	assert_eq(Banking.banked(200.0, 120.0, false, [], false), 200, "dying keeps it all")
	assert_eq(Banking.banked(200.0, 0.0, false, ["haste", "horde"], false), 330, "Omen gold bonuses add up")
	assert_eq(Banking.banked(200.0, 0.0, false, [], true), 300, "Swift Mode: gold ×1.5")


func test_quitting_from_the_pause_menu_banks_10_percent() -> void:
	var run: RunState = GameAuthority.start_run("aegean_shore")
	run.gold = 300.0
	run.elapsed_s = 400.0
	var before: int = SaveGame.gold()
	Meta.quit_run()
	assert_eq(SaveGame.gold(), before + 30)
	assert_true(SaveGame.data()["run_in_progress"].is_empty())


func test_force_closing_never_loses_an_unlock() -> void:
	assert_true(HeroRules.unlock("king_arthur"))
	GodLevels.mark_bound("thor")
	Bestiary.count_kill("medusa")
	SecretRules.reveal("the_mirrored_shield")
	# The game is closed without finishing the run; the next start reads the file.
	SaveGame.forget_loaded()
	assert_true(SaveGame.list(HeroRules.UNLOCKS_SECTION).has("king_arthur"))
	assert_true(GodLevels.bound_ever("thor"))
	assert_eq(Bestiary.kills("medusa"), 1, "a new Bestiary entry is saved at once")
	assert_true(SecretRules.is_found("the_mirrored_shield"))
	assert_true(SaveGame.list("passives_unlocked").has("mirrored_shield"), "the secret's reward too")


func test_a_run_cut_short_is_settled_as_a_quit_next_time() -> void:
	SaveGame.data()["run_in_progress"] = {"gold": 300.0, "arc_s": 400.0, "omens": [], "swift": false}
	SaveGame.commit()
	SaveGame.forget_loaded()
	var before: int = SaveGame.gold()
	assert_eq(Meta.settle_unfinished_run(), 30)
	assert_eq(SaveGame.gold(), before + 30)
	SaveGame.forget_loaded()
	assert_true(SaveGame.data()["run_in_progress"].is_empty(), "settled only once")


func test_a_broken_save_falls_back_to_the_backup() -> void:
	SaveGame.add_gold(500)
	SaveGame.add_gold(1)
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string("{ not json")
	file.close()
	SaveGame.forget_loaded()
	assert_eq(SaveGame.gold(), 500, "the backup is one save older")


func test_cloud_merge_combines_unlocks_keeps_higher_levels_and_newest_gold() -> void:
	var a: Dictionary = SaveGame.migrate({"gold": 100, "heroes_unlocked": ["king_arthur"], "gods": {"thor": {"level": 3, "bound_ever": true}},
		"last_modified": {"gold": 10}})
	var b: Dictionary = SaveGame.migrate({"gold": 40, "heroes_unlocked": ["atalanta"], "gods": {"thor": {"level": 5, "bound_ever": true}},
		"last_modified": {"gold": 20}})
	var merged: Dictionary = SaveGame.merge(a, b)
	assert_true(merged["heroes_unlocked"].has("king_arthur") and merged["heroes_unlocked"].has("atalanta"))
	assert_eq(int(merged["gods"]["thor"]["level"]), 5)
	assert_eq(int(merged["gold"]), 40, "gold from the most recently played save")


func test_offerings_raise_a_god_and_strengthen_it() -> void:
	assert_false(GodLevels.offer("thor"), "only gods bound at least once")
	GodLevels.mark_bound("thor")
	SaveGame.add_gold(300)
	assert_true(GodLevels.offer("thor"))
	assert_eq(GodLevels.level("thor"), 2)
	assert_eq(SaveGame.gold(), 225)
	assert_almost_eq(GodLevels.blessing_mult("thor"), 1.1, 0.001)
	assert_true(GodLevels.offer("thor"))
	assert_almost_eq(GodLevels.charge_bonus("thor"), 0.1, 0.001, "level 3: meter 10% faster")
	assert_false(GodLevels.offer("thor"), "250 gold for level 4 is more than 75")


func test_omens_and_swift_mode_change_the_run() -> void:
	SaveGame.add_to("omens_unlocked", "all")
	OmenRules.set_active("haste", true)
	OmenRules.set_active("frailty", true)
	var run: RunState = GameAuthority.start_run("aegean_shore")
	assert_almost_eq(run.enemy_speed_mult, 1.25, 0.001)
	var player: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, "heracles")
	assert_almost_eq(player.max_hp, 150.0 * 0.7, 0.5, "Omen of Frailty")
	var swift := RunState.new(1, run.level_data)
	OmenRules.apply_to_run(swift, PackedStringArray(), true)
	swift.elapsed_s = 7.0 * 60.0
	assert_almost_eq(swift.arc_s(), 600.0, 0.5, "Swift Mode: the 10:00 boss comes at 7:00")


func test_locked_weapons_stay_out_of_level_ups_until_unlocked() -> void:
	GameAuthority.start_run("aegean_shore")
	var player: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, "heracles")
	var ids: Array = LevelUpRules.item_cards(player).map(func(card: Dictionary) -> String: return str(card["id"]))
	assert_false(ids.has("breeze"), "Breeze costs 300 gold")
	assert_false(ids.has("mirrored_shield"), "a secret passive")
	SaveGame.add_to("weapons_unlocked", "breeze")
	ids = LevelUpRules.item_cards(player).map(func(card: Dictionary) -> String: return str(card["id"]))
	assert_true(ids.has("breeze"))


func test_survive_20_unlocks_atalanta() -> void:
	assert_false(HeroRules.is_unlocked(HeroRules.find("atalanta")))
	var lines: PackedStringArray = AchievementRules.check({"arc_s": 1200.0})
	assert_true(HeroRules.is_unlocked(HeroRules.find("atalanta")))
	assert_true(SaveGame.list("omens_unlocked").size() > 0, "Survive 10:00 unlocks the Omens")
	assert_gt(lines.size(), 2)


func test_the_death_recap_shows_a_relevant_tip_and_never_the_same_twice_in_a_row() -> void:
	var medusa: Dictionary = {"killer": "medusa", "killer_type": DeathRecap._enemy("medusa"), "elements": PackedStringArray(["physical"]), "gods": 1, "arc_s": 650.0}
	assert_eq(str(TipRules.pick(medusa)["text"]), str(tr("TIP_MEDUSA")))
	assert_ne(str(TipRules.pick(medusa).get("id", "")), "medusa", "not twice in a row")
	SaveGame.set_setting("last_tip", "")
	var shades: Dictionary = {"killer": "shade_swarm", "killer_type": DeathRecap._enemy("shade_swarm"), "elements": PackedStringArray(["fire"]),
		"gods": 1, "arc_s": 300.0}
	var tip: Dictionary = TipRules.pick(shades)
	assert_eq(tip["id"], "weakness")
	assert_string_contains(str(tip["text"]), str(tr("ELEMENT_HOLY")))
	assert_true(Bestiary.weakness_known("shade_swarm"), "the tip reveals the weakness in the Bestiary")


func test_the_bestiary_reveals_weakness_and_myth_with_kills() -> void:
	for _i: int in Data.cfg_int("bestiary.weakness_kills"):
		Bestiary.count_kill("harpy_swarm")
	assert_true(Bestiary.weakness_known("harpy_swarm"))
	assert_false(Bestiary.myth_known("harpy_swarm"))


func test_beating_the_20_00_boss_records_it_and_the_30_00_boss_unlocks_swift_mode() -> void:
	LevelRules.note_boss("aegean_shore", "achilles", 1)
	assert_true(LevelRules.bosses_defeated("aegean_shore").has("achilles"))
	assert_false(LevelRules.swift_unlocked("aegean_shore"))
	LevelRules.note_boss("aegean_shore", "kronos", 2)
	assert_true(LevelRules.swift_unlocked("aegean_shore"))


func test_the_oracle_gives_a_hint_every_5_runs() -> void:
	for _i: int in Data.cfg_int("meta.oracle_runs_per_hint") - 1:
		assert_eq(SecretRules.count_run(), "")
	var hint: String = SecretRules.count_run()
	assert_ne(hint, "")
	assert_true(SecretRules.hints().has(hint))


func test_records_keep_the_best_time_per_hero_and_level() -> void:
	var run: RunState = GameAuthority.start_run("aegean_shore")
	run.elapsed_s = 500.0
	Records.note(run, "heracles")
	run.elapsed_s = 300.0
	Records.note(run, "heracles")
	assert_almost_eq(Records.best("heracles", "aegean_shore", false), 500.0, 0.1)
	assert_eq(Records.best("heracles", "aegean_shore", true), 0.0, "Swift records are separate")


func test_f1_debug_gold_is_never_banked_into_the_account() -> void:
	var run: RunState = GameAuthority.start_run("aegean_shore")
	var player: Player = GameAuthority.spawn_player(add_child_autofree(Node2D.new()), Vector2.ZERO, null, true, "heracles")
	run.gold = 300.0
	run.debug_gold = 1000.0
	run.gold += run.debug_gold
	assert_eq(TraderScreen.bankable(player), 300.0, "only the gold earned in play counts")
	player.gold_spent = 600.0
	assert_eq(TraderScreen.bankable(player), 300.0, "spending comes out of debug gold first")
	player.gold_spent = 1200.0
	assert_eq(TraderScreen.bankable(player), 100.0, "then out of real gold")
	GameAuthority.end_scene()
