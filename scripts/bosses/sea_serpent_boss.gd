class_name SeaSerpentBoss
extends BossController
## The Sea Serpent, 10:00 (docs/PACK_9_PLAN.md: Libertalia). Signature, the humps: every few seconds the great serpent
## rises in a line of humps across the arena (each marked first), striking whoever is under them, then sinks again.
## Source: Erik Pontoppidan, The Natural History of Norway (1752-53): the sea serpent seen in great coils on the water.

## Humps about to rise: {"pos": Vector2, "left": float}.
var humps: Array = []
var rises: int = 0
var _rise_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	for i: int in range(humps.size() - 1, -1, -1):
		humps[i]["left"] = float(humps[i]["left"]) - delta
		if float(humps[i]["left"]) <= 0.0:
			_hump_rises(humps[i]["pos"])
			humps.remove_at(i)
	if not is_alive():
		return
	_rise_in -= delta
	if _rise_in <= 0.0:
		_rise_in = float(_sig().get("rise_every_s", 6.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			rise_across(near.position)


## A line of humps through `through`, at a random slant.
func rise_across(through: Vector2) -> void:
	rises += 1
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var dir := Vector2.from_angle(rng.randf() * TAU)
	var count: int = int(_sig().get("humps", 7))
	var gap: float = float(_sig().get("hump_gap_px", 44.0))
	for k: int in count:
		humps.append({"pos": through + dir * gap * (k - (count - 1) * 0.5), "left": float(_sig().get("telegraph_s", 1.2)) + k * 0.06})


func _hump_rises(at: Vector2) -> void:
	var reach: float = float(_sig().get("hump_radius_px", 24.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("hump_damage", 14.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.3, 0.5, 0.45), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for h: Dictionary in humps:
		h["pos"] = Vector2(h["pos"]) - shift_px


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var reach: float = float(_sig().get("hump_radius_px", 24.0))
	for h: Dictionary in humps:
		var at: Vector2 = Vector2(h["pos"]) - global_position
		draw_arc(at, reach, 0.0, TAU, 20, area_color, 1.5)
		draw_circle(at, reach * clampf(1.0 - float(h["left"]) / float(_sig().get("telegraph_s", 1.2)), 0.0, 1.0), Color(0.2, 0.4, 0.5, 0.35))
	super._draw()
