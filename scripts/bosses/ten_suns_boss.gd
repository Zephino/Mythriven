class_name TenSunsBoss
extends BossController
## The Ten Suns, 30:00 (docs/BONUS_LEVELS_PLAN.md: the Realm of the Ten Suns). Signature: ten suns blaze together and
## every few seconds scorch every Hero, harder the more suns are left. Each tenth of their strength shot away brings a
## sun down; when nine have fallen they are beaten, and the last sun is left in the sky, as Yi left it. Defeating them
## unlocks Hou Yi (bosses.json unlocks_hero). Source: the Huainanzi; the Shanhaijing (a crow in each sun).

var _scorch_in: float = 3.0
var _spoken: bool = false


func _sig() -> Dictionary:
	return data.get("signature", {})


## Suns still blazing (10 down to 1).
func suns_left() -> int:
	var total: int = int(_sig().get("suns", 10))
	if not is_alive():
		return 1
	return clampi(ceili(hp_fraction() * total), 1, total)


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	var enemies: EnemyManager = GameAuthority.enemies
	var last: float = enemies.max_hp[slot] / float(_sig().get("suns", 10))
	# The ninth sun falls: the fight is won and the last sun stays in the sky.
	if enemies.hp[slot] - amount <= last:
		return enemies.hp[slot] + 1.0
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if not _spoken:
		_spoken = true
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_TEN_SUNS_RISE"))
	_scorch_in -= delta
	if _scorch_in <= 0.0:
		_scorch_in = float(_sig().get("scorch_every_s", 4.0))
		for player: Player in GameAuthority.players:
			if player.alive:
				GameAuthority.damage_player(player, float(_sig().get("scorch_per_sun", 1.5)) * suns_left(), str(data.get("id", "")))


## The suns blazing over the arena, one small sun for each still in the sky.
func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	var at: Vector2 = position_now() - global_position + Vector2(0, -GameAuthority.enemies.radius[slot] - 50.0)
	var n: int = suns_left()
	for k: int in n:
		var spot: Vector2 = at + Vector2((k - (n - 1) * 0.5) * 14.0, sin(k + Time.get_ticks_msec() * 0.002) * 3.0)
		draw_circle(spot, 5.0, Color(1.0, 0.6, 0.15))
		draw_circle(spot, 3.0, Color(1.0, 0.95, 0.6))
