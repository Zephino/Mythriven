class_name Bestiary
extends RefCounted
## The Bestiary (GAME_DESIGN.md: Collections): each creature gets an entry on
## its first kill; its weakness and resistance are revealed after 25 kills (or
## by a death-recap tip), and its myth summary (with source) after 100. Kills
## are counted in the save's "bestiary" section: enemy id -> {"kills", "revealed"}.
## A new entry or threshold is saved at once; plain counts are saved with the run.


static func entry(enemy_id: String) -> Dictionary:
	var found: Variant = (SaveGame.data()["bestiary"] as Dictionary).get(enemy_id, {})
	return found if found is Dictionary else {}


static func kills(enemy_id: String) -> int:
	return int(entry(enemy_id).get("kills", 0))


static func weakness_known(enemy_id: String) -> bool:
	return kills(enemy_id) >= Data.cfg_int("bestiary.weakness_kills") or bool(entry(enemy_id).get("revealed", false))


static func myth_known(enemy_id: String) -> bool:
	return kills(enemy_id) >= Data.cfg_int("bestiary.myth_kills")


## Counts a kill. Saves at once when it creates the entry or crosses a threshold.
static func count_kill(enemy_id: String) -> void:
	if enemy_id == "":
		return
	var bestiary: Dictionary = SaveGame.data()["bestiary"]
	var current: Dictionary = entry(enemy_id).duplicate()
	var before: int = int(current.get("kills", 0))
	current["kills"] = before + 1
	bestiary[enemy_id] = current
	for threshold: int in [1, Data.cfg_int("bestiary.weakness_kills"), Data.cfg_int("bestiary.myth_kills")]:
		if before < threshold and before + 1 >= threshold:
			SaveGame.commit("bestiary")
			return


## Marks an enemy's weakness and resistance as known (a recap tip named them).
static func reveal(enemy_id: String) -> void:
	if enemy_id == "" or bool(entry(enemy_id).get("revealed", false)):
		return
	var current: Dictionary = entry(enemy_id).duplicate()
	current["revealed"] = true
	SaveGame.data()["bestiary"][enemy_id] = current
	SaveGame.commit("bestiary")
