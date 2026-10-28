class_name PlayerStats
extends RefCounted
## A player's stats (GAME_DESIGN.md: Heroes / base stats; Core mechanics /
## Level-up choices). Base values come from config (from heroes.json in
## Phase 9); bonuses come from passives and stat cards. There are no hard
## caps: cooldown = base ÷ (1 + bonus) never reaches zero, and Move Speed
## above +100% and Area above +150% count at half value.

const STATS: PackedStringArray = [
	"max_hp", "move_speed", "armor", "might", "area", "cooldown", "pickup_radius", "luck", "crit",
]

## Flat starting values, e.g. {"max_hp": 100, "move_speed": 100, ...}.
var base: Dictionary = {}
## Added bonuses. Percent-style stats use fractions: might 0.1 = +10%.
var bonus: Dictionary = {}


func _init(base_values: Dictionary = {}) -> void:
	for stat: String in STATS:
		base[stat] = float(base_values.get(stat, 0.0))
		bonus[stat] = 0.0


## Starting stats from config.json until Heroes exist.
static func from_config() -> PlayerStats:
	return PlayerStats.new({
		"max_hp": Data.cfg_float("player.placeholder_max_hp"),
		"move_speed": Data.cfg_float("player.placeholder_move_speed"),
		"armor": Data.cfg_float("player.placeholder_armor"),
		"pickup_radius": Data.cfg_float("player.placeholder_pickup_radius_px"),
		"crit": Data.cfg_float("combat.base_crit_chance"),
	})


func add_bonus(stat: String, amount: float) -> void:
	bonus[stat] = float(bonus.get(stat, 0.0)) + amount


func max_hp() -> float:
	return float(base["max_hp"]) * (1.0 + float(bonus["max_hp"]))


func move_speed() -> float:
	var cap: float = Data.cfg_float("stats.move_speed_soft_cap_pct") / 100.0
	return float(base["move_speed"]) * (1.0 + soft(float(bonus["move_speed"]), cap))


func armor() -> float:
	return float(base["armor"]) + float(bonus["armor"])


## Damage multiplier part: the formula multiplies by (1 + might).
func might() -> float:
	return float(base["might"]) + float(bonus["might"])


func area_mult() -> float:
	var cap: float = Data.cfg_float("stats.area_soft_cap_pct") / 100.0
	return 1.0 + soft(float(base["area"]) + float(bonus["area"]), cap)


## Multiply a weapon's attack interval by this.
func cooldown_mult() -> float:
	return 1.0 / (1.0 + maxf(float(base["cooldown"]) + float(bonus["cooldown"]), 0.0))


func pickup_radius() -> float:
	return float(base["pickup_radius"]) * (1.0 + float(bonus["pickup_radius"]))


func luck() -> float:
	return float(base["luck"]) + float(bonus["luck"])


func crit_chance() -> float:
	return float(base["crit"]) + float(bonus["crit"])


## Bonus above `cap` counts at the configured fraction (half by default).
static func soft(value: float, cap: float) -> float:
	if value <= cap:
		return value
	return cap + (value - cap) * Data.cfg_float("stats.over_soft_cap_value")
