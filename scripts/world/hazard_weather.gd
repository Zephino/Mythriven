class_name HazardWeather
extends Hazard
## The "weather" hazard (hazard library: push wind and vision shrink): a
## blizzard, sandstorm, or mist bank. While active, wind pushes players (and
## lighter, enemies) in a direction that turns every few seconds, and a veil
## closes in around the screen's edges so only a circle around the Hero stays
## clear. Data: push_px_s, enemy_push_px_s, wind_turn_s, vision_screens (radius
## of the clear circle in screen heights; 0 = no veil), veil_color, fade_s.

var wind := Vector2.RIGHT

var _turn_left: float = 0.0
var _strength: float = 0.0
var _layer: CanvasLayer
var _veil: ColorRect


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


func begin(data: Dictionary) -> void:
	super.begin(data)
	_turn_left = 0.0


## How much of the weather is on now (fades in and out), 0–1.
func strength() -> float:
	return _strength


func _process(delta: float) -> void:
	var target: float = 1.0 if active and not paused else 0.0
	_strength = move_toward(_strength, target, delta / maxf(float(_data.get("fade_s", 1.5)), 0.05))
	_update_veil()
	if _strength <= 0.0 or GameAuthority.run == null:
		return
	_turn_left -= delta
	if _turn_left <= 0.0:
		_turn_left = float(_data.get("wind_turn_s", 6.0))
		wind = Vector2.from_angle(GameAuthority.run.rng.world.randf() * TAU)
	var push: float = float(_data.get("push_px_s", 0.0)) * _strength
	for player: Player in GameAuthority.players:
		if player.alive and not (player.kit != null and player.kit.controls_movement()):
			player.position += wind * push * delta
	var enemy_push: float = float(_data.get("enemy_push_px_s", 0.0)) * _strength
	var enemies: EnemyManager = GameAuthority.enemies
	if enemy_push > 0.0 and enemies != null:
		for i: int in enemies.capacity:
			if enemies.active[i] != 0 and not bool(enemies.type_of(i).get("boss", false)):
				enemies.positions[i] += wind * enemy_push * delta


func _update_veil() -> void:
	var vision: float = float(_data.get("vision_screens", 0.0))
	_veil.visible = _strength > 0.0 and vision > 0.0
	if not _veil.visible:
		return
	var material: ShaderMaterial = _veil.material
	var view: Vector2 = get_viewport().get_visible_rect().size
	material.set_shader_parameter("veil_color", Color.html(str(_data.get("veil_color", "#e8ecf4"))))
	material.set_shader_parameter("clear_radius", vision * 0.5)
	material.set_shader_parameter("strength", _strength)
	material.set_shader_parameter("aspect", view.x / maxf(view.y, 1.0))
