class_name CoraniaidBoss
extends BossController
## The Coraniaid, 10:00 (docs/PACK_11_PLAN.md: Dinas Emrys). Signature, the hearing: they hear every word the wind
## touches, so when a blow comes they hear it and step aside (it misses), though they need a moment before they can do it
## again. Pools of Llefelys' insect-water lie about the arena: standing in one they can't step aside and take triple
## damage. Source: "Lludd and Llefelys" (the Coraniaid, the first plague of Britain; the insects steeped in water).

var pools: Array[Vector2] = []
var sidesteps: int = 0
## Damage taken while standing in the insect-water.
var soaked_damage: float = 0.0
var _hear_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and pools.is_empty():
		var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		var n: int = int(_sig().get("pools", 3))
		for k: int in n:
			pools.append(centre + Vector2.from_angle(k * TAU / n + rng.randf() * 0.5) * rng.randf_range(70.0, 150.0))


func in_pool() -> bool:
	var reach: float = float(_sig().get("pool_radius_px", 34.0))
	for at: Vector2 in pools:
		if position_now().distance_to(at) <= reach:
			return true
	return false


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if in_pool():
		amount *= float(_sig().get("pool_damage_taken", 3.0))
		soaked_damage += amount
		return amount
	if _hear_in <= 0.0 and is_alive() and broken_s <= 0.0:
		_hear_in = float(_sig().get("sidestep_every_s", 2.0))
		sidesteps += 1
		var from: Vector2 = attacker.position if attacker != null else position_now() + Vector2.LEFT
		var side: Vector2 = (position_now() - from).orthogonal().normalized()
		if sidesteps % 2 == 0:
			side = -side
		GameAuthority.enemies.positions[slot] += side * float(_sig().get("sidestep_px", 40.0))
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null and sidesteps == 1:
			banner.show_text(tr("BOSS_CORANIAID_HEARS"))
		return 0.0
	return amount


func signature(delta: float) -> void:
	_hear_in = maxf(_hear_in - delta, 0.0)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the pools move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in pools.size():
		pools[i] -= shift_px


## The pools of insect-water: dark water with specks in it.
func _draw() -> void:
	if is_alive():
		var reach: float = float(_sig().get("pool_radius_px", 34.0))
		for at: Vector2 in pools:
			var p: Vector2 = at - global_position
			draw_set_transform(p, 0.0, Vector2(1.0, 0.6))
			draw_circle(Vector2.ZERO, reach, Color(0.25, 0.4, 0.45, 0.55))
			draw_set_transform(Vector2.ZERO)
			for k: int in 6:
				draw_circle(p + Vector2.from_angle(k * 1.1) * reach * 0.5 * Vector2(1.0, 0.6), 1.0, Color(0.1, 0.12, 0.08))
	super._draw()
