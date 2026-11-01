class_name CeryneianHindBoss
extends BossController
## The Ceryneian Hind, 10:00 (docs/PACK_7_PLAN.md: Arcadia). Signature, the endless chase: it hardly fights; whenever a
## Hero comes close it bounds far away across the arena. Corner it, or keep at it until it tires. Source: Apollodorus,
## Library 2.5.3 (the golden-horned hind sacred to Artemis, which Heracles chased for a whole year).

var bounds: int = 0
var _ready_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_ready_in = maxf(_ready_in - delta, 0.0)
	if _ready_in > 0.0:
		return
	var near: Player = GameAuthority.enemies.nearest_player(position_now())
	if near != null and near.position.distance_to(position_now()) <= float(_sig().get("shy_px", 90.0)):
		bound_away(near)


## A great leap away from `from`, staying inside the arena.
func bound_away(from: Player) -> void:
	bounds += 1
	_ready_in = float(_sig().get("bound_cooldown_s", 2.5))
	var enemies: EnemyManager = GameAuthority.enemies
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	var limit: float = float(_sig().get("arena_px", 230.0))
	# Of eight directions, the leap that lands farthest from the Hero (kept inside the arena).
	var to: Vector2 = position_now()
	for k: int in 8:
		var spot: Vector2 = position_now() + Vector2.from_angle(TAU * k / 8.0) * float(_sig().get("bound_px", 220.0))
		if spot.distance_to(centre) > limit:
			spot = centre + (spot - centre).normalized() * limit
		if spot.distance_to(from.position) > to.distance_to(from.position):
			to = spot
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(position_now(), 24.0, Color(0.95, 0.85, 0.4), true)
	enemies.positions[slot] = to


## The Year's Chase secret: caught before it bounds away ten times.
func secret_earned() -> String:
	return "the_years_chase" if bounds < 10 else ""
