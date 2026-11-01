class_name BrassHorsemanBoss
extends BossController
## The Brass Horseman, 30:00 (docs/PACK_13_PLAN.md: the City of Brass; the design's boss). Signature, the pointing
## spear: every few seconds he turns his spear to point at a Hero (a marked line), then charges along it. A Hero who
## stands behind him for a moment turns him the wrong way: he is dazed (stunned, double damage). Source: "The City of
## Brass", One Thousand and One Nights (the brass horseman on the pillar, who points the way when he is turned).

var aim := Vector2.INF
var charges: int = 0
var turned: int = 0
var dazed_s: float = 0.0
## The way his spear points; it turns only when he aims (or is turned), not as he walks.
var spear := Vector2.LEFT
var _aim_left: float = 0.0
var _aim_in: float = 2.0
var _behind: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("dazed_damage_taken", 2.0)) if dazed_s > 0.0 else amount


## Whether the Hero stands behind him, against the way his spear points.
func is_behind(player: Player) -> bool:
	var to: Vector2 = player.position - position_now()
	return to.length() <= float(_sig().get("turn_px", 40.0)) + float(data.get("radius", 26.0)) and to.normalized().dot(spear) < -0.3


func signature(delta: float) -> void:
	if not is_alive():
		aim = Vector2.INF
		return
	if dazed_s > 0.0:
		dazed_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(dazed_s, 0.2))
		return
	var any: bool = false
	for player: Player in GameAuthority.players:
		if player.alive and is_behind(player):
			any = true
	_behind = _behind + delta if any else 0.0
	if _behind >= float(_sig().get("turn_s", 1.0)):
		turn_him()
		return
	if aim != Vector2.INF:
		spear = (aim - position_now()).normalized() if aim != position_now() else spear
		_aim_left -= delta
		if _aim_left <= 0.0:
			_charge()
		return
	_aim_in -= delta
	if _aim_in <= 0.0:
		_aim_in = float(_sig().get("aim_every_s", 4.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null and near.position != position_now():
			spear = (near.position - position_now()).normalized()
			aim = position_now() + spear * float(_sig().get("charge_px", 220.0))
			_aim_left = float(_sig().get("aim_s", 1.5))


func _charge() -> void:
	charges += 1
	var from: Vector2 = position_now()
	for player: Player in GameAuthority.players:
		if player.alive and Geometry2D.get_closest_point_to_segment(player.position, from, aim).distance_to(player.position) <= float(_sig().get("charge_width_px", 24.0)) + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("charge_damage", 16.0)), str(data.get("id", "")), from)
	GameAuthority.enemies.positions[slot] = aim
	aim = Vector2.INF


## Turned on his pillar: the spear swings the wrong way and he stands dazed.
func turn_him() -> void:
	turned += 1
	_behind = 0.0
	aim = Vector2.INF
	spear = -spear
	dazed_s = float(_sig().get("dazed_s", 3.0))
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and turned == 1:
		banner.show_text(tr("BOSS_BRASS_HORSEMAN_TURNED"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the charge line moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if aim != Vector2.INF:
		aim -= shift_px


func _draw() -> void:
	if aim != Vector2.INF and is_alive():
		var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
		draw_line(position_now() - global_position, aim - global_position, area_color, float(_sig().get("charge_width_px", 24.0)) * 0.5)
	if is_alive():
		var me: Vector2 = position_now() - global_position
		draw_line(me, me + spear * (float(data.get("radius", 26.0)) + 18.0), Color(0.85, 0.65, 0.3), 2.0)
	if _behind > 0.0 and is_alive():
		draw_arc(position_now() - global_position, float(data.get("radius", 26.0)) + 10.0, -PI / 2, -PI / 2 + TAU * _behind / float(_sig().get("turn_s", 1.0)), 24, Color(1.0, 0.9, 0.5), 2.0)
	super._draw()
