class_name PhantasosBoss
extends BossController
## Phantasos, 10:00 (docs/PACK_10_PLAN.md: Demos Oneiron). Signature, the shaper of things: by turns he becomes a rock
## (he stands still and blows hardly hurt him) or water (he slips about fast). Source: Ovid, Metamorphoses 11.641-643
## (Phantasos, who takes the shapes of earth, rock, water and wood, all things that have no life).

const FORMS := ["rock", "water"]

var form: int = 0
var changes: int = 0
var _left: float = -1.0
var _base_speed: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "phantasos_" + str(FORMS[form])


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("rock_damage_taken", 0.25)) if FORMS[form] == "rock" else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _left < 0.0:
		data = data.duplicate(true)
		_base_speed = float(data.get("move_speed", 40.0))
		_left = float(_sig().get("form_s", 5.0))
		_apply()
	_left -= delta
	if _left <= 0.0:
		_left = float(_sig().get("form_s", 5.0))
		form = (form + 1) % FORMS.size()
		changes += 1
		_apply()


func _apply() -> void:
	data["move_speed"] = 0.0 if FORMS[form] == "rock" else _base_speed * float(_sig().get("water_speed_mult", 2.5))
