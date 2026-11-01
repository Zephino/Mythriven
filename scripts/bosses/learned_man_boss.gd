class_name LearnedManBoss
extends BossController
## The Learned Man, 10:00 (docs/PACK_12_PLAN.md: the Shadow's Court). Signature, the shadow's shadow: he clings to the
## dark side of the nearest Hero, away from the lamp that burns in the arena, like a shadow. Brought into the lamp's
## light he fades and takes double damage. Source: Andersen, "The Shadow" (1847: the learned man becomes his own shadow's
## shadow).

var lamp := Vector2.INF
## Damage he has taken in the lamplight.
var lit_damage: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and lamp == Vector2.INF:
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		lamp = centre + Vector2(0.0, -float(_sig().get("lamp_px", 110.0)))
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_LEARNED_MAN_LAMP"))


func in_light() -> bool:
	return lamp != Vector2.INF and position_now().distance_to(lamp) <= float(_sig().get("lamp_radius_px", 90.0))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if in_light():
		amount *= float(_sig().get("lit_damage_taken", 2.0))
		lit_damage += amount
	return amount


## Where he wants to be: just behind the nearest Hero, on the side away from the lamp.
func shadow_spot(player: Player) -> Vector2:
	var away: Vector2 = player.position - lamp
	if away.length() < 1.0:
		away = Vector2.DOWN
	return player.position + away.normalized() * float(_sig().get("behind_px", 40.0))


func _move(delta: float) -> void:
	if target == null or lamp == Vector2.INF:
		super._move(delta)
		return
	var to: Vector2 = shadow_spot(target) - position_now()
	facing = (target.position - position_now()).normalized() if target.position != position_now() else facing
	GameAuthority.enemies.positions[slot] += to.limit_length(float(_sig().get("follow_px_s", 70.0)) * GameAuthority.enemies.statuses.speed_mult(slot) * delta)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the lamp moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if lamp != Vector2.INF:
		lamp -= shift_px


## The lamp on its post, and its pool of light.
func _draw() -> void:
	if lamp != Vector2.INF and is_alive():
		var p: Vector2 = lamp - global_position
		draw_circle(p, float(_sig().get("lamp_radius_px", 90.0)), Color(1.0, 0.9, 0.55, 0.12))
		draw_line(p + Vector2(0, 14), p + Vector2(0, -6), Color(0.2, 0.2, 0.22), 2.0)
		draw_rect(Rect2(p + Vector2(-4, -14), Vector2(8, 9)), Color(1.0, 0.85, 0.4))
		draw_rect(Rect2(p + Vector2(-4, -14), Vector2(8, 9)), Color(0.2, 0.2, 0.22), false, 1.0)
	super._draw()
