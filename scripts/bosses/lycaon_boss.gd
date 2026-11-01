class_name LycaonBoss
extends BossController
## Lycaon, 30:00 (docs/PACK_7_PLAN.md: Arcadia; the design's boss). Signature, Zeus' wrath: every so often Zeus'
## thunderbolts fall on marked spots round the arena, under the Heroes and under Lycaon himself; they hurt whoever they
## strike, Lycaon too, so keep him where they fall. In his last phase he is a wolf, and faster. Source: Ovid,
## Metamorphoses 1.163-243 (Lycaon serves Zeus human flesh; Zeus strikes his house with lightning and he becomes a wolf).

var as_wolf: bool = false
## Thunderbolts on their way: {"pos": Vector2, "left": float}.
var bolts: Array = []
var self_struck: int = 0
var _bolt_in: float = 5.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "lycaon_wolf" if as_wolf else "lycaon"


func _on_phase_started(index: int) -> void:
	if index >= 2 and not as_wolf:
		as_wolf = true
		data = data.duplicate(true)
		data["move_speed"] = float(data.get("move_speed", 40.0)) * float(_sig().get("wolf_speed_mult", 1.6))
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_LYCAON_WOLF"))


func signature(delta: float) -> void:
	for i: int in range(bolts.size() - 1, -1, -1):
		bolts[i]["left"] = float(bolts[i]["left"]) - delta
		if float(bolts[i]["left"]) <= 0.0:
			strike(bolts[i]["pos"])
			bolts.remove_at(i)
	if not is_alive():
		return
	_bolt_in -= delta
	if _bolt_in <= 0.0:
		_bolt_in = float(_sig().get("bolt_every_s", 7.0))
		call_down()


## Zeus marks where his bolts will fall: under each Hero and under Lycaon.
func call_down() -> void:
	var tele: float = float(_sig().get("telegraph_s", 1.2))
	bolts.append({"pos": position_now(), "left": tele})
	for player: Player in GameAuthority.players:
		if player.alive:
			bolts.append({"pos": player.position, "left": tele})


func strike(at: Vector2) -> void:
	var reach: float = float(_sig().get("bolt_radius_px", 40.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("bolt_damage", 16.0)), str(data.get("id", "")), at)
	if is_alive() and position_now().distance_to(at) <= reach + GameAuthority.enemies.radius[slot]:
		self_struck += 1
		GameAuthority.damage_enemy(slot, GameAuthority.enemies.max_hp[slot] * float(_sig().get("self_damage_fraction", 0.04)),
				null, Vector2.ZERO, "lightning")
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_bolt(at, Color(0.85, 0.9, 1.0), true, true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for b: Dictionary in bolts:
		b["pos"] = Vector2(b["pos"]) - shift_px


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var reach: float = float(_sig().get("bolt_radius_px", 40.0))
	for b: Dictionary in bolts:
		var at: Vector2 = Vector2(b["pos"]) - global_position
		draw_arc(at, reach, 0.0, TAU, 24, area_color, 1.5)
		draw_circle(at, reach * (1.0 - float(b["left"]) / float(_sig().get("telegraph_s", 1.2))), Color(area_color, 0.3))
	super._draw()


## Zeus' Judgement secret: his own thunderbolts struck him three times.
func secret_earned() -> String:
	return "zeus_judgement" if self_struck >= 3 else ""
