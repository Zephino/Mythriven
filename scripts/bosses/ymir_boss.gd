class_name YmirBoss
extends BossController
## Ymir, 30:00 (docs/PACK_2_PLAN.md: Jotunheim). Signature, the frost shapes: every so often the rime splits into
## three shapes of him; only the real one casts a shadow (and only it can be hurt; the others are rime). Each phase
## they shift more often. His cast "Endless Winter" freezes the ground except for safe circles.
## Source: Snorri, Gylfaginning 5-6.

## Where the false shapes stand (empty when there are none).
var shapes := PackedVector2Array()
var _shift_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	_shift_in -= delta
	if _shift_in > 0.0:
		return
	var list: Array = _sig().get("shift_every_s", [9])
	_shift_in = float(list[mini(phase_index, list.size() - 1)])
	_shift()


## The real Ymir moves to one of three spots round where he stood; rime shapes stand at the others.
func _shift() -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = position_now()
	var spread: float = float(_sig().get("spread_px", 110.0))
	var count: int = int(_sig().get("shapes", 3))
	var start: float = rng.randf() * TAU
	var spots := PackedVector2Array()
	for k: int in count:
		spots.append(centre + Vector2.from_angle(start + TAU * k / count) * spread)
	var real: int = rng.randi_range(0, count - 1)
	enemies.positions[slot] = spots[real]
	spots.remove_at(real)
	shapes = spots
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(centre, spread, Color(0.85, 0.95, 1.0), true)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in shapes.size():
		shapes[i] -= shift_px


## The real Ymir casts a shadow; the rime shapes don't (and shimmer).
func _draw() -> void:
	if not is_alive():
		return
	var art: Dictionary = PixelArt.boss(art_id())
	var r: float = GameAuthority.enemies.radius[slot]
	draw_set_transform(position_now() - global_position + Vector2(0, r), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, r * 1.4, Color(0, 0, 0, 0.45))
	draw_set_transform(Vector2.ZERO)
	super._draw()
	if art.is_empty():
		return
	var shimmer: float = 0.75 + 0.15 * sin(Time.get_ticks_msec() * 0.006)
	for at: Vector2 in shapes:
		var texture: ImageTexture = PixelArt.frame(art, false, 0.0)
		var anchor: Vector2 = art["anchor"]
		draw_texture(texture, at - global_position + Vector2(-anchor.x, r - anchor.y), Color(0.9, 0.97, 1.0, shimmer))
