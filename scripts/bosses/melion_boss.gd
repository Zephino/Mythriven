class_name MelionBoss
extends BossController
## Melion, 20:00 (docs/PACK_5_PLAN.md: Ossory). Signature, the pack leader: every few seconds he howls and wolves come
## to him, and every wolf close to him shields him (less damage taken for each, up to a limit). Kill his pack to reach
## him. Source: the Lai de Melion (13th c.): the knight left a wolf by his faithless wife, who led a pack of wolves
## through Ireland.

var _call_in: float = 2.0
var calls: int = 0


func _sig() -> Dictionary:
	return data.get("signature", {})


## Wolves of his pack within reach.
func pack_near() -> int:
	var enemies: EnemyManager = GameAuthority.enemies
	var at: Vector2 = position_now()
	var reach: float = float(_sig().get("shield_radius_px", 120.0))
	var wolf: String = str(_sig().get("wolf", "wolf"))
	var count: int = 0
	for other: int in enemies.query(at, reach):
		if other != slot and enemies.active[other] != 0 and str(enemies.type_of(other).get("id", "")) == wolf \
				and enemies.positions[other].distance_to(at) <= reach:
			count += 1
	return count


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	var shield: float = minf(pack_near() * float(_sig().get("shield_per_wolf", 0.1)), float(_sig().get("max_shield", 0.6)))
	return amount * (1.0 - shield)


func signature(delta: float) -> void:
	if not is_alive():
		return
	_call_in -= delta
	if _call_in <= 0.0:
		_call_in = float(_sig().get("call_every_s", 10.0))
		call_pack()


func call_pack() -> void:
	calls += 1
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var at: Vector2 = position_now()
	for _k: int in int(_sig().get("wolves", 4)):
		GameAuthority.spawn_enemy(str(_sig().get("wolf", "wolf")), at + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(40.0, 90.0))
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, float(_sig().get("shield_radius_px", 120.0)), Color(0.6, 0.6, 0.7), true)
