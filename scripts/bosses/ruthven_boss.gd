class_name RuthvenBoss
extends BossController
## Lord Ruthven, 20:00 (docs/PACK_5_PLAN.md: Karnstein). Signature, the cold nobleman: every few seconds he fastens on
## the nearest Hero; for a while, as long as that Hero stays close, he drains their life and heals himself. Step away
## to break it. Source: John Polidori, The Vampyre (1819).

## The Hero he is draining, and for how much longer.
var victim: Player
var drain_left: float = 0.0
var drained: float = 0.0
var _drain_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		victim = null
		return
	if drain_left > 0.0 and victim != null and is_instance_valid(victim):
		drain_left -= delta
		if not victim.alive or victim.position.distance_to(position_now()) > float(_sig().get("drain_reach_px", 150.0)):
			drain_left = 0.0
		else:
			var amount: float = float(_sig().get("drain_dps", 6.0)) * delta
			GameAuthority.damage_player_over_time(victim, amount)
			drained += amount
			var enemies: EnemyManager = GameAuthority.enemies
			enemies.hp[slot] = minf(enemies.hp[slot] + amount * float(_sig().get("heal_mult", 8.0)), enemies.max_hp[slot])
		if drain_left <= 0.0:
			victim = null
		return
	_drain_in -= delta
	if _drain_in <= 0.0:
		_drain_in = float(_sig().get("drain_every_s", 7.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null and near.position.distance_to(position_now()) <= float(_sig().get("drain_reach_px", 150.0)):
			victim = near
			drain_left = float(_sig().get("drain_s", 3.0))


## A dark red thread from the drained Hero to him.
func _draw() -> void:
	super._draw()
	if victim == null or not is_instance_valid(victim) or drain_left <= 0.0 or not is_alive():
		return
	var from: Vector2 = victim.position - global_position
	var to: Vector2 = position_now() - global_position
	draw_line(from, to, Color(0.6, 0.05, 0.1, 0.8), 2.0)
	draw_circle(from, 6.0, Color(0.6, 0.05, 0.1, 0.4))
