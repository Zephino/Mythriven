class_name PoseidonsBullBoss
extends BossController
## Poseidon's Bull, 10:00 (docs/PACK_11_PLAN.md: Atlantis). Signature, staves and nooses: it charges at the nearest Hero
## (a marked line first). Nooses lie about the arena; a Hero who takes one ropes the bull: it is held fast and takes
## double damage for a while. Source: Plato, Critias 119d-e (the ten kings hunted the bulls of Poseidon's temple without
## weapons, with staves and nooses).

var nooses: Array[Vector2] = []
var noosed: int = 0
var held_s: float = 0.0
## The charge being aimed: where it ends (INF = none).
var aim := Vector2.INF
var _aim_left: float = 0.0
var _charge_in: float = 2.0
var _noose_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("held_damage_taken", 2.0)) if held_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	var reach: float = float(_sig().get("reach_px", 14.0))
	for i: int in range(nooses.size() - 1, -1, -1):
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(nooses[i]) <= reach + player.body_radius:
				nooses.remove_at(i)
				rope()
				break
	_noose_in -= delta
	if _noose_in <= 0.0:
		_noose_in = float(_sig().get("noose_every_s", 9.0))
		_lay_nooses()
	if held_s > 0.0:
		held_s -= delta
		aim = Vector2.INF
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(held_s, 0.2))
		return
	if aim != Vector2.INF:
		_aim_left -= delta
		if _aim_left <= 0.0:
			GameAuthority.enemies.positions[slot] = aim
			for player: Player in GameAuthority.players:
				if player.alive and player.position.distance_to(aim) <= 40.0 + player.body_radius:
					GameAuthority.damage_player(player, float(_sig().get("charge_damage", 14.0)), str(data.get("id", "")), aim)
			aim = Vector2.INF
		return
	_charge_in -= delta
	if _charge_in <= 0.0:
		_charge_in = float(_sig().get("charge_every_s", 3.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			aim = position_now() + (near.position - position_now()).limit_length(float(_sig().get("charge_px", 170.0)))
			_aim_left = float(_sig().get("telegraph_s", 0.8))


func _lay_nooses() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	while nooses.size() < int(_sig().get("nooses", 2)):
		nooses.append(centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 180.0))


## A noose round its horns: held fast.
func rope() -> void:
	noosed += 1
	held_s = float(_sig().get("held_s", 3.0))
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and noosed == 1:
		banner.show_text(tr("BOSS_POSEIDONS_BULL_NOOSED"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the nooses and the charge move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in nooses.size():
		nooses[i] -= shift_px
	if aim != Vector2.INF:
		aim -= shift_px


func _draw() -> void:
	if is_alive():
		for at: Vector2 in nooses:
			var p: Vector2 = at - global_position
			draw_arc(p, 6.0, 0.0, TAU, 14, Color(0.75, 0.62, 0.38), 2.0)
			draw_line(p + Vector2(5, 3), p + Vector2(12, 8), Color(0.75, 0.62, 0.38), 2.0)
		if aim != Vector2.INF:
			var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
			draw_line(position_now() - global_position, aim - global_position, area_color, 3.0)
			draw_arc(aim - global_position, 40.0, 0.0, TAU, 24, area_color, 1.5)
		if held_s > 0.0:
			draw_arc(position_now() - global_position, float(data.get("radius", 22.0)) + 4.0, 0.0, TAU, 24, Color(0.75, 0.62, 0.38), 2.0)
	super._draw()


## Staves and Nooses secret: noosed three times, then beaten.
func secret_earned() -> String:
	return "staves_and_nooses" if noosed >= 3 else ""
