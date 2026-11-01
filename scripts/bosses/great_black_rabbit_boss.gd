class_name GreatBlackRabbitBoss
extends BossController
## The Great Black Rabbit, 10:00 (docs/PACK_12_PLAN.md: Hy-Brasil). Signature, bounding: every few seconds it marks a
## spot near the nearest Hero and bounds there, landing hard on whoever is under it. Source: "O-Brazile, or the
## Inchanted Island" (1675: the island swarming with great black rabbits).

var landing := Vector2.INF
var leaps: int = 0
## Heroes it has landed on.
var landed_on: int = 0
var _leap_in: float = 2.0
var _left: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		landing = Vector2.INF
		return
	if landing != Vector2.INF:
		_left -= delta
		if _left <= 0.0:
			land()
		return
	_leap_in -= delta
	if _leap_in <= 0.0:
		_leap_in = float(_sig().get("leap_every_s", 2.5))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
			landing = near.position + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0.0, 30.0)
			_left = float(_sig().get("telegraph_s", 0.9))


func land() -> void:
	leaps += 1
	GameAuthority.enemies.positions[slot] = landing
	var reach: float = float(_sig().get("land_radius_px", 40.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(landing) <= reach + player.body_radius:
			landed_on += 1
			GameAuthority.damage_player(player, float(_sig().get("land_damage", 12.0)), str(data.get("id", "")), landing)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(landing, reach, Color(0.3, 0.28, 0.3), true)
	landing = Vector2.INF


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the landing spot moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if landing != Vector2.INF:
		landing -= shift_px


func _draw() -> void:
	if landing != Vector2.INF and is_alive():
		var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
		draw_arc(landing - global_position, float(_sig().get("land_radius_px", 40.0)), 0.0, TAU, 24, area_color, 1.5)
	super._draw()
