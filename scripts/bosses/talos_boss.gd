class_name TalosBoss
extends BossController
## Talos, 30:00 (docs/PACK_9_PLAN.md: Lemnos; the design's boss). Signature, the bronze guardian: he hurls boulders at
## the Heroes (marked where they will land), and every so often heats himself red-hot, burning whoever is close; when
## the heat is spent, the nail in his ankle shows for a few seconds and he takes far more damage. Sources: Apollonius,
## Argonautica 4.1638-1688; Apollodorus 1.9.26 (the single vein closed by a bronze nail at his ankle).

var hot_s: float = 0.0
var nail_s: float = 0.0
var heats: int = 0
## Boulders on their way: {"pos": Vector2, "left": float}.
var boulders: Array = []
var _throw_in: float = 4.0
var _heat_in: float = 10.0
var _burn_in: float = 0.5


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "talos_hot" if hot_s > 0.0 else "talos"


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("nail_damage_taken", 2.5)) if nail_s > 0.0 else amount


func signature(delta: float) -> void:
	for i: int in range(boulders.size() - 1, -1, -1):
		boulders[i]["left"] = float(boulders[i]["left"]) - delta
		if float(boulders[i]["left"]) <= 0.0:
			land(boulders[i]["pos"])
			boulders.remove_at(i)
	if not is_alive():
		return
	nail_s = maxf(nail_s - delta, 0.0)
	if hot_s > 0.0:
		hot_s -= delta
		_burn_in -= delta
		if _burn_in <= 0.0:
			_burn_in = 0.5
			for player: Player in GameAuthority.players:
				if player.alive and player.position.distance_to(position_now()) <= float(_sig().get("heat_radius_px", 70.0)) + player.body_radius:
					GameAuthority.damage_player(player, float(_sig().get("heat_damage", 6.0)), str(data.get("id", "")), position_now())
					player.statuses.apply("burn")
		if hot_s <= 0.0:
			nail_s = float(_sig().get("nail_s", 3.0))
		return
	_heat_in -= delta
	if _heat_in <= 0.0:
		_heat_in = float(_sig().get("heat_every_s", 14.0))
		heat_up()
		return
	_throw_in -= delta
	if _throw_in <= 0.0:
		_throw_in = float(_sig().get("throw_every_s", 4.0))
		for player: Player in GameAuthority.players:
			if player.alive:
				boulders.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 1.2))})


func heat_up() -> void:
	heats += 1
	hot_s = float(_sig().get("heat_s", 4.0))
	_burn_in = 0.3
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and heats == 1:
		banner.show_text(tr("BOSS_TALOS_RED_HOT"))


func land(at: Vector2) -> void:
	var reach: float = float(_sig().get("boulder_radius_px", 36.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("boulder_damage", 16.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.6, 0.55, 0.45), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for b: Dictionary in boulders:
		b["pos"] = Vector2(b["pos"]) - shift_px


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var reach: float = float(_sig().get("boulder_radius_px", 36.0))
	for b: Dictionary in boulders:
		var at: Vector2 = Vector2(b["pos"]) - global_position
		draw_arc(at, reach, 0.0, TAU, 24, area_color, 1.5)
		draw_circle(at, reach * (1.0 - float(b["left"]) / float(_sig().get("telegraph_s", 1.2))), Color(area_color, 0.3))
	super._draw()
	if not is_alive():
		return
	var me: Vector2 = position_now() - global_position
	if hot_s > 0.0:
		draw_arc(me, float(_sig().get("heat_radius_px", 70.0)), 0.0, TAU, 40, Color(1.0, 0.4, 0.1, 0.5), 2.0)
	if nail_s > 0.0:
		draw_circle(me + Vector2(6, GameAuthority.enemies.radius[slot] - 2.0), 3.0, Color(1.0, 0.9, 0.5))
