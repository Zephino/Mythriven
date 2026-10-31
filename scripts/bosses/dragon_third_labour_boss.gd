class_name DragonThirdLabourBoss
extends BossController
## The Dragon of the Third Labour, 10:00 (docs/PACK_3_PLAN.md: Mazandaran). Signature, hidden in darkness: it can't be
## seen except near a Hero (within light_px) or for a few seconds after Holy light strikes it, and while hidden it
## takes little harm. Source: the Shahnameh, third labour (the dragon came out of the dark three times while Rostam
## slept; each time it vanished before he could see it, until Rakhsh woke him and God let him see it).

var revealed_s: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func on_element_hit(element: String) -> void:
	if element == "holy":
		revealed_s = float(_sig().get("revealed_s", 4.0))


## True when it can be seen: a Hero is close, or Holy light lit it up.
func is_seen() -> bool:
	if revealed_s > 0.0 or broken_s > 0.0:
		return true
	var at: Vector2 = position_now()
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= float(_sig().get("light_px", 90.0)):
			return true
	return false


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount if is_seen() else amount * float(_sig().get("hidden_damage_mult", 0.25))


func signature(delta: float) -> void:
	revealed_s = maxf(revealed_s - delta, 0.0)


## Hidden, only two burning eyes show in the dark.
func _draw() -> void:
	if not is_alive():
		return
	if is_seen():
		super._draw()
		return
	var at: Vector2 = position_now() - global_position + Vector2(0, -10)
	var blink: float = 0.6 + 0.4 * sin(Time.get_ticks_msec() * 0.005)
	draw_circle(at + Vector2(-5, 0), 2.0, Color(1.0, 0.6, 0.1, blink))
	draw_circle(at + Vector2(5, 0), 2.0, Color(1.0, 0.6, 0.1, blink))
