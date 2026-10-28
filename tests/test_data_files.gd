extends GutTest
## Phase 1: the real game data loads cleanly, and the version matches everywhere.


func test_game_data_has_no_errors_or_warnings() -> void:
	var result: Dictionary = DataLoader.load_set(DataLoader.DATA_DIR, DataLoader.SCHEMA_FILE, true)
	var messages: PackedStringArray = []
	for err: Dictionary in result["errors"] + result["warnings"]:
		messages.append(JsonValidator.describe(err))
	assert_eq(messages.size(), 0, "\n".join(messages))
	assert_true((result["files"] as Dictionary).has(DataLoader.CONFIG_FILE))


func test_version_file_matches_project_settings() -> void:
	var file_version: String = FileAccess.get_file_as_string("res://VERSION").strip_edges()
	assert_eq(file_version, str(ProjectSettings.get_setting("application/config/version")))
	var parts: PackedStringArray = file_version.split(".")
	assert_eq(parts.size(), 3, "version must look like XX.XX.XX")
	for part: String in parts:
		assert_eq(part.length(), 2)
		assert_true(part.is_valid_int())


func test_changelog_matches_version() -> void:
	var file_version: String = FileAccess.get_file_as_string("res://VERSION").strip_edges()
	var changelog: String = FileAccess.get_file_as_string("res://CHANGELOG.md")
	var marker: String = "## Version "
	var start: int = changelog.find(marker)
	assert_ne(start, -1, "CHANGELOG.md has at least one entry")
	var newest: String = changelog.substr(start + marker.length(), file_version.length())
	assert_eq(newest, file_version, "the newest changelog entry matches VERSION")


func test_translation_keys_are_unique() -> void:
	var seen: Dictionary = {}
	var file := FileAccess.open("res://localization/text.csv", FileAccess.READ)
	assert_not_null(file)
	var _header: PackedStringArray = file.get_csv_line()
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 2 or row[0] == "":
			continue
		assert_false(seen.has(row[0]), "duplicate key %s" % row[0])
		seen[row[0]] = true
