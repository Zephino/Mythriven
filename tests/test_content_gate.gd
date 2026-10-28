extends GutTest
## Phase 1: release builds refuse entries that aren't care_tier "A" with
## lore_verified true; dev builds load them with a warning.

const FIXTURES := "res://tests/fixtures/"
const GATE_FILE := "gate_entries.json"


func _gate(release: bool) -> Dictionary:
	var result: Dictionary = DataLoader.load_set(FIXTURES, "fixture_schemas.json", release)
	return result["gates"][GATE_FILE]


func _ids(entries: Array) -> Array[String]:
	var ids: Array[String] = []
	for entry: Dictionary in entries:
		ids.append(str(entry["id"]))
	return ids


func test_release_refuses_tier_b_and_unverified() -> void:
	var gate: Dictionary = _gate(true)
	assert_eq(_ids(gate["kept"]), ["test_tier_a_verified"] as Array[String])
	assert_eq(_ids(gate["refused"]), ["test_tier_a_unverified", "test_tier_b"] as Array[String])
	assert_eq((gate["warnings"] as Array).size(), 0)


func test_dev_keeps_everything_with_warnings() -> void:
	var gate: Dictionary = _gate(false)
	assert_eq((gate["kept"] as Array).size(), 3)
	assert_eq((gate["refused"] as Array).size(), 0)
	assert_eq(_ids(gate["warnings"]), ["test_tier_a_unverified", "test_tier_b"] as Array[String])


func test_missing_or_wrongly_typed_gate_fields_never_pass() -> void:
	assert_false(ContentGate.passes({"id": "x"}))
	assert_false(ContentGate.passes({"id": "x", "care_tier": "A", "lore_verified": "true"}))
	assert_false(ContentGate.passes({"id": "x", "care_tier": "a", "lore_verified": true}))
	assert_true(ContentGate.passes({"id": "x", "care_tier": "A", "lore_verified": true}))


func test_refusal_message_names_file_and_entry() -> void:
	var gate: Dictionary = _gate(true)
	var message: String = ContentGate.describe(gate["refused"][1], true)
	assert_string_contains(message, GATE_FILE)
	assert_string_contains(message, "test_tier_b")
