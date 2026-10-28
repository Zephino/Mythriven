class_name WeaponInstance
extends RefCounted
## One weapon held by one player during a run: its data from weapons.json,
## its level (1–8), and its timers. Lost when the run ends (persists: false).

var data: Dictionary = {}
var level: int = 1
var owner_player: Player = null
## Seconds until the next attack.
var cooldown_left: float = 0.0
## Seconds until the target is picked again (every 0.1 s).
var retarget_left: float = 0.0
## Last targeting result (see Targeting.pick).
var aim: Dictionary = {}
## Attacks made so far (e.g. the Great Club quakes on every 4th slam).
var attacks_made: int = 0
## Per-enemy hit timers for weapons that touch the same enemy again
## (auras, orbits, returning projectiles): slot -> seconds until it can be hit.
var hit_wait: Dictionary = {}


func _init(weapon_data: Dictionary, holder: Player) -> void:
	data = weapon_data
	owner_player = holder


func id() -> String:
	return str(data.get("id", ""))


func max_level() -> int:
	return (data.get("levels", []) as Array).size()


## Stats for the current level.
func stats() -> Dictionary:
	var levels: Array = data.get("levels", [])
	if levels.is_empty():
		return {}
	return levels[clampi(level, 1, levels.size()) - 1]


func stat(key: String, fallback: float = 0.0) -> float:
	return float(stats().get(key, fallback))


## True if this weapon may hit `slot` now; starts that enemy's hit timer.
func try_hit(slot: int) -> bool:
	if float(hit_wait.get(slot, 0.0)) > 0.0:
		return false
	var interval: float = stat("hit_interval")
	if interval > 0.0:
		hit_wait[slot] = interval
	return true


func tick_hit_timers(delta: float) -> void:
	for slot: Variant in hit_wait.keys():
		var left: float = float(hit_wait[slot]) - delta
		if left <= 0.0:
			hit_wait.erase(slot)
		else:
			hit_wait[slot] = left
