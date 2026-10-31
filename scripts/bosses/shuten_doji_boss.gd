class_name ShutenDojiBoss
extends BossController
## Shuten-doji, 30:00 (docs/PACK_3_PLAN.md: the Land of Legends). Signature, drunken: the oni king lurches about
## unpredictably, a stagger in a new direction every so often, and calls his oni bands (his patterns). Water slows him,
## as Raiko's men laid him low with poisoned sake: every Water hit chills him. Source: the Oeyama tale.

var _lurch_in: float = 1.0
var _lurch := Vector2.ZERO
var _lurch_s: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func on_element_hit(element: String) -> void:
	if element == "water" and bool(_sig().get("water_chill", true)) and is_alive():
		GameAuthority.enemies.statuses.apply(slot, "chill", 1.0, false)


func signature(delta: float) -> void:
	if not is_alive():
		return
	_lurch_in -= delta
	if _lurch_in <= 0.0:
		var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
		_lurch_in = float(_sig().get("lurch_every_s", 1.2)) * rng.randf_range(0.6, 1.4)
		_lurch = Vector2.from_angle(rng.randf() * TAU)
		_lurch_s = 0.35
	if _lurch_s > 0.0:
		_lurch_s -= delta
		var speed: float = float(_sig().get("lurch_px", 60.0)) / 0.35 * GameAuthority.enemies.statuses.speed_mult(slot)
		GameAuthority.enemies.positions[slot] += _lurch * speed * delta
