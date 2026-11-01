class_name LordOfAshkarrowBoss
extends BossController
## The Lord of Ashkarrow, 30:00 (docs/PACK_11_PLAN.md: Ashkarrow, the game's own invented realm). Signature, the four
## braziers: four great braziers burn round the arena, and each one still lit makes him harder to hurt. A Hero who
## stands at a brazier for a moment puts it out; every so often he lights one again.

## The braziers: {"pos", "lit"}.
var braziers: Array = []
var doused: int = 0
## The most braziers ever out at the same moment.
var most_out: int = 0
var _held: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _relight_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and braziers.is_empty():
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		for k: int in 4:
			braziers.append({"pos": centre + Vector2.from_angle(k * TAU / 4.0 + PI / 4.0) * float(_sig().get("brazier_px", 130.0)), "lit": true})
		_relight_in = float(_sig().get("relight_every_s", 10.0))
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_LORD_OF_ASHKARROW_BRAZIERS"))


func lit_count() -> int:
	var n: int = 0
	for b: Dictionary in braziers:
		if bool(b["lit"]):
			n += 1
	return n


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * maxf(1.0 - float(_sig().get("per_brazier_cut", 0.18)) * lit_count(), 0.1)


func signature(delta: float) -> void:
	if not is_alive():
		return
	var reach: float = float(_sig().get("reach_px", 18.0))
	for i: int in braziers.size():
		if not bool(braziers[i]["lit"]):
			_held[i] = 0.0
			continue
		var on: bool = false
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(braziers[i]["pos"]) <= reach + player.body_radius:
				on = true
		_held[i] = _held[i] + delta if on else 0.0
		if _held[i] >= float(_sig().get("douse_s", 1.5)):
			douse(i)
	_relight_in -= delta
	if _relight_in <= 0.0:
		_relight_in = float(_sig().get("relight_every_s", 10.0))
		for b: Dictionary in braziers:
			if not bool(b["lit"]):
				b["lit"] = true
				break


func douse(i: int) -> void:
	braziers[i]["lit"] = false
	_held[i] = 0.0
	doused += 1
	most_out = maxi(most_out, braziers.size() - lit_count())
	_relight_in = maxf(_relight_in, 3.0)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the braziers move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for b: Dictionary in braziers:
		b["pos"] = Vector2(b["pos"]) - shift_px


## The braziers on their stands: flames while lit, cold ash when out, and a ring filling while a Hero puts one out.
func _draw() -> void:
	if is_alive():
		for i: int in braziers.size():
			var at: Vector2 = Vector2(braziers[i]["pos"]) - global_position
			draw_line(at + Vector2(-5, 8), at + Vector2(0, 0), Color(0.25, 0.2, 0.2), 2.0)
			draw_line(at + Vector2(5, 8), at + Vector2(0, 0), Color(0.25, 0.2, 0.2), 2.0)
			draw_rect(Rect2(at + Vector2(-8, -4), Vector2(16, 5)), Color(0.3, 0.26, 0.26))
			if bool(braziers[i]["lit"]):
				draw_colored_polygon(PackedVector2Array([at + Vector2(-7, -4), at + Vector2(0, -18), at + Vector2(7, -4)]), Color(0.95, 0.45, 0.15))
				draw_colored_polygon(PackedVector2Array([at + Vector2(-3, -4), at + Vector2(0, -11), at + Vector2(3, -4)]), Color(1.0, 0.85, 0.4))
				draw_line(at, position_now() - global_position, Color(0.95, 0.45, 0.15, 0.25), 1.0)
			else:
				draw_rect(Rect2(at + Vector2(-6, -6), Vector2(12, 2)), Color(0.5, 0.48, 0.46))
			if _held[i] > 0.0:
				draw_arc(at, 18.0, -PI / 2, -PI / 2 + TAU * _held[i] / float(_sig().get("douse_s", 1.5)), 24, Color(0.7, 0.85, 1.0), 2.0)
	super._draw()


## The Cold Hearth secret: all four braziers out at once at some point, then beaten.
func secret_earned() -> String:
	return "the_cold_hearth" if most_out >= 4 else ""
