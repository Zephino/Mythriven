class_name UtgardaLokiBoss
extends BossController
## Utgarda-Loki, 30:00 (docs/PACK_8_PLAN.md: Utgard; the design's boss). Signature, illusions: every so often he
## raises copies of himself round the arena. While any copy stands, most blows meant for him strike only air (he takes a
## quarter of the damage). Break the illusions first. Source: Snorri, Gylfaginning 44-47 (the king of Utgard deceives
## Thor with illusions: every contest was not what it seemed).

## Enemy slots of his copies.
var copies: Array[int] = []
var raised: int = 0
var _raise_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func copies_standing() -> int:
	var enemies: EnemyManager = GameAuthority.enemies
	var copy_id: String = str(_sig().get("copy", "utgard_illusion"))
	for i: int in range(copies.size() - 1, -1, -1):
		if enemies.active[copies[i]] == 0 or str(enemies.type_of(copies[i]).get("id", "")) != copy_id:
			copies.remove_at(i)
	return copies.size()


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("shielded_damage_taken", 0.25)) if copies_standing() > 0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if copies_standing() > 0:
		return
	_raise_in -= delta
	if _raise_in <= 0.0:
		_raise_in = float(_sig().get("raise_every_s", 6.0))
		raise_copies()


func raise_copies() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var at: Vector2 = position_now()
	for k: int in int(_sig().get("copies", 3)):
		var c: int = GameAuthority.spawn_enemy(str(_sig().get("copy", "utgard_illusion")),
				at + Vector2.from_angle(TAU * k / float(_sig().get("copies", 3)) + rng.randf()) * rng.randf_range(80.0, 140.0))
		if c >= 0:
			copies.append(c)
			raised += 1
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and raised <= int(_sig().get("copies", 3)):
		banner.show_text(tr("BOSS_UTGARDA_LOKI_ILLUSIONS"))


## A shimmer round him while his copies stand.
func _draw() -> void:
	super._draw()
	if is_alive() and not copies.is_empty():
		draw_arc(position_now() - global_position, GameAuthority.enemies.radius[slot] + 10.0, 0.0, TAU, 32,
				Color(0.7, 0.75, 1.0, 0.4 + 0.2 * sin(Time.get_ticks_msec() * 0.008)), 2.0)
