class_name BrokkrBoss
extends BossController
## Brokkr, 20:00 (docs/PACK_6_PLAN.md: Nidavellir). Signature, the bellows: every so often he stands at the forge
## working the bellows while a treasure is made. Hurt him enough while he works (as the fly stung him) and the forging
## fails; let him finish and the hammer is made, and his blows are stronger for a while. Source: Snorri,
## Skaldskaparmal 35 (Brokkr at the bellows, stung by a fly; Mjolnir comes out short in the handle).

var working_s: float = 0.0
var hammer_s: float = 0.0
var forged: int = 0
var spoiled: int = 0
var _stung: float = 0.0
var _work_in: float = 6.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if working_s > 0.0:
		_stung += amount
		if _stung >= GameAuthority.enemies.max_hp[slot] * float(_sig().get("sting_fraction", 0.05)):
			spoil()
	return amount


func _damage_mult() -> float:
	return super._damage_mult() * (float(_sig().get("hammer_mult", 1.5)) if hammer_s > 0.0 else 1.0)


func signature(delta: float) -> void:
	if not is_alive():
		return
	hammer_s = maxf(hammer_s - delta, 0.0)
	if working_s > 0.0:
		working_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(working_s, 0.2))
		if working_s <= 0.0:
			finish()
		return
	_work_in -= delta
	if _work_in <= 0.0:
		_work_in = float(_sig().get("work_every_s", 12.0))
		start_work()


func start_work() -> void:
	working_s = float(_sig().get("work_s", 4.0))
	_stung = 0.0
	cast = {}
	if patterns != null:
		patterns.clear()
	_say("BOSS_BROKKR_BELLOWS")


## The fly stings: the treasure is spoiled.
func spoil() -> void:
	working_s = 0.0
	spoiled += 1
	GameAuthority.enemies.statuses.stun[slot] = 0.0
	_say("BOSS_BROKKR_SPOILED")


func finish() -> void:
	forged += 1
	hammer_s = float(_sig().get("hammer_s", 8.0))
	_say("BOSS_BROKKR_HAMMER")


func _say(key: String) -> void:
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr(key))


## The forge's glow while he works, filling as the treasure takes shape.
func _draw() -> void:
	super._draw()
	if working_s <= 0.0 or not is_alive():
		return
	var at: Vector2 = position_now() - global_position
	var full: float = float(_sig().get("work_s", 4.0))
	draw_arc(at, 34.0, -PI / 2, -PI / 2 + TAU * (1.0 - working_s / full), 32, Color(1.0, 0.6, 0.2), 3.0)


## The Fly's Sting secret: his forging spoiled three times.
func secret_earned() -> String:
	return "the_flys_sting" if spoiled >= 3 else ""
