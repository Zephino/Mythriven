class_name SecretPassives
extends RefCounted
## Passives earned from secrets (GAME_DESIGN.md: Secret unlocks), added to the
## level-up pool once found:
##   Mirrored Shield: a chance per level to send an enemy shot back (as Perseus
##     used his reflecting shield against Medusa) instead of being hit.
##   Tyr's Oath: more damage while below half health (Tyr gave his hand to bind Fenrir).
##   Pomegranate Seed: heals after every boss (Persephone's pomegranate; Homeric Hymn to Demeter).
##   Whetstone Shard: crit chance (a plain stat passive; Hrungnir's whetstone, Skaldskaparmal 17).
##   The Green Girdle: once per level per run, a killing blow leaves the Hero at 1 HP instead (Sir Gawain and the
##     Green Knight: the girdle keeps its wearer from death).
##   Plant of Youth: slowly regenerates health (Epic of Gilgamesh, Tablet XI).


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


## Pomegranate Seed: a boss fell; heals every Hero who holds it.
static func on_boss_defeated() -> void:
	for player: Player in GameAuthority.players:
		var level: int = int(player.passives.get("pomegranate_seed", 0))
		if level > 0 and player.alive:
			GameAuthority.heal_player(player, player.max_hp * level * float(LevelUpRules.passive_data("pomegranate_seed").get("heal_pct_per_level", 0.0)) / 100.0)


## The Green Girdle: true (and the Hero is left at 1 HP, briefly safe) when it saves them from a killing blow.
static func girdle_saves(player: Player) -> bool:
	var level: int = int(player.passives.get("green_girdle", 0))
	var used: int = int(player.get_meta("girdle_used", 0))
	if level <= used:
		return false
	player.set_meta("girdle_used", used + 1)
	player.hp = 1.0
	player.invulnerable_s = maxf(player.invulnerable_s, float(LevelUpRules.passive_data("green_girdle").get("saved_invulnerable_s", 1.5)))
	return true


## Plant of Youth: health regenerated per second, in % of Max HP.
static func regen_pct(player: Player) -> float:
	var level: int = int(player.passives.get("plant_of_youth", 0))
	return level * float(LevelUpRules.passive_data("plant_of_youth").get("regen_pct_per_s_per_level", 0.0)) if level > 0 else 0.0


## Tyr's Oath: damage multiplier while below the health threshold.
static func low_hp_mult(player: Player) -> float:
	var level: int = int(player.passives.get("tyrs_oath", 0))
	if level <= 0:
		return 1.0
	var data: Dictionary = LevelUpRules.passive_data("tyrs_oath")
	if player.hp >= player.max_hp * float(data.get("below_hp_fraction", 0.5)):
		return 1.0
	return 1.0 + level * float(data.get("damage_per_level", 0.0))
