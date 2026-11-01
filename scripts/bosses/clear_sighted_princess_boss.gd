class_name ClearSightedPrincessBoss
extends BossController
## The Princess Who Saw Too Clearly, 20:00 (docs/PACK_12_PLAN.md: the Shadow's Court). Signature, too clear a sight: her
## gaze sweeps slowly round her in a wide cone, hurting and Shocking every Hero it falls on. She can't see behind her:
## blows struck from behind hurt her more. Source: Andersen, "The Shadow" (1847: the princess who suffered from seeing too
## clearly).

var gaze_angle: float = 0.0
## Times her gaze has caught a Hero.
var seen: int = 0
var _gaze_in: float = 0.5


func _sig() -> Dictionary:
	return data.get("signature", {})


func gaze_dir() -> Vector2:
	return Vector2.from_angle(gaze_angle)


func sees(at: Vector2) -> bool:
	var to: Vector2 = at - position_now()
	if to.length() > float(_sig().get("range_px", 220.0)) or to.length() < 1.0:
		return to.length() < 1.0
	return absf(gaze_dir().angle_to(to)) <= deg_to_rad(float(_sig().get("cone_deg", 35.0)))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if attacker != null and gaze_dir().dot((attacker.position - position_now()).normalized()) < -0.3:
		return amount * float(_sig().get("behind_damage_taken", 1.5))
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	gaze_angle = wrapf(gaze_angle + float(_sig().get("turn_rad_s", 0.8)) * delta, -PI, PI)
	_gaze_in -= delta
	if _gaze_in > 0.0:
		return
	_gaze_in = float(_sig().get("gaze_every_s", 0.5))
	for player: Player in GameAuthority.players:
		if player.alive and sees(player.position):
			seen += 1
			GameAuthority.damage_player(player, float(_sig().get("gaze_damage", 4.0)), str(data.get("id", "")), position_now())
			player.statuses.apply("shock")
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null and seen == 1:
				banner.show_text(tr("BOSS_CLEAR_SIGHTED_PRINCESS_GAZE"))


## Her gaze: a pale cone sweeping round her.
func _draw() -> void:
	if is_alive():
		var me: Vector2 = position_now() - global_position
		var half: float = deg_to_rad(float(_sig().get("cone_deg", 35.0)))
		var r: float = float(_sig().get("range_px", 220.0))
		var pts := PackedVector2Array([me])
		for k: int in 13:
			pts.append(me + Vector2.from_angle(gaze_angle - half + 2.0 * half * k / 12.0) * r)
		draw_colored_polygon(pts, Color(0.85, 0.9, 1.0, 0.12))
		draw_line(me, me + Vector2.from_angle(gaze_angle - half) * r, Color(0.85, 0.9, 1.0, 0.4), 1.0)
		draw_line(me, me + Vector2.from_angle(gaze_angle + half) * r, Color(0.85, 0.9, 1.0, 0.4), 1.0)
	super._draw()
