class_name GreatBoygBoss
extends BossController
## The Great Bøyg, 20:00 (docs/PACK_13_PLAN.md: Dovrefjell). Signature, "go round about": it can't be beaten by force.
## Blows from a Hero who stands still barely touch it; a Hero who keeps moving round it hurts it fully. Source: Ibsen,
## Peer Gynt (1867), Act II.

## Each Hero's speed round it (px per second along the circle), smoothed.
var circling: Dictionary = {}
var full_hits: int = 0
var _last_angle: Dictionary = {}
var _told: bool = false


func _sig() -> Dictionary:
	return data.get("signature", {})


func is_circling(player: Player) -> bool:
	return float(circling.get(player, 0.0)) >= float(_sig().get("circling_px_s", 30.0))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if attacker != null and is_circling(attacker):
		full_hits += 1
		return amount
	return amount * float(_sig().get("still_damage_taken", 0.2))


func signature(delta: float) -> void:
	if not is_alive() or delta <= 0.0:
		return
	if not _told:
		_told = true
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_GREAT_BOYG_ROUND"))
	for player: Player in GameAuthority.players:
		var to: Vector2 = player.position - position_now()
		var angle: float = to.angle()
		if _last_angle.has(player):
			var speed: float = absf(angle_difference(float(_last_angle[player]), angle)) * to.length() / delta
			circling[player] = lerpf(float(circling.get(player, 0.0)), speed, minf(delta * 4.0, 1.0))
		_last_angle[player] = angle


## The Bøyg: a vast, slimy darkness round its body, hard to make out.
func _draw() -> void:
	if is_alive():
		var me: Vector2 = position_now() - global_position
		draw_circle(me, float(data.get("radius", 28.0)) + 26.0, Color(0.05, 0.05, 0.08, 0.35))
		draw_arc(me, float(data.get("radius", 28.0)) + 26.0, 0.0, TAU, 40, Color(0.25, 0.3, 0.25, 0.5), 2.0)
	super._draw()
