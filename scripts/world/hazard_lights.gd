class_name HazardLights
extends Hazard
## The "lights" hazard (docs/PACK_3_PLAN.md: the Slavic Wilds, wandering lights): will-o'-the-wisp lights drift about
## near the Heroes and slowly close in on them, and every monster near a light is drawn along with it, so the lights
## herd crowds onto you. (The design's "confused controls" were left out, owner decision 10/31/2026.)
## Data: lights, lure_radius_px, lure_px_s (how fast monsters are drawn), drift_px_s, range_px, color.

var lights := PackedVector2Array()
var _wander := PackedVector2Array()


func _ready() -> void:
	CoopMirror.attach(self, "lights")


func begin(data: Dictionary) -> void:
	super.begin(data)
	lights.clear()
	_wander.clear()
	var target: Player = _target()
	if target == null:
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.world
	for k: int in int(data.get("lights", 3)):
		lights.append(target.position + Vector2.from_angle(rng.randf() * TAU) * float(data.get("range_px", 260.0)))
		_wander.append(Vector2.from_angle(rng.randf() * TAU))


func _target() -> Player:
	for player: Player in GameAuthority.players:
		if player.alive:
			return player
	return null


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in lights.size():
		lights[i] -= shift_px


func _process(delta: float) -> void:
	queue_redraw()
	if not active or paused or Net.is_client() or lights.is_empty():
		return
	var target: Player = _target()
	var enemies: EnemyManager = GameAuthority.enemies
	if target == null or enemies == null:
		return
	var drift: float = float(_data.get("drift_px_s", 28.0))
	var reach: float = float(_data.get("lure_radius_px", 130.0))
	var lure: float = float(_data.get("lure_px_s", 70.0))
	for i: int in lights.size():
		# Wander a little, and close in on the Hero.
		_wander[i] = _wander[i].rotated(sin(Time.get_ticks_msec() * 0.001 + i) * delta)
		var toward: Vector2 = (target.position - lights[i]).normalized()
		lights[i] += (toward * 0.7 + _wander[i] * 0.6) * drift * delta
		for slot: int in enemies.query(lights[i], reach):
			if enemies.charmed[slot] != 0 or bool(enemies.type_of(slot).get("boss", false)) or bool(enemies.type_of(slot).get("animal", false)):
				continue
			var to_light: Vector2 = lights[i] - enemies.positions[slot]
			if to_light.length() > 6.0:
				enemies.positions[slot] += to_light.normalized() * lure * delta


func end() -> void:
	super.end()
	lights.clear()


## Each light: a soft glow that flickers, with a bright heart.
func _draw() -> void:
	if not active or lights.is_empty():
		return
	var color := Color.html(str(_data.get("color", "#c8f0a0")))
	var t: float = Time.get_ticks_msec() / 1000.0
	for i: int in lights.size():
		var flick: float = 0.75 + 0.25 * sin(t * 7.0 + i * 2.0)
		var at: Vector2 = lights[i] + Vector2(0, sin(t * 2.0 + i) * 4.0)
		draw_circle(at, 22.0, Color(color, 0.12 * flick))
		draw_circle(at, 10.0, Color(color, 0.35 * flick))
		draw_circle(at, 4.0, Color(1, 1, 0.95, 0.9 * flick))


func net_capture() -> Variant:
	return [super.net_capture(), lights]


func net_apply(state: Variant) -> void:
	super.net_apply(state[0])
	lights = state[1]
