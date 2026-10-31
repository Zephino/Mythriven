class_name AchievementRules
extends RefCounted
## Achievements (GAME_DESIGN.md: Collections / Achievements): goals that can
## unlock content (e.g. "Survive 20:00" unlocks Atalanta; "Trigger 4
## different Resonances" unlocks the Bladed Discus). Each is saved the moment
## it's earned. Conditions are data in achievements.json; `context` holds the
## current run: arc_s, kills, level, swift, omens (count).

const FILE := "achievements.json"


## An achievement's name as shown to the player (its own name_key from achievements.json).
static func display_name(achievement_id: String) -> String:
	for entry: Dictionary in all():
		if str(entry.get("id", "")) == achievement_id:
			return TranslationServer.translate(str(entry.get("name_key", "")))
	return achievement_id


static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	return found


static func is_earned(achievement_id: String) -> bool:
	return SaveGame.list("achievements").has(achievement_id)


## Earns every achievement whose condition is now met. Returns the lines for
## the results screen (the achievement and anything it unlocked).
static func check(context: Dictionary) -> PackedStringArray:
	var lines: PackedStringArray = []
	for achievement: Dictionary in all():
		var id: String = str(achievement.get("id", ""))
		if is_earned(id) or not met(achievement.get("condition", {}), context):
			continue
		SaveGame.add_to("achievements", id)
		lines.append(TranslationServer.translate("ACHIEVEMENT_EARNED") % TranslationServer.translate(str(achievement.get("name_key", id))))
		var reward_line: String = Rewards.grant(achievement.get("reward", {}))
		if reward_line != "":
			lines.append(reward_line)
	return lines


static func met(condition: Dictionary, context: Dictionary) -> bool:
	var need: float = float(condition.get("count", condition.get("seconds", condition.get("level", 1))))
	var save: Dictionary = SaveGame.data()
	match str(condition.get("type", "")):
		"survive_s":
			return float(context.get("arc_s", 0.0)) >= need and (not bool(condition.get("swift", false)) or bool(context.get("swift", false))) \
					and int(context.get("omens", 0)) >= int(condition.get("omens", 0))
		"kills_run":
			return float(context.get("kills", 0)) >= need
		"level_run":
			return float(context.get("level", 0)) >= need
		"kills_total", "elites_total", "runs", "gold_banked_total", "bosses_total":
			return SaveGame.stat(str(condition["type"])) >= need
		"gods_bound":
			var bound: int = 0
			for god_id: Variant in save["gods"]:
				bound += 1 if GodLevels.bound_ever(str(god_id)) else 0
			return bound >= need
		"resonances_fired":
			return Profile.get_list("codex", "resonances_fired").size() >= need
		"evolutions":
			return Profile.get_list(EvolutionRules.CODEX_SECTION, EvolutionRules.CODEX_KEY).size() >= need
		"infusions":
			return Profile.get_list(EvolutionRules.CODEX_SECTION, Infusions.CODEX_KEY).size() >= need
		"bestiary":
			return (save["bestiary"] as Dictionary).size() >= need
		"boss":
			for level_entry: Variant in (save["levels"] as Dictionary).values():
				if level_entry is Dictionary and (level_entry.get("bosses", []) as Array).has(str(condition.get("id", ""))):
					return true
			return false
		"offering_level":
			for god_id: Variant in save["gods"]:
				if GodLevels.level(str(god_id)) >= need:
					return true
			return false
		"heroes":
			return HeroRules.unlocked().size() >= need
	return false
