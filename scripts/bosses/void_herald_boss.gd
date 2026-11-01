class_name VoidHeraldBoss
extends BossController
## The Herald of the Void, 30:00 (docs/PACK_11_PLAN.md: Ginnungagap; the design's invented herald, plain name). Signature,
## rime and fire: he turns by turns into rime (Chilling whoever is near) and fire (Burning whoever is near). A blow of
## the other element (Fire on rime, Ice on fire) shatters his form: stunned for a moment, he takes double damage, once
## per form. Every few seconds the gap opens under the farthest Hero (a marked spot). Source for the setting: Snorri,
## Gylfaginning 4-5 (Niflheim's rime and Muspelheim's fire meeting in Ginnungagap).

const FORMS := ["rime", "fire"]

var form: int = 0
var shatters: int = 0
var shattered_s: float = 0.0
var marks: Array = []
var _shattered_this_form: bool = false
var _left: float = -1.0
var _aura_in: float = 1.0
var _gap_in: float = 3.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "void_herald_" + str(FORMS[form])


func on_element_hit(element: String) -> void:
	if not is_alive() or _shattered_this_form:
		return
	if (FORMS[form] == "rime" and element == "fire") or (FORMS[form] == "fire" and element == "ice"):
		shatter()


func shatter() -> void:
	shatters += 1
	_shattered_this_form = true
	shattered_s = float(_sig().get("shatter_s", 2.0))
	cast = {}
	if patterns != null:
		patterns.clear()
	GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], shattered_s)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and shatters == 1:
		banner.show_text(tr("BOSS_VOID_HERALD_SHATTER"))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("shatter_damage_taken", 2.0)) if shattered_s > 0.0 else amount


func signature(delta: float) -> void:
	for i: int in range(marks.size() - 1, -1, -1):
		marks[i]["left"] = float(marks[i]["left"]) - delta
		if float(marks[i]["left"]) <= 0.0:
			_open_gap(marks[i]["pos"])
			marks.remove_at(i)
	if not is_alive():
		return
	shattered_s = maxf(shattered_s - delta, 0.0)
	if _left < 0.0:
		_left = float(_sig().get("form_s", 8.0))
	_left -= delta
	if _left <= 0.0:
		_left = float(_sig().get("form_s", 8.0))
		form = (form + 1) % FORMS.size()
		_shattered_this_form = false
	_aura_in -= delta
	if _aura_in <= 0.0:
		_aura_in = float(_sig().get("aura_every_s", 2.0))
		var reach: float = float(_sig().get("aura_radius_px", 70.0))
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(position_now()) <= reach + player.body_radius:
				GameAuthority.damage_player(player, float(_sig().get("aura_damage", 6.0)), str(data.get("id", "")), position_now())
				player.statuses.apply("chill" if FORMS[form] == "rime" else "burn")
	_gap_in -= delta
	if _gap_in <= 0.0:
		_gap_in = float(_sig().get("gap_every_s", 5.0))
		var far: Player = null
		for player: Player in GameAuthority.players:
			if player.alive and (far == null or player.position.distance_to(position_now()) > far.position.distance_to(position_now())):
				far = player
		if far != null:
			marks.append({"pos": far.position, "left": float(_sig().get("gap_telegraph_s", 1.2))})


func _open_gap(at: Vector2) -> void:
	var reach: float = float(_sig().get("gap_radius_px", 34.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("gap_damage", 16.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.35, 0.28, 0.6), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for m: Dictionary in marks:
		m["pos"] = Vector2(m["pos"]) - shift_px


## The marked spots where the gap will open, and his aura of rime or fire.
func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	for m: Dictionary in marks:
		draw_arc(Vector2(m["pos"]) - global_position, float(_sig().get("gap_radius_px", 34.0)), 0.0, TAU, 20, area_color, 1.5)
	if is_alive():
		var aura := Color(0.7, 0.85, 1.0, 0.25) if FORMS[form] == "rime" else Color(1.0, 0.45, 0.15, 0.25)
		draw_arc(position_now() - global_position, float(_sig().get("aura_radius_px", 70.0)), 0.0, TAU, 40, aura, 3.0)
	super._draw()
