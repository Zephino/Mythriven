class_name KarkinosBoss
extends BossController
## Karkinos, 10:00 (docs/PACK_7_PLAN.md: Lerna). Signature, the shell: blows from in front glance off its claws and
## shell (much less damage); strike it from the side or behind. It scuttles sideways as crabs do. Source: Apollodorus,
## Library 2.5.2 (Hera sends a giant crab to bite Heracles' foot while he fights the Hydra).

var _scuttle: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


## True when `from` is in front of it (where its claws face).
func in_front(from: Vector2) -> bool:
	var to: Vector2 = from - position_now()
	return to.length() > 0.1 and facing.dot(to.normalized()) >= float(_sig().get("front_dot", 0.5))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if attacker != null and in_front(attacker.position):
		return amount * float(_sig().get("front_damage_taken", 0.25))
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	_scuttle += delta
	var enemies: EnemyManager = GameAuthority.enemies
	var side: Vector2 = facing.orthogonal() * sin(_scuttle * float(_sig().get("scuttle_hz", 0.8)) * TAU)
	enemies.positions[slot] += side * float(_sig().get("scuttle_px_s", 50.0)) * enemies.statuses.speed_mult(slot) * delta
