class_name Damage
extends RefCounted
## The damage formula (GAME_DESIGN.md: Core mechanics / Damage formula).
## Every hit is calculated in this order:
##   1. weapon base damage (plus Hero expertise)
##   2. × (1 + Might)
##   3. critical hit: chance roll, × crit multiplier
##   4. × weakness (1.5) or resistance (0.5) multiplier
##   5. − target Armor
##   6. minimum 1
## Damage over time skips Armor. Damage to players: enemy damage − player Armor, minimum 1.


## Returns {"amount": float, "crit": bool}. `crit_roll` is a random number 0..1
## (passed in so tests and co-op can control it).
static func hit(base: float, expertise_bonus: float, might: float, crit_chance: float, crit_mult: float,
		crit_roll: float, element_mult: float, armor: float, min_damage: float, skips_armor: bool = false) -> Dictionary:
	var amount: float = base + expertise_bonus
	amount *= 1.0 + might
	var crit: bool = crit_roll < crit_chance
	if crit:
		amount *= crit_mult
	amount *= element_mult
	if not skips_armor:
		amount -= armor
	return {"amount": maxf(amount, min_damage), "crit": crit}


## Damage a player takes from an enemy.
static func to_player(enemy_damage: float, player_armor: float, min_damage: float) -> float:
	return maxf(enemy_damage - player_armor, min_damage)
