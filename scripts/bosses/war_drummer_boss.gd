class_name WarDrummerBoss
extends BossController
## The War Drummer, 10:00 (docs/PACK_8_PLAN.md: Ghorvast, the game's own invented realm). Signature, the war drums:
## each drumbeat calls more orcs into the fight, and he beats faster the more he is hurt.

var beats: int = 0
var _beat_in: float = 3.0
var _pulse_s: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


## Seconds between beats: slower when he is whole, faster as he is hurt.
func beat_every() -> float:
	return float(_sig().get("beat_every_s", 8.0)) * (0.4 + 0.6 * hp_fraction())


func signature(delta: float) -> void:
	_pulse_s = maxf(_pulse_s - delta, 0.0)
	if not is_alive():
		return
	_beat_in -= delta
	if _beat_in <= 0.0:
		_beat_in = beat_every()
		beat()


func beat() -> void:
	beats += 1
	_pulse_s = 0.5
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var at: Vector2 = position_now()
	for _k: int in int(_sig().get("callers", 3)):
		GameAuthority.spawn_enemy(str(_sig().get("call", "orc_warrior")), at + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(140.0, 220.0))


## The drumbeat booming out from him.
func _draw() -> void:
	super._draw()
	if _pulse_s > 0.0 and is_alive():
		draw_arc(position_now() - global_position, 30.0 + (0.5 - _pulse_s) * 160.0, 0.0, TAU, 40, Color(0.9, 0.5, 0.2, _pulse_s * 1.6), 3.0)


## The Silent Drum secret: beaten before his sixth drumbeat.
func secret_earned() -> String:
	return "the_silent_drum" if beats < 6 else ""
