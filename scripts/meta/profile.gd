class_name Profile
extends RefCounted
## Lists kept between runs by the Phase 10–14 systems (discovered Codex
## recipes, infusions, and Resonances). Since Phase 15 they live in the save
## file (SaveGame) under `section` → `key`, and are saved the moment they change.


static func get_value(section: String, key: String, fallback: Variant = null) -> Variant:
	var part: Variant = SaveGame.data().get(section)
	return (part as Dictionary).get(key, fallback) if part is Dictionary else fallback


static func set_value(section: String, key: String, value: Variant) -> void:
	var save: Dictionary = SaveGame.data()
	if not save.get(section) is Dictionary:
		save[section] = {}
	save[section][key] = value
	SaveGame.commit(section)


static func get_list(section: String, key: String) -> PackedStringArray:
	var value: Variant = get_value(section, key, [])
	return PackedStringArray(value) if value is Array or value is PackedStringArray else PackedStringArray()


## Adds `item` to a saved list. Returns true if it wasn't there before.
static func add_to_list(section: String, key: String, item: String) -> bool:
	var items: PackedStringArray = get_list(section, key)
	if items.has(item):
		return false
	items.append(item)
	set_value(section, key, Array(items))
	return true
