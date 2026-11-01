class_name GoldAntBoss
extends BossController
## The Gold-Digging Ant, 10:00 (docs/PACK_6_PLAN.md: the Myrmidon Hive). Signature, the gold sand: it digs up heaps of
## gold sand around the arena. A Hero who takes one gets the gold, but the ant smells the thief and runs them down,
## much faster, for a while. Source: Herodotus, Histories 3.102-105 (the ants of India, bigger than foxes, throw up gold
## sand as they dig, and chase the Indians who steal it on the swiftest camels).

## Heaps of gold sand on the ground.
var heaps: Array[Vector2] = []
var thief: Player
var chase_s: float = 0.0
var thefts: int = 0
var _dig_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_dig_in -= delta
	if _dig_in <= 0.0:
		_dig_in = float(_sig().get("dig_every_s", 6.0))
		dig()
	var reach: float = float(_sig().get("heap_reach_px", 16.0))
	for i: int in range(heaps.size() - 1, -1, -1):
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(heaps[i]) <= reach + player.body_radius:
				heaps.remove_at(i)
				steal(player)
				break
	if chase_s > 0.0 and thief != null and is_instance_valid(thief) and thief.alive:
		chase_s -= delta
		target = thief
		var enemies: EnemyManager = GameAuthority.enemies
		enemies.positions[slot] = enemies.positions[slot].move_toward(thief.position,
				float(_sig().get("chase_px_s", 130.0)) * enemies.statuses.speed_mult(slot) * delta)


func dig() -> void:
	if heaps.size() >= int(_sig().get("max_heaps", 2)):
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	heaps.append(centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 200.0))


## The thief gets the gold; the ant gives chase.
func steal(player: Player) -> void:
	thefts += 1
	GameAuthority.collect_gold(player, float(_sig().get("heap_gold", 15.0)))
	thief = player
	chase_s = float(_sig().get("chase_s", 5.0))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and thefts == 1:
		banner.show_text(tr("BOSS_GOLD_ANT_CHASE"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the heaps move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in heaps.size():
		heaps[i] -= shift_px


func _draw() -> void:
	for at: Vector2 in heaps:
		var p: Vector2 = at - global_position
		draw_set_transform(p, 0.0, Vector2(1.0, 0.55))
		draw_circle(Vector2.ZERO, 12.0, Color(0.85, 0.65, 0.2))
		draw_circle(Vector2(-2, -2), 7.0, Color(1.0, 0.85, 0.35))
		draw_set_transform(Vector2.ZERO)
	super._draw()
