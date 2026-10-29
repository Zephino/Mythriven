class_name ContentGate
extends RefCounted
## Release content gate (GAME_DESIGN.md: Tech stack and performance rules).
## Every Hero, god, and boss entry carries care_tier and lore_verified. Release
## builds refuse any entry that isn't care_tier "A" with lore_verified true;
## dev builds keep everything but report a warning for each such entry.

const ALLOWED_TIER := "A"


## Returns {"kept": Array, "refused": Array[Dictionary], "warnings": Array[Dictionary]}.
## Each refusal or warning names the file, the entry id, and why.
static func filter(entries: Array, file_label: String, release: bool) -> Dictionary:
	var kept: Array = []
	var refused: Array[Dictionary] = []
	var warnings: Array[Dictionary] = []
	for entry: Variant in entries:
		if entry is Dictionary and passes(entry):
			kept.append(entry)
			continue
		var report: Dictionary = _report(entry, file_label)
		if release:
			refused.append(report)
		else:
			warnings.append(report)
			kept.append(entry)
	return {"kept": kept, "refused": refused, "warnings": warnings}


## True when an entry may ship in a release build.
static func passes(entry: Dictionary) -> bool:
	var tier: Variant = entry.get("care_tier")
	var verified: Variant = entry.get("lore_verified")
	return tier is String and tier == ALLOWED_TIER and verified is bool and verified == true


## Translated sentence for a refusal (release) or warning (dev).
static func describe(report: Dictionary, release: bool) -> String:
	var key: String = "GATE_REFUSED" if release else "GATE_WARNING"
	return TranslationServer.translate(key) % [
		report.get("file", ""), report.get("id", ""), report.get("care_tier", ""), report.get("lore_verified", "")
	]


static func _report(entry: Variant, file_label: String) -> Dictionary:
	var data: Dictionary = entry if entry is Dictionary else {}
	return {
		"file": file_label,
		"id": str(data.get("id", "?")),
		"care_tier": str(data.get("care_tier", "?")),
		"lore_verified": str(data.get("lore_verified", "?")),
	}
