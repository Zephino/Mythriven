class_name BlackAnnisBoss
extends BossController
## Black Annis, 30:00 (docs/PACK_5_PLAN.md: the Brocken; the design's boss). Signature, the bower: after a while in the
## open she goes back to the bower she dug in the hillside and heals there (taking less damage); then she springs out
## at the nearest Hero, and her iron claws leave wounds that bleed (Poison). Source: Leicestershire folklore (John
## Heyrick, 1797; county histories): the blue-faced hag with iron claws who dug her cave, Black Annis' Bower, in the
## Dane Hills, and leapt out on whoever came near.

## "out", "home" (going back or resting in the bower), or "spring".
var state: String = "out"
var bower := Vector2.INF
var springs: int = 0
## The Empty Bower secret: how many times she has gone home (beaten before the third).
var homes: int = 0
var _left: float = -1.0
var _spring_to := Vector2.ZERO


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if state == "home" and bower != Vector2.INF and position_now().distance_to(bower) <= 12.0:
		amount *= float(_sig().get("bower_damage_taken", 0.5))
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	var enemies: EnemyManager = GameAuthority.enemies
	if bower == Vector2.INF:
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		bower = centre + Vector2(0, -float(_sig().get("bower_offset_px", 150.0)))
		_left = float(_sig().get("out_s", 7.0))
	_left -= delta
	match state:
		"out":
			if _left <= 0.0:
				state = "home"
				homes += 1
				_left = float(_sig().get("home_s", 4.0))
		"home":
			enemies.positions[slot] = enemies.positions[slot].move_toward(bower, float(_sig().get("run_px_s", 260.0)) * delta)
			if enemies.positions[slot].distance_to(bower) <= 12.0:
				enemies.hp[slot] = minf(enemies.hp[slot] + enemies.max_hp[slot] * float(_sig().get("heal_per_s", 0.01)) * delta, enemies.max_hp[slot])
			if _left <= 0.0:
				spring()
		"spring":
			enemies.positions[slot] = enemies.positions[slot].move_toward(_spring_to, float(_sig().get("spring_px_s", 600.0)) * delta)
			if enemies.positions[slot].distance_to(_spring_to) <= 4.0 or _left <= 0.0:
				land()


func spring() -> void:
	state = "spring"
	_left = 0.8
	var near: Player = GameAuthority.enemies.nearest_player(position_now())
	_spring_to = near.position if near != null else position_now()


func land() -> void:
	springs += 1
	state = "out"
	_left = float(_sig().get("out_s", 7.0))
	var at: Vector2 = position_now()
	var reach: float = float(_sig().get("claw_radius_px", 46.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("claw_damage", 20.0)), str(data.get("id", "")), at)
			player.statuses.apply("poison")
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.3, 0.4, 0.8), true)


## Her bower: a dark cave mouth in the hillside.
func _draw() -> void:
	if bower != Vector2.INF and is_alive():
		var at: Vector2 = bower - global_position
		draw_set_transform(at, 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, 30.0, Color(0.32, 0.28, 0.22, 0.9))
		draw_circle(Vector2.ZERO, 22.0, Color(0.04, 0.03, 0.03, 0.95))
		draw_set_transform(Vector2.ZERO)
	super._draw()


func secret_earned() -> String:
	return "the_empty_bower" if homes < 3 else ""

## The world re-centres under the Heroes (WorldRoot.origin_shifted): move what this boss left on the ground with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if bower != Vector2.INF:
		bower -= shift_px
	_spring_to -= shift_px
