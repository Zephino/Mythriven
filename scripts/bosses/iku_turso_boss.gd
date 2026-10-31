class_name IkuTursoBoss
extends BossController
## Iku-Turso, 20:00 (docs/PACK_3_PLAN.md: Pohjola). Signature, under the ice: every few seconds he dives under the
## frozen lake (he can't be hurt while under) and bursts up beneath his target, breaking the ice: anyone where he rises
## is hurt, and the hole of open water stays, slowing and chilling anyone who wades in. Source: Kalevala 42 (Turso rises
## from the water against the ship; Vainamoinen lifts him out by his ears).

var under_s: float = 0.0
## Open water: {"pos": Vector2, "left": float}.
var holes: Array = []
var _dive_in: float = 4.0
var _rise_at := Vector2.ZERO
var _hurt_in: float = 0.0
var _slowed: Dictionary = {}


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	return 0.0 if under_s > 0.0 else super.modify_hit(amount, attacker, push)


func signature(delta: float) -> void:
	if not is_alive():
		return
	if under_s > 0.0:
		under_s -= delta
		if under_s <= 0.0:
			_surface()
	else:
		_dive_in -= delta
		if _dive_in <= 0.0:
			_dive_in = float(_sig().get("dive_every_s", 9.0))
			under_s = float(_sig().get("under_s", 2.5))
			_rise_at = target.position if target != null and is_instance_valid(target) else position_now()
	for i: int in range(holes.size() - 1, -1, -1):
		holes[i]["left"] = float(holes[i]["left"]) - delta
		if float(holes[i]["left"]) <= 0.0:
			holes.remove_at(i)
	_wade(delta)


func _surface() -> void:
	GameAuthority.enemies.positions[slot] = _rise_at
	holes.append({"pos": _rise_at, "left": float(_sig().get("hole_s", 40.0))})
	while holes.size() > int(_sig().get("max_holes", 8)):
		holes.pop_front()
	var reach: float = float(_sig().get("surface_radius_px", 46.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(_rise_at) <= reach:
			GameAuthority.damage_player(player, float(_sig().get("surface_damage", 18.0)), "iku_turso", _rise_at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(_rise_at, reach, Color(0.85, 0.95, 1.0), true)


## Heroes wading in open water are slowed, and hurt a little each second.
func _wade(delta: float) -> void:
	_hurt_in -= delta
	var hurting: bool = _hurt_in <= 0.0
	if hurting:
		_hurt_in = 1.0
	var reach: float = float(_sig().get("hole_radius_px", 30.0))
	for player: Player in GameAuthority.players:
		var inside: bool = false
		for hole: Dictionary in holes:
			if player.position.distance_to(hole["pos"]) <= reach:
				inside = true
				break
		if inside:
			player.slow_zone_mult = float(_sig().get("hole_slow", 0.5))
			_slowed[player.player_id] = true
			if hurting and player.alive:
				GameAuthority.damage_player(player, float(_sig().get("hole_damage", 6.0)), "iku_turso")
		elif _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
			_slowed.erase(player.player_id)


func _exit_tree() -> void:
	for player: Player in GameAuthority.players:
		if is_instance_valid(player) and _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
	_slowed.clear()


## Open water in the ice; while he is under, ripples where he will rise.
func _draw() -> void:
	var reach: float = float(_sig().get("hole_radius_px", 30.0))
	for hole: Dictionary in holes:
		var at: Vector2 = Vector2(hole["pos"]) - global_position
		draw_set_transform(at, 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, reach + 4.0, Color(0.88, 0.95, 1.0, 0.9))
		draw_circle(Vector2.ZERO, reach, Color(0.06, 0.16, 0.22, 0.9))
		draw_set_transform(Vector2.ZERO)
	if under_s > 0.0:
		var at: Vector2 = _rise_at - global_position
		var t: float = Time.get_ticks_msec() / 1000.0
		for r: int in 3:
			draw_arc(at, 10.0 + fmod(t * 30.0 + r * 12.0, 36.0), 0.0, TAU, 24, Color(0.85, 0.95, 1.0, 0.7), 1.5)
		return
	super._draw()
