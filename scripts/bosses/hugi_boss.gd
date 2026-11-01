class_name HugiBoss
extends BossController
## Hugi, 20:00 (docs/PACK_8_PLAN.md: Utgard). Signature, the speed of thought: every few seconds he is suddenly ahead
## of a Hero, where that Hero is heading, as he outran Thjalfi three times: no one can run as fast as thought. Source:
## Snorri, Gylfaginning 46-47 (Hugi wins the race against Thjalfi; Utgarda-Loki reveals that Hugi was his thought).

var leaps: int = 0
var _leap_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_leap_in -= delta
	if _leap_in <= 0.0:
		_leap_in = float(_sig().get("leap_every_s", 3.5))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			get_ahead_of(near)


## Appears where the Hero is heading (in front of them if they stand still).
func get_ahead_of(player: Player) -> void:
	leaps += 1
	var heading: Vector2 = player.velocity.normalized() if player.velocity.length() > 1.0 else player.facing.normalized()
	if heading == Vector2.ZERO:
		heading = Vector2.RIGHT
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(position_now(), 20.0, Color(0.85, 0.9, 1.0), true)
	GameAuthority.enemies.positions[slot] = player.position + heading * float(_sig().get("ahead_px", 110.0))
	if effects != null:
		effects.spawn_ring(position_now(), 20.0, Color(0.85, 0.9, 1.0), true)


## Faster Than Thought secret: beaten before he leaps ahead ten times.
func secret_earned() -> String:
	return "faster_than_thought" if leaps < 10 else ""
