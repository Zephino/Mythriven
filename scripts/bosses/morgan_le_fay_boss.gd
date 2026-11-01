class_name MorganLeFayBoss
extends BossController
## Morgan le Fay, 20:00 (docs/PACK_8_PLAN.md: Logres). Signature, the stolen scabbard: she wears Excalibur's scabbard,
## whose wearer loses no blood, so she heals all the time and shrugs off Burn and Poison. Every so often it falls in the
## arena for a few seconds; a Hero who takes it stops her healing for a while. Source: Thomas Malory, Le Morte
## d'Arthur, 4.14 (Morgan steals the scabbard and throws it into a lake).

## Where the scabbard lies (INF while she wears it or while it is lost to her).
var scabbard := Vector2.INF
var lost_s: float = 0.0
var taken: int = 0
var _lies_s: float = 0.0
var _drop_in: float = 8.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func wearing() -> bool:
	return scabbard == Vector2.INF and lost_s <= 0.0


## The scabbard: no blood is lost (Burn and Poison do nothing while she wears it).
func cap_lethal(amount: float) -> float:
	return 0.0 if wearing() else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	var enemies: EnemyManager = GameAuthority.enemies
	if lost_s > 0.0:
		lost_s -= delta
		return
	if scabbard != Vector2.INF:
		_lies_s -= delta
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(scabbard) <= float(_sig().get("scabbard_reach_px", 16.0)) + player.body_radius:
				take(player)
				return
		if _lies_s <= 0.0:
			scabbard = Vector2.INF
		return
	enemies.hp[slot] = minf(enemies.hp[slot] + enemies.max_hp[slot] * float(_sig().get("heal_per_s", 0.008)) * delta, enemies.max_hp[slot])
	_drop_in -= delta
	if _drop_in <= 0.0:
		_drop_in = float(_sig().get("drop_every_s", 12.0))
		drop()


func drop() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	scabbard = position_now() + Vector2.from_angle(rng.randf() * TAU) * float(_sig().get("drop_px", 110.0))
	_lies_s = float(_sig().get("lies_s", 5.0))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and taken == 0:
		banner.show_text(tr("BOSS_MORGAN_SCABBARD"))


func take(_player: Player) -> void:
	taken += 1
	scabbard = Vector2.INF
	lost_s = float(_sig().get("lost_s", 10.0))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the scabbard moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if scabbard != Vector2.INF:
		scabbard -= shift_px


func _draw() -> void:
	if scabbard != Vector2.INF and is_alive():
		var at: Vector2 = scabbard - global_position
		draw_line(at + Vector2(-9, 4), at + Vector2(9, -4), Color(0.55, 0.15, 0.2), 4.0)
		draw_line(at + Vector2(-9, 4), at + Vector2(9, -4), Color(0.9, 0.75, 0.3), 1.0)
		draw_arc(at, 16.0, 0.0, TAU, 20, Color(1, 1, 1, 0.4), 1.0)
	if wearing() and is_alive():
		draw_arc(position_now() - global_position, GameAuthority.enemies.radius[slot] + 6.0, 0.0, TAU, 24, Color(0.4, 0.9, 0.5, 0.35), 1.5)
	super._draw()
