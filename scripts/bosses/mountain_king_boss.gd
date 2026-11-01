class_name MountainKingBoss
extends BossController
## The Mountain King, 30:00 (docs/PACK_13_PLAN.md: Dovrefjell; the design's boss). Signature, the hall: every so often he
## gives the nearest Hero the troll's eye (Hexed). But a church bell stands in the arena: a Hero who stands at it for a
## moment rings it, and the hall falls in round him (stunned, double damage); the bell can be rung again a while later.
## Source: Ibsen, Peer Gynt (1867), Act II (the Dovre-King's hall; the church bells that save Peer).

var bell := Vector2.INF
var rung: int = 0
var eyes: int = 0
var rung_s: float = 0.0
var _eye_in: float = 5.0
var _held: float = 0.0
var _bell_again: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and bell == Vector2.INF:
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		bell = centre + Vector2(0.0, float(_sig().get("bell_px", 130.0)))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("rung_damage_taken", 2.0)) if rung_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	_bell_again = maxf(_bell_again - delta, 0.0)
	if _bell_again <= 0.0 and bell != Vector2.INF:
		var on: bool = false
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(bell) <= float(_sig().get("bell_reach_px", 20.0)) + player.body_radius:
				on = true
		_held = _held + delta if on else 0.0
		if _held >= float(_sig().get("ring_s", 2.0)):
			ring()
	if rung_s > 0.0:
		rung_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(rung_s, 0.2))
		return
	_eye_in -= delta
	if _eye_in <= 0.0:
		_eye_in = float(_sig().get("eye_every_s", 9.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			eyes += 1
			near.statuses.apply("hex")
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null and eyes == 1:
				banner.show_text(tr("BOSS_MOUNTAIN_KING_EYE"))


## The church bell rings: the hall falls in round the troll king.
func ring() -> void:
	rung += 1
	_held = 0.0
	_bell_again = float(_sig().get("bell_again_s", 15.0))
	rung_s = float(_sig().get("rung_s", 3.0))
	cast = {}
	if patterns != null:
		patterns.clear()
	GameCamera.shake_screen(get_tree(), Data.cfg_float("settings.shake_guard_break_px"))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_MOUNTAIN_KING_BELL"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the bell moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if bell != Vector2.INF:
		bell -= shift_px


## The church bell on its little wooden frame, swinging while it rings.
func _draw() -> void:
	if bell != Vector2.INF and is_alive():
		var p: Vector2 = bell - global_position
		var wood := Color(0.4, 0.28, 0.16)
		draw_line(p + Vector2(-12, 10), p + Vector2(-10, -18), wood, 2.0)
		draw_line(p + Vector2(12, 10), p + Vector2(10, -18), wood, 2.0)
		draw_line(p + Vector2(-12, -18), p + Vector2(12, -18), wood, 2.0)
		var swing: float = sin(Time.get_ticks_msec() / 80.0) * 0.4 if rung_s > 0.0 else 0.0
		draw_set_transform(p + Vector2(0, -17), swing, Vector2.ONE)
		draw_colored_polygon(PackedVector2Array([Vector2(-3, 0), Vector2(3, 0), Vector2(7, 12), Vector2(-7, 12)]), Color(0.75, 0.6, 0.3) if _bell_again <= 0.0 else Color(0.45, 0.4, 0.3))
		draw_set_transform(Vector2.ZERO)
		if _held > 0.0:
			draw_arc(p, 22.0, -PI / 2, -PI / 2 + TAU * _held / float(_sig().get("ring_s", 2.0)), 24, Color(1.0, 0.9, 0.5), 2.0)
	super._draw()
