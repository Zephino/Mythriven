class_name ChestRules
extends RefCounted
## What a chest holds (GAME_DESIGN.md: Discovery and feel / Chest reveal;
## Standard evolutions). The light's colour previews the reward: bronze = 1
## upgrade, silver = 2, gold = 3 upgrades or an evolution. Luck raises the
## odds of silver and gold. A weapon ready to evolve always makes the chest
## gold and evolves. Every chest also holds some gold.
## A plan: {"tier": String, "rewards": [reward]}; a reward is one of
##   {"kind": "evolution", "weapon", "passive", "into"}
##   {"kind": "weapon_up" | "passive_up", "id", "from", "to"}
##   {"kind": "gold", "amount"}

const BRONZE := "bronze"
const SILVER := "silver"
const GOLD := "gold"
const TIERS: PackedStringArray = [BRONZE, SILVER, GOLD]


## Rolls the tier: base odds from config, with Luck moving odds from bronze up.
## `big` chests (bosses, lairs) are always gold.
static func roll_tier(luck: float, rng: RandomNumberGenerator, big: bool = false) -> String:
	if big:
		return GOLD
	var odds: Dictionary = Data.cfg("chests.tier_odds")
	var shift: float = clampf(luck * Data.cfg_float("chests.luck_shift"), 0.0, float(odds.get(BRONZE, 0.0)))
	var weights: Dictionary = {
		BRONZE: float(odds.get(BRONZE, 0.0)) - shift,
		SILVER: float(odds.get(SILVER, 0.0)) + shift * 0.6,
		GOLD: float(odds.get(GOLD, 0.0)) + shift * 0.4,
	}
	return RunArc.pick_weighted(weights, rng)


static func upgrades_for(tier: String) -> int:
	return TIERS.find(tier) + 1


## Builds a chest's contents for `player` (nothing is applied yet).
static func build(player: Player, rng: RandomNumberGenerator, big: bool = false) -> Dictionary:
	var rewards: Array[Dictionary] = []
	var tier: String = roll_tier(player.stats.luck(), rng, big)
	var ready: Array[WeaponInstance] = EvolutionRules.candidates(player)
	if not ready.is_empty():
		tier = GOLD
		var weapon: WeaponInstance = ready[rng.randi_range(0, ready.size() - 1)]
		var evolution: Dictionary = weapon.data["evolution"]
		rewards.append({"kind": "evolution", "weapon": weapon.id(), "passive": str(evolution.get("passive", "")),
				"into": str(evolution.get("into", ""))})
	else:
		var pool: Array[Dictionary] = []
		for card: Dictionary in LevelUpRules.item_cards(player):
			if card["kind"] == LevelUpRules.WEAPON_UP or card["kind"] == LevelUpRules.PASSIVE_UP:
				pool.append(card)
		for _k: int in upgrades_for(tier):
			if pool.is_empty():
				break
			var card: Dictionary = pool.pop_at(rng.randi_range(0, pool.size() - 1))
			var kind: String = "weapon_up" if card["kind"] == LevelUpRules.WEAPON_UP else "passive_up"
			rewards.append({"kind": kind, "id": card["id"], "from": card["from"], "to": card["to"]})
	var gold_range: Array = Data.cfg("chests.big_gold" if big else "chests.gold")
	rewards.append({"kind": "gold", "amount": float(rng.randi_range(int(gold_range[0]), int(gold_range[1])))})
	return {"tier": tier, "rewards": rewards}


## Applies a chest's rewards to `player`. Returns the evolution recipes found.
static func apply(player: Player, plan: Dictionary) -> Array[Dictionary]:
	var evolved: Array[Dictionary] = []
	for reward: Dictionary in plan.get("rewards", []):
		match str(reward.get("kind", "")):
			"evolution":
				for weapon: WeaponInstance in player.weapons:
					if weapon.id() == str(reward["weapon"]) and EvolutionRules.can_evolve(weapon, player):
						var recipe: Dictionary = EvolutionRules.evolve(weapon)
						if not recipe.is_empty():
							recipe["new"] = EvolutionRules.discover(recipe)
							evolved.append(recipe)
						break
			"weapon_up":
				for weapon: WeaponInstance in player.weapons:
					if weapon.id() == str(reward["id"]):
						weapon.level = mini(weapon.level + 1, weapon.max_level())
			"passive_up":
				var passive_id: String = str(reward["id"])
				var passive: Dictionary = LevelUpRules.passive_data(passive_id)
				player.passives[passive_id] = int(player.passives.get(passive_id, 0)) + 1
				player.stats.add_bonus(str(passive.get("stat", "")), float(passive.get("per_level", 0.0)))
			"gold":
				GameAuthority.collect_gold(player, float(reward.get("amount", 0.0)))
	player.refresh_stats()
	return evolved
