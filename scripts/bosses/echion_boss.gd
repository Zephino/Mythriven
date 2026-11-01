class_name EchionBoss
extends BossController
## Echion, 20:00 (docs/PACK_7_PLAN.md: Lerna). Signature, the sown men: every so often he raises Spartoi from the
## ground round him. A stone lies in the arena; a Hero who takes it throws it among them, and every Spartoi nearby
## turns on the others for a while (charmed), as when Cadmus threw a stone among the sown men. Source: Apollodorus,
## Library 3.4.1 (the dragon's teeth; the Spartoi kill each other; Echion is one of the five who survive).

var stone := Vector2.INF
var raised: int = 0
var thrown: int = 0
var _raise_in: float = 3.0
var _stone_in: float = 2.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_raise_in -= delta
	if _raise_in <= 0.0:
		_raise_in = float(_sig().get("raise_every_s", 8.0))
		raise_sown_men()
	if stone == Vector2.INF:
		_stone_in -= delta
		if _stone_in <= 0.0:
			place_stone()
		return
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(stone) <= float(_sig().get("stone_reach_px", 16.0)) + player.body_radius:
			throw_stone(player)
			return


func raise_sown_men() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var at: Vector2 = position_now()
	for _k: int in int(_sig().get("sown", 4)):
		if GameAuthority.spawn_enemy(str(_sig().get("sown_man", "spartoi")), at + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(40.0, 90.0)) >= 0:
			raised += 1


func place_stone() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	stone = centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(80.0, 200.0)


## The stone lands among them: every sown man near turns on the others.
func throw_stone(player: Player) -> void:
	thrown += 1
	var enemies: EnemyManager = GameAuthority.enemies
	var ids: Array = _sig().get("sown_ids", ["spartoi", "spartoi_brute"])
	for other: int in enemies.query(position_now(), float(_sig().get("throw_reach_px", 400.0))):
		if enemies.active[other] != 0 and ids.has(str(enemies.type_of(other).get("id", ""))):
			enemies.charm(other, float(_sig().get("charm_s", 6.0)), player)
	stone = Vector2.INF
	_stone_in = float(_sig().get("stone_every_s", 10.0))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and thrown == 1:
		banner.show_text(tr("BOSS_ECHION_STONE"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the stone moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if stone != Vector2.INF:
		stone -= shift_px


func _draw() -> void:
	if stone != Vector2.INF and is_alive():
		var at: Vector2 = stone - global_position
		draw_circle(at, 6.0, Color(0.55, 0.55, 0.52))
		draw_circle(at + Vector2(-2, -2), 3.0, Color(0.75, 0.75, 0.72))
		draw_arc(at, 14.0, 0.0, TAU, 20, Color(1, 1, 1, 0.4), 1.0)
	super._draw()


## The Thrown Stone secret: the stone thrown three times.
func secret_earned() -> String:
	return "the_thrown_stone" if thrown >= 3 else ""
