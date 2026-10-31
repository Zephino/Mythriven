class_name HraesvelgrBoss
extends BossController
## Hraesvelgr, 10:00 (docs/PACK_4_PLAN.md: Niflheim). Signature, wingbeats: every few seconds he beats his vast wings
## and a gale blows out from him, shoving every Hero away and stinging them. Source: Vafthrudnismal 37 (the giant in
## eagle's shape at the end of the heavens; the wind comes from his wings).

var gust_s: float = 0.0
var _gust_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_gust_in -= delta
	if _gust_in <= 0.0:
		_gust_in = float(_sig().get("gust_every_s", 5.0))
		gust_s = float(_sig().get("gust_s", 1.2))
		for player: Player in GameAuthority.players:
			if player.alive:
				GameAuthority.damage_player(player, float(_sig().get("gust_damage", 6.0)), str(data.get("id", "")), position_now())
	if gust_s > 0.0:
		gust_s -= delta
		var at: Vector2 = position_now()
		for player: Player in GameAuthority.players:
			if player.alive and not (player.kit != null and player.kit.controls_movement()):
				GameAuthority.push_player(player, (player.position - at).normalized() * float(_sig().get("gust_px_s", 220.0)) * delta)


## The gale: streaks of wind streaming out from him.
func _draw() -> void:
	super._draw()
	if gust_s <= 0.0 or not is_alive():
		return
	var at: Vector2 = position_now() - global_position
	var t: float = Time.get_ticks_msec() / 1000.0
	for k: int in 16:
		var dir := Vector2.from_angle(TAU * k / 16.0)
		var r: float = fmod(t * 300.0 + k * 37.0, 260.0)
		draw_line(at + dir * r, at + dir * (r + 30.0), Color(0.9, 0.95, 1.0, 0.6), 2.0)
