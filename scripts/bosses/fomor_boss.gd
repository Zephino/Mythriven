class_name FomorBoss
extends BossController
## The Fomor, 20:00 (docs/PACK_12_PLAN.md: Tír na nÓg). Signature, three days and three nights: by day he fights; at each
## nightfall he rests a moment and gets back a third of the damage done to him since dawn. Source: Coimín, "Laoi Oisín i
## dTír na nÓg" (Oisín fights the Fomorian giant for three days and three nights).

var nights: int = 0
var night_s: float = 0.0
## Damage taken since dawn.
var since_dawn: float = 0.0
var _day_left: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	since_dawn += amount
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _day_left < 0.0:
		_day_left = float(_sig().get("day_s", 12.0))
	if night_s > 0.0:
		night_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(night_s, 0.2))
		if night_s <= 0.0:
			since_dawn = 0.0
			_day_left = float(_sig().get("day_s", 12.0))
		return
	_day_left -= delta
	if _day_left <= 0.0:
		nightfall()


## Night: he rests, and a third of the day's wounds close.
func nightfall() -> void:
	nights += 1
	night_s = float(_sig().get("night_s", 3.0))
	var enemies: EnemyManager = GameAuthority.enemies
	enemies.hp[slot] = minf(enemies.hp[slot] + since_dawn * float(_sig().get("night_heal", 0.33)), enemies.max_hp[slot])
	since_dawn = 0.0
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and nights == 1:
		banner.show_text(tr("BOSS_FOMOR_NIGHT"))


## A dark sky over him while he rests at night.
func _draw() -> void:
	if night_s > 0.0 and is_alive():
		var me: Vector2 = position_now() - global_position
		draw_circle(me, float(data.get("radius", 26.0)) + 20.0, Color(0.05, 0.05, 0.2, 0.35))
		draw_circle(me + Vector2(18, -40), 5.0, Color(0.95, 0.95, 0.85))
	super._draw()
