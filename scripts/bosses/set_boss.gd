class_name SetBoss
extends BossController
## Set, 20:00 (GAME_DESIGN.md: The Two Lands bosses). Signature, the desert
## storm: from phase 2 a sandstorm shrinks the player's vision to a small
## circle while Set strikes from its edge. Phases: spear and storm-bolt
## patterns → sandstorm → red-desert cyclones that pull the player in.

## Cyclones: {"pos", "dir", "left"}.
var cyclones: Array[Dictionary] = []

var _storm: HazardWeather
var _blink_left: float = 0.0
var _cyclone_left: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index >= 1 and _storm == null:
		_storm = HazardWeather.new()
		add_child(_storm)
		_storm.begin(_sig().get("sandstorm", {}))
	_blink_left = 1.0
	_cyclone_left = 1.0


func signature(delta: float) -> void:
	if _storm != null and not is_alive():
		_storm.end()
	if phase_index >= 1 and target != null:
		_blink_left -= delta
		if _blink_left <= 0.0:
			_blink_left = float(_sig().get("blink_every_s", 5.0))
			_blink_to_storm_edge()
	if phase_index >= 2:
		_tick_cyclones(delta)


## Set reappears at the edge of the clear circle and strikes from there.
func _blink_to_storm_edge() -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	var edge: float = view.y * 0.5 * float((_sig().get("sandstorm", {}) as Dictionary).get("vision_screens", 0.35)) * 1.1
	GameAuthority.enemies.positions[slot] = target.position + Vector2.from_angle(GameAuthority.run.rng.combat.randf() * TAU) * edge
	_fire(_sig().get("edge_strike", {"pattern": "aimed_fan", "count": 5, "spread_deg": 30, "damage": 9}))


func _tick_cyclones(delta: float) -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	_cyclone_left -= delta
	if _cyclone_left <= 0.0 and cyclones.size() < int(_sig().get("cyclones", 3)):
		_cyclone_left = float(_sig().get("cyclone_every_s", 4.0))
		cyclones.append({"pos": target.position + Vector2.from_angle(rng.randf() * TAU) * 150.0, "dir": Vector2.from_angle(rng.randf() * TAU),
				"left": float(_sig().get("cyclone_s", 10.0))})
	var pull: float = float(_sig().get("cyclone_pull_px_s", 40.0))
	var reach: float = float(_sig().get("cyclone_radius_px", 90.0))
	for i: int in range(cyclones.size() - 1, -1, -1):
		var cyclone: Dictionary = cyclones[i]
		cyclone["left"] = float(cyclone["left"]) - delta
		cyclone["pos"] = Vector2(cyclone["pos"]) + Vector2(cyclone["dir"]) * float(_sig().get("cyclone_speed_px_s", 30.0)) * delta
		if float(cyclone["left"]) <= 0.0:
			cyclones.remove_at(i)
			continue
		for player: Player in GameAuthority.players:
			var offset: Vector2 = Vector2(cyclone["pos"]) - player.position
			if player.alive and offset.length() < reach:
				player.position += offset.normalized() * minf(pull * delta, offset.length())
				if offset.length() < 16.0:
					GameAuthority.damage_player(player, float(_sig().get("cyclone_damage", 4.0)) * delta * 4.0, str(data.get("id", "")))


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for cyclone: Dictionary in cyclones:
		cyclone["pos"] = Vector2(cyclone["pos"]) - shift_px


func _exit_tree() -> void:
	if _storm != null:
		_storm.end()


func _draw() -> void:
	super._draw()
	var color := Color.html(str(_sig().get("cyclone_color", "#c06040")))
	for cyclone: Dictionary in cyclones:
		var at: Vector2 = Vector2(cyclone["pos"]) - global_position
		for ring: int in 3:
			draw_arc(at, 12.0 + ring * 14.0, float(cyclone["left"]) * 3.0 + ring, float(cyclone["left"]) * 3.0 + ring + PI * 1.4, 16, color, 2.0)
