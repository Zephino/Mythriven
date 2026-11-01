class_name GreatBearBoss
extends BossController
## The Great Bear, 20:00 (docs/PACK_10_PLAN.md: the Empyrean). Signature, the bear that never sets: she circles the
## arena without stopping, as the Bear turns round the pole and never sinks below the sea, swiping whoever comes near her
## path. Sources: Ovid, Metamorphoses 2.401-530 (Callisto made a bear and set among the stars); Aratus, Phaenomena 26-62
## (the Bears turn round the pole).

var angle: float = 0.0
## The Bear Sets secret: seconds since she came (beaten within secret_s).
var age: float = 0.0
var swipes: int = 0
var _swipe_in: float = 1.0
var _started: bool = false


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	age += delta
	var enemies: EnemyManager = GameAuthority.enemies
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	if not _started:
		_started = true
		angle = (position_now() - centre).angle()
	angle += float(_sig().get("turn_rad_s", 0.6)) * enemies.statuses.speed_mult(slot) * delta
	enemies.positions[slot] = centre + Vector2.from_angle(angle) * float(_sig().get("orbit_px", 150.0))
	_swipe_in -= delta
	if _swipe_in <= 0.0:
		_swipe_in = float(_sig().get("swipe_every_s", 1.0))
		var reach: float = float(_sig().get("swipe_radius_px", 50.0))
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(position_now()) <= reach + player.body_radius:
				swipes += 1
				GameAuthority.damage_player(player, float(_sig().get("swipe_damage", 12.0)), str(data.get("id", "")), position_now())


## Her path round the pole.
func _draw() -> void:
	if is_alive():
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		draw_arc(centre - global_position, float(_sig().get("orbit_px", 150.0)), 0.0, TAU, 64, Color(0.75, 0.8, 1.0, 0.15), 1.0)
	super._draw()


func secret_earned() -> String:
	return "the_bear_sets" if age <= float(_sig().get("secret_s", 60.0)) else ""
