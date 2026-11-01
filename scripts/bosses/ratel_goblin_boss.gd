class_name RatelGoblinBoss
extends BossController
## The Ratel Goblin, 10:00 (docs/PACK_9_PLAN.md: the Goblin Market). Signature, hurry skurry: every couple of seconds it
## tumbles off at speed in a sudden, wild direction, bowling over whoever is in its way. Source: Christina Rossetti,
## Goblin Market (1862): "one like a ratel tumbled hurry skurry".

var tumble_s: float = 0.0
var tumble_dir := Vector2.RIGHT
var tumbles: int = 0
var _tumble_in: float = 2.0
var _bowled: Dictionary = {}


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	var enemies: EnemyManager = GameAuthority.enemies
	if tumble_s > 0.0:
		tumble_s -= delta
		enemies.positions[slot] += tumble_dir * float(_sig().get("tumble_px_s", 300.0)) * enemies.statuses.speed_mult(slot) * delta
		for player: Player in GameAuthority.players:
			if player.alive and not _bowled.has(player.player_id) and player.position.distance_to(position_now()) <= enemies.radius[slot] + player.body_radius + 4.0:
				_bowled[player.player_id] = true
				GameAuthority.damage_player(player, float(_sig().get("tumble_damage", 12.0)), str(data.get("id", "")), position_now())
		return
	_tumble_in -= delta
	if _tumble_in <= 0.0:
		_tumble_in = float(_sig().get("tumble_every_s", 2.0))
		tumble()


## Off it goes: mostly toward the nearest Hero, but wildly.
func tumble() -> void:
	tumbles += 1
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var near: Player = GameAuthority.enemies.nearest_player(position_now())
	var toward: Vector2 = (near.position - position_now()).normalized() if near != null else Vector2.RIGHT
	tumble_dir = toward.rotated(rng.randf_range(-1.2, 1.2))
	tumble_s = float(_sig().get("tumble_s", 0.8))
	_bowled.clear()
