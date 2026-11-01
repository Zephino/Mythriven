class_name MyceliumBoss
extends BossController
## The Mycelium, 20:00 (docs/PACK_6_PLAN.md: Mycendra, the game's own invented realm). Signature, spreading threads:
## every few seconds its pale threads spread a little further over the ground around it. Standing on them slows and
## Poisons. They stay until it dies, so keep it moving.

## Patches of threads on the ground.
var threads: Array[Vector2] = []
var _spread_in: float = 2.0
var _tick: float = 0.0
var _slowed: Dictionary = {}


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		_release_all()
		return
	_spread_in -= delta
	if _spread_in <= 0.0:
		_spread_in = float(_sig().get("spread_every_s", 3.0))
		spread()
	var reach: float = float(_sig().get("thread_radius_px", 26.0))
	_tick -= delta
	var poison_now: bool = _tick <= 0.0
	if poison_now:
		_tick = float(_sig().get("poison_every_s", 1.5))
	for player: Player in GameAuthority.players:
		var on: bool = false
		for at: Vector2 in threads:
			if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
				on = true
				break
		if on:
			player.slow_zone_mult = float(_sig().get("thread_slow", 0.6))
			_slowed[player.player_id] = true
			if poison_now:
				player.statuses.apply("poison")
		elif _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
			_slowed.erase(player.player_id)


## A new patch where it stands, or growing out from an old one.
func spread() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var from: Vector2 = position_now() if threads.is_empty() or rng.randf() < 0.5 else threads[rng.randi() % threads.size()]
	threads.append(from + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(10.0, 40.0))
	if threads.size() > int(_sig().get("max_threads", 30)):
		threads.pop_front()


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the threads move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in threads.size():
		threads[i] -= shift_px


func _release_all() -> void:
	for player: Player in GameAuthority.players:
		if is_instance_valid(player) and _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
	_slowed.clear()


func _exit_tree() -> void:
	_release_all()


func _draw() -> void:
	var reach: float = float(_sig().get("thread_radius_px", 26.0))
	for at: Vector2 in threads:
		var p: Vector2 = at - global_position
		draw_circle(p, reach, Color(0.85, 0.85, 0.75, 0.18))
		for k: int in 5:
			draw_line(p, p + Vector2.from_angle(k * 1.3 + at.x) * reach, Color(0.92, 0.9, 0.82, 0.5), 1.0)
	super._draw()
