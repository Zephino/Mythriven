class_name Records
extends RefCounted
## Best times (GAME_DESIGN.md: Death and scoring / Records): per Hero, per
## Hero on each level, per Omen set, and overall. Swift Mode records are kept
## separately. Score = time survived. Kept in the save's "records" section.


static func key(kind: String, id: String, swift: bool) -> String:
	return ("swift:" if swift else "") + kind + (":" + id if id != "" else "")


static func get_best(record_key: String) -> float:
	return float((SaveGame.data()["records"] as Dictionary).get(record_key, 0.0))


## The personal best for a Hero on a level (the HUD's marker and the recap).
static func best(hero_id: String, level_id: String, swift: bool) -> float:
	return get_best(key("hero_level", hero_id + "@" + level_id, swift))


## Updates every record the run beat (saved with the run).
static func note(run: RunState, hero_id: String) -> void:
	var records: Dictionary = SaveGame.data()["records"]
	var level_id: String = str(run.level_data.get("id", ""))
	var keys: PackedStringArray = [key("overall", "", run.swift), key("hero", hero_id, run.swift),
		key("hero_level", hero_id + "@" + level_id, run.swift)]
	if not run.omens.is_empty():
		keys.append(key("omens", OmenRules.set_key(run.omens), run.swift))
	for record_key: String in keys:
		if run.elapsed_s > get_best(record_key):
			records[record_key] = snappedf(run.elapsed_s, 0.1)
