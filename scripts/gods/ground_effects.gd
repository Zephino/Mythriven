class_name GroundEffects
extends Node2D
## Patches on the ground that hurt enemies (not players): Greenwood thorns,
## Burning Greenwood's fire patches and wild blooms. Each patch hits the
## enemies inside it every 0.5 s with its element (and that element's
## status). A fixed budget; when full the oldest patch goes first.

## Each {"at", "radius", "left", "dps", "element", "player", "tick", "color"}.
var _patches: Array[Dictionary] = []


func _ready() -> void:
	z_index = -1


func count() -> int:
	return _patches.size()


func add(at: Vector2, reach: float, seconds: float, dps: float, element: String, player: Player) -> void:
	if _patches.size() >= Data.cfg_int("effect_budgets.max_player_patches"):
		_patches.pop_front()
	_patches.append({"at": at, "radius": reach, "left": seconds, "dps": dps, "element": element, "player": player, "tick": 0.0,
			"color": Elements.color(element)})


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for patch: Dictionary in _patches:
		patch["at"] = Vector2(patch["at"]) - shift_px


func _process(delta: float) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	var step: float = Data.cfg_float("combat.contact_damage_interval_s")
	for patch: Dictionary in _patches.duplicate():
		patch["left"] = float(patch["left"]) - delta
		patch["tick"] = float(patch["tick"]) - delta
		if float(patch["tick"]) <= 0.0 and enemies != null:
			patch["tick"] = step
			var player: Player = patch["player"] if is_instance_valid(patch["player"]) else null
			var at: Vector2 = patch["at"]
			for slot: int in enemies.query(at, float(patch["radius"]) + enemies.max_radius()):
				if enemies.positions[slot].distance_to(at) <= float(patch["radius"]) + enemies.radius[slot]:
					GameAuthority.damage_enemy(slot, float(patch["dps"]) * step, player, Vector2.ZERO, str(patch["element"]), 0.5)
		if float(patch["left"]) <= 0.0:
			_patches.erase(patch)
	queue_redraw()


## Earth patches are thorns: a dark tangle with spikes. Fire patches burn: a glow with flames flickering up.
## (owner request 10/31/2026)
func _draw() -> void:
	var t: float = Time.get_ticks_msec() * 0.001
	for patch: Dictionary in _patches:
		var at: Vector2 = patch["at"]
		var r: float = float(patch["radius"])
		var color: Color = patch["color"]
		var fade: float = clampf(float(patch["left"]), 0.0, 1.0)
		draw_circle(at, r, Color(color, 0.25 * fade))
		match str(patch["element"]):
			"earth":
				for k: int in 8:
					var d: Vector2 = Vector2.from_angle(TAU * k / 8.0 + k)
					var base: Vector2 = at + d * r * (0.3 + 0.08 * (k % 3))
					draw_line(base, base + d.rotated(0.6) * r * 0.5, Color(0.3, 0.38, 0.18, fade), 2.0)
					draw_line(base + d.rotated(0.6) * r * 0.3, base + d.rotated(0.6) * r * 0.3 + d.orthogonal() * 3.0,
							Color(0.75, 0.7, 0.5, fade), 1.0)
			"fire":
				for k: int in 6:
					var spot: Vector2 = at + Vector2.from_angle(TAU * k / 6.0) * r * 0.5
					var tall: float = 5.0 + 3.0 * sin(t * 9.0 + k * 1.9)
					draw_colored_polygon(PackedVector2Array([spot + Vector2(-3, 0), spot + Vector2(3, 0), spot + Vector2(0, -tall)]),
							Color(1.0, 0.6, 0.2, 0.85 * fade))
			_:
				draw_arc(at, r, 0.0, TAU, 20, Color(color, 0.6 * fade), 1.5)
