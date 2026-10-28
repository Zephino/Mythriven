class_name LevelScaling
extends RefCounted
## Difficulty that grows with the player's level (owner request, 2026-10-28):
## every 5 levels more enemies spawn, and every 10 levels enemies have more HP
## and hit harder. Steps are in config.json → enemies.level_scaling.


## Spawn rate multiplier: +spawn_rate_step for every full `spawn_every_levels`.
static func spawn_mult(level: int) -> float:
	return 1.0 + _steps(level, "spawn_every_levels") * Data.cfg_float("enemies.level_scaling.spawn_rate_step")


## Enemy HP multiplier: +hp_step for every full `difficulty_every_levels`.
static func hp_mult(level: int) -> float:
	return 1.0 + _steps(level, "difficulty_every_levels") * Data.cfg_float("enemies.level_scaling.hp_step")


## Enemy contact damage multiplier: +damage_step for every full `difficulty_every_levels`.
static func damage_mult(level: int) -> float:
	return 1.0 + _steps(level, "difficulty_every_levels") * Data.cfg_float("enemies.level_scaling.damage_step")


static func current_level() -> int:
	return GameAuthority.run.level if GameAuthority.run != null else 1


static func _steps(level: int, key: String) -> int:
	var every: int = maxi(Data.cfg_int("enemies.level_scaling." + key), 1)
	return floori(level / float(every))
