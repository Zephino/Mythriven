class_name HammerGiantBoss
extends BossController
## The Giant with the Hammer, 20:00 (docs/PACK_9_PLAN.md: the Hollow Hills). Signature, the steady beat: without
## stopping, his great iron hammer falls on a marked strip in front of him in a steady beat. Pass between the blows.
## Source: L. Frank Baum, Ozma of Oz (1907), chapter 13: the giant of cast iron who pounds the narrow road to the Nome
## King's kingdom with his hammer, so no one can pass.

var blows: int = 0
var aim := Vector2.RIGHT
var _beat_left: float = 1.2


func _sig() -> Dictionary:
	return data.get("signature", {})


## True when `at` is on the strip the hammer will fall on.
func on_strip(at: Vector2) -> bool:
	var to: Vector2 = at - position_now()
	var along: float = to.dot(aim)
	return along >= 0.0 and along <= float(_sig().get("strip_px", 170.0)) and absf(to.dot(aim.orthogonal())) <= float(_sig().get("strip_width_px", 36.0)) * 0.5


func signature(delta: float) -> void:
	if not is_alive():
		return
	_beat_left -= delta
	if _beat_left <= 0.0:
		_beat_left = float(_sig().get("beat_s", 1.5))
		hammer_falls()


func hammer_falls() -> void:
	blows += 1
	for player: Player in GameAuthority.players:
		if player.alive and on_strip(player.position):
			GameAuthority.damage_player(player, float(_sig().get("hammer_damage", 16.0)), str(data.get("id", "")), position_now())
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(position_now() + aim * float(_sig().get("strip_px", 170.0)) * 0.6, 26.0, Color(0.55, 0.55, 0.6), true)
	# The next blow: toward the nearest Hero.
	var near: Player = GameAuthority.enemies.nearest_player(position_now())
	if near != null and near.position.distance_to(position_now()) > 1.0:
		aim = (near.position - position_now()).normalized()


## The strip the next blow will fall on, filling as it comes.
func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var p: Vector2 = position_now() - global_position
	var length: float = float(_sig().get("strip_px", 170.0))
	var n: Vector2 = aim.orthogonal() * float(_sig().get("strip_width_px", 36.0)) * 0.5
	var fill: float = clampf(1.0 - _beat_left / float(_sig().get("beat_s", 1.5)), 0.0, 1.0)
	draw_colored_polygon(PackedVector2Array([p + n, p + aim * length + n, p + aim * length - n, p - n]), Color(area_color, 0.1 + 0.3 * fill))
