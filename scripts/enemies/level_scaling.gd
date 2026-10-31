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
	return (1.0 + _steps(level, "difficulty_every_levels") * Data.cfg_float("enemies.level_scaling.hp_step")) * pack("hp_mult")


## Enemy contact damage multiplier: +damage_step for every full `difficulty_every_levels`.
static func damage_mult(level: int) -> float:
	return (1.0 + _steps(level, "difficulty_every_levels") * Data.cfg_float("enemies.level_scaling.damage_step")) * pack("damage_mult")


## The current level's pack makes enemies tougher (owner decision 10/31/2026: Pack 2 is harder than Pack 1):
## config enemies.pack_difficulty.<act>.<key>, x1 when the pack isn't listed.
static func pack(key: String, level_data: Dictionary = {}) -> float:
	var data: Dictionary = level_data if not level_data.is_empty() else (GameAuthority.run.level_data if GameAuthority.run != null else {})
	var packs: Variant = Data.cfg("enemies.pack_difficulty")
	var entry: Variant = (packs as Dictionary).get(str(int(data.get("act", 1))), {}) if packs is Dictionary else {}
	return float((entry as Dictionary).get(key, 1.0)) if entry is Dictionary else 1.0


static func current_level() -> int:
	return GameAuthority.run.level if GameAuthority.run != null else 1


static func _steps(level: int, key: String) -> int:
	var every: int = maxi(Data.cfg_int("enemies.level_scaling." + key), 1)
	return floori(level / float(every))
