class_name SporeMotherBoss
extends BossController
## The Spore Mother, 30:00 (docs/PACK_6_PLAN.md: Mycendra, the game's own invented realm). Signature, fruiting:
## mushrooms sprout around the arena and swell; after a few seconds each bursts, Poisoning and hurting whoever is near.
## A Hero who stands on one for a moment stamps it out first.

## Sprouting mushrooms: {"pos": Vector2, "age": float, "held": float}.
var sprouts: Array = []
var stamped: int = 0
var burst_count: int = 0
var _sprout_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_sprout_in -= delta
	if _sprout_in <= 0.0:
		_sprout_in = float(_sig().get("sprout_every_s", 4.0))
		for _k: int in int(_sig().get("sprouts_each", 2)):
			sprout()
	var stamp_reach: float = float(_sig().get("stamp_reach_px", 14.0))
	for i: int in range(sprouts.size() - 1, -1, -1):
		var s: Dictionary = sprouts[i]
		s["age"] = float(s["age"]) + delta
		var on: bool = false
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(s["pos"]) <= stamp_reach + player.body_radius:
				on = true
		s["held"] = float(s["held"]) + delta if on else 0.0
		if float(s["held"]) >= float(_sig().get("stamp_s", 0.6)):
			sprouts.remove_at(i)
			stamped += 1
		elif float(s["age"]) >= float(_sig().get("grow_s", 5.0)):
			sprouts.remove_at(i)
			burst(s["pos"])


func sprout() -> void:
	if sprouts.size() >= int(_sig().get("max_sprouts", 8)):
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	sprouts.append({"pos": centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(30.0, 200.0), "age": 0.0, "held": 0.0})


func burst(at: Vector2) -> void:
	burst_count += 1
	var reach: float = float(_sig().get("burst_radius_px", 50.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("burst_damage", 10.0)), str(data.get("id", "")), at)
			player.statuses.apply("poison")
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.65, 0.75, 0.3), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the mushrooms move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for s: Dictionary in sprouts:
		s["pos"] = Vector2(s["pos"]) - shift_px


## Each mushroom swelling, with its burst ring showing as it ripens.
func _draw() -> void:
	var grow: float = float(_sig().get("grow_s", 5.0))
	var reach: float = float(_sig().get("burst_radius_px", 50.0))
	for s: Dictionary in sprouts:
		var at: Vector2 = Vector2(s["pos"]) - global_position
		var ripe: float = clampf(float(s["age"]) / grow, 0.0, 1.0)
		draw_arc(at, reach, 0.0, TAU, 24, Color(0.7, 0.8, 0.3, 0.2 + 0.5 * ripe), 1.0)
		draw_rect(Rect2(at + Vector2(-1.5, -4.0 - 4.0 * ripe), Vector2(3, 4.0 + 4.0 * ripe)), Color(0.9, 0.88, 0.78))
		draw_circle(at + Vector2(0, -6.0 - 5.0 * ripe), 3.0 + 4.0 * ripe, Color(0.7, 0.45 + 0.2 * ripe, 0.3))
	super._draw()
