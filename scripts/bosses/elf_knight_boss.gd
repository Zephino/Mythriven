class_name ElfKnightBoss
extends BossController
## The Elf-Knight, 20:00 (docs/PACK_7_PLAN.md: Elfame). Signature, horn and lullaby: every so often he blows his horn
## and every Hero is drawn toward him. But if no one hurts him for a few seconds he dozes off, as Lady Isabel lulled him
## to sleep; asleep he can't act, and the first blow that wakes him lands twice as hard. Source: the ballad Lady Isabel
## and the Elf-Knight (Child 4).

var asleep: bool = false
var horn_left: float = 0.0
var horns: int = 0
var naps: int = 0
var _quiet_s: float = 0.0
var _horn_in: float = 5.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	_quiet_s = 0.0
	if asleep:
		asleep = false
		GameAuthority.enemies.statuses.stun[slot] = 0.0
		return amount * float(_sig().get("wake_damage_mult", 2.0))
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if asleep:
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], 0.2)
		return
	_quiet_s += delta
	if _quiet_s >= float(_sig().get("lull_s", 4.0)):
		fall_asleep()
		return
	if horn_left > 0.0:
		horn_left -= delta
		for player: Player in GameAuthority.players:
			if player.alive and not (player.kit != null and player.kit.controls_movement()):
				player.position = player.position.move_toward(position_now(), float(_sig().get("pull_px_s", 70.0)) * delta)
		return
	_horn_in -= delta
	if _horn_in <= 0.0:
		_horn_in = float(_sig().get("horn_every_s", 10.0))
		horns += 1
		horn_left = float(_sig().get("horn_s", 1.5))
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null and horns == 1:
			banner.show_text(tr("BOSS_ELF_KNIGHT_HORN"))


func fall_asleep() -> void:
	asleep = true
	naps += 1
	horn_left = 0.0
	cast = {}
	if patterns != null:
		patterns.clear()


## Asleep: little "z"s over his head.
func _draw() -> void:
	super._draw()
	if asleep and is_alive():
		var at: Vector2 = position_now() - global_position + Vector2(10, -GameAuthority.enemies.radius[slot] - 20.0)
		for k: int in 3:
			var z: Vector2 = at + Vector2(k * 5, -k * 6)
			draw_polyline(PackedVector2Array([z, z + Vector2(4, 0), z + Vector2(0, 4), z + Vector2(4, 4)]), Color(0.9, 0.95, 1.0), 1.0)
