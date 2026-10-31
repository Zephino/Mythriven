class_name RocBoss
extends HraesvelgrBoss
## The Roc, 30:00 (docs/PACK_4_PLAN.md: Cloud-Cuckoo-Land). Signature: its wingbeats raise a gale that shoves Heroes
## away (as Hraesvelgr's, hraesvelgr_boss.gd), and every few seconds it drops great boulders round its target: their
## shadows grow, then they land. Source: the Thousand and One Nights (the Roc drops boulders on Sindbad's ship).

## Falling boulders: {"pos": Vector2, "left": float}.
var boulders: Array = []
var _drop_in: float = 3.0
## Sindbad's Escape secret: no boulder ever lands on the local Hero.
var struck_local: bool = false


func secret_earned() -> String:
	return "sindbads_escape" if not struck_local else ""


func signature(delta: float) -> void:
	super.signature(delta)
	if not is_alive():
		return
	var reach: float = float(_sig().get("boulder_radius_px", 34.0))
	for i: int in range(boulders.size() - 1, -1, -1):
		boulders[i]["left"] = float(boulders[i]["left"]) - delta
		if float(boulders[i]["left"]) > 0.0:
			continue
		var at: Vector2 = boulders[i]["pos"]
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(at) <= reach:
				GameAuthority.damage_player(player, float(_sig().get("boulder_damage", 18.0)), str(data.get("id", "")), at)
				if player.is_local:
					struck_local = true
		var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
		if effects != null:
			effects.spawn_ring(at, reach, Color(0.6, 0.5, 0.4), true)
		boulders.remove_at(i)
	_drop_in -= delta
	if _drop_in <= 0.0:
		_drop_in = float(_sig().get("boulder_every_s", 5.0))
		var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
		var around: Vector2 = target.position if target != null and is_instance_valid(target) else position_now()
		for k: int in int(_sig().get("boulders", 3)):
			boulders.append({"pos": around + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0.0, 80.0),
					"left": float(_sig().get("boulder_fall_s", 1.3))})


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for b: Dictionary in boulders:
		b["pos"] = Vector2(b["pos"]) - shift_px


## Each boulder's shadow grows as it falls; the stone drops onto it.
func _draw() -> void:
	super._draw()
	var reach: float = float(_sig().get("boulder_radius_px", 34.0))
	var full: float = maxf(float(_sig().get("boulder_fall_s", 1.3)), 0.01)
	for b: Dictionary in boulders:
		var at: Vector2 = Vector2(b["pos"]) - global_position
		var k: float = clampf(1.0 - float(b["left"]) / full, 0.0, 1.0)
		draw_circle(at, reach * k, Color(0, 0, 0, 0.3))
		draw_arc(at, reach, 0.0, TAU, 24, Color(1, 0.4, 0.3, 0.6), 1.5)
		var stone: Vector2 = at + Vector2(0, -160.0 * (1.0 - k))
		draw_circle(stone, reach * 0.45, Color(0.45, 0.4, 0.35))
		draw_circle(stone + Vector2(-3, -3), reach * 0.28, Color(0.6, 0.55, 0.5))
