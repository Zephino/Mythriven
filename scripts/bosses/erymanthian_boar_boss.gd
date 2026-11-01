class_name ErymanthianBoarBoss
extends MorvarchBoss
## The Erymanthian Boar, 20:00 (docs/PACK_7_PLAN.md: Arcadia). Signature, the deep snow: it charges across the arena
## (the gallop), but snowdrifts lie about, and if it charges into one it sticks fast for a few seconds. Lure it into
## the drifts. Source: Apollodorus, Library 2.5.4 (Heracles drove the boar into deep snow and snared it).

var drifts: Array[Vector2] = []
var stuck_s: float = 0.0
var stuck_count: int = 0


func signature(delta: float) -> void:
	if not is_alive():
		return
	if drifts.is_empty():
		_lay_drifts()
	if stuck_s > 0.0:
		stuck_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(stuck_s, 0.2))
		return
	super.signature(delta)
	if gallop_s > 0.0:
		var reach: float = float(_sig().get("drift_radius_px", 30.0))
		for at: Vector2 in drifts:
			if position_now().distance_to(at) <= reach:
				stick()
				return


func _lay_drifts() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	for k: int in int(_sig().get("drifts", 4)):
		drifts.append(centre + Vector2.from_angle(TAU * k / float(_sig().get("drifts", 4)) + rng.randf()) * rng.randf_range(90.0, 180.0))


## Stuck fast in the snow.
func stick() -> void:
	stuck_count += 1
	gallop_s = 0.0
	stuck_s = float(_sig().get("stuck_s", 3.0))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and stuck_count == 1:
		banner.show_text(tr("BOSS_ERYMANTHIAN_STUCK"))


func on_origin_shifted(shift_px: Vector2, shift_chunks: Vector2i) -> void:
	super.on_origin_shifted(shift_px, shift_chunks)
	for i: int in drifts.size():
		drifts[i] -= shift_px


## The snowdrifts.
func _draw() -> void:
	var reach: float = float(_sig().get("drift_radius_px", 30.0))
	for at: Vector2 in drifts:
		var p: Vector2 = at - global_position
		draw_set_transform(p, 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, reach, Color(0.86, 0.9, 0.96, 0.85))
		draw_circle(Vector2(-4, -3), reach * 0.6, Color(0.97, 0.98, 1.0, 0.9))
		draw_set_transform(Vector2.ZERO)
	super._draw()
