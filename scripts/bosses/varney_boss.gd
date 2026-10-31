class_name VarneyBoss
extends BossController
## Varney, 10:00 (docs/PACK_5_PLAN.md: Karnstein). Signature, raised by the moon: the first time he is struck down he
## falls and lies in the moonlight, and after a few seconds he rises again with part of his strength, unless a Hero
## stands over him and blocks the light; then he stays dead. Once risen he can die as usual. Source: Rymer and Prest,
## Varney the Vampire (1845-47): the moon's rays restore the fallen vampire.

## Seconds left lying in the moonlight (> 0 while fallen).
var fallen_s: float = 0.0
var risen: bool = false
var finished: bool = false


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if fallen_s > 0.0:
		return 0.0
	var after: float = float((data.get("guard_gauge", {}) as Dictionary).get("damage_taken_mult", 1.5)) if broken_s > 0.0 else 1.0
	return cap_lethal(amount * after) / after


## Before he has risen once, a killing blow only lays him down in the moonlight.
func cap_lethal(amount: float) -> float:
	if risen or finished or not is_alive():
		return amount
	if fallen_s > 0.0:
		return 0.0
	var hp: float = GameAuthority.enemies.hp[slot]
	if amount >= hp - 1.0:
		fall()
		return maxf(hp - 1.0, 0.0)
	return amount


func fall() -> void:
	fallen_s = float(_sig().get("moonlight_s", 4.0))
	GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], fallen_s)
	if patterns != null:
		patterns.clear()
	cast = {}


func signature(delta: float) -> void:
	if not is_alive() or fallen_s <= 0.0:
		return
	var at: Vector2 = position_now()
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= float(_sig().get("block_radius_px", 34.0)) + player.body_radius:
			# The light is blocked: he stays dead.
			finished = true
			fallen_s = 0.0
			GameAuthority.kill_enemy(slot, player)
			return
	fallen_s -= delta
	if fallen_s <= 0.0:
		rise()


func rise() -> void:
	risen = true
	fallen_s = 0.0
	var enemies: EnemyManager = GameAuthority.enemies
	enemies.hp[slot] = enemies.max_hp[slot] * float(_sig().get("rise_fraction", 0.35))
	enemies.statuses.stun[slot] = 0.0
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_VARNEY_RISES"))


## The moonlight on him while he lies fallen, and the ring a Hero must step into to block it.
func _draw() -> void:
	super._draw()
	if fallen_s <= 0.0 or not is_alive():
		return
	var at: Vector2 = position_now() - global_position
	var reach: float = float(_sig().get("block_radius_px", 34.0))
	draw_circle(at, reach, Color(0.85, 0.9, 1.0, 0.18))
	draw_arc(at, reach, 0.0, TAU, 32, Color(0.9, 0.95, 1.0, 0.7), 1.5)


## The Moon Blocked secret: he never rose again.
func secret_earned() -> String:
	return "the_moon_blocked" if finished and not risen else ""
