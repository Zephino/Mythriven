class_name LouhiBoss
extends BossController
## Louhi, mistress of Pohjola, 30:00 (docs/PACK_3_PLAN.md: Pohjola). Signature: in her second phase she hides the sun
## and the moon, and darkness closes round every Hero (Kalevala 47); in her third she takes the shape of a great eagle
## with claws of scythes (Kalevala 43), and her attacks come faster.

var _veil_layer: CanvasLayer
var _veil: ColorRect


func _sig() -> Dictionary:
	return data.get("signature", {})


func is_eagle() -> bool:
	return phase_index >= int(_sig().get("eagle_phase", 2))


func is_dark() -> bool:
	return phase_index == int(_sig().get("dark_phase", 1)) and is_alive()


func art_id() -> String:
	return "louhi_eagle" if is_eagle() else "louhi"


func _on_phase_started(index: int) -> void:
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner == null:
		return
	if index == int(_sig().get("dark_phase", 1)):
		banner.show_text(tr("BOSS_LOUHI_DARK"))
	elif index == int(_sig().get("eagle_phase", 2)):
		banner.show_text(tr("BOSS_LOUHI_EAGLE"))


func signature(_delta: float) -> void:
	if _veil == null:
		_make_veil()
	_veil.visible = is_dark()
	if _veil.visible:
		var view: Vector2 = get_viewport().get_visible_rect().size
		(_veil.material as ShaderMaterial).set_shader_parameter("aspect", view.x / maxf(view.y, 1.0))


## The stolen sun: a dark veil with a small clear ring round the Hero.
func _make_veil() -> void:
	_veil_layer = CanvasLayer.new()
	_veil_layer.layer = 5
	add_child(_veil_layer)
	_veil = ColorRect.new()
	_veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = """shader_type canvas_item;
uniform float clear_radius = 0.2;
uniform float aspect = 1.78;
void fragment() {
	vec2 p = (UV - vec2(0.5)) * vec2(aspect, 1.0);
	float a = smoothstep(clear_radius, clear_radius + 0.15, length(p));
	COLOR = vec4(0.01, 0.02, 0.05, 0.94 * a);
}"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("clear_radius", float(_sig().get("dark_vision_screens", 0.4)) * 0.5)
	_veil.material = material
	_veil.visible = false
	_veil_layer.add_child(_veil)
