class_name BabaYagaBoss
extends BossController
## Baba Yaga, 20:00 (docs/PACK_3_PLAN.md: the Slavic Wilds). Signature, the hut on chicken legs: she flies in her
## mortar, while her hut stalks round the arena on its great hen's legs after her target, stamping every few seconds;
## anyone under its feet is hurt. The hut can't be harmed. Source: Afanasyev, "Vasilisa the Beautiful".

var hut := Vector2.INF
var _stomp_in: float = 2.0
var _stomped_s: float = 0.0
var _hut_stride: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	if hut == Vector2.INF:
		hut = position_now() + Vector2(-float(_sig().get("hut_start_px", 160.0)), 0)
	_stomped_s = maxf(_stomped_s - delta, 0.0)
	var goal: Vector2 = target.position if target != null and is_instance_valid(target) else position_now()
	var step: Vector2 = (goal - hut).limit_length(float(_sig().get("hut_speed_px_s", 40.0)) * delta)
	hut += step
	_hut_stride += step.length()
	_stomp_in -= delta
	if _stomp_in <= 0.0:
		_stomp_in = float(_sig().get("stomp_every_s", 2.5))
		_stomp()


func _stomp() -> void:
	_stomped_s = 0.3
	var reach: float = float(_sig().get("stomp_radius_px", 46.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(hut) <= reach:
			GameAuthority.damage_player(player, float(_sig().get("stomp_damage", 14.0)), "baba_yaga", hut)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(hut, reach, Color(0.85, 0.65, 0.3), true)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if hut != Vector2.INF:
		hut -= shift_px


func _draw() -> void:
	if is_alive() and hut != Vector2.INF:
		var art: Dictionary = PixelArt.boss("baba_yaga_hut")
		var at: Vector2 = hut - global_position
		draw_set_transform(at + Vector2(0, 8), 0.0, Vector2(1.0, 0.35))
		draw_circle(Vector2.ZERO, float(_sig().get("stomp_radius_px", 46.0)) * 0.6, Color(0, 0, 0, 0.3 + (0.3 if _stomped_s > 0.0 else 0.0)))
		draw_set_transform(Vector2.ZERO)
		if not art.is_empty():
			PixelArt.draw_standing(self, art, at, false, Color.WHITE, true, _hut_stride)
	super._draw()
