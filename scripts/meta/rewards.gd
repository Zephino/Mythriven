class_name Rewards
extends RefCounted
## Grants what achievements and secrets unlock (GAME_DESIGN.md: Collections;
## Secret unlocks), saving at once (persistence rule). A reward is
## {"type": "hero" | "weapon" | "passive" | "cosmetic" | "omens", "id": ...}.


## Grants a reward. Returns a line for the results screen, or "" if there was
## nothing new.
static func grant(reward: Dictionary) -> String:
	var id: String = str(reward.get("id", ""))
	match str(reward.get("type", "")):
		"hero":
			if HeroRules.unlock(id):
				return TranslationServer.translate("UNLOCK_HERO") % TranslationServer.translate(str(HeroRules.find(id).get("name_key", id)))
		"weapon":
			if SaveGame.add_to("weapons_unlocked", id):
				var weapon: Dictionary = LeaderboardEntry._weapon_data(id)
				return TranslationServer.translate("UNLOCK_WEAPON") % TranslationServer.translate(str(weapon.get("name_key", id)))
		"passive":
			if SaveGame.add_to("passives_unlocked", id):
				return TranslationServer.translate("UNLOCK_PASSIVE") % TranslationServer.translate(str(LevelUpRules.passive_data(id).get("name_key", id)))
		"cosmetic":
			if SaveGame.add_to("cosmetics", id):
				return TranslationServer.translate("UNLOCK_COSMETIC") % TranslationServer.translate(str(cosmetic(id).get("name_key", id)))
		"omens":
			if SaveGame.add_to("omens_unlocked", "all"):
				return TranslationServer.translate("UNLOCK_OMENS")
	return ""


## A cosmetic's entry from config.json → cosmetics.
static func cosmetic(cosmetic_id: String) -> Dictionary:
	for entry: Variant in Data.cfg("cosmetics.list"):
		if entry is Dictionary and str(entry.get("id", "")) == cosmetic_id:
			return entry
	return {}


## The colour of the cosmetic aura equipped (alpha 0 when none).
static func equipped_aura() -> Color:
	var chosen: String = str(SaveGame.setting("cosmetic", ""))
	if chosen == "" or not SaveGame.list("cosmetics").has(chosen):
		return Color(0, 0, 0, 0)
	return Color.html(str(cosmetic(chosen).get("color", "#00000000")))


## A Hero's mastery level, 1–5, from the time played with them.
static func mastery(hero_id: String) -> int:
	var minutes: float = float((SaveGame.data()["mastery"] as Dictionary).get(hero_id, 0.0)) / 60.0
	var level: int = 1
	for needed: Variant in Data.cfg("heroes.mastery_minutes"):
		if minutes >= float(needed):
			level += 1
	return level


## The palette colour chosen for a Hero (alpha 0 = their usual colour).
static func palette(hero_id: String) -> Color:
	var index: int = int((SaveGame.setting("palette", {}) as Dictionary).get(hero_id, 0))
	var palettes: Array = Data.cfg("heroes.mastery_palettes")
	if index <= 0 or index > palettes.size() or index >= mastery(hero_id):
		return Color(0, 0, 0, 0)
	return Color.html(str(palettes[index - 1]))


## Moves a Hero to the next palette their mastery has unlocked (0 = usual).
static func next_palette(hero_id: String) -> void:
	var choices: Dictionary = (SaveGame.setting("palette", {}) as Dictionary).duplicate()
	var unlocked: int = mini(mastery(hero_id) - 1, (Data.cfg("heroes.mastery_palettes") as Array).size())
	choices[hero_id] = (int(choices.get(hero_id, 0)) + 1) % (unlocked + 1)
	SaveGame.set_setting("palette", choices)
