class_name GadeirusBoss
extends BossController
## Gadeirus, 20:00 (docs/PACK_11_PLAN.md: Atlantis). Signature, the rings of sea: every so often a ring of sea water
## spreads out from him; a Hero it passes over is hurt and Soaked (each ring catches a Hero once). Source: Plato,
## Critias 113d-114b (Poseidon rings Cleito's hill with rings of sea and land; Gadeirus, Atlas' twin).

## The rings spreading out: {"pos", "r", "hit": Array of Heroes caught}.
var rings: Array = []
var caught: int = 0
var _ring_in: float = 2.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	var band: float = float(_sig().get("band_px", 14.0))
	for i: int in range(rings.size() - 1, -1, -1):
		var ring: Dictionary = rings[i]
		ring["r"] = float(ring["r"]) + float(_sig().get("ring_px_s", 110.0)) * delta
		for player: Player in GameAuthority.players:
			if not player.alive or (ring["hit"] as Array).has(player):
				continue
			if absf(player.position.distance_to(ring["pos"]) - float(ring["r"])) <= band + player.body_radius:
				(ring["hit"] as Array).append(player)
				caught += 1
				GameAuthority.damage_player(player, float(_sig().get("ring_damage", 10.0)), str(data.get("id", "")), ring["pos"])
				player.statuses.apply("soaked")
		if float(ring["r"]) >= float(_sig().get("ring_max_px", 260.0)):
			rings.remove_at(i)
	if not is_alive():
		return
	_ring_in -= delta
	if _ring_in <= 0.0:
		_ring_in = float(_sig().get("ring_every_s", 6.0))
		rings.append({"pos": position_now(), "r": 0.0, "hit": []})


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the rings move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for ring: Dictionary in rings:
		ring["pos"] = Vector2(ring["pos"]) - shift_px


func _draw() -> void:
	var band: float = float(_sig().get("band_px", 14.0))
	for ring: Dictionary in rings:
		draw_arc(Vector2(ring["pos"]) - global_position, float(ring["r"]), 0.0, TAU, 48, Color(0.25, 0.5, 0.8, 0.5), band * 2.0)
		draw_arc(Vector2(ring["pos"]) - global_position, float(ring["r"]) + band, 0.0, TAU, 48, Color(0.85, 0.95, 1.0, 0.7), 1.5)
	super._draw()
