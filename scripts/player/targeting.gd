class_name Targeting
extends RefCounted
## Smart targeting (GAME_DESIGN.md: Controls and smart targeting). Each
## weapon's data names its type; this picks the enemy and direction.
##   targeted     nearest enemy in range (prefers an elite/boss within 1.5×
##                the nearest distance); doesn't fire if none is in range
##   melee        nearest enemy within melee range, else the facing direction
##   orbit / aura no aiming
##   random       a random enemy in range, else a random direction
##   directional  the facing (movement) direction, on purpose
##   range_switch melee when an enemy is within 2 tiles, otherwise ranged

const TARGETED := "targeted"
const MELEE := "melee"
const ORBIT := "orbit"
const AURA := "aura"
const RANDOM := "random"
const DIRECTIONAL := "directional"
const RANGE_SWITCH := "range_switch"


## Returns {"target": slot or -1, "direction": Vector2, "fire": bool, "melee": bool}.
static func pick(type: String, player: Player, weapon_range: float, enemies: EnemyManager,
		rng: RandomNumberGenerator) -> Dictionary:
	var result: Dictionary = {"target": -1, "direction": Vector2.ZERO, "fire": true, "melee": false}
	match type:
		TARGETED:
			result["target"] = _prefer_priority(player.position, weapon_range, enemies)
			result["fire"] = result["target"] != -1
		MELEE:
			result["target"] = enemies.nearest(player.position, weapon_range)
			result["melee"] = true
			if result["target"] == -1:
				result["direction"] = player.facing
		ORBIT, AURA:
			pass
		RANDOM:
			var nearby: PackedInt32Array = enemies.query(player.position, weapon_range)
			if nearby.is_empty():
				result["direction"] = Vector2.from_angle(rng.randf() * TAU)
			else:
				result["target"] = nearby[rng.randi_range(0, nearby.size() - 1)]
		DIRECTIONAL:
			result["direction"] = player.facing
		RANGE_SWITCH:
			var switch_px: float = Data.cfg_float("combat.range_switch_tiles") * Data.cfg_float("world.tile_px")
			var close: int = enemies.nearest(player.position, switch_px)
			result["melee"] = close != -1
			result["target"] = close if close != -1 else _prefer_priority(player.position, weapon_range, enemies)
			result["fire"] = result["target"] != -1
		_:
			push_error("Targeting: unknown targeting type '%s'" % type)
			result["fire"] = false
	if result["target"] != -1:
		result["direction"] = direction_to(player.position, result["target"], enemies, player.facing)
	return result


## Direction from `from` to an enemy slot (facing if it's on top of us).
static func direction_to(from: Vector2, slot: int, enemies: EnemyManager, fallback: Vector2) -> Vector2:
	var offset: Vector2 = enemies.positions[slot] - from
	return offset.normalized() if offset.length_squared() > 0.0001 else fallback


## Nearest enemy, but an elite or boss wins if it's within 1.5× the nearest distance.
static func _prefer_priority(from: Vector2, weapon_range: float, enemies: EnemyManager) -> int:
	var nearest: int = enemies.nearest(from, weapon_range)
	if nearest == -1:
		return -1
	var limit: float = enemies.positions[nearest].distance_to(from) * Data.cfg_float("combat.priority_target_range_mult")
	var best: int = nearest
	var best_dist: float = INF
	for slot: int in enemies.query(from, minf(limit, weapon_range)):
		if enemies.is_priority(slot):
			var dist: float = enemies.positions[slot].distance_to(from)
			if dist < best_dist:
				best_dist = dist
				best = slot
	return best
