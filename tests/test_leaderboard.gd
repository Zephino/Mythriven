extends GutTest
## Shared leaderboard (owner request): the score the game sends, name rules,
## and runs that used debug options staying off the board. The Worker's own
## checks are tested in leaderboard-api/test (npm test).

var _parent: Node2D
var _player: Player


func before_each() -> void:
	GameAuthority.start_run("aegean_shore")
	_parent = add_child_autofree(Node2D.new())
	_player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, "heracles")
	_player.kit.set_process(false)


func after_each() -> void:
	GameAuthority.end_scene()


func test_names_keep_only_safe_characters_and_are_cut_to_12() -> void:
	assert_eq(LeaderboardEntry.clean_name("  Zeph  ino!!  "), "Zeph ino")
	assert_eq(LeaderboardEntry.clean_name("ABCDEFGHIJKLMNOP"), "ABCDEFGHIJKL")
	assert_eq(LeaderboardEntry.clean_name("<script>"), "script")
	assert_eq(LeaderboardEntry.clean_name("!!!"), "")


func test_score_lists_hero_weapons_and_upgrades() -> void:
	GameAuthority.give_weapon(_player, "longbow")
	var passive_id: String = str(Data.get_file("passives.json")[0]["id"])
	_player.passives[passive_id] = 2
	var run: RunState = GameAuthority.run
	run.elapsed_s = 125.7
	run.level = 6
	run.kills = 40
	var entry: Dictionary = LeaderboardEntry.build(run, _player, " Ari! ")
	assert_eq(entry["name"], "Ari")
	assert_eq(entry["hero"], "heracles")
	assert_eq(entry["time_s"], 125)
	assert_eq(entry["level"], 6)
	assert_eq(entry["kills"], 40)
	assert_eq(entry["weapons"], [{"id": "longbow", "level": 1}])
	assert_eq(entry["passives"], [{"id": passive_id, "level": 2}])
	assert_eq(entry["version"], str(ProjectSettings.get_setting("application/config/version")))
	var text: String = LeaderboardEntry.describe(1, entry)
	assert_string_contains(text, "Ari")
	assert_string_contains(text, str(TranslationServer.translate(str(HeroRules.find("heracles")["name_key"]))))


func test_runs_that_used_debug_options_are_not_sent() -> void:
	var run: RunState = GameAuthority.run
	run.elapsed_s = 60.0
	assert_true(LeaderboardEntry.can_submit(run))
	run.debug_used = true
	assert_false(LeaderboardEntry.can_submit(run))


func test_board_rows_are_read_from_the_reply() -> void:
	var rows: Array[Dictionary] = LeaderboardClient.parse_entries('{"entries": [{"name": "A"}, 5, {"name": "B"}]}')
	assert_eq(rows.size(), 2)
	assert_eq(LeaderboardClient.parse_entries("not json").size(), 0)
	assert_eq(LeaderboardClient.parse_entries('{"entries": "x"}').size(), 0)


func test_unknown_ids_still_show() -> void:
	var text: String = LeaderboardEntry.describe(3, {"name": "Z", "hero": "someone_new", "time_s": 61, "level": 2, "kills": 1,
			"weapons": [{"id": "future_weapon", "level": 4}], "passives": []})
	assert_string_contains(text, "someone_new")
	assert_string_contains(text, "future_weapon")
