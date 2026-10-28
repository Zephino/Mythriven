class_name RunArc
extends RefCounted
## The run arc (GAME_DESIGN.md: Core loop and run arc): four Ages by time
## (Dusk 0–10 min, Night 10–20, Deep Night 20–30, the Unraveling 30+), enemy
## HP that grows gently from ×1 at 0:00 to ×3 at 30:00 and never faster, and
## the wave table row for the current minute. Times are in config run_arc.

const DUSK := "dusk"
const NIGHT := "night"
const DEEP_NIGHT := "deep_night"
const UNRAVELING := "unraveling"
const AGES: PackedStringArray = [DUSK, NIGHT, DEEP_NIGHT, UNRAVELING]


## The Age at `seconds` into the run.
static func age_at(seconds: float) -> String:
	var starts: Dictionary = Data.cfg("run_arc.age_start_s")
	var current: String = DUSK
	for age: String in AGES:
		if seconds >= float(starts.get(age, INF)):
			current = age
	return current


## 0 for Dusk, 1 for Night, 2 for Deep Night, 3 for the Unraveling.
static func age_index(seconds: float) -> int:
	return AGES.find(age_at(seconds))


## Enemy HP multiplier from time: linear from the start value to the 30:00
## value, then held (the Unraveling ends runs instead of inflating HP).
static func hp_mult(seconds: float) -> float:
	var start: float = Data.cfg_float("run_arc.enemy_hp_mult_start")
	var end: float = Data.cfg_float("run_arc.enemy_hp_mult_at_30_min")
	var full_s: float = float((Data.cfg("run_arc.age_start_s") as Dictionary).get(UNRAVELING, 1800))
	return lerpf(start, end, clampf(seconds / full_s, 0.0, 1.0))


## Elite modifiers for an elite spawned at `seconds` (1, or 2 in Deep Night and later).
static func elite_modifier_count(seconds: float) -> int:
	if age_index(seconds) >= AGES.find(DEEP_NIGHT):
		return Data.cfg_int("run_arc.elite_modifiers_deep_night")
	return Data.cfg_int("run_arc.elite_modifiers_normal")


## The level's wave table (from the file named in levels.json "waves"), or {}.
static func wave_table(level: Dictionary) -> Dictionary:
	var loaded: Variant = Data.get_file(str(level.get("waves", "")))
	return loaded if loaded is Dictionary else {}


## The wave row in effect at `seconds` (the last row whose from_min has passed).
static func wave_row(table: Dictionary, seconds: float) -> Dictionary:
	var found: Dictionary = {}
	for row: Variant in table.get("rows", []):
		if row is Dictionary and seconds >= float(row.get("from_min", 0.0)) * 60.0:
			found = row
	return found


## Picks a key from {key: weight} using `rng`; "" when empty.
static func pick_weighted(weights: Dictionary, rng: RandomNumberGenerator) -> String:
	var total: float = 0.0
	for key: String in weights:
		total += maxf(float(weights[key]), 0.0)
	if total <= 0.0:
		return ""
	var roll: float = rng.randf() * total
	for key: String in weights:
		roll -= maxf(float(weights[key]), 0.0)
		if roll <= 0.0:
			return key
	return str(weights.keys().back())
