class_name PhobetorBoss
extends BossController
## Phobetor, 30:00 (docs/PACK_10_PLAN.md: Demos Oneiron; the design's boss). Signature, the nightmare's shapes: by turns
## he is a beast (charging at a Hero), a bird (flying out of reach and striking from above) and a serpent (rings of venom
## around him). Source: Ovid, Metamorphoses 11.638-641 (called Icelus by the gods and Phobetor by men: he becomes a beast,
## a bird, a long serpent).

const FORMS := ["beast", "bird", "serpent"]

var form: int = 0
var changes: int = 0
## Marked strikes from the bird: {"pos", "left"}.
var marks: Array = []
var _left: float = -1.0
var _act_in: float = 1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "phobetor_" + str(FORMS[form])


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return 0.0 if FORMS[form] == "bird" else amount


func signature(delta: float) -> void:
	for i: int in range(marks.size() - 1, -1, -1):
		marks[i]["left"] = float(marks[i]["left"]) - delta
		if float(marks[i]["left"]) <= 0.0:
			_hit_area(marks[i]["pos"], float(_sig().get("strike_radius_px", 30.0)), float(_sig().get("strike_damage", 14.0)), "")
			marks.remove_at(i)
	if not is_alive():
		return
	if _left < 0.0:
		_left = float(_sig().get("form_s", 6.0))
	_left -= delta
	if _left <= 0.0:
		_left = float(_sig().get("form_s", 6.0))
		form = (form + 1) % FORMS.size()
		changes += 1
		_act_in = 0.5
	_act_in -= delta
	if _act_in > 0.0:
		return
	var near: Player = GameAuthority.enemies.nearest_player(position_now())
	match str(FORMS[form]):
		"beast":
			_act_in = float(_sig().get("charge_every_s", 2.0))
			if near != null:
				var to: Vector2 = near.position - position_now()
				GameAuthority.enemies.positions[slot] += to.limit_length(float(_sig().get("charge_px", 140.0)))
				_hit_area(position_now(), 40.0, float(_sig().get("charge_damage", 14.0)), "")
		"bird":
			_act_in = float(_sig().get("strike_every_s", 1.0))
			GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], 0.2)
			for player: Player in GameAuthority.players:
				if player.alive:
					marks.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 1.0))})
		"serpent":
			_act_in = float(_sig().get("venom_every_s", 2.0))
			_hit_area(position_now(), float(_sig().get("venom_radius_px", 80.0)), float(_sig().get("venom_damage", 8.0)), "poison")


func _hit_area(at: Vector2, reach: float, damage: float, status: String) -> void:
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, damage, str(data.get("id", "")), at)
			if status != "":
				player.statuses.apply(status)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.55, 0.35, 0.75), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for m: Dictionary in marks:
		m["pos"] = Vector2(m["pos"]) - shift_px


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	for m: Dictionary in marks:
		draw_arc(Vector2(m["pos"]) - global_position, float(_sig().get("strike_radius_px", 30.0)), 0.0, TAU, 20, area_color, 1.5)
	if FORMS[form] == "bird" and is_alive():
		draw_set_transform(position_now() - global_position, 0.0, Vector2(1.0, 0.4))
		draw_circle(Vector2.ZERO, 20.0, Color(0, 0, 0, 0.35))
		draw_set_transform(Vector2.ZERO)
		return
	super._draw()
