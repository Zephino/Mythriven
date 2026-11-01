class_name FinvarraBoss
extends BossController
## Finvarra, 30:00 (docs/PACK_12_PLAN.md: Tír na nÓg; the design's boss). Signature, the hill of Knockma: every so often
## he carries the nearest Hero off into his hill (whisked across the arena and Hexed). His hill stands in the arena: a
## Hero who stands on it for a moment digs into it and breaks his guard, as Ethna's husband dug into Knockma to win her
## back; the hill can be dug again a while later. Source: Lady Wilde, Ancient Legends of Ireland (1887), "Ethna the
## Bride".

var hill := Vector2.INF
var carried: int = 0
var digs: int = 0
var _carry_in: float = 5.0
var _held: float = 0.0
var _dig_again: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and hill == Vector2.INF:
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		hill = centre + Vector2(0.0, -float(_sig().get("hill_px", 120.0)))


func signature(delta: float) -> void:
	if not is_alive():
		return
	_dig_again = maxf(_dig_again - delta, 0.0)
	if _dig_again <= 0.0 and hill != Vector2.INF:
		var on: bool = false
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(hill) <= float(_sig().get("hill_radius_px", 26.0)) + player.body_radius:
				on = true
		_held = _held + delta if on else 0.0
		if _held >= float(_sig().get("dig_s", 2.0)):
			dig()
	if broken_s > 0.0:
		return
	_carry_in -= delta
	if _carry_in <= 0.0:
		_carry_in = float(_sig().get("carry_every_s", 8.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			carry_off(near)


## Off into the hill: the Hero is whisked away across the arena, and comes back Hexed.
func carry_off(player: Player) -> void:
	carried += 1
	if not (player.kit != null and player.kit.controls_movement()):
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		var away: Vector2 = (centre - player.position)
		if away.length() < 1.0:
			away = Vector2.RIGHT
		player.position = centre + away.normalized() * float(_sig().get("carry_px", 200.0)) * 0.6
	player.statuses.apply("hex")
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and carried == 1:
		banner.show_text(tr("BOSS_FINVARRA_CARRIED"))


## Digging into Knockma: his guard breaks.
func dig() -> void:
	digs += 1
	_held = 0.0
	_dig_again = float(_sig().get("dig_again_s", 10.0))
	guard_break()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and digs == 1:
		banner.show_text(tr("BOSS_FINVARRA_DUG"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the hill moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if hill != Vector2.INF:
		hill -= shift_px


## The green hill of Knockma, with a ring filling while a Hero digs, and a dark scar while it can't be dug again.
func _draw() -> void:
	if hill != Vector2.INF and is_alive():
		var p: Vector2 = hill - global_position
		var r: float = float(_sig().get("hill_radius_px", 26.0))
		draw_set_transform(p, 0.0, Vector2(1.0, 0.55))
		draw_circle(Vector2.ZERO, r, Color(0.35, 0.6, 0.3))
		draw_circle(Vector2(0, -4), r * 0.7, Color(0.45, 0.7, 0.35))
		if _dig_again > 0.0:
			draw_circle(Vector2(0, -2), r * 0.35, Color(0.3, 0.2, 0.12))
		draw_set_transform(Vector2.ZERO)
		if _held > 0.0:
			draw_arc(p, r + 6.0, -PI / 2, -PI / 2 + TAU * _held / float(_sig().get("dig_s", 2.0)), 24, Color(1.0, 0.9, 0.5), 2.0)
	super._draw()


## Ethna Won Back secret: Knockma dug into twice, then Finvarra beaten.
func secret_earned() -> String:
	return "ethna_won_back" if digs >= 2 else ""
