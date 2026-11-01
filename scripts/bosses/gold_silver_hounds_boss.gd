class_name GoldSilverHoundsBoss
extends BossController
## The Gold and Silver Hounds, 20:00 (docs/PACK_9_PLAN.md: Lemnos). Signature, two metals: Alcinous' immortal watchdogs
## take turns at the fight. The gold hound shrugs off Fire but Lightning hurts it double; the silver hound shrugs off
## Lightning but Fire hurts it double. They change places every few seconds. Source: Homer, Odyssey 7.91-94 (gold and
## silver dogs Hephaestus made to guard the house of Alcinous, immortal and ageless for ever).

var gold: bool = true
var swaps: int = 0
var _last_element: String = ""
var _left: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "gold_silver_hounds_gold" if gold else "gold_silver_hounds_silver"


func on_element_hit(element: String) -> void:
	_last_element = element


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	var shrugs: String = "fire" if gold else "lightning"
	var fears: String = "lightning" if gold else "fire"
	if _last_element == shrugs:
		amount *= float(_sig().get("resisted", 0.25))
	elif _last_element == fears:
		amount *= float(_sig().get("feared", 2.0))
	_last_element = ""
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _left < 0.0:
		_left = float(_sig().get("swap_s", 6.0))
	_left -= delta
	if _left <= 0.0:
		_left = float(_sig().get("swap_s", 6.0))
		gold = not gold
		swaps += 1
		var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
		if effects != null:
			effects.spawn_ring(position_now(), 36.0, Color(1.0, 0.85, 0.3) if gold else Color(0.85, 0.88, 0.95), true)
