class_name ErlkingBoss
extends BossController
## The Erlking, 30:00 (docs/PACK_7_PLAN.md: Alfheim; the design's boss). Signature, the lure: every so often he
## beckons, and for a few seconds the nearest Hero is drawn toward him, struggling. His daughters dance round him (his
## adds). Source: Goethe, "Erlkonig" (1782): "I love you, your fair form allures me; and if you're not willing, I'll
## use force."

var lured: Player
var lure_left: float = 0.0
var lures: int = 0
var _lure_in: float = 5.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		lured = null
		return
	if lure_left > 0.0 and lured != null and is_instance_valid(lured) and lured.alive:
		lure_left -= delta
		if not (lured.kit != null and lured.kit.controls_movement()):
			lured.position = lured.position.move_toward(position_now(), float(_sig().get("pull_px_s", 90.0)) * delta)
		if lure_left <= 0.0:
			lured = null
		return
	_lure_in -= delta
	if _lure_in <= 0.0:
		_lure_in = float(_sig().get("lure_every_s", 8.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			lure(near)


func lure(player: Player) -> void:
	lures += 1
	lured = player
	lure_left = float(_sig().get("lure_s", 2.5))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and lures == 1:
		banner.show_text(tr("BOSS_ERLKING_LURE"))


## A misty thread from the lured Hero to him.
func _draw() -> void:
	super._draw()
	if lure_left > 0.0 and lured != null and is_instance_valid(lured) and is_alive():
		var from: Vector2 = lured.position - global_position
		var to: Vector2 = position_now() - global_position
		for k: int in 3:
			var bend: Vector2 = (to - from).orthogonal().normalized() * (k - 1) * 6.0
			draw_polyline(PackedVector2Array([from, from.lerp(to, 0.5) + bend, to]), Color(0.8, 0.85, 0.95, 0.5), 1.0)
