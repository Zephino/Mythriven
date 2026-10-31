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
## Set when something lasting is saved (not the mid-run checkpoint), so cloud
## sync knows there is something new to upload.
static var _cloud_change: bool = false


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
		"profile": {}, "reset_at": 0,
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
	if section != "run_in_progress":
		_cloud_change = true
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


## True (once) if something lasting was saved since the last call.
static func take_cloud_change() -> bool:
	var changed: bool = _cloud_change
	_cloud_change = false
	return changed


## True when a save holds anything earned (gold, a run played, an unlock, a record...).
static func has_progress(save: Dictionary) -> bool:
	if int(save.get("gold", 0)) > 0 or float((save.get("stats", {}) as Dictionary).get("runs", 0.0)) > 0.0:
		return true
	for section: String in UNION_LISTS:
		if not (save.get(section, []) as Array).is_empty():
			return true
	for section: String in ["gods", "bestiary", "codex", "records", "mastery", "levels"]:
		if not (save.get(section, {}) as Dictionary).is_empty():
			return true
	return false


## A save with nothing earned that keeps this device's id, settings and username.
static func blank() -> Dictionary:
	var old: Dictionary = data()
	var out: Dictionary = fresh()
	out["device_id"] = old["device_id"]
	out["settings"] = (old["settings"] as Dictionary).duplicate(true)
	out["profile"] = (old["profile"] as Dictionary).duplicate(true)
	for section: String in ["settings", "profile"]:
		if (old["last_modified"] as Dictionary).has(section):
			out["last_modified"][section] = old["last_modified"][section]
	return out


## Starts over from nothing (owner request 10/31/2026): every bit of progress goes (gold, unlocks, gods' levels,
## records, achievements, collections); settings and the username stay. Marked with the time, so cloud sync takes
## this save over the account's older one on every device (merge).
static func start_over() -> void:
	var out: Dictionary = blank()
	out["reset_at"] = int(Time.get_unix_time_from_system())
	_data = migrate(out)
	_loaded_from = path()
	Settings.clear_cache()
	commit("reset")


## Keeps a copy of this device's save aside (before it switches to an account's), never overwritten after.
static func put_aside(file_name: String) -> void:
	if not FileAccess.file_exists(file_name):
		var file := FileAccess.open(file_name, FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(data(), "  "))


## Replaces the whole save (with one merged with the cloud copy) and saves it,
## without counting that as a new change to upload.
static func replace(save: Dictionary) -> void:
	_data = migrate(save)
	_loaded_from = path()
	Settings.clear_cache()
	commit()
	_cloud_change = false


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


## The username the player chose (shown instead of their real name; owner
## request 10/31/2026). Kept in the save, so it follows them through cloud saves.
static func player_name() -> String:
	return str((data()["profile"] as Dictionary).get("name", ""))


static func set_player_name(new_name: String) -> void:
	data()["profile"]["name"] = new_name
	commit("profile")


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
	# Starting over (owner request 10/31/2026): the save reset more recently wins whole, so old progress on another
	# device never comes back into an account that was reset.
	if int(other["reset_at"]) > int(out["reset_at"]):
		other["device_id"] = out["device_id"]
		return other
	if int(out["reset_at"]) > int(other["reset_at"]):
		return out
	for section: String in UNION_LISTS:
		for item: Variant in other[section]:
			if not (out[section] as Array).has(item):
				out[section].append(item)
	for section: String in ["codex", "gods", "bestiary", "records", "mastery", "levels", "stats", "oracle"]:
		out[section] = _merge_higher(out[section], other[section])
	if _last_played(other) > _last_played(out):
		out["gold"] = other["gold"]
	# Settings and the username come from whichever device changed them last.
	for section: String in ["settings", "profile"]:
		if _changed_at(other, section) > _changed_at(out, section):
			out[section] = other[section]
	# Each section's time becomes the later of the two, so a third device compares fairly.
	var stamps: Dictionary = out["last_modified"]
	for section: Variant in other["last_modified"]:
		stamps[section] = maxi(int(stamps.get(section, 0)), int(other["last_modified"][section]))
	out["sync_counter"] = maxi(int(out["sync_counter"]), int(other["sync_counter"])) + 1
	return out


## When `section` last changed on that save (its own time, else the save's latest).
static func _changed_at(save: Dictionary, section: String) -> int:
	var stamp: int = int((save.get("last_modified", {}) as Dictionary).get(section, 0))
	return stamp if stamp > 0 else _last_played(save)


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
