class_name KronosBoss
extends BossController
## Kronos, 30:00, the Titan (GAME_DESIGN.md: The Aegean Shore bosses).
## Signature, Devouring Time: slow-time zones (you move at half speed inside),
## and once per phase he rewinds his shots back along their paths.
## Phases: scythe sweeps → time zones → devours: pulls you toward him while
## bullets spiral out.

## Each {"at": Vector2, "left": float}.
var _zones: Array[Dictionary] = []
var _zone_timer: float = 0.0
var _rewind_in: float = -1.0


func signature(delta: float) -> void:
	var sig: Dictionary = data.get("signature", {})
	if _rewind_in >= 0.0:
		_rewind_in -= delta
		if _rewind_in < 0.0 and GameAuthority.enemy_shots != null:
			GameAuthority.enemy_shots.rewind_boss_shots()
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null:
				banner.show_text(tr("BOSS_KRONOS_REWIND"))
	if bool(phase().get("zones", false)) and target != null:
		_zone_timer -= delta
		if _zone_timer <= 0.0:
			_zone_timer = float(sig.get("zone_s", 8.0))
			var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
			for _k: int in int(sig.get("zones", 3)):
				_zones.append({"at": target.position + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(20.0, 120.0),
						"left": float(sig.get("zone_s", 8.0))})
	for zone: Dictionary in _zones.duplicate():
		zone["left"] = float(zone["left"]) - delta
		if float(zone["left"]) <= 0.0:
			_zones.erase(zone)
	for player: Player in GameAuthority.players:
		player.slow_zone_mult = 1.0
		for zone: Dictionary in _zones:
			if player.position.distance_to(zone["at"]) <= float(sig.get("zone_radius_px", 46.0)):
				player.slow_zone_mult = float(sig.get("zone_slow", 0.5))
		if bool(phase().get("devour", false)) and player.alive and broken_s <= 0.0:
			var pull: Vector2 = position_now() - player.position
			if pull.length() > GameAuthority.enemies.radius[slot] * 2.0:
				GameAuthority.push_player(player, pull.normalized() * float(sig.get("pull_px_s", 40.0)) * delta)


func _on_phase_started(_index: int) -> void:
	_rewind_in = float((data.get("signature", {}) as Dictionary).get("rewind_after_s", 2.5))


## Players walk free again when he falls.
func _exit_tree() -> void:
	for player: Player in GameAuthority.players:
		if is_instance_valid(player):
			player.slow_zone_mult = 1.0


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for zone: Dictionary in _zones:
		zone["at"] = Vector2(zone["at"]) - shift_px


func _draw() -> void:
	super._draw()
	var sig: Dictionary = data.get("signature", {})
	var color := Color.html(Data.cfg_string("bosses.time_zone_color"))
	# Slowed time shows as a clock face (owner request 10/31/2026): twelve marks and a hand sweeping round.
	var turn: float = GameAuthority.run.elapsed_s * 1.5 if GameAuthority.run != null else 0.0
	for zone: Dictionary in _zones:
		var at: Vector2 = Vector2(zone["at"]) - global_position
		var r: float = float(sig.get("zone_radius_px", 46.0))
		draw_circle(at, r, color)
		var rim := Color(color.lightened(0.4), 0.9)
		draw_arc(at, r, 0.0, TAU, 32, rim, 1.5)
		for h: int in 12:
			var d: Vector2 = Vector2.from_angle(TAU * h / 12.0)
			draw_line(at + d * r * 0.82, at + d * r * 0.95, rim, 1.5 if h % 3 == 0 else 1.0)
		draw_line(at, at + Vector2.from_angle(turn - PI * 0.5) * r * 0.75, rim, 2.0)
		draw_line(at, at + Vector2.from_angle(turn / 12.0 - PI * 0.5) * r * 0.45, rim, 2.5)
	if is_alive() and bool(phase().get("devour", false)):
		draw_arc(position_now() - global_position, 60.0 + 20.0 * sin(GameAuthority.run.elapsed_s * 4.0), 0.0, TAU, 32, color, 2.0)
