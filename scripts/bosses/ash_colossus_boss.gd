class_name AshColossusBoss
extends BossController
## The Ash Colossus, 20:00 (docs/PACK_11_PLAN.md: Ashkarrow, the game's own invented realm). Signature, the ash crust:
## Fire only feeds it (a Fire blow heals it instead of hurting it), but Ice or Water cracks its crust and it takes double
## damage for a few seconds. Every few seconds it sends out a ring of hot ash.

var cracked_s: float = 0.0
var fed: float = 0.0
var _element: String = ""
var _ring_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func on_element_hit(element: String) -> void:
	_element = element
	if element == "ice" or element == "water":
		if cracked_s <= 0.0:
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null:
				banner.show_text(tr("BOSS_ASH_COLOSSUS_CRACKED"))
		cracked_s = float(_sig().get("crack_s", 3.0))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if _element == "fire" and is_alive():
		var enemies: EnemyManager = GameAuthority.enemies
		var heal: float = amount * float(_sig().get("fire_heal", 0.5))
		if fed == 0.0:
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null:
				banner.show_text(tr("BOSS_ASH_COLOSSUS_FED"))
		fed += heal
		enemies.hp[slot] = minf(enemies.hp[slot] + heal, enemies.max_hp[slot])
		return 0.0
	return amount * float(_sig().get("crack_damage_taken", 2.0)) if cracked_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	cracked_s = maxf(cracked_s - delta, 0.0)
	_ring_in -= delta
	if _ring_in <= 0.0:
		_ring_in = float(_sig().get("ring_every_s", 5.0))
		var at: Vector2 = position_now()
		var reach: float = float(_sig().get("ring_radius_px", 90.0))
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
				GameAuthority.damage_player(player, float(_sig().get("ring_damage", 10.0)), str(data.get("id", "")), at)
				player.statuses.apply("burn")
		var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
		if effects != null:
			effects.spawn_ring(at, reach, Color(0.85, 0.4, 0.2), true)


func _draw() -> void:
	super._draw()
	if cracked_s > 0.0 and is_alive():
		var at: Vector2 = position_now() - global_position
		for k: int in 5:
			var a: float = k * TAU / 5.0 + 0.3
			draw_line(at + Vector2.from_angle(a) * 6.0, at + Vector2.from_angle(a + 0.2) * 22.0, Color(0.75, 0.9, 1.0), 1.5)
