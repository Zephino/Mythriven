class_name SixMonthSleeperBoss
extends BossController
## The Six-Month Sleeper, 20:00 (docs/PACK_10_PLAN.md: Hyperborea). Signature, half asleep: like the men of the far
## north who sleep six months of the year, he is awake for a while (and fights hard), then asleep for a while: asleep he
## heals, but takes double damage. Source: Herodotus, Histories 4.25 (the men beyond the bald men who, it was said, slept
## for six months at a time).

var asleep: bool = false
var naps: int = 0
var _left: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("asleep_damage_taken", 2.0)) if asleep else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _left < 0.0:
		_left = float(_sig().get("awake_s", 8.0))
	_left -= delta
	var enemies: EnemyManager = GameAuthority.enemies
	if asleep:
		enemies.statuses.stun[slot] = maxf(enemies.statuses.stun[slot], 0.2)
		enemies.hp[slot] = minf(enemies.hp[slot] + enemies.max_hp[slot] * float(_sig().get("heal_per_s", 0.015)) * delta, enemies.max_hp[slot])
	if _left > 0.0:
		return
	asleep = not asleep
	_left = float(_sig().get("asleep_s", 5.0)) if asleep else float(_sig().get("awake_s", 8.0))
	if asleep:
		naps += 1
		cast = {}
		if patterns != null:
			patterns.clear()
	else:
		enemies.statuses.stun[slot] = 0.0


func _draw() -> void:
	super._draw()
	if asleep and is_alive():
		var at: Vector2 = position_now() - global_position + Vector2(10, -GameAuthority.enemies.radius[slot] - 20.0)
		for k: int in 3:
			var z: Vector2 = at + Vector2(k * 5, -k * 6)
			draw_polyline(PackedVector2Array([z, z + Vector2(4, 0), z + Vector2(0, 4), z + Vector2(4, 4)]), Color(0.9, 0.95, 1.0), 1.0)
