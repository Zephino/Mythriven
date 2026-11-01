class_name MinosBoss
extends BossController
## Minos, 20:00 (docs/PACK_8_PLAN.md: Knossos). Signature, the judge of the dead: every so often he condemns the Hero
## farthest from him. The condemned Hero takes damage every moment until they come close to him for judgement (or the
## sentence runs out). Sources: Homer, Odyssey 11.568 (Minos with his golden sceptre giving judgement to the dead);
## Apollodorus 3.1.3-4.

var condemned: Player
var sentence_s: float = 0.0
var sentences: int = 0
var _judge_in: float = 5.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		condemned = null
		return
	if sentence_s > 0.0 and condemned != null and is_instance_valid(condemned) and condemned.alive:
		sentence_s -= delta
		if condemned.position.distance_to(position_now()) <= float(_sig().get("judge_px", 90.0)):
			sentence_s = 0.0
		else:
			GameAuthority.damage_player_over_time(condemned, float(_sig().get("sentence_dps", 6.0)) * delta)
		if sentence_s <= 0.0:
			condemned = null
		return
	_judge_in -= delta
	if _judge_in <= 0.0:
		_judge_in = float(_sig().get("judge_every_s", 10.0))
		condemn_farthest()


func condemn_farthest() -> void:
	var far: Player = null
	for player: Player in GameAuthority.players:
		if player.alive and (far == null or player.position.distance_to(position_now()) > far.position.distance_to(position_now())):
			far = player
	if far == null or far.position.distance_to(position_now()) <= float(_sig().get("judge_px", 90.0)):
		return
	condemned = far
	sentence_s = float(_sig().get("sentence_s", 6.0))
	sentences += 1
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and sentences == 1:
		banner.show_text(tr("BOSS_MINOS_CONDEMNS"))


## The golden chain of judgement from him to the condemned.
func _draw() -> void:
	super._draw()
	if sentence_s > 0.0 and condemned != null and is_instance_valid(condemned) and is_alive():
		var from: Vector2 = condemned.position - global_position
		var to: Vector2 = position_now() - global_position
		for k: int in 12:
			draw_circle(from.lerp(to, k / 12.0), 1.5, Color(0.95, 0.8, 0.3, 0.8))
		draw_arc(position_now() - global_position, float(_sig().get("judge_px", 90.0)), 0.0, TAU, 40, Color(0.95, 0.8, 0.3, 0.35), 1.0)
