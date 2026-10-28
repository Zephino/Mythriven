extends GutTest
## Phase 1: the JSON loader reports clear errors naming the file and field.

const FIXTURES := "res://tests/fixtures/"
const SCHEMA: Dictionary = {
	"type": "object",
	"fields": {
		"speed": "number",
		"name_key": "string",
		"limits": {"type": "object", "fields": {"max_count": "int"}},
		"tags": {"type": "array", "items": "string", "optional": true},
	},
}


func _errors_with_code(errors: Array[Dictionary], code: String) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for err: Dictionary in errors:
		if err["code"] == code:
			found.append(err)
	return found


func test_valid_data_has_no_errors() -> void:
	var data: Dictionary = {"speed": 2, "name_key": "KEY", "limits": {"max_count": 3}}
	assert_eq(JsonValidator.validate(data, SCHEMA, "valid.json").size(), 0)


func test_missing_field_names_file_and_field() -> void:
	var data: Dictionary = {"speed": 2, "name_key": "KEY", "limits": {}}
	var errors: Array[Dictionary] = JsonValidator.validate(data, SCHEMA, "missing.json")
	assert_eq(errors.size(), 1)
	assert_eq(errors[0]["code"], JsonValidator.CODE_MISSING_FIELD)
	assert_eq(errors[0]["file"], "missing.json")
	assert_eq(errors[0]["field"], "limits.max_count")
	assert_string_contains(JsonValidator.describe(errors[0]), "missing.json")
	assert_string_contains(JsonValidator.describe(errors[0]), "limits.max_count")


func test_wrong_type_names_file_field_and_types() -> void:
	var data: Dictionary = {"speed": "fast", "name_key": "KEY", "limits": {"max_count": 3}}
	var errors: Array[Dictionary] = JsonValidator.validate(data, SCHEMA, "typed.json")
	assert_eq(errors.size(), 1)
	assert_eq(errors[0]["code"], JsonValidator.CODE_WRONG_TYPE)
	assert_eq(errors[0]["field"], "speed")
	assert_eq(errors[0]["expected"], "number")
	assert_eq(errors[0]["got"], "string")


func test_int_rejects_fractions_but_accepts_whole_floats() -> void:
	var whole: Dictionary = {"speed": 1, "name_key": "K", "limits": {"max_count": 4.0}}
	var fraction: Dictionary = {"speed": 1, "name_key": "K", "limits": {"max_count": 4.5}}
	assert_eq(JsonValidator.validate(whole, SCHEMA, "a.json").size(), 0)
	assert_eq(_errors_with_code(JsonValidator.validate(fraction, SCHEMA, "b.json"), JsonValidator.CODE_WRONG_TYPE).size(), 1)


func test_array_items_are_checked_with_index() -> void:
	var data: Dictionary = {"speed": 1, "name_key": "K", "limits": {"max_count": 1}, "tags": ["ok", 5]}
	var errors: Array[Dictionary] = JsonValidator.validate(data, SCHEMA, "arr.json")
	assert_eq(errors.size(), 1)
	assert_eq(errors[0]["field"], "tags[1]")


func test_unknown_field_is_a_warning_not_a_blocking_error() -> void:
	var data: Dictionary = {"speed": 1, "name_key": "K", "limits": {"max_count": 1}, "sped": 3, "_note": "ignored"}
	var errors: Array[Dictionary] = JsonValidator.validate(data, SCHEMA, "extra.json")
	assert_eq(errors.size(), 1)
	assert_eq(errors[0]["field"], "sped")
	assert_false(JsonValidator.is_blocking(errors[0]))


func test_bad_json_reports_file_and_line() -> void:
	var path: String = "user://test_bad_json.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{\n  \"speed\": 1,\n  oops\n}")
	file.close()
	var result: Dictionary = JsonValidator.load_file(path, "bad.json")
	DirAccess.remove_absolute(path)
	assert_eq(result["errors"][0]["code"], JsonValidator.CODE_PARSE)
	assert_eq(result["errors"][0]["file"], "bad.json")
	# The bad token is on the third line (Godot may count lines from 0 or 1).
	assert_true(int(result["errors"][0]["line"]) in [2, 3])


func test_missing_file_is_reported() -> void:
	var missing: Dictionary = JsonValidator.load_file(FIXTURES + "does_not_exist.json", "does_not_exist.json")
	assert_eq(missing["errors"][0]["code"], JsonValidator.CODE_FILE_MISSING)
	assert_eq(missing["errors"][0]["file"], "does_not_exist.json")


func test_broken_fixture_reports_each_broken_field() -> void:
	var result: Dictionary = DataLoader.load_set(FIXTURES, "fixture_schemas.json", false)
	var fields: Array[String] = []
	for err: Dictionary in result["errors"]:
		assert_eq(err["file"], "broken_example.json", "only the broken fixture should fail")
		fields.append(str(err["field"]))
	assert_has(fields, "speed")
	assert_has(fields, "limits.max_count")
	assert_false((result["files"] as Dictionary).has("broken_example.json"), "a broken file is not loaded")
	assert_true((result["files"] as Dictionary).has("example.json"))
