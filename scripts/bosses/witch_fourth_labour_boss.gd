class_name WitchFourthLabourBoss
extends BossController
## The Witch of the Fourth Labour, 20:00 (docs/PACK_3_PLAN.md: Mazandaran). Signature, the disguise: she stands among
## travellers who all look the same, a lovely young woman with a lute, and every few seconds they shift places. Only
## the real one can be hurt; a hit on her shows her true face (an old sorceress) for a few seconds. Source: the
## Shahnameh, fourth labour (she came to Rostam's feast disguised; when he spoke God's name her face turned black).

## Where the false travellers stand.
var decoys := PackedVector2Array()
var revealed_s: float = 0.0
var _shift_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "witch_fourth_labour" if revealed_s > 0.0 or broken_s > 0.0 else "witch_fourth_labour_disguised"


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	revealed_s = float(_sig().get("revealed_s", 4.0))
	return super.modify_hit(amount, attacker, push)


func signature(delta: float) -> void:
	revealed_s = maxf(revealed_s - delta, 0.0)
	_shift_in -= delta
	if _shift_in > 0.0 or not is_alive():
		return
	var list: Array = _sig().get("shift_every_s", [8])
	_shift_in = float(list[mini(phase_index, list.size() - 1)])
	_shift()


## She and her decoys take new places round where she stood; which one is real is chosen at random.
func _shift() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = position_now()
	var count: int = int(_sig().get("shapes", 4))
	var spread: float = float(_sig().get("spread_px", 120.0))
	var start: float = rng.randf() * TAU
	var spots := PackedVector2Array()
	for k: int in count:
		spots.append(centre + Vector2.from_angle(start + TAU * k / count) * spread)
	var real: int = rng.randi_range(0, count - 1)
	GameAuthority.enemies.positions[slot] = spots[real]
	spots.remove_at(real)
	decoys = spots
	revealed_s = 0.0


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in decoys.size():
		decoys[i] -= shift_px


## The decoys look exactly like her disguise.
func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	var art: Dictionary = PixelArt.boss("witch_fourth_labour_disguised")
	if art.is_empty():
		return
	var r: float = GameAuthority.enemies.radius[slot]
	for at: Vector2 in decoys:
		PixelArt.draw_standing(self, art, at - global_position + Vector2(0, r), false)
