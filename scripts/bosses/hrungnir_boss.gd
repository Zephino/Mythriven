class_name HrungnirBoss
extends BossController
## Hrungnir, 10:00 (docs/PACK_2_PLAN.md: Jotunheim). Signature, the stone heart: his head and heart are stone, and
## his body shrugs off most harm (stone_damage_mult) until Lightning cracks it, as Thor's hammer broke him; cracked,
## he takes full damage for crack_s. A Guard Break cracks him too, so a Hero without Lightning can still win.
## Source: Snorri, Skaldskaparmal 17.

## Seconds the stone stays cracked (0 = whole).
var cracked_s: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	return super.modify_hit(amount if cracked_s > 0.0 else amount * float(_sig().get("stone_damage_mult", 0.25)), attacker, push)


## Lightning cracks the stone (called by GameAuthority when he's hit, through the element of the hit).
func on_element_hit(element: String) -> void:
	if element == "lightning":
		_crack()


func guard_break() -> void:
	super.guard_break()
	_crack()


func _crack() -> void:
	if cracked_s <= 0.0:
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_HRUNGNIR_CRACKED"))
	cracked_s = float(_sig().get("crack_s", 6.0))


func signature(delta: float) -> void:
	cracked_s = maxf(cracked_s - delta, 0.0)


func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	var at: Vector2 = position_now() - global_position
	var r: float = GameAuthority.enemies.radius[slot] + 4.0
	if cracked_s > 0.0:
		for k: int in 5:
			var a: float = TAU * k / 5.0
			draw_line(at + Vector2.from_angle(a) * r * 0.3, at + Vector2.from_angle(a + 0.3) * r, Color(1.0, 0.95, 0.6, 0.9), 1.5)
	else:
		draw_arc(at, r, 0.0, TAU, 24, Color(0.75, 0.75, 0.8, 0.6), 2.0)
