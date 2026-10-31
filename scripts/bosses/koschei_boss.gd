class_name KoscheiBoss
extends BossController
## Koschei the Deathless, 30:00 (docs/PACK_3_PLAN.md: the Slavic Wilds). Signature, the hidden death: he can't die
## while his death is safe; it is a needle in an egg, which lies somewhere out on the map (a golden thread leads each
## Hero to it). Reach the egg to break it, and Koschei becomes mortal. Source: Afanasyev, "The Death of Koschei the
## Deathless" (a needle, in an egg, in a duck, in a hare, in an iron chest, under an oak, on an island).

var egg := Vector2.INF
var mortal: bool = false
var _spoken: bool = false
var age: float = 0.0
## When the egg broke (seconds after he came), -1 while whole (the Needle secret: within needle_s).
var broken_at: float = -1.0


func secret_earned() -> String:
	return "the_needle" if broken_at >= 0.0 and broken_at <= float(_sig().get("needle_s", 45.0)) else ""


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	# A Guard Break multiplies the blow after this, so allow for it.
	var after: float = float((data.get("guard_gauge", {}) as Dictionary).get("damage_taken_mult", 1.5)) if broken_s > 0.0 else 1.0
	return cap_lethal(amount * after) / after


## Deathless: he never falls below 1 HP while the egg is whole.
func cap_lethal(amount: float) -> float:
	if mortal or not is_alive():
		return amount
	return minf(amount, maxf(GameAuthority.enemies.hp[slot] - 1.0, 0.0))


func signature(delta: float) -> void:
	if not is_alive():
		return
	age += delta
	if egg == Vector2.INF and not mortal:
		var range_px: Array = _sig().get("egg_distance_px", [320, 460])
		var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		egg = centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(float(range_px[0]), float(range_px[1]))
	if not _spoken:
		_spoken = true
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_KOSCHEI_EGG"))
	if mortal:
		return
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(egg) <= float(_sig().get("egg_reach_px", 18.0)) + player.body_radius:
			break_egg()
			return


## The needle snaps: Koschei can die.
func break_egg() -> void:
	mortal = true
	broken_at = age
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null and egg != Vector2.INF:
		effects.spawn_ring(egg, 40.0, Color(1.0, 0.85, 0.4), true)
	egg = Vector2.INF
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_KOSCHEI_MORTAL"))


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if egg != Vector2.INF:
		egg -= shift_px


## The egg, glowing, and a golden thread from each Hero to it.
func _draw() -> void:
	super._draw()
	if mortal or egg == Vector2.INF or not is_alive():
		return
	var at: Vector2 = egg - global_position
	var pulse: float = 0.6 + 0.4 * sin(Time.get_ticks_msec() * 0.006)
	draw_circle(at, 16.0, Color(1.0, 0.85, 0.4, 0.25 * pulse))
	var art: Dictionary = PixelArt.boss("koschei_egg")
	if not art.is_empty():
		PixelArt.draw_standing(self, art, at + Vector2(0, 6), false)
	for player: Player in GameAuthority.players:
		if player.alive:
			var from: Vector2 = player.position - global_position
			draw_line(from, from + (at - from).limit_length(70.0), Color(1.0, 0.85, 0.4, 0.6 * pulse), 2.0)
