class_name JoanTheWadBoss
extends BossController
## Joan the Wad, 20:00 (docs/PACK_12_PLAN.md: the Knockers' Deep). Signature, led astray: every so often her light
## leads the farthest Hero astray: for a moment the light wanders off, and the Hero is drawn after it. Source: Robert Hunt,
## Popular Romances of the West of England (1865: "Jack o' the lantern, Joan the wad"; the piskies who lead people
## astray).

var led: int = 0
var light := Vector2.INF
var lead_s: float = 0.0
var _leading: Player
var _drift := Vector2.RIGHT
var _lead_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		light = Vector2.INF
		return
	if lead_s > 0.0:
		lead_s -= delta
		light += _drift * float(_sig().get("light_px_s", 60.0)) * delta
		if _leading != null and _leading.alive and not (_leading.kit != null and _leading.kit.controls_movement()):
			_leading.position = _leading.position.move_toward(light, float(_sig().get("pull_px_s", 70.0)) * delta)
		if lead_s <= 0.0:
			light = Vector2.INF
			_leading = null
		return
	_lead_in -= delta
	if _lead_in <= 0.0:
		_lead_in = float(_sig().get("lead_every_s", 8.0))
		var far: Player = null
		for player: Player in GameAuthority.players:
			if player.alive and (far == null or player.position.distance_to(position_now()) > far.position.distance_to(position_now())):
				far = player
		if far != null:
			lead_astray(far)


func lead_astray(player: Player) -> void:
	led += 1
	_leading = player
	lead_s = float(_sig().get("lead_s", 3.0))
	_drift = Vector2.from_angle(GameAuthority.run.rng.combat.randf() * TAU)
	light = player.position + _drift * 60.0
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and led == 1:
		banner.show_text(tr("BOSS_JOAN_THE_WAD_LED"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): her light moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if light != Vector2.INF:
		light -= shift_px


## Her wandering light, and a faint thread from it to the Hero it leads.
func _draw() -> void:
	if light != Vector2.INF and is_alive():
		var p: Vector2 = light - global_position
		draw_circle(p, 10.0, Color(1.0, 0.75, 0.3, 0.25))
		draw_circle(p, 4.0, Color(1.0, 0.9, 0.5))
		if _leading != null:
			draw_line(p, _leading.position - global_position, Color(1.0, 0.85, 0.4, 0.3), 1.0)
	super._draw()
