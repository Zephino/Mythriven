class_name WhiteDragonBoss
extends BossController
## The White Dragon, 30:00 (docs/PACK_11_PLAN.md: Dinas Emrys; the design's boss). Signature, the vat of mead: by turns
## it fights on the ground and takes to the air (out of reach), breathing frost on marked spots round the Heroes. A vat of
## mead under a silk cloth stands in the arena; a Hero who stands at it for a moment uncovers it, and the dragon comes
## down to drink: it falls asleep (stunned, taking double damage). The vat fills again after a while. Sources: Historia
## Brittonum 42; "Lludd and Llefelys" (the dragons fall into the vat of mead, drink, sleep, and are buried at Dinas
## Emrys).

var vat := Vector2.INF
var flying: bool = false
var asleep_s: float = 0.0
var sleeps: int = 0
## Marked frost strikes: {"pos", "left"}.
var marks: Array = []
## Seconds until the vat is full and covered again (0 = ready).
var refill_s: float = 0.0
var _left: float = 0.0
var _strike_in: float = 0.0
var _held: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and vat == Vector2.INF:
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		vat = centre + Vector2(0.0, float(_sig().get("vat_px", 120.0)))
		_left = float(_sig().get("ground_s", 8.0))
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_WHITE_DRAGON_VAT"))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if flying:
		return 0.0
	return amount * float(_sig().get("sleep_damage_taken", 2.0)) if asleep_s > 0.0 else amount


func signature(delta: float) -> void:
	for i: int in range(marks.size() - 1, -1, -1):
		marks[i]["left"] = float(marks[i]["left"]) - delta
		if float(marks[i]["left"]) <= 0.0:
			_frost(marks[i]["pos"])
			marks.remove_at(i)
	if not is_alive():
		return
	refill_s = maxf(refill_s - delta, 0.0)
	if asleep_s > 0.0:
		asleep_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(asleep_s, 0.2))
		return
	_watch_vat(delta)
	_left -= delta
	if _left <= 0.0:
		flying = not flying
		_left = float(_sig().get("sky_s" if flying else "ground_s", 5.0))
		_strike_in = 0.3
	if flying:
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], 0.2)
		_strike_in -= delta
		if _strike_in <= 0.0:
			_strike_in = float(_sig().get("strike_every_s", 1.0))
			for player: Player in GameAuthority.players:
				if player.alive:
					marks.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 1.0))})


func _watch_vat(delta: float) -> void:
	if refill_s > 0.0 or vat == Vector2.INF:
		_held = 0.0
		return
	var on: bool = false
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(vat) <= float(_sig().get("reach_px", 20.0)) + player.body_radius:
			on = true
	_held = _held + delta if on else 0.0
	if _held >= float(_sig().get("uncover_s", 1.5)):
		drink()


## The cloth comes off the mead: down comes the dragon to drink, and sleeps.
func drink() -> void:
	_held = 0.0
	sleeps += 1
	flying = false
	_left = float(_sig().get("ground_s", 8.0))
	GameAuthority.enemies.positions[slot] = vat + Vector2(0.0, -float(data.get("radius", 26.0)))
	asleep_s = float(_sig().get("sleep_s", 5.0))
	refill_s = float(_sig().get("refill_s", 15.0))
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_WHITE_DRAGON_ASLEEP"))


func _frost(at: Vector2) -> void:
	var reach: float = float(_sig().get("strike_radius_px", 32.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("strike_damage", 14.0)), str(data.get("id", "")), at)
			player.statuses.apply("chill")
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.8, 0.9, 1.0), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the vat and the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if vat != Vector2.INF:
		vat -= shift_px
	for m: Dictionary in marks:
		m["pos"] = Vector2(m["pos"]) - shift_px


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	for m: Dictionary in marks:
		draw_arc(Vector2(m["pos"]) - global_position, float(_sig().get("strike_radius_px", 32.0)), 0.0, TAU, 20, area_color, 1.5)
	if vat != Vector2.INF and is_alive():
		var p: Vector2 = vat - global_position
		draw_rect(Rect2(p + Vector2(-14, -12), Vector2(28, 20)), Color(0.45, 0.3, 0.18))
		draw_line(p + Vector2(-14, -6), p + Vector2(14, -6), Color(0.3, 0.2, 0.12), 2.0)
		if refill_s <= 0.0:
			draw_colored_polygon(PackedVector2Array([p + Vector2(-17, -12), p + Vector2(17, -12), p + Vector2(12, -16), p + Vector2(-12, -16)]), Color(0.92, 0.88, 0.95))
		else:
			draw_rect(Rect2(p + Vector2(-12, -13), Vector2(24, 2)), Color(0.85, 0.65, 0.25))
		if _held > 0.0:
			draw_arc(p, 22.0, -PI / 2, -PI / 2 + TAU * _held / float(_sig().get("uncover_s", 1.5)), 24, Color(1.0, 0.9, 0.5), 2.0)
	if flying and is_alive():
		draw_set_transform(position_now() - global_position, 0.0, Vector2(1.0, 0.4))
		draw_circle(Vector2.ZERO, 24.0, Color(0, 0, 0, 0.35))
		draw_set_transform(Vector2.ZERO)
		return
	super._draw()
