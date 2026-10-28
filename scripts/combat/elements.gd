class_name Elements
extends RefCounted
## Read-only helpers for elements.json (GAME_DESIGN.md: Elements, statuses,
## and reactions): colours, each element's status, weakness ×1.5 /
## resistance ×0.5, reaction settings, and spell tier names.

const FILE := "elements.json"
const PHYSICAL := "physical"


static func data() -> Dictionary:
	var loaded: Variant = Data.get_file(FILE)
	return loaded if loaded is Dictionary else {}


static func element(element_id: String) -> Dictionary:
	return (data().get("elements", {}) as Dictionary).get(element_id, {})


static func status_of(element_id: String) -> String:
	return str(element(element_id).get("status", ""))


static func status(status_id: String) -> Dictionary:
	return (data().get("statuses", {}) as Dictionary).get(status_id, {})


static func reaction(reaction_id: String) -> Dictionary:
	return (data().get("reactions", {}) as Dictionary).get(reaction_id, {})


static func color(element_id: String) -> Color:
	return Color.html(str(element(element_id).get("color", "#ffffff")))


## ×1.5 if the enemy is weak to the element, ×0.5 if it resists, else ×1.
## An enemy's "weak" / "resist" can be one element or a list (bosses).
static func multiplier(enemy_type: Dictionary, element_id: String) -> float:
	if _listed(enemy_type.get("weak"), element_id):
		return float(data().get("weakness_mult", 1.5))
	if _listed(enemy_type.get("resist"), element_id):
		return float(data().get("resistance_mult", 0.5))
	return 1.0


## Spell tiers: levels 1–3 = Tier I, 4–6 = Tier II, 7–8 = Tier III, evolution = Tier IV.
static func tier_index(level: int, evolved: bool = false) -> int:
	if evolved:
		return 3
	if level >= 7:
		return 2
	if level >= 4:
		return 1
	return 0


## Translation key for a spell's name at a level, or "" if it has no tiers.
static func tier_key(element_id: String, level: int, evolved: bool = false) -> String:
	var keys: Array = element(element_id).get("tier_keys", [])
	if keys.is_empty():
		return ""
	return str(keys[mini(tier_index(level, evolved), keys.size() - 1)])


static func _listed(value: Variant, element_id: String) -> bool:
	if value is String:
		return value == element_id
	if value is Array:
		return (value as Array).has(element_id)
	return false
