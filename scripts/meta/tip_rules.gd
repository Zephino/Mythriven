class_name TipRules
extends RefCounted
## The death recap's one tip (GAME_DESIGN.md: Death recap): chosen by rules
## from what happened in the run. Tips live in tips.json with a condition, a
## text key, and a priority; the highest-priority tip whose condition is met
## wins, and the same tip never shows twice in a row. A weakness revealed by a
## tip is also marked in the Bestiary.
##
## `context`: killer (source id), killer_type (enemy data or {}), elements
## (the build's elements), gods (number bound this run), arc_s, evolutions.

const FILE := "tips.json"


static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	found.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("priority", 0)) > int(b.get("priority", 0)))
	return found


## Picks the tip and returns {"id", "text"}; remembers it so it isn't repeated next time.
static func pick(context: Dictionary) -> Dictionary:
	var last: String = str(SaveGame.setting("last_tip", ""))
	for tip: Dictionary in all():
		var id: String = str(tip.get("id", ""))
		if id == last or not met(tip.get("condition", {}), context):
			continue
		SaveGame.set_setting("last_tip", id)
		return {"id": id, "text": text(tip, context)}
	return {}


static func met(condition: Dictionary, context: Dictionary) -> bool:
	var killer: String = str(context.get("killer", ""))
	match str(condition.get("type", "")):
		"killer":
			return killer == str(condition.get("id", ""))
		"killer_prefix":
			return killer.begins_with(str(condition.get("prefix", "")))
		"killer_weakness_missing":
			var weak: Variant = (context.get("killer_type", {}) as Dictionary).get("weak")
			var elements: PackedStringArray = context.get("elements", PackedStringArray())
			return weak is String and str(weak) != "" and not elements.has(str(weak))
		"no_gods":
			return int(context.get("gods", 0)) == 0 and float(context.get("arc_s", 0.0)) >= float(condition.get("after_s", 0.0))
		"died_before":
			return float(context.get("arc_s", 0.0)) < float(condition.get("seconds", 0.0))
		"no_evolution_after":
			return int(context.get("evolutions", 0)) == 0 and float(context.get("arc_s", 0.0)) >= float(condition.get("seconds", 0.0))
		"always":
			return true
	return false


## The tip's text, filled in (the weakness tip names the enemy and element, and
## marks the weakness in the Bestiary).
static func text(tip: Dictionary, context: Dictionary) -> String:
	var line: String = TranslationServer.translate(str(tip.get("text_key", "")))
	if str((tip.get("condition", {}) as Dictionary).get("type", "")) != "killer_weakness_missing":
		return line
	var enemy: Dictionary = context.get("killer_type", {})
	var weak: String = str(enemy.get("weak", ""))
	Bestiary.reveal(str(enemy.get("id", "")))
	return line % [TranslationServer.translate(str(enemy.get("name_key", ""))),
		TranslationServer.translate(str(Elements.element(weak).get("name_key", weak)))]
