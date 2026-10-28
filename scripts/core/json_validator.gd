class_name JsonValidator
extends RefCounted
## Checks parsed JSON against a schema from data/schemas.json.
## Every problem is returned as a Dictionary naming the file and the field
## path (for example "performance.enemy_cap"), so errors are easy to find.
##
## A field spec is either a type name ("number", "int", "string", "bool",
## "any", "object", "array") or a Dictionary:
##   {"type": "object", "fields": {name: spec, ...}, "optional": bool, "open": bool}
## "open" objects may have extra keys besides the listed fields.
##   {"type": "array", "items": spec, "optional": bool}
## Keys starting with "_" are notes and are never checked.

const CODE_PARSE := "parse"
const CODE_FILE_MISSING := "file_missing"
const CODE_MISSING_FIELD := "missing_field"
const CODE_WRONG_TYPE := "wrong_type"
const CODE_UNKNOWN_FIELD := "unknown_field"
const CODE_BAD_SCHEMA := "bad_schema"


## Reads and parses a JSON file. Returns {"data": Variant, "errors": Array}.
static func load_file(path: String, file_label: String) -> Dictionary:
	var errors: Array[Dictionary] = []
	if not FileAccess.file_exists(path):
		errors.append(make_error(CODE_FILE_MISSING, file_label, ""))
		return {"data": null, "errors": errors}
	var text: String = FileAccess.get_file_as_string(path)
	var json := JSON.new()
	if json.parse(text) != OK:
		var err: Dictionary = make_error(CODE_PARSE, file_label, "")
		err["line"] = json.get_error_line()
		err["detail"] = json.get_error_message()
		errors.append(err)
		return {"data": null, "errors": errors}
	return {"data": json.data, "errors": errors}


## Validates data against a spec. Returns errors and warnings (unknown fields).
static func validate(data: Variant, spec: Variant, file_label: String) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	_check(data, spec, file_label, "", errors)
	return errors


## True when an error should block loading (unknown fields are only warnings).
static func is_blocking(err: Dictionary) -> bool:
	return err.get("code", "") != CODE_UNKNOWN_FIELD


static func make_error(code: String, file_label: String, field: String) -> Dictionary:
	return {"code": code, "file": file_label, "field": field}


## Turns an error into a translated, readable sentence.
static func describe(err: Dictionary) -> String:
	var file_label: String = err.get("file", "")
	var field: String = err.get("field", "")
	match err.get("code", ""):
		CODE_PARSE:
			return _tr("DATA_ERROR_PARSE") % [file_label, int(err.get("line", 0)), str(err.get("detail", ""))]
		CODE_FILE_MISSING:
			return _tr("DATA_ERROR_FILE_MISSING") % file_label
		CODE_MISSING_FIELD:
			return _tr("DATA_ERROR_MISSING_FIELD") % [file_label, field]
		CODE_WRONG_TYPE:
			return _tr("DATA_ERROR_WRONG_TYPE") % [file_label, field, str(err.get("expected", "")), str(err.get("got", ""))]
		CODE_UNKNOWN_FIELD:
			return _tr("DATA_WARN_UNKNOWN_FIELD") % [file_label, field]
		_:
			return _tr("DATA_ERROR_BAD_SCHEMA") % [file_label, field]


static func _tr(key: String) -> String:
	return TranslationServer.translate(key)


static func _spec_type(spec: Variant) -> String:
	if spec is String:
		return spec
	if spec is Dictionary:
		return str((spec as Dictionary).get("type", ""))
	return ""


static func _check(value: Variant, spec: Variant, file_label: String, path: String, errors: Array[Dictionary]) -> void:
	var expected: String = _spec_type(spec)
	if expected == "":
		errors.append(make_error(CODE_BAD_SCHEMA, file_label, path))
		return
	if not _type_matches(value, expected):
		var err: Dictionary = make_error(CODE_WRONG_TYPE, file_label, path)
		err["expected"] = expected
		err["got"] = _type_name(value)
		errors.append(err)
		return
	if not (spec is Dictionary):
		return
	var spec_dict: Dictionary = spec
	if expected == "object" and spec_dict.has("fields"):
		_check_object(value, spec_dict["fields"], file_label, path, errors, bool(spec_dict.get("open", false)))
	elif expected == "array" and spec_dict.has("items"):
		var items: Array = value
		for i: int in items.size():
			_check(items[i], spec_dict["items"], file_label, "%s[%d]" % [path, i], errors)


static func _check_object(value: Dictionary, fields: Dictionary, file_label: String, path: String,
		errors: Array[Dictionary], open: bool = false) -> void:
	for field_name: String in fields:
		if field_name.begins_with("_"):
			continue
		var field_spec: Variant = fields[field_name]
		var field_path: String = _join(path, field_name)
		if not value.has(field_name):
			var optional: bool = field_spec is Dictionary and bool((field_spec as Dictionary).get("optional", false))
			if not optional:
				errors.append(make_error(CODE_MISSING_FIELD, file_label, field_path))
			continue
		_check(value[field_name], field_spec, file_label, field_path, errors)
	if open:
		return
	for key: Variant in value:
		var key_name: String = str(key)
		if not key_name.begins_with("_") and not fields.has(key_name):
			errors.append(make_error(CODE_UNKNOWN_FIELD, file_label, _join(path, key_name)))


static func _join(path: String, field_name: String) -> String:
	return field_name if path == "" else "%s.%s" % [path, field_name]


static func _type_matches(value: Variant, expected: String) -> bool:
	match expected:
		"any":
			return true
		"number":
			return value is float or value is int
		"int":
			return (value is int) or (value is float and is_equal_approx(value, roundf(value)))
		"string":
			return value is String
		"bool":
			return value is bool
		"object":
			return value is Dictionary
		"array":
			return value is Array
	return false


static func _type_name(value: Variant) -> String:
	match typeof(value):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "bool"
		TYPE_INT, TYPE_FLOAT:
			return "number"
		TYPE_STRING:
			return "string"
		TYPE_DICTIONARY:
			return "object"
		TYPE_ARRAY:
			return "array"
	return type_string(typeof(value))
