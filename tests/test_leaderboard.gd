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
	if LocalLeaderboard.path_override != "":
		DirAccess.remove_absolute(LocalLeaderboard.path_override)
		LocalLeaderboard.path_override = ""


func _use_scratch_board() -> void:
	LocalLeaderboard.path_override = "user://test_leaderboard_local.json"
	DirAccess.remove_absolute(LocalLeaderboard.path_override)


func _score(player_name: String, time_s: int, level: int, kills: int) -> Dictionary:
	return {"name": player_name, "hero": "heracles", "time_s": time_s, "level": level, "kills": kills, "weapons": [], "passives": []}


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


func test_local_board_keeps_the_best_runs_in_order_and_saves_them() -> void:
	_use_scratch_board()
	assert_true(LocalLeaderboard.load_entries().is_empty())
	assert_true(LocalLeaderboard.add(_score("Ari", 600, 20, 900)))
	assert_true(LocalLeaderboard.add(_score("Bo", 900, 25, 1200)))
	assert_true(LocalLeaderboard.add(_score("Cy", 600, 22, 100)), "same time, higher level ranks higher")
	assert_true(LocalLeaderboard.add(_score("Ari", 600, 20, 900)), "the same run twice")
	var names: Array = LocalLeaderboard.load_entries().map(func(row: Dictionary) -> String: return str(row["name"]))
	assert_eq(names, ["Bo", "Cy", "Ari"], "longest time first, then level; duplicates kept once")


func test_local_board_keeps_only_the_top_rows() -> void:
	_use_scratch_board()
	var keep: int = Data.cfg_int("leaderboard.local_max_entries")
	for i: int in keep:
		LocalLeaderboard.add(_score("P%d" % i, 100 + i, 1, 0))
	assert_false(LocalLeaderboard.add(_score("Slow", 50, 1, 0)), "too short for a full board")
	assert_true(LocalLeaderboard.add(_score("Fast", 5000, 1, 0)))
	var rows: Array[Dictionary] = LocalLeaderboard.load_entries()
	assert_eq(rows.size(), keep)
	assert_eq(str(rows[0]["name"]), "Fast")


func test_until_online_scores_are_set_up_scores_go_to_this_device() -> void:
	if not LeaderboardClient.is_local():
		pass_test("online scores are set up")
		return
	_use_scratch_board()
	var client := LeaderboardClient.new()
	add_child_autofree(client)
	watch_signals(client)
	client.send(_score("Ari", 700, 21, 800))
	await wait_for_signal(client.score_sent, 1.0)
	assert_signal_emitted_with_parameters(client, "score_sent", [true, ""])
	client.fetch()
	await wait_for_signal(client.board_loaded, 1.0)
	var params: Array = get_signal_parameters(client, "board_loaded")
	assert_eq((params[0] as Array).size(), 1)
	assert_eq(params[1], "")
