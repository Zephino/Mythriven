class_name HeroRules
extends RefCounted
## Helpers for heroes.json (GAME_DESIGN.md: Heroes; Weapon speeds and Hero
## expertise).

const FILE := "heroes.json"


## Heroes that loaded (in release builds only those passing the content gate).
static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	return found


static func find(hero_id: String) -> Dictionary:
	for hero: Dictionary in all():
		if str(hero.get("id", "")) == hero_id:
			return hero
	return {}


## Base stats in the game's units: crit and luck are percent in the data.
static func base_stats(hero: Dictionary) -> Dictionary:
	var stats: Dictionary = (hero.get("stats", {}) as Dictionary).duplicate()
	stats["crit"] = float(stats.get("crit", 0.0)) / 100.0
	stats["luck"] = float(stats.get("luck", 0.0)) / 100.0
	return stats


## Expertise: a weapon in one of the Hero's expert categories that isn't the
## weapon they start with gets +25% attack speed, +15% damage, and an extra
## projectile or pierce at level 8.
static func is_expert(hero: Dictionary, weapon: Dictionary) -> bool:
	if hero.is_empty() or str(weapon.get("id", "")) == str(hero.get("signature_weapon", "")):
		return false
	for category: Variant in weapon.get("categories", []):
		if (hero.get("expertise", []) as Array).has(category):
			return true
	return false
