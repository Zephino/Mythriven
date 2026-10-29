class_name SecretPassives
extends RefCounted
## Passives earned from secrets (GAME_DESIGN.md: Secret unlocks), added to the
## level-up pool once found:
##   Mirrored Shield: a chance per level to send an enemy shot back (as Perseus
##     used his reflecting shield against Medusa) instead of being hit.
##   Tyr's Oath: more damage while below half health (Tyr gave his hand to bind Fenrir).


## Tries to reflect an enemy shot hitting `player`; true if it was sent back.
## The reflected shot hits the nearest enemy for twice its damage.
static func reflects(player: Player, at: Vector2, damage: float) -> bool:
	var level: int = int(player.passives.get("mirrored_shield", 0))
	if level <= 0 or GameAuthority.run == null:
		return false
	var chance: float = level * float(LevelUpRules.passive_data("mirrored_shield").get("reflect_chance_per_level", 0.0))
	if GameAuthority.run.rng.combat.randf() >= chance:
		return false
	var enemies: EnemyManager = GameAuthority.enemies
	var reach: float = float(LevelUpRules.passive_data("mirrored_shield").get("reflect_range_px", 200.0))
	var target: int = -1
	var best: float = INF
	for slot: int in enemies.query(at, reach):
		var dist: float = enemies.positions[slot].distance_to(at)
		if dist < best:
			best = dist
			target = slot
	if target != -1:
		GameAuthority.damage_enemy(target, damage * 2.0, player, Vector2.ZERO, Elements.PHYSICAL)
	return true


## Tyr's Oath: damage multiplier while below the health threshold.
static func low_hp_mult(player: Player) -> float:
	var level: int = int(player.passives.get("tyrs_oath", 0))
	if level <= 0:
		return 1.0
	var data: Dictionary = LevelUpRules.passive_data("tyrs_oath")
	if player.hp >= player.max_hp * float(data.get("below_hp_fraction", 0.5)):
		return 1.0
	return 1.0 + level * float(data.get("damage_per_level", 0.0))
