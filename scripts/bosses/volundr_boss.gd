class_name VolundrBoss
extends BossController
## Volundr, 20:00 (docs/PACK_7_PLAN.md: Alfheim). Signature, the forged wings: every so often he rises into the air on
## the wings he made. While he flies he can't be reached, and he drops strikes on marked spots under the Heroes; then he
## lands. Source: the Poetic Edda, Volundarkvida (Volundr, "prince of elves", forges wings and flies from King Nidud,
## laughing).

var flying_s: float = 0.0
var flights: int = 0
## Strikes he has marked: {"pos": Vector2, "left": float}.
var marks: Array = []
var _fly_in: float = 8.0
var _drop_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return 0.0 if flying_s > 0.0 else amount


func signature(delta: float) -> void:
	for i: int in range(marks.size() - 1, -1, -1):
		marks[i]["left"] = float(marks[i]["left"]) - delta
		if float(marks[i]["left"]) <= 0.0:
			land_strike(marks[i]["pos"])
			marks.remove_at(i)
	if not is_alive():
		return
	if flying_s > 0.0:
		flying_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(flying_s, 0.2))
		_drop_in -= delta
		if _drop_in <= 0.0:
			_drop_in = float(_sig().get("drop_every_s", 1.0))
			for player: Player in GameAuthority.players:
				if player.alive:
					marks.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 1.0))})
		return
	_fly_in -= delta
	if _fly_in <= 0.0:
		_fly_in = float(_sig().get("fly_every_s", 12.0))
		take_wing()


func take_wing() -> void:
	flights += 1
	flying_s = float(_sig().get("fly_s", 4.0))
	_drop_in = 0.3
	cast = {}
	if patterns != null:
		patterns.clear()


func land_strike(at: Vector2) -> void:
	var reach: float = float(_sig().get("strike_radius_px", 34.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("strike_damage", 14.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.85, 0.85, 0.95), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for m: Dictionary in marks:
		m["pos"] = Vector2(m["pos"]) - shift_px


## In the air: only his shadow on the ground; the marked spots fill as the strikes come.
func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var reach: float = float(_sig().get("strike_radius_px", 34.0))
	for m: Dictionary in marks:
		var at: Vector2 = Vector2(m["pos"]) - global_position
		draw_arc(at, reach, 0.0, TAU, 24, area_color, 1.5)
		draw_circle(at, reach * (1.0 - float(m["left"]) / float(_sig().get("telegraph_s", 1.0))), Color(area_color, 0.3))
	if flying_s > 0.0 and is_alive():
		draw_set_transform(position_now() - global_position, 0.0, Vector2(1.0, 0.4))
		draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 0.35))
		draw_set_transform(Vector2.ZERO)
		return
	super._draw()
