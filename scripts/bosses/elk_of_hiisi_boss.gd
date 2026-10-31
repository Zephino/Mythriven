class_name ElkOfHiisiBoss
extends BossController
## The Elk of Hiisi, 10:00 (docs/PACK_3_PLAN.md: Pohjola). Signature, the uncatchable: no skier could catch the elk
## Hiisi made (Kalevala 13-14). It sprints across the field every few seconds, and while it runs free it shrugs off most
## harm; slow it first (Chill, Freeze, stuns, any slowing status) or break its Guard, and it takes full damage.

## Seconds left of the current sprint, and its direction.
var sprint_s: float = 0.0
var sprint_dir := Vector2.RIGHT
var _sprint_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


## True while something holds it back: slowed, frozen, stunned or Guard-broken.
func is_slowed() -> bool:
	if slot == -1 or broken_s > 0.0:
		return broken_s > 0.0
	var st: EnemyStatuses = GameAuthority.enemies.statuses
	return st.stun[slot] > 0.0 or st.frozen[slot] > 0.0 or st.speed_mult(slot) < 0.99


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount if is_slowed() else amount * float(_sig().get("unslowed_damage_mult", 0.15))


func signature(delta: float) -> void:
	if not is_alive():
		return
	_sprint_in -= delta
	if _sprint_in <= 0.0 and sprint_s <= 0.0:
		_sprint_in = float(_sig().get("sprint_every_s", 6.0))
		sprint_s = 0.6
		var toward: Vector2 = (target.position - position_now()) if target != null and is_instance_valid(target) else Vector2.RIGHT
		sprint_dir = toward.normalized().rotated(GameAuthority.run.rng.combat.randf_range(-0.6, 0.6))
	if sprint_s > 0.0:
		sprint_s -= delta
		var speed: float = float(_sig().get("sprint_px", 260.0)) / 0.6 * GameAuthority.enemies.statuses.speed_mult(slot)
		if GameAuthority.enemies.statuses.stun[slot] <= 0.0 and GameAuthority.enemies.statuses.frozen[slot] <= 0.0:
			GameAuthority.enemies.positions[slot] += sprint_dir * speed * delta


func _draw() -> void:
	if is_alive() and sprint_s > 0.0:
		var at: Vector2 = position_now() - global_position
		for k: int in 5:
			var off: Vector2 = sprint_dir.orthogonal() * (k - 2) * 6.0
			draw_line(at + off - sprint_dir * 20.0, at + off - sprint_dir * 50.0, Color(0.9, 0.95, 1.0, 0.6), 1.5)
	if is_alive() and not is_slowed():
		draw_arc(position_now() - global_position, GameAuthority.enemies.radius[slot] + 4.0, 0.0, TAU, 24, Color(0.85, 0.75, 0.5, 0.5), 1.5)
	super._draw()
