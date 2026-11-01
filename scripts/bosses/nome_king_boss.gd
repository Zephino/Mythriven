class_name NomeKingBoss
extends BossController
## The Nome King, 30:00 (docs/PACK_9_PLAN.md: the Hollow Hills; the design's boss, from Baum's book). Signature,
## ornaments and eggs: every so often he turns the nearest Hero into an ornament for a moment (they can't move). But
## Nomes fear eggs above everything: eggs appear in the arena, and a Hero who takes one terrifies him (he is stunned and
## takes double damage for a while). Source: L. Frank Baum, Ozma of Oz (1907): the Nome King turns his visitors into
## ornaments for his palace, and Billina the hen's eggs (poison to Nomes) undo him.

var eggs: Array[Vector2] = []
var scared_s: float = 0.0
var ornaments: int = 0
var frights: int = 0
var _turn_in: float = 6.0
var _egg_in: float = 5.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("scared_damage_taken", 2.0)) if scared_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	var reach: float = float(_sig().get("egg_reach_px", 14.0))
	for i: int in range(eggs.size() - 1, -1, -1):
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(eggs[i]) <= reach + player.body_radius:
				eggs.remove_at(i)
				fright()
				break
	if scared_s > 0.0:
		scared_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(scared_s, 0.2))
		return
	_egg_in -= delta
	if _egg_in <= 0.0:
		_egg_in = float(_sig().get("egg_every_s", 10.0))
		lay_egg()
	_turn_in -= delta
	if _turn_in <= 0.0:
		_turn_in = float(_sig().get("ornament_every_s", 9.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			make_ornament(near)


func lay_egg() -> void:
	if eggs.size() >= int(_sig().get("max_eggs", 2)):
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	eggs.append(centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 200.0))


## For a moment the Hero is a little ornament on his shelf.
func make_ornament(player: Player) -> void:
	ornaments += 1
	player.rooted_s = maxf(player.rooted_s, float(_sig().get("ornament_s", 2.0)))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and ornaments == 1:
		banner.show_text(tr("BOSS_NOME_KING_ORNAMENT"))


## An egg! The Nome King is terrified.
func fright() -> void:
	frights += 1
	scared_s = float(_sig().get("scared_s", 3.0))
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and frights == 1:
		banner.show_text(tr("BOSS_NOME_KING_EGG"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the eggs move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in eggs.size():
		eggs[i] -= shift_px


func _draw() -> void:
	for at: Vector2 in eggs:
		var p: Vector2 = at - global_position
		draw_set_transform(p, 0.0, Vector2(0.8, 1.0))
		draw_circle(Vector2.ZERO, 5.0, Color(0.96, 0.94, 0.88))
		draw_set_transform(Vector2.ZERO)
		draw_arc(p, 12.0, 0.0, TAU, 20, Color(1, 1, 1, 0.4), 1.0)
	super._draw()


## Billina's Eggs secret: frightened three times.
func secret_earned() -> String:
	return "billinas_eggs" if frights >= 3 else ""
