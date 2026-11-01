class_name PuffballBoss
extends BossController
## The Great Puffball, 10:00 (docs/PACK_6_PLAN.md: Mycendra, the game's own invented realm). Signature, bursting:
## every time it loses a tenth of its health it bursts in a cloud of spores around it, which Poisons whoever stands in it
## for a few seconds. Keep moving out of the clouds.

## Spore clouds: {"pos": Vector2, "left": float}.
var clouds: Array = []
var bursts: int = 0
var _next_burst: float = 0.9
var _tick: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	while hp_fraction() <= _next_burst and _next_burst > 0.0:
		_next_burst -= float(_sig().get("burst_every_fraction", 0.1))
		burst()
	for i: int in range(clouds.size() - 1, -1, -1):
		clouds[i]["left"] = float(clouds[i]["left"]) - delta
		if float(clouds[i]["left"]) <= 0.0:
			clouds.remove_at(i)
	_tick -= delta
	if _tick <= 0.0:
		_tick = float(_sig().get("poison_every_s", 1.0))
		poison_in_clouds()


func burst() -> void:
	bursts += 1
	clouds.append({"pos": position_now(), "left": float(_sig().get("cloud_s", 5.0))})
	poison_in_clouds()


func poison_in_clouds() -> void:
	var reach: float = float(_sig().get("cloud_radius_px", 70.0))
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		for cloud: Dictionary in clouds:
			if player.position.distance_to(cloud["pos"]) <= reach + player.body_radius:
				player.statuses.apply("poison")
				break


func _draw() -> void:
	var reach: float = float(_sig().get("cloud_radius_px", 70.0))
	for cloud: Dictionary in clouds:
		var fade: float = clampf(float(cloud["left"]) / 1.0, 0.0, 1.0)
		var at: Vector2 = Vector2(cloud["pos"]) - global_position
		draw_circle(at, reach, Color(0.6, 0.7, 0.3, 0.22 * fade))
		draw_circle(at, reach * 0.6, Color(0.7, 0.8, 0.35, 0.18 * fade))
	super._draw()

## The world re-centres under the Heroes (WorldRoot.origin_shifted): move what this boss left on the ground with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for cloud: Dictionary in clouds:
		cloud["pos"] = Vector2(cloud["pos"]) - shift_px
