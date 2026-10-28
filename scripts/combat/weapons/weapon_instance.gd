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
## True when the holder's Hero is an expert in this weapon's category.
var expert: bool = false
## True after a chest evolved it; base_id is the weapon it evolved from.
var evolved: bool = false
var base_id: String = ""


func _init(weapon_data: Dictionary, holder: Player) -> void:
	data = weapon_data
	owner_player = holder


func id() -> String:
	return str(data.get("id", ""))


## Translation key for the weapon's current name. Elemental spells rename as
## they level: levels 1–3 Tier I, 4–6 Tier II, 7–8 Tier III (GAME_DESIGN.md:
## Spell tier names).
func name_key() -> String:
	return name_key_at(data, level)


static func name_key_at(weapon_data: Dictionary, at_level: int) -> String:
	var tiers: Array = weapon_data.get("tier_names", [])
	if tiers.is_empty():
		return str(weapon_data.get("name_key", ""))
	return str(tiers[mini(Elements.tier_index(at_level), tiers.size() - 1)])


func max_level() -> int:
	return (data.get("levels", []) as Array).size()


## Stats for the current level. Expert weapons at level 8 get one extra
## projectile (or one extra pierce when they don't fire projectiles).
func stats() -> Dictionary:
	var levels: Array = data.get("levels", [])
	if levels.is_empty():
		return {}
	var current: Dictionary = levels[clampi(level, 1, levels.size()) - 1]
	if not expert or level < max_level():
		return current
	var boosted: Dictionary = current.duplicate()
	if boosted.has("count"):
		boosted["count"] = int(boosted["count"]) + 1
	elif boosted.has("pierce"):
		boosted["pierce"] = int(boosted["pierce"]) + 1
	return boosted


## Seconds between attacks after Cooldown, attack speed, and expertise.
func attack_interval() -> float:
	var speed: float = 1.0
	if owner_player != null:
		speed += owner_player.stats.attack_speed() + owner_player.kit_attack_speed_bonus()
		# Thousand-Arrow Ride: arrows fly fast during every charge.
		if bool(data.get("charge_arrows", false)) and owner_player.kit != null and owner_player.kit.has_method("is_charging") \
				and bool(owner_player.kit.call("is_charging")):
			speed += Data.cfg_float("combat.charge_arrows_attack_speed")
	if expert:
		speed += Data.cfg_float("combat.expertise_attack_speed_pct") / 100.0
	var cooldown_mult: float = owner_player.stats.cooldown_mult() if owner_player != null else 1.0
	return stat("cooldown") * cooldown_mult / speed


## Base damage per hit after expertise (+15%) and the Hero's own bonuses.
func damage() -> float:
	var amount: float = stat("damage")
	if expert:
		amount *= 1.0 + Data.cfg_float("combat.expertise_damage_pct") / 100.0
	if owner_player != null:
		amount *= owner_player.kit_damage_mult(self)
	return amount


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
