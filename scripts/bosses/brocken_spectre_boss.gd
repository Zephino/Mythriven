class_name BrockenSpectreBoss
extends BossController
## The Brocken Spectre, 10:00 (docs/PACK_5_PLAN.md: the Brocken). Signature, the shadow in the mist: it always stands
## opposite the nearest Hero across the middle of the arena, like a shadow cast on the cloud, a ring of coloured light
## (the "glory") round its head. Walk toward the middle and it comes toward you. Source: Johann Silberschlag (1780), the
## first description of the giant shadows seen from the Brocken.


## The Glory secret: seconds since it came (beaten within secret_s).
var age: float = 0.0


func secret_earned() -> String:
	return "the_glory" if age <= float(_sig().get("secret_s", 60.0)) else ""


func _sig() -> Dictionary:
	return data.get("signature", {})


## Where it stands: the Hero's place mirrored through the arena's middle.
func mirror_point(of: Vector2) -> Vector2:
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	return centre * 2.0 - of


func signature(delta: float) -> void:
	age += delta
	if not is_alive() or target == null or not is_instance_valid(target):
		return
	var enemies: EnemyManager = GameAuthority.enemies
	enemies.positions[slot] = enemies.positions[slot].move_toward(mirror_point(target.position),
			float(_sig().get("glide_px_s", 220.0)) * enemies.statuses.speed_mult(slot) * delta)


## The glory: a faint ring of coloured light round its head.
func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	var at: Vector2 = position_now() - global_position + Vector2(0, -GameAuthority.enemies.radius[slot] - 18.0)
	var colours := [Color(0.9, 0.3, 0.3, 0.45), Color(0.95, 0.85, 0.3, 0.45), Color(0.3, 0.8, 0.4, 0.45), Color(0.3, 0.5, 0.95, 0.45)]
	for k: int in colours.size():
		draw_arc(at, 14.0 + k * 2.0, 0.0, TAU, 28, colours[k], 2.0)
