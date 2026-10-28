class_name Profile
extends RefCounted
## Small things kept between runs until the full save system arrives in
## Phase 15 (then they move into the save file): discovered Codex recipes,
## discovered Resonances, Heroes unlocked by defeating them, and the
## leaderboard name. Stored in a ConfigFile at config save.profile_file.


## Tests point this at a scratch file so they never touch the player's real profile.
static var path_override: String = ""


static func get_value(section: String, key: String, fallback: Variant = null) -> Variant:
	var file := ConfigFile.new()
	if file.load(_path()) != OK:
		return fallback
	return file.get_value(section, key, fallback)


static func set_value(section: String, key: String, value: Variant) -> void:
	var file := ConfigFile.new()
	file.load(_path())
	file.set_value(section, key, value)
	var err: Error = file.save(_path())
	if err != OK:
		push_warning("Profile: couldn't save %s (error %d)" % [_path(), err])


static func get_list(section: String, key: String) -> PackedStringArray:
	var value: Variant = get_value(section, key, PackedStringArray())
	if value is PackedStringArray:
		return value
	if value is Array:
		return PackedStringArray(value)
	return PackedStringArray()


## Adds `item` to a saved list. Returns true if it wasn't there before.
static func add_to_list(section: String, key: String, item: String) -> bool:
	var list: PackedStringArray = get_list(section, key)
	if list.has(item):
		return false
	list.append(item)
	set_value(section, key, list)
	return true


static func _path() -> String:
	return path_override if path_override != "" else Data.cfg_string("save.profile_file")
