class_name AlberichBoss
extends BossController
## Alberich, 30:00 (docs/PACK_6_PLAN.md: Svartalfheim; the design's boss). Signature, the cloak of invisibility: every
## so often he puts on the Tarnkappe and vanishes; then he can't be hurt. Walk into him (he is a faint shimmer) and you
## tear the cloak off, as Siegfried did: his guard breaks. If no one finds him he takes it off again after a while.
## Source: the Nibelungenlied (c. 1200), 3rd adventure (Siegfried wrestles the cloak of invisibility from the dwarf
## Alberich, guardian of the Nibelung hoard).

var cloaked_s: float = 0.0
var torn: int = 0
var _cloak_in: float = 6.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return 0.0 if cloaked_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if cloaked_s > 0.0:
		cloaked_s -= delta
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(position_now()) <= GameAuthority.enemies.radius[slot] + player.body_radius + 4.0:
				tear_cloak()
				return
		return
	_cloak_in -= delta
	if _cloak_in <= 0.0:
		_cloak_in = float(_sig().get("cloak_every_s", 12.0))
		cloaked_s = float(_sig().get("cloak_s", 6.0))
		cast = {}
		if patterns != null:
			patterns.clear()


func tear_cloak() -> void:
	torn += 1
	cloaked_s = 0.0
	guard_break()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_ALBERICH_TORN"))


## Cloaked, only a faint shimmer shows where he stands.
func _draw() -> void:
	if cloaked_s <= 0.0:
		super._draw()
		return
	if not is_alive():
		return
	var at: Vector2 = position_now() - global_position
	var shimmer: float = 0.15 + 0.1 * sin(Time.get_ticks_msec() * 0.01)
	draw_arc(at, GameAuthority.enemies.radius[slot], 0.0, TAU, 20, Color(0.8, 0.85, 1.0, shimmer), 1.0)
