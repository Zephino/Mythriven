class_name AchillesBoss
extends BossController
## Achilles, 20:00, a rival hero's duel (GAME_DESIGN.md: The Aegean Shore
## bosses). Signature, the Heel: he takes −80% damage from the front, and hits
## from behind deal ×2, so circle him. Phases: spear rushes → shield-charge
## combos → rage (faster rushes that leave dust trails). Defeating him
## unlocks him as a Hero (handled by BossManager).


## Front or back: where the hit came from, against the way he faces.
func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	var at: Vector2 = position_now()
	var from := Vector2.INF
	if attacker != null and is_instance_valid(attacker):
		from = attacker.position
	elif push != Vector2.ZERO:
		from = at - push.normalized() * 10.0
	return amount * preload("res://scripts/player/hero_traits/the_heel.gd").heel_mult(at, facing, from, data.get("signature", {}))


func _draw() -> void:
	super._draw()
	if is_alive() and bool(phase().get("rage", false)):
		draw_arc(position_now() - global_position, GameAuthority.enemies.radius[slot] + 3.0, 0.0, TAU, 20,
				Color.html(Data.cfg_string("bosses.rage_color")), 2.0)
