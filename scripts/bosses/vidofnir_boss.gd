class_name VidofnirBoss
extends BossController
## Vidofnir, 20:00 (docs/PACK_4_PLAN.md: Muspelheim). Signature, gleaming: every few seconds the golden cock flares so
## bright that the whole screen goes white for a moment, and anyone close to him is scorched. Source: the Poetic Edda,
## Fjolsvinnsmal 18-26 (the shining cock on the tree, gleaming like gold).

var flare_s: float = 0.0
var _flare_in: float = 4.0
var _layer: CanvasLayer
var _white: ColorRect


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if _white == null:
		_layer = CanvasLayer.new()
		_layer.layer = 6
		add_child(_layer)
		_white = ColorRect.new()
		_white.set_anchors_preset(Control.PRESET_FULL_RECT)
		_white.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_white.color = Color(1.0, 0.97, 0.85, 0.0)
		_layer.add_child(_white)
	flare_s = maxf(flare_s - delta, 0.0)
	_white.color.a = clampf(flare_s / maxf(float(_sig().get("flare_s", 1.6)), 0.01), 0.0, 1.0) * 0.85 if is_alive() else 0.0
	if not is_alive():
		return
	_flare_in -= delta
	if _flare_in <= 0.0:
		_flare_in = float(_sig().get("flare_every_s", 8.0))
		flare()


func flare() -> void:
	flare_s = float(_sig().get("flare_s", 1.6))
	var at: Vector2 = position_now()
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= 90.0:
			GameAuthority.damage_player(player, float(_sig().get("flare_damage", 10.0)), "vidofnir", at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, 90.0, Color(1.0, 0.9, 0.4), true)


## Laevateinn secret: only Laevateinn can kill him (Fjolsvinnsmal 25-26); the final blow is Fire.
var last_element: String = ""


func on_element_hit(element: String) -> void:
	last_element = element


func secret_earned() -> String:
	return "laevateinn" if last_element == "fire" else ""
