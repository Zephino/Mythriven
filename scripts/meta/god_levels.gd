class_name GodLevels
extends RefCounted
## Offerings: permanent god levels (GAME_DESIGN.md: Gods / Offerings). In the
## Hall of Legends, gold offered to a god bound at least once raises its level
## from 1 to 10; the level applies whenever that god is bound again:
##   2, 4, 6, 8  Blessing +10% each
##   3, 9        meter fills 10% faster each
##   5           summon upgrade (summons +25% stronger; placeholder)
##   7           Resonance Harmony with this god is 50% stronger
##   10          Ascended: summons +25% stronger again, golden aura during summons
## Costs and steps are in config.json → offerings.


static func level(god_id: String) -> int:
	var entry: Variant = (SaveGame.data()["gods"] as Dictionary).get(god_id, {})
	return clampi(int((entry as Dictionary).get("level", 1)), 1, max_level()) if entry is Dictionary else 1


static func max_level() -> int:
	return (Data.cfg("offerings.costs") as Array).size() + 1


static func bound_ever(god_id: String) -> bool:
	var entry: Variant = (SaveGame.data()["gods"] as Dictionary).get(god_id, {})
	return entry is Dictionary and bool((entry as Dictionary).get("bound_ever", false))


## Records that a god was bound (unlocks its offerings and Compendium page).
## Saved at once. Returns true the first time.
static func mark_bound(god_id: String) -> bool:
	if bound_ever(god_id):
		return false
	var gods: Dictionary = SaveGame.data()["gods"]
	gods[god_id] = {"level": level(god_id), "bound_ever": true}
	SaveGame.commit("gods")
	return true


## Gold for the next level, or -1 at max level.
static func next_cost(god_id: String) -> int:
	var at: int = level(god_id)
	var costs: Array = Data.cfg("offerings.costs")
	return int(costs[at - 1]) if at < max_level() else -1


## Spends banked gold to raise a god's level. Saves at once.
static func offer(god_id: String) -> bool:
	var cost: int = next_cost(god_id)
	if cost < 0 or not bound_ever(god_id) or not SaveGame.spend_gold(cost):
		return false
	SaveGame.data()["gods"][god_id]["level"] = level(god_id) + 1
	SaveGame.commit("gods")
	return true


## How many of the levels up to the god's level are in `steps`.
static func _count(god_id: String, key: String) -> int:
	var count: int = 0
	for step: Variant in Data.cfg("offerings." + key):
		if level(god_id) >= int(step):
			count += 1
	return count


## Multiplier on the god's Blessing.
static func blessing_mult(god_id: String) -> float:
	return 1.0 + _count(god_id, "blessing_levels") * Data.cfg_float("offerings.blessing_step")


## Extra meter charge (0.1 = 10% faster).
static func charge_bonus(god_id: String) -> float:
	return _count(god_id, "meter_levels") * Data.cfg_float("offerings.meter_step")


## Multiplier on the god's summon (damage, healing, and similar amounts).
static func summon_power(god_id: String) -> float:
	return 1.0 + _count(god_id, "summon_levels") * Data.cfg_float("offerings.summon_step")


## Multiplier on a Resonance Harmony that includes this god.
static func harmony_mult(god_id: String) -> float:
	return Data.cfg_float("offerings.harmony_mult") if level(god_id) >= Data.cfg_int("offerings.harmony_level") else 1.0


static func is_ascended(god_id: String) -> bool:
	return level(god_id) >= max_level()


## The translation key of what the next level unlocks.
static func next_unlock_key(god_id: String) -> String:
	return "OFFERING_LEVEL_%d" % (level(god_id) + 1) if level(god_id) < max_level() else "OFFERING_MAXED"
