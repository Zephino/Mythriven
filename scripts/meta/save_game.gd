class_name SaveGame
extends RefCounted
## The save file (GAME_DESIGN.md: Death, permanent progression, and saving /
## Save file; Cloud saves). JSON at config save.file with `save_version` 3,
## a `device_id`, a `last_modified` time per section, and a `sync_counter`, so
## cloud sync can be added later without changing the format.
## Persistence rule: anything used outside a level is saved the moment it's
## earned (commit()). Writes go to a temp file that is then renamed, and the
## previous file is kept as a backup.
## Phase 15 replaces the Phase 10–14 profile file: its contents are copied in
## the first time the save is loaded (see migrate_profile()).

## Sections that only ever grow; cloud conflicts combine both sides.
const UNION_LISTS: PackedStringArray = ["heroes_unlocked", "weapons_unlocked", "passives_unlocked", "achievements",
	"secrets", "omens_unlocked", "cosmetics", "words"]

## Tests and other tools point this at a scratch file.
static var path_override: String = ""

static var _data: Dictionary = {}
static var _loaded_from: String = ""
static var _test_file_cleared: bool = false


static func path() -> String:
	if path_override != "":
		return path_override
	# A test run never touches the player's real save.
	if OS.get_cmdline_args().has("res://addons/gut/gut_cmdln.gd") or OS.get_cmdline_args().has("addons/gut/gut_cmdln.gd"):
		return Data.cfg_string("save.test_file")
	return Data.cfg_string("save.file")


## Points the save at `file` (empty = back to normal) and forgets what was loaded.
static func use_test_file(file: String) -> void:
	path_override = file
	if file != "":
		for name: String in [file, file + ".bak", file + ".tmp"]:
			DirAccess.remove_absolute(name)
	_data = {}
	_loaded_from = ""
	Settings.clear_cache()


## Forgets what was loaded, so the next use reads the file again (as when
## the game starts after being closed).
static func forget_loaded() -> void:
	_data = {}
	_loaded_from = ""
	Settings.clear_cache()


## The save data, loaded on first use.
static func data() -> Dictionary:
	if _loaded_from != path():
		# Every test run starts from an empty test save.
		if path() == Data.cfg_string("save.test_file") and not _test_file_cleared:
			_test_file_cleared = true
			for name: String in [path(), path() + ".bak", path() + ".tmp"]:
				DirAccess.remove_absolute(name)
		_data = _read(path())
		if _data.is_empty():
			_data = _read(path() + ".bak")
		if _data.is_empty():
			_data = fresh()
			migrate_profile(_data)
		_data = migrate(_data)
		_loaded_from = path()
	return _data


## A save with nothing earned yet.
static func fresh() -> Dictionary:
	var device := RandomNumberGenerator.new()
	device.randomize()
	return migrate({"save_version": Data.cfg_int("save.save_version"), "device_id": "%08x%08x" % [device.randi(), device.randi()]})


## Fills in any section a save from an older version doesn't have.
static func migrate(save: Dictionary) -> Dictionary:
	var empty: Dictionary = {
		"device_id": "", "sync_counter": 0, "last_modified": {}, "gold": 0, "gods": {}, "bestiary": {}, "codex": {},
		"records": {}, "mastery": {}, "settings": {}, "levels": {}, "stats": {}, "oracle": {}, "run_in_progress": {},
	}
	for list: String in UNION_LISTS:
		empty[list] = []
	for key: String in empty:
		# JSON reads whole numbers back as floats, so any number counts as a number.
		var numbers: bool = save.get(key) is float and empty[key] is int
		if not save.has(key) or (typeof(save[key]) != typeof(empty[key]) and not numbers):
			save[key] = empty[key]
	save["save_version"] = Data.cfg_int("save.save_version")
	return save


## Copies the Phase 10–14 profile file (Codex, Resonances, unlocked Heroes) in.
static func migrate_profile(save: Dictionary) -> void:
	if path() != Data.cfg_string("save.file"):
		return
	var file := ConfigFile.new()
	if file.load(Data.cfg_string("save.profile_file")) != OK:
		return
	for section: String in file.get_sections():
		for key: String in file.get_section_keys(section):
			var value: Variant = file.get_value(section, key)
			if section == "unlocks" and key == "heroes":
				save["heroes_unlocked"] = Array(PackedStringArray(value))
			elif value is PackedStringArray or value is Array:
				if not save.has(section) or not save[section] is Dictionary:
					save[section] = {}
				save[section][key] = Array(PackedStringArray(value))


## Saves now (after something persistent was earned, a run, or a purchase).
static func commit(section: String = "") -> bool:
	var save: Dictionary = data()
	if section != "":
		save["last_modified"][section] = int(Time.get_unix_time_from_system())
	save["sync_counter"] = int(save.get("sync_counter", 0)) + 1
	var target: String = path()
	DirAccess.make_dir_recursive_absolute(target.get_base_dir())
	var temp: String = target + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		push_warning("SaveGame: couldn't write %s (error %d)" % [temp, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(save, "  "))
	file.close()
	if FileAccess.file_exists(target):
		DirAccess.copy_absolute(target, target + ".bak")
	return DirAccess.rename_absolute(temp, target) == OK


# --- Small helpers ----------------------------------------------------------------

static func list(section: String) -> Array:
	var value: Variant = data().get(section, [])
	return value if value is Array else []


## Adds `item` to a growing list and saves at once. Returns true the first time.
static func add_to(section: String, item: String) -> bool:
	var items: Array = list(section)
	if items.has(item):
		return false
	items.append(item)
	data()[section] = items
	commit(section)
	return true


static func gold() -> int:
	return int(data().get("gold", 0))


static func add_gold(amount: int) -> void:
	data()["gold"] = maxi(gold() + amount, 0)
	commit("gold")


## Spends banked gold if there is enough. Saves at once.
static func spend_gold(amount: int) -> bool:
	if amount > gold():
		return false
	add_gold(-amount)
	return true


static func setting(key: String, fallback: Variant = null) -> Variant:
	return (data()["settings"] as Dictionary).get(key, fallback)


static func set_setting(key: String, value: Variant) -> void:
	data()["settings"][key] = value
	commit("settings")


static func stat(key: String) -> float:
	return float((data()["stats"] as Dictionary).get(key, 0.0))


## Adds to a lifetime counter (not saved until the next commit).
static func add_stat(key: String, amount: float) -> void:
	data()["stats"][key] = stat(key) + amount


# --- Cloud merge (GAME_DESIGN.md: Cloud saves / Conflicts) -------------------------

## Combines two saves of the same player: unlocks and discoveries are combined,
## levels, records, mastery, and counts keep the higher value, and gold comes
## from the save played most recently.
static func merge(a: Dictionary, b: Dictionary) -> Dictionary:
	var out: Dictionary = migrate(a.duplicate(true))
	var other: Dictionary = migrate(b.duplicate(true))
	for section: String in UNION_LISTS:
		for item: Variant in other[section]:
			if not (out[section] as Array).has(item):
				out[section].append(item)
	for section: String in ["codex", "gods", "bestiary", "records", "mastery", "levels", "stats", "oracle"]:
		out[section] = _merge_higher(out[section], other[section])
	var newer: bool = _last_played(other) > _last_played(out)
	if newer:
		out["gold"] = other["gold"]
		out["settings"] = other["settings"]
	out["sync_counter"] = maxi(int(out["sync_counter"]), int(other["sync_counter"])) + 1
	return out


static func _last_played(save: Dictionary) -> int:
	var latest: int = 0
	for stamp: Variant in (save.get("last_modified", {}) as Dictionary).values():
		latest = maxi(latest, int(stamp))
	return latest


## Numbers keep the higher value, lists combine, dictionaries merge deeply,
## true beats false.
static func _merge_higher(a: Variant, b: Variant) -> Variant:
	if a is Dictionary and b is Dictionary:
		var out: Dictionary = (a as Dictionary).duplicate(true)
		for key: Variant in b:
			out[key] = _merge_higher(out[key], b[key]) if out.has(key) else b[key]
		return out
	if a is Array and b is Array:
		var out_list: Array = (a as Array).duplicate()
		for item: Variant in b:
			if not out_list.has(item):
				out_list.append(item)
		return out_list
	if (a is float or a is int) and (b is float or b is int):
		return maxf(float(a), float(b))
	if a is bool and b is bool:
		return a or b
	return a


static func _read(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(file_path)) != OK or not json.data is Dictionary:
		push_warning("SaveGame: %s is unreadable; trying the backup" % file_path)
		return {}
	return json.data
