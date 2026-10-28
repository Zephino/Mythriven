class_name PlayerStatuses
extends RefCounted
## Elemental statuses on a player (GAME_DESIGN.md: Status effects on the
## player). Enemies only apply them from 30:00 (the Unraveling), at reduced
## strength: half duration, Chill never becomes a full Freeze, and the
## player is immune for 2 s after each status ends. Gust and Smite don't
## affect players.

const LASTING: PackedStringArray = ["burn", "chill", "shock", "soaked", "poison", "hex"]

var timers: Dictionary = {}
var chill_stacks: int = 0
var poison_stacks: int = 0
var _immune: float = 0.0


func has(status_id: String) -> bool:
	return float(timers.get(status_id, 0.0)) > 0.0


func is_immune() -> bool:
	return _immune > 0.0


## Applies a status unless the player is immune. Returns true if it took hold.
func apply(status_id: String) -> bool:
	if not LASTING.has(status_id) or is_immune():
		return false
	var p: Dictionary = Elements.status(status_id)
	var duration: float = float(p.get("duration_s", 0.0)) * Data.cfg_float("combat.player_status_duration_mult")
	timers[status_id] = maxf(float(timers.get(status_id, 0.0)), duration)
	if status_id == "chill":
		var cap: int = int((Elements.data().get("player_statuses", {}) as Dictionary).get("max_chill_stacks", 2))
		chill_stacks = mini(chill_stacks + 1, cap)
	elif status_id == "poison":
		poison_stacks = mini(poison_stacks + 1, int(p.get("max_stacks", 5)))
	return true


## Counts down; returns damage over time (Burn, Poison) for this step.
func tick(delta: float) -> float:
	_immune = maxf(_immune - delta, 0.0)
	var dot: float = 0.0
	if has("burn"):
		dot += float(Elements.status("burn").get("dps", 0.0)) * delta
	if has("poison"):
		dot += float(Elements.status("poison").get("dps_per_stack", 0.0)) * poison_stacks * delta
	for status_id: Variant in timers.keys():
		var left: float = float(timers[status_id]) - delta
		if left > 0.0:
			timers[status_id] = left
			continue
		timers.erase(status_id)
		if status_id == "chill":
			chill_stacks = 0
		elif status_id == "poison":
			poison_stacks = 0
		_immune = Data.cfg_float("combat.player_status_immunity_s")
	return dot


func speed_mult() -> float:
	if not has("chill"):
		return 1.0
	return maxf(1.0 - float(Elements.status("chill").get("slow_per_stack", 0.3)) * chill_stacks, 0.0)


func armor_mult() -> float:
	return 1.0 - float(Elements.status("hex").get("armor_reduction", 0.4)) if has("hex") else 1.0


## Multiplier on the damage this player deals (Hex weakens it).
func outgoing_damage_mult() -> float:
	return 1.0 - float(Elements.status("hex").get("damage_reduction", 0.2)) if has("hex") else 1.0


## Shock: the next hit taken deals +20%, then the Shock ends.
func consume_shock() -> float:
	if not has("shock"):
		return 1.0
	timers.erase("shock")
	return 1.0 + float(Elements.status("shock").get("next_hit_bonus", 0.2))
