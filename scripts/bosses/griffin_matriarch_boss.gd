class_name GriffinMatriarchBoss
extends BossController
## The Griffin Matriarch, 30:00 (docs/PACK_10_PLAN.md: Hyperborea; the design's boss). Signature, the golden nest: she
## goes back to her nest of gold, where she heals and takes half damage; then she rises into the sky (out of reach) and
## swoops down on a marked spot under a Hero; then she fights on the ground before going back to the nest. Source:
## Herodotus, Histories 3.116 and 4.13, 4.27 (the griffins that guard the gold of the north).

## "ground", "nest", "sky", "swoop".
var state: String = "ground"
var nest := Vector2.INF
var swoop_at := Vector2.INF
var swoops: int = 0
var _left: float = 6.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func on_nest() -> bool:
	return state == "nest" and nest != Vector2.INF and position_now().distance_to(nest) <= 14.0


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if state == "sky" or state == "swoop":
		return 0.0
	return amount * float(_sig().get("nest_damage_taken", 0.5)) if on_nest() else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	var enemies: EnemyManager = GameAuthority.enemies
	if nest == Vector2.INF:
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		nest = centre + Vector2(0, -float(_sig().get("nest_offset_px", 140.0)))
	_left -= delta
	match state:
		"ground":
			if _left <= 0.0:
				state = "nest"
				_left = float(_sig().get("nest_s", 5.0))
		"nest":
			enemies.positions[slot] = enemies.positions[slot].move_toward(nest, float(_sig().get("fly_px_s", 260.0)) * delta)
			if on_nest():
				enemies.hp[slot] = minf(enemies.hp[slot] + enemies.max_hp[slot] * float(_sig().get("heal_per_s", 0.01)) * delta, enemies.max_hp[slot])
			if _left <= 0.0:
				state = "sky"
				_left = float(_sig().get("sky_s", 2.0))
				cast = {}
				if patterns != null:
					patterns.clear()
		"sky":
			enemies.statuses.stun[slot] = maxf(enemies.statuses.stun[slot], 0.2)
			if _left <= 0.0:
				var near: Player = enemies.nearest_player(position_now())
				swoop_at = near.position if near != null else position_now()
				state = "swoop"
				_left = float(_sig().get("swoop_telegraph_s", 1.0))
		"swoop":
			enemies.statuses.stun[slot] = maxf(enemies.statuses.stun[slot], 0.2)
			if _left <= 0.0:
				land()


func land() -> void:
	swoops += 1
	state = "ground"
	_left = float(_sig().get("ground_s", 6.0))
	GameAuthority.enemies.positions[slot] = swoop_at
	GameAuthority.enemies.statuses.stun[slot] = 0.0
	var reach: float = float(_sig().get("swoop_radius_px", 50.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(swoop_at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("swoop_damage", 22.0)), str(data.get("id", "")), swoop_at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(swoop_at, reach, Color(0.95, 0.8, 0.4), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the nest and the mark move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if nest != Vector2.INF:
		nest -= shift_px
	if swoop_at != Vector2.INF:
		swoop_at -= shift_px


func _draw() -> void:
	if nest != Vector2.INF and is_alive():
		var at: Vector2 = nest - global_position
		draw_set_transform(at, 0.0, Vector2(1.0, 0.55))
		draw_circle(Vector2.ZERO, 26.0, Color(0.55, 0.42, 0.25))
		draw_circle(Vector2.ZERO, 18.0, Color(0.9, 0.72, 0.25))
		draw_set_transform(Vector2.ZERO)
	if state == "swoop" and swoop_at != Vector2.INF:
		var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
		var p: Vector2 = swoop_at - global_position
		var reach: float = float(_sig().get("swoop_radius_px", 50.0))
		draw_arc(p, reach, 0.0, TAU, 28, area_color, 1.5)
		draw_circle(p, reach * 0.7, Color(0, 0, 0, 0.25))
	if state == "sky" or state == "swoop":
		return
	super._draw()
