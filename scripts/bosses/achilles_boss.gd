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
		var at: Vector2 = position_now() - global_position
		var r: float = GameAuthority.enemies.radius[slot]
		var rage := Color.html(Data.cfg_string("bosses.rage_color"))
		draw_arc(at, r + 3.0, 0.0, TAU, 20, rage, 2.0)
		# His wrath burns round him (owner request 10/31/2026; the flame Athena kindles on his head, Iliad 18.205).
		var t: float = GameAuthority.run.elapsed_s if GameAuthority.run != null else 0.0
		for f: int in 10:
			var a: float = TAU * f / 10.0 + t
			var base: Vector2 = at + Vector2.from_angle(a) * (r + 2.0)
			var tall: float = 5.0 + 4.0 * sin(t * 10.0 + f * 2.1)
			draw_colored_polygon(PackedVector2Array([base + Vector2(-3, 0), base + Vector2(3, 0), base + Vector2(0, -tall)]),
					Color(rage, 0.85))
