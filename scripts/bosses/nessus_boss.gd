class_name NessusBoss
extends BossController
## Nessus, 30:00 (docs/PACK_13_PLAN.md: Mount Pelion; the design's boss). Signature, the ferryman: he charges along
## marked lines at the Heroes, and every so often carries the nearest off across the arena, Poisoned by his venomed
## blood. Heracles shot him from the far bank: blows from a Hero far from him hurt him twice as much. Sources: Ovid,
## Metamorphoses 9.98-133; Apollodorus 2.7.6.

var aim := Vector2.INF
var carried: int = 0
## Damage taken from far-off blows.
var far_damage: float = 0.0
var _aim_left: float = 0.0
var _charge_in: float = 2.0
var _carry_in: float = 6.0
var _told: bool = false


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if attacker != null and attacker.position.distance_to(position_now()) >= float(_sig().get("far_px", 150.0)):
		amount *= float(_sig().get("far_damage_taken", 2.0))
		far_damage += amount
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		aim = Vector2.INF
		return
	if not _told:
		_told = true
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_NESSUS_FAR"))
	_carry_in -= delta
	if _carry_in <= 0.0:
		_carry_in = float(_sig().get("carry_every_s", 10.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			carry_off(near)
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
		_charge_in = float(_sig().get("charge_every_s", 4.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			aim = position_now() + (near.position - position_now()).limit_length(float(_sig().get("charge_px", 180.0)))
			_aim_left = float(_sig().get("telegraph_s", 0.8))


## Across the river on his back: the Hero is set down on the far side, Poisoned.
func carry_off(player: Player) -> void:
	carried += 1
	if not (player.kit != null and player.kit.controls_movement()):
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		var across: Vector2 = centre - player.position
		if across.length() < 1.0:
			across = Vector2.RIGHT
		player.position = centre + across.normalized() * float(_sig().get("carry_px", 220.0)) * 0.6
	player.statuses.apply("poison")
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and carried == 1:
		banner.show_text(tr("BOSS_NESSUS_CARRIED"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the charge line moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if aim != Vector2.INF:
		aim -= shift_px


func _draw() -> void:
	if aim != Vector2.INF and is_alive():
		var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
		draw_line(position_now() - global_position, aim - global_position, area_color, 3.0)
		draw_arc(aim - global_position, 40.0, 0.0, TAU, 24, area_color, 1.5)
	super._draw()


## From Across the River secret: a third of his health struck from far away, then beaten.
func secret_earned() -> String:
	var whole: float = GameAuthority.enemies.max_hp[slot] if slot != -1 and GameAuthority.enemies != null else 1.0
	return "from_across_the_river" if far_damage >= whole / 3.0 else ""
