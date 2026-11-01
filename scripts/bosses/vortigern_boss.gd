class_name VortigernBoss
extends BossController
## Vortigern, 30:00 (docs/PACK_8_PLAN.md: Logres; the design's boss). Signature, the tower that would not stand: his
## tower stands in the arena, and near it he takes much less damage. Every so often it falls (stones crash down round
## it, hurting whoever is close) and is rebuilt after a while. A Fire hit on him while he is by the tower brings it down
## at once, as Aurelius burned him in it. Source: Geoffrey of Monmouth, Historia Regum Britanniae 6.17-8.2.

var tower := Vector2.INF
var standing: bool = false
var falls: int = 0
var _fall_in: float = 15.0
var _rebuild_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func near_tower() -> bool:
	return standing and position_now().distance_to(tower) <= float(_sig().get("tower_reach_px", 100.0))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("tower_damage_taken", 0.4)) if near_tower() else amount


func on_element_hit(element: String) -> void:
	if element == "fire" and near_tower():
		fall()


func signature(delta: float) -> void:
	if not is_alive():
		return
	if tower == Vector2.INF:
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		tower = centre + Vector2(0, -float(_sig().get("tower_offset_px", 120.0)))
		standing = true
		_fall_in = float(_sig().get("fall_every_s", 15.0))
	if not standing:
		_rebuild_in -= delta
		if _rebuild_in <= 0.0:
			standing = true
			_fall_in = float(_sig().get("fall_every_s", 15.0))
		return
	_fall_in -= delta
	if _fall_in <= 0.0:
		fall()


## The tower falls: stones crash down round it.
func fall() -> void:
	if not standing:
		return
	falls += 1
	standing = false
	_rebuild_in = float(_sig().get("rebuild_s", 6.0))
	var reach: float = float(_sig().get("rubble_radius_px", 90.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(tower) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("rubble_damage", 16.0)), str(data.get("id", "")), tower)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(tower, reach, Color(0.6, 0.58, 0.55), true)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and falls == 1:
		banner.show_text(tr("BOSS_VORTIGERN_TOWER_FALLS"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the tower moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if tower != Vector2.INF:
		tower -= shift_px


## The tower (or its rubble), and its sheltering ring.
func _draw() -> void:
	if tower != Vector2.INF and is_alive():
		var at: Vector2 = tower - global_position
		if standing:
			draw_rect(Rect2(at + Vector2(-12, -48), Vector2(24, 48)), Color(0.5, 0.48, 0.45))
			draw_rect(Rect2(at + Vector2(-12, -48), Vector2(5, 48)), Color(0.4, 0.38, 0.36))
			for k: int in 4:
				draw_rect(Rect2(at + Vector2(-12 + k * 7, -54), Vector2(4, 6)), Color(0.5, 0.48, 0.45))
			draw_arc(at, float(_sig().get("tower_reach_px", 100.0)), 0.0, TAU, 40, Color(0.7, 0.7, 0.75, 0.25), 1.0)
		else:
			for k: int in 7:
				draw_circle(at + Vector2.from_angle(k * 0.9) * (6.0 + k * 2.0), 4.0, Color(0.45, 0.43, 0.4))
	super._draw()
