class_name RunTracker
extends RefCounted
## What happened during one run, for the death recap, achievements, and
## secrets (GAME_DESIGN.md: Death recap; Secret unlocks). Lost when the run
## ends; anything persistent is saved by Meta the moment it's earned.

## Damage the local player took recently: {"t", "source", "amount"}.
var damage_taken: Array[Dictionary] = []
## Damage the local player dealt, per weapon id ("" = traits, summons, hazards).
var damage_by_weapon: Dictionary = {}
var damage_total: float = 0.0
var gods_bound: PackedStringArray = []
var resonances_fired: PackedStringArray = []
var bosses_defeated: PackedStringArray = []
var elites_killed: int = 0
## Kills this run by monster family (Beowulf's unlock counts giants and trolls).
var family_kills: Dictionary = {}
var gold_pickups: int = 0
var petrified: bool = false
var labors_done: int = 0
var evolutions: int = 0
## Lines for the results screen ("New Hero: Atalanta", ...).
var new_unlocks: PackedStringArray = []


func note_damage(seconds: float, source: String, amount: float) -> void:
	damage_taken.append({"t": seconds, "source": source, "amount": amount})
	var window: float = Data.cfg_float("recap.recent_window_s")
	while not damage_taken.is_empty() and float(damage_taken[0]["t"]) < seconds - window:
		damage_taken.pop_front()


## The source that dealt the most damage in the last few seconds before `seconds`.
func top_recent_source(seconds: float) -> String:
	var totals: Dictionary = {}
	var window: float = Data.cfg_float("recap.recent_window_s")
	for hit: Dictionary in damage_taken:
		if float(hit["t"]) >= seconds - window:
			totals[hit["source"]] = float(totals.get(hit["source"], 0.0)) + float(hit["amount"])
	var best: String = ""
	for source: Variant in totals:
		if best == "" or float(totals[source]) > float(totals[best]):
			best = str(source)
	return best


func note_dealt(weapon_id: String, amount: float) -> void:
	damage_by_weapon[weapon_id] = float(damage_by_weapon.get(weapon_id, 0.0)) + amount
	damage_total += amount


## [weapon id, share of all damage 0–1] for the weapon that dealt the most.
func top_weapon() -> Array:
	var best: String = ""
	for weapon_id: Variant in damage_by_weapon:
		if str(weapon_id) != "" and (best == "" or float(damage_by_weapon[weapon_id]) > float(damage_by_weapon[best])):
			best = str(weapon_id)
	if best == "" or damage_total <= 0.0:
		return ["", 0.0]
	return [best, float(damage_by_weapon[best]) / damage_total]
