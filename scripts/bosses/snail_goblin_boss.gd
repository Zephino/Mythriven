class_name SnailGoblinBoss
extends BossController
## The Snail Goblin, 20:00 (docs/PACK_9_PLAN.md: the Goblin Market). Signature, the slime: very slow and very tough, it
## leaves a trail of slime behind it that slows whoever steps in it. Source: Christina Rossetti, Goblin Market (1862):
## "one crawled like a snail".

## Slime on the ground: {"pos": Vector2, "left": float}.
var slime: Array = []
var _drop_in: float = 0.0
var _slowed: Dictionary = {}


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	for i: int in range(slime.size() - 1, -1, -1):
		slime[i]["left"] = float(slime[i]["left"]) - delta
		if float(slime[i]["left"]) <= 0.0:
			slime.remove_at(i)
	var reach: float = float(_sig().get("slime_radius_px", 22.0))
	for player: Player in GameAuthority.players:
		var inside: bool = false
		for s: Dictionary in slime:
			if player.alive and player.position.distance_to(s["pos"]) <= reach + player.body_radius:
				inside = true
				break
		if inside:
			player.slow_zone_mult = float(_sig().get("slime_slow", 0.5))
			_slowed[player.player_id] = true
		elif _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
			_slowed.erase(player.player_id)
	if not is_alive():
		return
	_drop_in -= delta
	if _drop_in <= 0.0:
		_drop_in = float(_sig().get("drop_every_s", 0.4))
		slime.append({"pos": position_now(), "left": float(_sig().get("slime_s", 10.0))})


func _exit_tree() -> void:
	for player: Player in GameAuthority.players:
		if is_instance_valid(player) and _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
	_slowed.clear()


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the slime moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for s: Dictionary in slime:
		s["pos"] = Vector2(s["pos"]) - shift_px


func _draw() -> void:
	var reach: float = float(_sig().get("slime_radius_px", 22.0))
	for s: Dictionary in slime:
		var fade: float = clampf(float(s["left"]) / 2.0, 0.0, 1.0)
		draw_circle(Vector2(s["pos"]) - global_position, reach, Color(0.6, 0.75, 0.55, 0.3 * fade))
	super._draw()
