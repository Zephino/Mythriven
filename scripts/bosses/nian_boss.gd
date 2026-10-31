class_name NianBoss
extends BossController
## Nian, 10:00 (docs/BONUS_LEVELS_PLAN.md: the Realm of the Ten Suns). Signature, frightened: Nian fears loud noise, fire
## and the colour red, so a Lightning (thunder) or Fire hit stuns it for a moment (no more often than every few
## seconds). Source: Chinese New Year folklore (firecrackers and red drive the Nian away).

var _scare_ready: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func on_element_hit(element: String) -> void:
	if _scare_ready > 0.0 or not is_alive() or not (_sig().get("elements", ["lightning", "fire"]) as Array).has(element):
		return
	_scare_ready = float(_sig().get("cooldown_s", 3.0))
	GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], float(_sig().get("stun_s", 0.8)))
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(position_now(), 40.0, Color(0.9, 0.2, 0.2), true)


func signature(delta: float) -> void:
	_scare_ready = maxf(_scare_ready - delta, 0.0)
