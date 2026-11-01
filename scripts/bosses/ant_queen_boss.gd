class_name AntQueenBoss
extends BossController
## The Queen of the Gold-Digging Ants, 30:00 (docs/PACK_6_PLAN.md: the Myrmidon Hive; the design's boss). Signature,
## the carriers: worker ants keep coming in from the edge of the arena, carrying gold to her; each one that reaches her
## heals her. Kill the carriers before they arrive. Source: Herodotus, Histories 3.102-105 (the gold-digging ants of
## India); the design's queen of the hive.

## Carrier ants on their way to her (enemy slots).
var carriers: Array[int] = []
var delivered: int = 0
var _send_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_send_in -= delta
	if _send_in <= 0.0:
		_send_in = float(_sig().get("send_every_s", 7.0))
		send_carriers()
	var enemies: EnemyManager = GameAuthority.enemies
	var at: Vector2 = position_now()
	var carrier_id: String = str(_sig().get("carrier", "gold_carrier_ant"))
	for i: int in range(carriers.size() - 1, -1, -1):
		var c: int = carriers[i]
		if enemies.active[c] == 0 or str(enemies.type_of(c).get("id", "")) != carrier_id:
			carriers.remove_at(i)
			continue
		enemies.positions[c] = enemies.positions[c].move_toward(at, float(_sig().get("carrier_px_s", 60.0)) * enemies.statuses.speed_mult(c) * delta)
		if enemies.positions[c].distance_to(at) <= enemies.radius[slot] + 6.0:
			enemies.remove_quietly(c)
			carriers.remove_at(i)
			delivered += 1
			enemies.hp[slot] = minf(enemies.hp[slot] + enemies.max_hp[slot] * float(_sig().get("heal_each", 0.03)), enemies.max_hp[slot])


func send_carriers() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	for _k: int in int(_sig().get("carriers", 3)):
		var c: int = GameAuthority.spawn_enemy(str(_sig().get("carrier", "gold_carrier_ant")),
				centre + Vector2.from_angle(rng.randf() * TAU) * float(_sig().get("edge_px", 260.0)))
		if c >= 0:
			carriers.append(c)


## The Starved Queen secret: beaten before three carriers reach her.
func secret_earned() -> String:
	return "the_starved_queen" if delivered < 3 else ""
