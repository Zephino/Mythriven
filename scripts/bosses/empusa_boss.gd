class_name EmpusaBoss
extends BossController
## Empusa, 10:00 (docs/PACK_5_PLAN.md: Erebus). Signature, many shapes: every few seconds she changes shape. As a
## bull she is armoured (takes less damage); as a dog she runs fast; as a woman she attacks more often. Source:
## Aristophanes, The Frogs 285-295 ("now a bull, now a mule, now a lovely woman, now a dog").

const SHAPES := ["woman", "bull", "dog"]

var shape: int = 0
var changes: int = 0
var _left: float = -1.0
var _base_speed: float = -1.0
var _base_every: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "empusa" if shape == 0 else "empusa_" + str(SHAPES[shape])


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if SHAPES[shape] == "bull":
		amount *= float(_sig().get("bull_damage_taken", 0.5))
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _left < 0.0:
		data = data.duplicate(true)
		_base_speed = float(data.get("move_speed", 40.0))
		_base_every = float(data.get("attack_every_s", 2.5))
		_left = float(_sig().get("shape_s", 6.0))
	_left -= delta
	if _left > 0.0:
		return
	_left = float(_sig().get("shape_s", 6.0))
	shift((shape + 1) % SHAPES.size())


func shift(to: int) -> void:
	shape = to
	changes += 1
	data["move_speed"] = _base_speed * (float(_sig().get("dog_speed_mult", 2.2)) if SHAPES[shape] == "dog" else 1.0)
	data["attack_every_s"] = _base_every * (float(_sig().get("woman_attack_mult", 0.6)) if SHAPES[shape] == "woman" else 1.0)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(position_now(), 40.0, Color(0.6, 0.4, 0.7), true)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and changes == 1:
		banner.show_text(tr("BOSS_EMPUSA_SHIFTS"))
