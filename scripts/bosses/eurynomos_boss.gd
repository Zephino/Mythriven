class_name EurynomosBoss
extends BossController
## Eurynomos, 20:00 (docs/PACK_5_PLAN.md: Erebus). Signature, the eater of the dead: every few seconds he devours the
## monsters close to him and heals for each one, so fight him away from the crowd. Source: Pausanias, Description of
## Greece 10.28.7 (the daemon in Polygnotus' painting who eats the flesh of the dead, leaving only the bones).

var _devour_in: float = 4.0
var devoured: int = 0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_devour_in -= delta
	if _devour_in <= 0.0:
		_devour_in = float(_sig().get("devour_every_s", 5.0))
		devour()


## Eats up to `devour_max` ordinary monsters within reach; returns how many.
func devour() -> int:
	var enemies: EnemyManager = GameAuthority.enemies
	var at: Vector2 = position_now()
	var reach: float = float(_sig().get("devour_radius_px", 90.0))
	var eaten: int = 0
	for other: int in enemies.query(at, reach):
		if eaten >= int(_sig().get("devour_max", 6)):
			break
		if other == slot or enemies.active[other] == 0 or enemies.is_elite(other) or bool(enemies.type_of(other).get("boss", false)):
			continue
		if enemies.positions[other].distance_to(at) > reach:
			continue
		enemies.remove_quietly(other)
		eaten += 1
	if eaten > 0:
		devoured += eaten
		enemies.hp[slot] = minf(enemies.hp[slot] + enemies.max_hp[slot] * float(_sig().get("heal_fraction_each", 0.01)) * eaten, enemies.max_hp[slot])
		var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
		if effects != null:
			effects.spawn_ring(at, reach, Color(0.35, 0.5, 0.75), true)
	return eaten
