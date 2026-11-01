class_name WitchSnakesBoss
extends BossController
## The Witch's Water Snakes, 20:00 (docs/PACK_13_PLAN.md: the Sea King's Hall). Signature, the coils: every so often
## their coils ring the arena and close in; while the ring is drawn tight, every Hero caught outside it is squeezed (hurt
## over and over), then the coils loosen again. Source: Andersen, "The Little Mermaid" (1837: the Sea Witch's water-snakes,
## her "little chickens").

## The coil ring's radius round the arena's centre (INF while there is no ring).
var ring: float = INF
var squeezed: int = 0
var _hold: float = 0.0
var _coil_in: float = 5.0
var _hurt_wait: Dictionary = {}


func _sig() -> Dictionary:
	return data.get("signature", {})


func _centre() -> Vector2:
	return GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()


func signature(delta: float) -> void:
	if not is_alive():
		ring = INF
		return
	if ring == INF:
		_coil_in -= delta
		if _coil_in <= 0.0:
			_coil_in = float(_sig().get("coil_every_s", 9.0))
			ring = float(_sig().get("start_px", 280.0))
			_hold = float(_sig().get("hold_s", 1.5))
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null and squeezed == 0:
				banner.show_text(tr("BOSS_WITCH_SNAKES_COIL"))
		return
	var end: float = float(_sig().get("end_px", 120.0))
	if ring > end:
		ring = maxf(ring - float(_sig().get("close_px_s", 40.0)) * delta, end)
		return
	for player: Player in GameAuthority.players:
		var wait: float = maxf(float(_hurt_wait.get(player, 0.0)) - delta, 0.0)
		_hurt_wait[player] = wait
		if player.alive and wait <= 0.0 and player.position.distance_to(_centre()) > ring:
			_hurt_wait[player] = float(_sig().get("squeeze_every_s", 0.5))
			squeezed += 1
			GameAuthority.damage_player(player, float(_sig().get("squeeze_damage", 6.0)), str(data.get("id", "")), _centre())
	_hold -= delta
	if _hold <= 0.0:
		ring = INF


## The ring of coils: green-black scales round the arena.
func _draw() -> void:
	if ring != INF and is_alive():
		var c: Vector2 = _centre() - global_position
		var tight: bool = ring <= float(_sig().get("end_px", 120.0))
		draw_arc(c, ring, 0.0, TAU, 64, Color(0.2, 0.35, 0.2, 0.8 if tight else 0.5), 10.0)
		draw_arc(c, ring, 0.0, TAU, 64, Color(0.45, 0.6, 0.3, 0.6), 2.0)
	super._draw()
