class_name LevelRules
extends RefCounted
## Levels and their unlock flow (GAME_DESIGN.md: Regional levels / Unlock
## flow; Swift Mode). The first level of Act I is open at the start; beating
## a level's 20:00 boss unlocks the other levels of its Act, which can then be
## played in any order; beating its 30:00
## boss unlocks Swift Mode for that level. Progress is in the save's "levels"
## section: level id -> {"unlocked", "bosses" (ids defeated), "swift"}.


## Levels in Act and play order.
static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(GameAuthority.LEVELS_FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	found.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("act", 1)) * 100 + int(a.get("order", 1)) < int(b.get("act", 1)) * 100 + int(b.get("order", 1)))
	return found


static func progress(level_id: String) -> Dictionary:
	var entry: Variant = (SaveGame.data()["levels"] as Dictionary).get(level_id, {})
	return entry if entry is Dictionary else {}


static func is_unlocked(level: Dictionary) -> bool:
	return (int(level.get("act", 1)) == 1 and int(level.get("order", 1)) == 1) or bool(progress(str(level.get("id", ""))).get("unlocked", false))


static func swift_unlocked(level_id: String) -> bool:
	return bool(progress(level_id).get("swift", false))


static func bosses_defeated(level_id: String) -> PackedStringArray:
	return PackedStringArray(progress(level_id).get("bosses", []))


## Records a boss defeat (index 0/1/2 = the 10/20/30-minute boss) and unlocks
## what it opens. Saved at once. Returns results-screen lines for anything new.
static func note_boss(level_id: String, boss_id: String, index: int) -> PackedStringArray:
	var lines: PackedStringArray = []
	var levels: Dictionary = SaveGame.data()["levels"]
	var entry: Dictionary = progress(level_id).duplicate()
	var bosses: Array = entry.get("bosses", [])
	if not bosses.has(boss_id):
		bosses.append(boss_id)
	entry["bosses"] = bosses
	entry["unlocked"] = true
	if index == 2 and not bool(entry.get("swift", false)):
		entry["swift"] = true
		lines.append(TranslationServer.translate("UNLOCK_SWIFT"))
	levels[level_id] = entry
	if index == 1:
		for other: Dictionary in _act_of(level_id):
			if not is_unlocked(other):
				var other_entry: Dictionary = progress(str(other["id"])).duplicate()
				other_entry["unlocked"] = true
				levels[str(other["id"])] = other_entry
				lines.append(TranslationServer.translate("UNLOCK_LEVEL") % TranslationServer.translate(str(other.get("name_key", ""))))
	SaveGame.commit("levels")
	return lines


## The other levels in the same Act as `level_id`.
static func _act_of(level_id: String) -> Array[Dictionary]:
	var act: int = 0
	for level: Dictionary in all():
		if str(level.get("id", "")) == level_id:
			act = int(level.get("act", 1))
	var found: Array[Dictionary] = []
	for level: Dictionary in all():
		if int(level.get("act", 1)) == act and str(level.get("id", "")) != level_id:
			found.append(level)
	return found
