class_name RedEaredHoundBoss
extends BossController
## The Red-Eared Hound, 10:00 (docs/PACK_12_PLAN.md: Tír na nÓg). Signature, the fawn: a hornless fawn runs about the
## arena and the hound chases it for ever, running down whoever is in its way. A Hero who reaches the fawn first leaves
## the hound baffled (dazed, taking double damage); the fawn comes back a little later. Source: Coimín, "Laoi Oisín i
## dTír na nÓg" (the hornless fawn and the white hound with red ears).

var fawn := Vector2.INF
var baffled: int = 0
var baffled_s: float = 0.0
var _angle: float = 0.0
var _fawn_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _centre() -> Vector2:
	return GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("baffled_damage_taken", 2.0)) if baffled_s > 0.0 else amount


## The hound runs after the fawn, not the Heroes, while there is a fawn to chase.
func _move(delta: float) -> void:
	if fawn == Vector2.INF or baffled_s > 0.0:
		super._move(delta)
		return
	var to: Vector2 = fawn - position_now()
	facing = to.normalized() if to.length() > 1.0 else facing
	GameAuthority.enemies.positions[slot] += to.limit_length(float(_sig().get("hound_px_s", 60.0)) * GameAuthority.enemies.statuses.speed_mult(slot) * delta)


func signature(delta: float) -> void:
	if not is_alive():
		return
	if baffled_s > 0.0:
		baffled_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(baffled_s, 0.2))
	if fawn == Vector2.INF:
		_fawn_in -= delta
		if _fawn_in <= 0.0:
			_angle = GameAuthority.run.rng.combat.randf() * TAU
			fawn = _fawn_at(_angle)
		return
	# The fawn bounds round and round the arena, weaving in and out.
	_angle += float(_sig().get("fawn_px_s", 70.0)) / 150.0 * delta
	fawn = _fawn_at(_angle)
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(fawn) <= float(_sig().get("fawn_reach_px", 16.0)) + player.body_radius:
			reach_fawn()
			return
	if position_now().distance_to(fawn) < float(data.get("radius", 18.0)):
		_angle += PI * 0.5


## Where the fawn is on its weaving path round the arena.
func _fawn_at(angle: float) -> Vector2:
	return _centre() + Vector2.from_angle(angle) * (150.0 + 40.0 * sin(angle * 3.0))


## A Hero gets to the fawn before the hound: the hound loses it.
func reach_fawn() -> void:
	baffled += 1
	fawn = Vector2.INF
	_fawn_in = float(_sig().get("fawn_again_s", 4.0))
	baffled_s = float(_sig().get("baffled_s", 3.0))
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and baffled == 1:
		banner.show_text(tr("BOSS_RED_EARED_HOUND_BAFFLED"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the fawn moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if fawn != Vector2.INF:
		fawn -= shift_px


## The hornless fawn, small and golden-brown.
func _draw() -> void:
	if fawn != Vector2.INF and is_alive():
		var p: Vector2 = fawn - global_position
		draw_set_transform(p, 0.0, Vector2(1.0, 0.7))
		draw_circle(Vector2.ZERO, 7.0, Color(0.78, 0.55, 0.32))
		draw_set_transform(Vector2.ZERO)
		draw_circle(p + Vector2(7, -6), 3.5, Color(0.78, 0.55, 0.32))
		for x: float in [-4.0, -1.0, 2.0, 5.0]:
			draw_line(p + Vector2(x, 3), p + Vector2(x, 10), Color(0.5, 0.33, 0.18), 1.5)
		draw_arc(p, 14.0, 0.0, TAU, 20, Color(1.0, 0.95, 0.6, 0.6), 1.0)
	super._draw()


## The Fawn Goes Free secret: the fawn reached first three times, then the hound beaten.
func secret_earned() -> String:
	return "the_fawn_goes_free" if baffled >= 3 else ""
