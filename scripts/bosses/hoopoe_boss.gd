class_name HoopoeBoss
extends BossController
## The Hoopoe, 10:00 (docs/PACK_4_PLAN.md: Cloud-Cuckoo-Land). Signature, the call of the birds: every few seconds the
## king of the birds calls, and a flock comes from every side to close round his target. Source: Aristophanes, The
## Birds (Tereus, turned into a hoopoe, calls the birds together).

var calls: int = 0
var _call_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_call_in -= delta
	if _call_in <= 0.0:
		_call_in = float(_sig().get("call_every_s", 6.0))
		call_birds()


func call_birds() -> void:
	calls += 1
	var around: Vector2 = target.position if target != null and is_instance_valid(target) else position_now()
	var n: int = int(_sig().get("flock", 8))
	for k: int in n:
		GameAuthority.spawn_enemy(str(_sig().get("add", "bird_flock")), around + Vector2.from_angle(TAU * k / n) * 220.0)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and calls == 1:
		banner.show_text(tr("BOSS_HOOPOE_CALLS"))
