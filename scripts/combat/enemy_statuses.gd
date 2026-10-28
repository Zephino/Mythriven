class_name EnemyStatuses
extends RefCounted
## Status effects stored as data on pooled enemies (GAME_DESIGN.md: Statuses
## are data, not nodes), ticked 5 times a second. One status per element:
## Burn (damage over time), Chill (−30% speed per stack; 3 stacks = Frozen),
## Shock (next hit +20%), Soaked (sets up reactions), Poison (stacking damage
## over time), Smite (marks the hit for shield breaking), Hex (−40% Armor,
## −20% damage). Gust is an instant push, not a lasting status.
## Stuns and roots (from gods and Guard Breaks) stop movement like Freeze.
## Elites have diminishing crowd control: each Freeze, root, or stun within
## 10 s lasts 100% → 50% → 25%, then they're immune for 5 s (GAME_DESIGN.md:
## Crowd control on elites and bosses).

var burn := PackedFloat32Array()
var chill := PackedFloat32Array()
var chill_stacks := PackedInt32Array()
var frozen := PackedFloat32Array()
var shock := PackedFloat32Array()
var soaked := PackedFloat32Array()
var poison := PackedFloat32Array()
var poison_stacks := PackedInt32Array()
var smite := PackedFloat32Array()
var hex := PackedFloat32Array()
var stun := PackedFloat32Array()
## 1 for elites (diminishing crowd control).
var cc_limited := PackedByteArray()
var cc_count := PackedInt32Array()
var cc_window := PackedFloat32Array()
var cc_immune := PackedFloat32Array()

var _p: Dictionary = {}
var _tints: Dictionary = {}


func _init(capacity: int) -> void:
	burn.resize(capacity)
	chill.resize(capacity)
	chill_stacks.resize(capacity)
	frozen.resize(capacity)
	shock.resize(capacity)
	soaked.resize(capacity)
	poison.resize(capacity)
	poison_stacks.resize(capacity)
	smite.resize(capacity)
	hex.resize(capacity)
	stun.resize(capacity)
	cc_limited.resize(capacity)
	cc_count.resize(capacity)
	cc_window.resize(capacity)
	cc_immune.resize(capacity)
	for status_id: String in ["burn", "chill", "shock", "soaked", "poison", "smite", "hex"]:
		_p[status_id] = Elements.status(status_id)
		_tints[status_id] = Color.html(str((_p[status_id] as Dictionary).get("tint", "#ffffff")))
	_tints["frozen"] = _tints["chill"]


func clear(slot: int) -> void:
	burn[slot] = 0.0
	chill[slot] = 0.0
	chill_stacks[slot] = 0
	frozen[slot] = 0.0
	shock[slot] = 0.0
	soaked[slot] = 0.0
	poison[slot] = 0.0
	poison_stacks[slot] = 0
	smite[slot] = 0.0
	hex[slot] = 0.0
	stun[slot] = 0.0
	cc_limited[slot] = 0
	cc_count[slot] = 0
	cc_window[slot] = 0.0
	cc_immune[slot] = 0.0


## How long a Freeze, root, or stun of `duration` really lasts on this slot
## (shorter for elites hit repeatedly, 0 while immune). Counts the use.
func cc_duration(slot: int, duration: float) -> float:
	if cc_limited[slot] == 0:
		return duration
	if cc_immune[slot] > 0.0:
		return 0.0
	if cc_window[slot] <= 0.0:
		cc_count[slot] = 0
	var mults: Array = Data.cfg("combat.elite_cc_duration_mults")
	var lasts: float = duration * float(mults[mini(cc_count[slot], mults.size() - 1)])
	cc_count[slot] += 1
	cc_window[slot] = Data.cfg_float("combat.elite_cc_window_s")
	if cc_count[slot] >= mults.size():
		cc_immune[slot] = lasts + Data.cfg_float("combat.elite_cc_immunity_s")
		cc_count[slot] = 0
		cc_window[slot] = 0.0
	return lasts


## Stops the enemy for `seconds` (roots, stuns); elites resist repeats.
func apply_stun(slot: int, seconds: float) -> void:
	stun[slot] = maxf(stun[slot], cc_duration(slot, seconds))


## Applies a status. `duration_mult` shortens or lengthens it; bosses can
## only be Chilled, never Frozen (`can_freeze` false).
func apply(slot: int, status_id: String, duration_mult: float = 1.0, can_freeze: bool = true) -> void:
	var p: Dictionary = _p.get(status_id, {})
	var duration: float = float(p.get("duration_s", 0.0)) * duration_mult
	match status_id:
		"burn":
			burn[slot] = maxf(burn[slot], duration)
		"chill":
			if frozen[slot] > 0.0:
				return
			chill[slot] = maxf(chill[slot], duration)
			chill_stacks[slot] = mini(chill_stacks[slot] + 1, int(p.get("stacks_to_freeze", 3)))
			if can_freeze and chill_stacks[slot] >= int(p.get("stacks_to_freeze", 3)):
				frozen[slot] = cc_duration(slot, float(p.get("freeze_s", 1.5)) * duration_mult)
				chill[slot] = 0.0
				chill_stacks[slot] = 0
		"shock":
			shock[slot] = maxf(shock[slot], duration)
		"soaked":
			soaked[slot] = maxf(soaked[slot], duration)
		"poison":
			poison[slot] = maxf(poison[slot], duration)
			poison_stacks[slot] = mini(poison_stacks[slot] + 1, int(p.get("max_stacks", 5)))
		"smite":
			smite[slot] = maxf(smite[slot], duration)
		"hex":
			hex[slot] = maxf(hex[slot], duration)


func has(slot: int, status_id: String) -> bool:
	match status_id:
		"burn":
			return burn[slot] > 0.0
		"chill":
			return chill[slot] > 0.0
		"frozen":
			return frozen[slot] > 0.0
		"shock":
			return shock[slot] > 0.0
		"soaked":
			return soaked[slot] > 0.0
		"poison":
			return poison[slot] > 0.0
		"smite":
			return smite[slot] > 0.0
		"hex":
			return hex[slot] > 0.0
	return false


func remove(slot: int, status_id: String) -> void:
	match status_id:
		"burn":
			burn[slot] = 0.0
		"chill":
			chill[slot] = 0.0
			chill_stacks[slot] = 0
		"frozen":
			frozen[slot] = 0.0
		"shock":
			shock[slot] = 0.0
		"soaked":
			soaked[slot] = 0.0
		"poison":
			poison[slot] = 0.0
			poison_stacks[slot] = 0
		"hex":
			hex[slot] = 0.0


## Movement multiplier: Frozen stops the enemy; each Chill stack slows it.
func speed_mult(slot: int) -> float:
	if frozen[slot] > 0.0 or stun[slot] > 0.0:
		return 0.0
	if chill[slot] > 0.0:
		return maxf(1.0 - float(_p["chill"].get("slow_per_stack", 0.3)) * chill_stacks[slot], 0.0)
	return 1.0


func armor_mult(slot: int) -> float:
	return 1.0 - float(_p["hex"].get("armor_reduction", 0.4)) if hex[slot] > 0.0 else 1.0


## Multiplier on the damage this enemy deals (Hex weakens it).
func outgoing_damage_mult(slot: int) -> float:
	return 1.0 - float(_p["hex"].get("damage_reduction", 0.2)) if hex[slot] > 0.0 else 1.0


## Shock: the next hit taken deals +20%, then the Shock ends.
func consume_shock(slot: int) -> float:
	if shock[slot] <= 0.0:
		return 1.0
	shock[slot] = 0.0
	return 1.0 + float(_p["shock"].get("next_hit_bonus", 0.2))


## Counts timers down by `step` seconds. Calls on_dot(slot, damage) for Burn
## and Poison damage over time.
func tick(step: float, active: PackedByteArray, on_dot: Callable) -> void:
	var burn_dps: float = float(_p["burn"].get("dps", 0.0))
	var poison_dps: float = float(_p["poison"].get("dps_per_stack", 0.0))
	for slot: int in active.size():
		if active[slot] == 0:
			continue
		var dot: float = 0.0
		if burn[slot] > 0.0:
			dot += burn_dps * step
			burn[slot] -= step
		if poison[slot] > 0.0:
			dot += poison_dps * poison_stacks[slot] * step
			poison[slot] -= step
			if poison[slot] <= 0.0:
				poison_stacks[slot] = 0
		if chill[slot] > 0.0:
			chill[slot] -= step
			if chill[slot] <= 0.0:
				chill_stacks[slot] = 0
		frozen[slot] = maxf(frozen[slot] - step, 0.0)
		shock[slot] = maxf(shock[slot] - step, 0.0)
		soaked[slot] = maxf(soaked[slot] - step, 0.0)
		smite[slot] = maxf(smite[slot] - step, 0.0)
		hex[slot] = maxf(hex[slot] - step, 0.0)
		stun[slot] = maxf(stun[slot] - step, 0.0)
		cc_window[slot] = maxf(cc_window[slot] - step, 0.0)
		cc_immune[slot] = maxf(cc_immune[slot] - step, 0.0)
		if dot > 0.0:
			on_dot.call(slot, dot)


## Colour to tint an enemy with to show its strongest status (alpha 0 = none).
func tint(slot: int) -> Color:
	if frozen[slot] > 0.0:
		return _tints["frozen"]
	if burn[slot] > 0.0:
		return _tints["burn"]
	if poison[slot] > 0.0:
		return _tints["poison"]
	if shock[slot] > 0.0:
		return _tints["shock"]
	if hex[slot] > 0.0:
		return _tints["hex"]
	if soaked[slot] > 0.0:
		return _tints["soaked"]
	if chill[slot] > 0.0:
		return _tints["chill"]
	return Color(0, 0, 0, 0)
