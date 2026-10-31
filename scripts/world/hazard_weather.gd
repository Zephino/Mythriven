class_name HazardWeather
extends Hazard
## The "weather" hazard (hazard library: push wind and vision shrink): a
## blizzard, sandstorm, or mist bank. While active, wind pushes players (and
## lighter, enemies) in a direction that turns every few seconds, and a veil
## closes in around the screen's edges so only a circle around the Hero stays
## clear. Data: push_px_s, enemy_push_px_s, wind_turn_s, vision_screens (radius
## of the clear circle in screen heights; 0 = no veil), pulse (0-1: how much the clear circle breathes in and out, as
## Pohjola's polar night does; pulse_hz how fast), veil_color, fade_s, particles ("snow", "sand", "mist", or "aurora":
## the northern lights rippling across the top of the screen
## blowing across the screen; "" for none) and particle_color.

var wind := Vector2.RIGHT

var _turn_left: float = 0.0
var _strength: float = 0.0
var _layer: CanvasLayer
var _veil: ColorRect
## Snowflakes, sand or mist blowing across the screen (owner request 10/31/2026), drawn in screen space.
var _flakes: Node2D
var _flake_pos := PackedVector2Array()
var _flake_seed := PackedFloat32Array()


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 5
	add_child(_layer)
	_veil = ColorRect.new()
	_veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = """shader_type canvas_item;
uniform vec4 veil_color : source_color = vec4(0.9, 0.92, 1.0, 1.0);
uniform float clear_radius = 0.3;
uniform float strength = 0.0;
uniform float aspect = 1.78;
void fragment() {
	vec2 p = (UV - vec2(0.5)) * vec2(aspect, 1.0);
	float d = length(p);
	float a = smoothstep(clear_radius, clear_radius + 0.18, d);
	COLOR = vec4(veil_color.rgb, veil_color.a * a * strength);
}"""
	var material := ShaderMaterial.new()
	material.shader = shader
	_veil.material = material
	_veil.visible = false
	_layer.add_child(_veil)
	_flakes = Node2D.new()
	_flakes.draw.connect(_draw_flakes)
	_layer.add_child(_flakes)
	CoopMirror.attach(self, "weather")
	# Co-op (joining player): keep running to blow this device's own Hero with the host's wind.
	process_mode = Node.PROCESS_MODE_INHERIT


func begin(data: Dictionary) -> void:
	super.begin(data)
	_turn_left = 0.0


## How much of the weather is on now (fades in and out), 0–1.
func strength() -> float:
	return _strength


func _process(delta: float) -> void:
	if Net.is_client():
		_update_veil()
		_push_players(delta, true)
		return
	var target: float = 1.0 if active and not paused else 0.0
	_strength = move_toward(_strength, target, delta / maxf(float(_data.get("fade_s", 1.5)), 0.05))
	_update_veil()
	if _strength <= 0.0 or GameAuthority.run == null:
		return
	_turn_left -= delta
	if _turn_left <= 0.0:
		_turn_left = float(_data.get("wind_turn_s", 6.0))
		wind = Vector2.from_angle(GameAuthority.run.rng.world.randf() * TAU)
	_push_players(delta, false)
	var enemy_push: float = float(_data.get("enemy_push_px_s", 0.0)) * _strength
	var enemies: EnemyManager = GameAuthority.enemies
	if enemy_push > 0.0 and enemies != null:
		for i: int in enemies.capacity:
			if enemies.active[i] != 0 and not bool(enemies.type_of(i).get("boss", false)):
				enemies.positions[i] += wind * enemy_push * delta


func _update_veil() -> void:
	_move_flakes(get_process_delta_time())
	var vision: float = float(_data.get("vision_screens", 0.0))
	_veil.visible = _strength > 0.0 and vision > 0.0
	if not _veil.visible:
		return
	var material: ShaderMaterial = _veil.material
	var view: Vector2 = get_viewport().get_visible_rect().size
	material.set_shader_parameter("veil_color", Color.html(str(_data.get("veil_color", "#e8ecf4"))))
	var pulse: float = float(_data.get("pulse", 0.0))
	var breathe: float = 1.0 - pulse * (0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU * float(_data.get("pulse_hz", 0.2))))
	material.set_shader_parameter("clear_radius", vision * 0.5 * breathe)
	material.set_shader_parameter("strength", _strength)
	material.set_shader_parameter("aspect", view.x / maxf(view.y, 1.0))


## Wind pushes the Heroes (in co-op each device pushes its own Hero).
func _push_players(delta: float, only_local: bool) -> void:
	var push: float = float(_data.get("push_px_s", 0.0)) * _strength
	if push <= 0.0:
		return
	for player: Player in GameAuthority.players:
		if (player.is_local or not only_local) and player.alive and not (player.kit != null and player.kit.controls_movement()):
			player.position += wind * push * delta


func net_capture() -> Variant:
	return [super.net_capture(), _strength, wind]


func net_apply(state: Variant) -> void:
	super.net_apply(state[0])
	_strength = float(state[1])
	wind = state[2]


## Moves the weather's particles with the wind, wrapping round the screen; how many show grows with its strength.
func _move_flakes(delta: float) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var count: int = Data.cfg_int("world.weather_particles")
	if _flake_pos.size() != count:
		_flake_pos.resize(count)
		_flake_seed.resize(count)
		for i: int in count:
			_flake_pos[i] = Vector2(randf() * view.x, randf() * view.y)
			_flake_seed[i] = randf()
	_flakes.visible = _strength > 0.0 and str(_data.get("particles", "")) != ""
	if not _flakes.visible:
		return
	var speed: float = Data.cfg_float("world.weather_particle_speed_px_s")
	var kind: String = str(_data.get("particles", ""))
	for i: int in count:
		var drift: Vector2 = wind * speed * (0.6 + _flake_seed[i])
		if kind == "snow":
			drift += Vector2(sin(Time.get_ticks_msec() * 0.002 + i) * 10.0, 25.0)
		elif kind == "mist":
			drift *= 0.25
		var p: Vector2 = _flake_pos[i] + drift * delta
		_flake_pos[i] = Vector2(fposmod(p.x, view.x), fposmod(p.y, view.y))
	_flakes.queue_redraw()


func _draw_flakes() -> void:
	var shown: int = int(_flake_pos.size() * _strength)
	var color := Color.html(str(_data.get("particle_color", "#ffffff")))
	match str(_data.get("particles", "")):
		"snow":
			for i: int in shown:
				_flakes.draw_circle(_flake_pos[i], 1.0 + _flake_seed[i] * 1.5, Color(color, 0.85))
		"sand":
			for i: int in shown:
				_flakes.draw_line(_flake_pos[i], _flake_pos[i] + wind * (4.0 + _flake_seed[i] * 8.0), Color(color, 0.7), 1.0)
		"aurora":
			# The northern lights: soft green and violet ribbons rippling across the top of the sky.
			var view: Vector2 = get_viewport().get_visible_rect().size
			var t: float = Time.get_ticks_msec() / 1000.0
			for band: int in 3:
				var points := PackedVector2Array()
				for k: int in 25:
					var x: float = view.x * k / 24.0
					points.append(Vector2(x, view.y * (0.08 + 0.06 * band) + sin(x * 0.012 + t * (0.5 + band * 0.2) + band) * 18.0))
				var tint: Color = color if band != 1 else Color(0.7, 0.5, 1.0)
				_flakes.draw_polyline(points, Color(tint, 0.18 * _strength), 18.0 - band * 4.0)
				_flakes.draw_polyline(points, Color(tint, 0.35 * _strength), 3.0)
		"mist":
			for i: int in shown / 6:
				_flakes.draw_circle(_flake_pos[i], 18.0 + _flake_seed[i] * 26.0, Color(color, 0.07))
