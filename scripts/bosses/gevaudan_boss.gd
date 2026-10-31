class_name GevaudanBoss
extends BossController
## The Beast of Gévaudan, 30:00 (docs/PACK_5_PLAN.md: Ossory; the design's boss). Signature, the stalker: after a while
## in the open it vanishes into the trees (it can't be hurt or seen), the undergrowth stirs where it will spring, and it
## pounces out onto that spot, mauling whoever is there. Sources: French newspapers of 1764-67 (the Courrier
## d'Avignon, the Gazette de France); the Abbé Pourcher's history (1889): a huge wolf-like beast, reddish, with a
## black stripe down its back, that sprang on its victims from cover.

## "open", "hidden", or "stirring" (the spot it will spring on is marked).
var state: String = "open"
var pounce_at := Vector2.INF
var pounces: int = 0
## Out of the Undergrowth secret: no pounce ever lands on the local Hero.
var caught_local: bool = false
var _left: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return 0.0 if state != "open" else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _left < 0.0:
		_left = float(_sig().get("open_s", 6.0))
	_left -= delta
	if state == "hidden" and target != null and is_instance_valid(target):
		# It creeps after its prey under cover.
		var enemies: EnemyManager = GameAuthority.enemies
		enemies.positions[slot] = enemies.positions[slot].move_toward(target.position, float(_sig().get("creep_px_s", 80.0)) * delta)
	if _left > 0.0:
		return
	match state:
		"open":
			state = "hidden"
			_left = float(_sig().get("hidden_s", 3.0))
			cast = {}
			if patterns != null:
				patterns.clear()
		"hidden":
			state = "stirring"
			_left = float(_sig().get("stir_s", 1.0))
			pounce_at = target.position if target != null and is_instance_valid(target) else position_now()
		"stirring":
			pounce()


func pounce() -> void:
	pounces += 1
	state = "open"
	_left = float(_sig().get("open_s", 6.0))
	GameAuthority.enemies.positions[slot] = pounce_at
	var reach: float = float(_sig().get("pounce_radius_px", 44.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(pounce_at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("pounce_damage", 22.0)), str(data.get("id", "")), pounce_at)
			if player.is_local:
				caught_local = true
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(pounce_at, reach, Color(0.7, 0.3, 0.15), true)
	pounce_at = Vector2.INF


## Hidden, it isn't drawn; where it will spring, the undergrowth stirs.
func _draw() -> void:
	if state == "open":
		super._draw()
	if state == "stirring" and pounce_at != Vector2.INF:
		var at: Vector2 = pounce_at - global_position
		var reach: float = float(_sig().get("pounce_radius_px", 44.0))
		draw_arc(at, reach, 0.0, TAU, 28, Color.html(Data.cfg_string("bosses.area_telegraph_color")), 1.5)
		for k: int in 7:
			var leaf: Vector2 = at + Vector2.from_angle(k * 0.9 + Time.get_ticks_msec() * 0.01) * reach * (0.3 + 0.08 * k)
			draw_line(leaf, leaf + Vector2(0, -6), Color(0.3, 0.5, 0.2), 2.0)


func secret_earned() -> String:
	return "out_of_the_undergrowth" if not caught_local else ""
