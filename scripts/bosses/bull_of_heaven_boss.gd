class_name BullOfHeavenBoss
extends BossController
## The Bull of Heaven, 20:00 (docs/PACK_2_PLAN.md: the Land Between the Rivers). Signature, the snorting pits: every
## few seconds he snorts and pits crack open in the earth round his target, and they stay for the rest of the fight:
## standing in one hurts and slows. Source: Epic of Gilgamesh, Tablet VI (at his snort a pit opened and a hundred men
## fell in).

## Open pits: {"pos": Vector2, "left": float}.
var pits: Array = []
var _snort_in: float = 2.0
var _hurt_in: float = 0.0
var _slowed: Dictionary = {}


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	_snort_in -= delta
	if _snort_in <= 0.0 and is_alive():
		_snort_in = float(_sig().get("every_s", 5.0))
		_snort()
	for i: int in range(pits.size() - 1, -1, -1):
		pits[i]["left"] = float(pits[i]["left"]) - delta
		if float(pits[i]["left"]) <= 0.0:
			pits.remove_at(i)
	_hurt_in -= delta
	var hurting: bool = _hurt_in <= 0.0
	if hurting:
		_hurt_in = 1.0
	var reach: float = float(_sig().get("pit_radius_px", 26.0))
	for player: Player in GameAuthority.players:
		var inside: bool = false
		for pit: Dictionary in pits:
			if player.position.distance_to(pit["pos"]) <= reach:
				inside = true
				break
		if inside:
			player.slow_zone_mult = float(_sig().get("pit_slow", 0.5))
			_slowed[player.player_id] = true
			if hurting and player.alive:
				GameAuthority.damage_player(player, float(_sig().get("pit_damage", 8.0)), "boss_bull_of_heaven")
		elif _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
			_slowed.erase(player.player_id)


func _snort() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var around: Vector2 = target.position if target != null and is_instance_valid(target) else position_now()
	for k: int in int(_sig().get("pits", 3)):
		var at: Vector2 = around + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0.0, 90.0)
		pits.append({"pos": at, "left": float(_sig().get("pit_s", 30.0))})
	while pits.size() > int(_sig().get("max_pits", 12)):
		pits.pop_front()
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(position_now(), 50.0, Color(0.7, 0.6, 0.45), true)


func _exit_tree() -> void:
	for player: Player in GameAuthority.players:
		if _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
	_slowed.clear()


## The pits: dark cracked holes in the ground.
func _draw() -> void:
	var reach: float = float(_sig().get("pit_radius_px", 26.0))
	for pit: Dictionary in pits:
		var at: Vector2 = Vector2(pit["pos"]) - global_position
		var fade: float = clampf(float(pit["left"]) / 2.0, 0.0, 1.0)
		draw_set_transform(at, 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, reach, Color(0.12, 0.08, 0.05, 0.85 * fade))
		draw_arc(Vector2.ZERO, reach, 0.0, TAU, 24, Color(0.45, 0.32, 0.2, fade), 2.0)
		draw_set_transform(Vector2.ZERO)
		for k: int in 5:
			var a: float = TAU * k / 5.0 + float(pit["pos"].x)
			draw_line(at + Vector2.from_angle(a) * Vector2(reach, reach * 0.6), at + Vector2.from_angle(a + 0.2) * Vector2(reach + 10.0, (reach + 10.0) * 0.6),
					Color(0.3, 0.2, 0.12, fade), 1.5)
	super._draw()
