class_name BergelmirBoss
extends BossController
## Bergelmir, 20:00 (docs/PACK_11_PLAN.md: Ginnungagap). Signature, the lúðr: every so often the flood of Ymir's blood
## pours into the gap. While it lasts he rides it in his lúðr, fast and out of reach, and the blood wells up in marked
## pools under the Heroes, hurting and Soaking them. Sources: Vafþrúðnismál 35; Snorri, Gylfaginning 7 (all the frost
## giants drowned in Ymir's blood but Bergelmir, who climbed on to his lúðr).

var flood_s: float = 0.0
var floods: int = 0
## Marked pools of blood: {"pos", "left"}.
var marks: Array = []
var _flood_in: float = 0.0
var _band_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and floods == 0:
		_flood_in = float(_sig().get("flood_every_s", 12.0)) * 0.5


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return 0.0 if flood_s > 0.0 else amount


## On the flood he sails straight at the nearest Hero.
func _move(delta: float) -> void:
	if flood_s <= 0.0 or target == null:
		super._move(delta)
		return
	var to: Vector2 = target.position - position_now()
	facing = to.normalized() if to.length() > 1.0 else facing
	GameAuthority.enemies.positions[slot] += to.limit_length(float(_sig().get("ride_px_s", 110.0)) * delta)


func signature(delta: float) -> void:
	for i: int in range(marks.size() - 1, -1, -1):
		marks[i]["left"] = float(marks[i]["left"]) - delta
		if float(marks[i]["left"]) <= 0.0:
			_well_up(marks[i]["pos"])
			marks.remove_at(i)
	if not is_alive():
		return
	if flood_s > 0.0:
		flood_s -= delta
		_band_in -= delta
		if _band_in <= 0.0:
			_band_in = float(_sig().get("band_every_s", 1.0))
			for player: Player in GameAuthority.players:
				if player.alive:
					marks.append({"pos": player.position, "left": float(_sig().get("band_telegraph_s", 0.8))})
		return
	_flood_in -= delta
	if _flood_in <= 0.0:
		_flood_in = float(_sig().get("flood_every_s", 12.0))
		flood()


func flood() -> void:
	floods += 1
	flood_s = float(_sig().get("flood_s", 5.0))
	_band_in = 0.2
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and floods == 1:
		banner.show_text(tr("BOSS_BERGELMIR_FLOOD"))


func _well_up(at: Vector2) -> void:
	var reach: float = float(_sig().get("band_radius_px", 44.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("band_damage", 9.0)), str(data.get("id", "")), at)
			player.statuses.apply("soaked")
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.6, 0.08, 0.1), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for m: Dictionary in marks:
		m["pos"] = Vector2(m["pos"]) - shift_px


## The marked pools, and his lúðr (a long wooden box-boat) under him while he rides the flood.
func _draw() -> void:
	var reach: float = float(_sig().get("band_radius_px", 44.0))
	for m: Dictionary in marks:
		var p: Vector2 = Vector2(m["pos"]) - global_position
		draw_set_transform(p, 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, reach * (1.0 - float(m["left"]) / float(_sig().get("band_telegraph_s", 0.8))), Color(0.55, 0.05, 0.08, 0.45))
		draw_set_transform(Vector2.ZERO)
		draw_arc(p, reach, 0.0, TAU, 24, Color(0.75, 0.15, 0.15, 0.8), 1.5)
	if flood_s > 0.0 and is_alive():
		var me: Vector2 = position_now() - global_position
		draw_set_transform(me + Vector2(0, 6), 0.0, Vector2(1.0, 0.5))
		draw_circle(Vector2.ZERO, 38.0, Color(0.55, 0.05, 0.08, 0.5))
		draw_set_transform(Vector2.ZERO)
		draw_colored_polygon(PackedVector2Array([me + Vector2(-30, -2), me + Vector2(30, -2), me + Vector2(24, 10), me + Vector2(-24, 10)]), Color(0.45, 0.3, 0.18))
	super._draw()
