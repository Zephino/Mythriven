class_name MorpheusBoss
extends BossController
## Morpheus, 20:00 (docs/PACK_10_PLAN.md: Demos Oneiron). Signature, the imitator: he imitates everything, and a share
## of every blow struck at him is turned back on whoever struck it. Source: Ovid, Metamorphoses 11.633-638 (Morpheus, who
## imitates the human form better than any other: the walk, the face, the voice, the dress and the very words).

var mirrored: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if attacker != null and is_instance_valid(attacker) and attacker.alive and amount > 0.0:
		var back: float = minf(amount * float(_sig().get("mirror_fraction", 0.15)), float(_sig().get("mirror_max", 8.0)))
		mirrored += back
		GameAuthority.damage_player_over_time(attacker, back)
	return amount


## A faint second outline beside him, the copy he is making.
func _draw() -> void:
	super._draw()
	if is_alive():
		var at: Vector2 = position_now() - global_position
		draw_arc(at + Vector2(sin(Time.get_ticks_msec() * 0.003) * 6.0, 0), GameAuthority.enemies.radius[slot] + 4.0, 0.0, TAU, 28, Color(0.8, 0.7, 1.0, 0.35), 1.5)


## Your Own Face secret: beaten while he turned back less than 30 damage.
func secret_earned() -> String:
	return "your_own_face" if mirrored < 30.0 else ""
