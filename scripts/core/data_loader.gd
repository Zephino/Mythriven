class_name DataLoader
extends Node
## Autoload "Data". Loads every file listed in res://data/schemas.json at
## startup, checks it against its schema, and runs gated files through the
## release content gate. Problems are printed to Godot's Output panel and
## kept in `errors` / `warnings` so screens can show them.

signal reloaded

const DATA_DIR := "res://data/"
const SCHEMA_FILE := "schemas.json"
const CONFIG_FILE := "config.json"

## Problems that stop a file from loading (missing field, wrong type, bad JSON).
var errors: Array[Dictionary] = []
## Problems that don't stop loading (unknown fields).
var warnings: Array[Dictionary] = []
## Content gate result per gated file: {"kept", "refused", "warnings"}.
var gate_results: Dictionary = {}
## Debug-menu switch: treat this dev build as a release build for the content gate.
var simulate_release: bool = false

var _files: Dictionary = {}


func _ready() -> void:
	reload()


## True in exported release builds, or when the debug menu pretends to be one.
func is_release() -> bool:
	return simulate_release or not OS.is_debug_build()


## Loads (or reloads) everything in res://data/.
func reload() -> void:
	var result: Dictionary = load_set(DATA_DIR, SCHEMA_FILE, is_release())
	_files = result["files"]
	errors = result["errors"]
	warnings = result["warnings"]
	gate_results = result["gates"]
	log_result(result)
	reloaded.emit()


## Parsed contents of a data file (after the content gate), or null.
func get_file(file_name: String) -> Variant:
	return _files.get(file_name)


## Reads a config.json value by dotted path, e.g. cfg("performance.enemy_cap").
func cfg(path: String) -> Variant:
	var node: Variant = _files.get(CONFIG_FILE)
	for part: String in path.split("."):
		if node is Dictionary and (node as Dictionary).has(part):
			node = (node as Dictionary)[part]
		else:
			push_error("Data: %s has no field '%s'" % [CONFIG_FILE, path])
			return null
	return node


func cfg_float(path: String) -> float:
	var value: Variant = cfg(path)
	return float(value) if (value is float or value is int) else 0.0


func cfg_int(path: String) -> int:
	var value: Variant = cfg(path)
	return int(value) if (value is float or value is int) else 0


func cfg_bool(path: String) -> bool:
	var value: Variant = cfg(path)
	return value if value is bool else false


func cfg_string(path: String) -> String:
	var value: Variant = cfg(path)
	return value if value is String else ""


## Loads every file a schema file lists from `dir`. Used for res://data/ and
## for the test fixtures in res://tests/fixtures/.
## Returns {"files", "errors", "warnings", "gates"}.
static func load_set(dir: String, schema_file: String, release: bool) -> Dictionary:
	var errs: Array[Dictionary] = []
	var warns: Array[Dictionary] = []
	var out: Dictionary = {"files": {}, "errors": errs, "warnings": warns, "gates": {}}
	var schema_result: Dictionary = JsonValidator.load_file(dir + schema_file, schema_file)
	errs.append_array(schema_result["errors"])
	var schemas: Variant = schema_result["data"]
	if not (schemas is Dictionary and (schemas as Dictionary).get("files") is Dictionary):
		if errs.is_empty():
			errs.append(JsonValidator.make_error(JsonValidator.CODE_MISSING_FIELD, schema_file, "files"))
		return out
	var listed: Dictionary = (schemas as Dictionary)["files"]
	for file_name: String in listed:
		if not file_name.begins_with("_"):
			_load_one(dir, file_name, listed[file_name], release, out)
	return out


static func _load_one(dir: String, file_name: String, entry: Variant, release: bool, out: Dictionary) -> void:
	var errs: Array[Dictionary] = out["errors"]
	var warns: Array[Dictionary] = out["warnings"]
	var info: Dictionary = entry if entry is Dictionary else {}
	var loaded: Dictionary = JsonValidator.load_file(dir + file_name, file_name)
	errs.append_array(loaded["errors"])
	if loaded["data"] == null:
		return
	var blocked: bool = false
	for problem: Dictionary in JsonValidator.validate(loaded["data"], info.get("schema", "any"), file_name):
		if JsonValidator.is_blocking(problem):
			errs.append(problem)
			blocked = true
		else:
			warns.append(problem)
	if blocked:
		return
	var data: Variant = loaded["data"]
	if bool(info.get("gated", false)) and data is Array:
		var gate: Dictionary = ContentGate.filter(data, file_name, release)
		(out["gates"] as Dictionary)[file_name] = gate
		data = gate["kept"]
	(out["files"] as Dictionary)[file_name] = data


## Prints a load result to the Output panel: errors in red, warnings in yellow.
static func log_result(result: Dictionary) -> void:
	for err: Dictionary in result["errors"]:
		push_error(JsonValidator.describe(err))
	for warn: Dictionary in result["warnings"]:
		push_warning(JsonValidator.describe(warn))
	var gates: Dictionary = result["gates"]
	for file_name: String in gates:
		var gate: Dictionary = gates[file_name]
		for report: Dictionary in gate["refused"]:
			push_warning(ContentGate.describe(report, true))
		for report: Dictionary in gate["warnings"]:
			push_warning(ContentGate.describe(report, false))
