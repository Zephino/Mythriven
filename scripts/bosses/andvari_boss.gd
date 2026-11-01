class_name AndvariBoss
extends BossController
## Andvari, 30:00 (docs/PACK_6_PLAN.md: Nidavellir; the design's boss). Signature, the cursed ring: every so often his
## ring Andvaranaut falls somewhere in the arena. A Hero who takes it breaks his guard, but the ring's curse falls on
## them (Hex). Source: the Poetic Edda, Reginsmal (Andvari, robbed of his gold and his ring, lays a curse on whoever
## owns it); Skaldskaparmal 39.

var ring := Vector2.INF
var taken: int = 0
var _ring_in: float = 8.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	if ring == Vector2.INF:
		_ring_in -= delta
		if _ring_in <= 0.0:
			drop_ring()
		return
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(ring) <= float(_sig().get("ring_reach_px", 16.0)) + player.body_radius:
			take_ring(player)
			return


func drop_ring() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	ring = centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(80.0, float(_sig().get("drop_px", 200.0)))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and taken == 0:
		banner.show_text(tr("BOSS_ANDVARI_RING"))


func take_ring(player: Player) -> void:
	taken += 1
	ring = Vector2.INF
	_ring_in = float(_sig().get("ring_every_s", 14.0))
	player.statuses.apply("hex")
	guard_break()


## The gold ring glinting on the ground.
func _draw() -> void:
	super._draw()
	if ring == Vector2.INF or not is_alive():
		return
	var at: Vector2 = ring - global_position
	var glint: float = 0.6 + 0.4 * sin(Time.get_ticks_msec() * 0.008)
	draw_arc(at, 5.0, 0.0, TAU, 16, Color(1.0, 0.85, 0.3, glint), 2.5)
	draw_arc(at, 14.0, 0.0, TAU, 24, Color(1.0, 0.85, 0.3, 0.35), 1.0)

## The world re-centres under the Heroes (WorldRoot.origin_shifted): move what this boss left on the ground with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if ring != Vector2.INF:
		ring -= shift_px
