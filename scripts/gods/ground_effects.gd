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


func _draw() -> void:
	for patch: Dictionary in _patches:
		draw_circle(patch["at"], float(patch["radius"]), Color(patch["color"], 0.3))
