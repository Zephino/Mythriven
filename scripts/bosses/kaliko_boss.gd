class_name KalikoBoss
extends BossController
## Kaliko, 10:00 (docs/PACK_9_PLAN.md: the Hollow Hills). Signature, the tunnels: three holes open in the arena. Kaliko
## comes up out of one, fights for a few seconds, then drops back down (he can't be hurt below) and pops up out of
## another, with a burst of rock round him. Source: L. Frank Baum, Ozma of Oz (1907): Kaliko, the Nome King's chief
## steward, in the tunnels of the Nome kingdom.

var holes: Array[Vector2] = []
var below_s: float = 0.0
var pops: int = 0
var _above_s: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return 0.0 if below_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if holes.is_empty():
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		var turn: float = GameAuthority.run.rng.combat.randf() * TAU
		for k: int in 3:
			holes.append(centre + Vector2.from_angle(turn + TAU * k / 3.0) * float(_sig().get("hole_px", 140.0)))
	if below_s > 0.0:
		below_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(below_s, 0.2))
		if below_s <= 0.0:
			pop_up()
		return
	_above_s -= delta
	if _above_s <= 0.0:
		below_s = float(_sig().get("below_s", 2.0))
		cast = {}
		if patterns != null:
			patterns.clear()


## Up out of a hole (not the one he went down), with a burst of rock.
func pop_up() -> void:
	pops += 1
	_above_s = float(_sig().get("above_s", 4.0))
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var at: Vector2 = holes[rng.randi() % holes.size()]
	if at.distance_to(position_now()) < 1.0:
		at = holes[(holes.find(at) + 1) % holes.size()]
	GameAuthority.enemies.positions[slot] = at
	var reach: float = float(_sig().get("burst_radius_px", 50.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("burst_damage", 14.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.55, 0.45, 0.35), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the holes move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in holes.size():
		holes[i] -= shift_px


func _draw() -> void:
	for at: Vector2 in holes:
		draw_set_transform(at - global_position, 0.0, Vector2(1.0, 0.55))
		draw_circle(Vector2.ZERO, 18.0, Color(0.35, 0.28, 0.2))
		draw_circle(Vector2.ZERO, 13.0, Color(0.05, 0.04, 0.03))
		draw_set_transform(Vector2.ZERO)
	if below_s <= 0.0:
		super._draw()
