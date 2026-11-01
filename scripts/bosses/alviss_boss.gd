class_name AlvissBoss
extends BossController
## Alviss, 10:00 (docs/PACK_6_PLAN.md: Svartalfheim). Signature, the dawn: shafts of daylight fall in the arena, moving
## slowly. When he stands in one he turns to stone for a few seconds: he can't act and takes double damage. Lead him
## into the light. Source: the Poetic Edda, Alvissmal (Thor keeps the dwarf talking until the sun rises, and the
## daylight turns him to stone).

## The sunbeams: {"pos": Vector2, "drift": Vector2}.
var beams: Array = []
var stone_s: float = 0.0
var petrified: int = 0
var _beam_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "alviss_stone" if stone_s > 0.0 else "alviss"


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("stone_damage_taken", 2.0)) if stone_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	_beam_in -= delta
	if _beam_in <= 0.0:
		_beam_in = float(_sig().get("beam_every_s", 6.0))
		add_beam()
	var reach: float = float(_sig().get("beam_radius_px", 40.0))
	for beam: Dictionary in beams:
		beam["pos"] = Vector2(beam["pos"]) + Vector2(beam["drift"]) * delta
	if stone_s > 0.0:
		stone_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(stone_s, 0.2))
		return
	for beam: Dictionary in beams:
		if position_now().distance_to(beam["pos"]) <= reach:
			turn_to_stone()
			beams.erase(beam)
			return


func add_beam() -> void:
	if beams.size() >= int(_sig().get("max_beams", 3)):
		beams.pop_front()
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	beams.append({"pos": centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(40.0, 180.0),
			"drift": Vector2.from_angle(rng.randf() * TAU) * float(_sig().get("drift_px_s", 12.0))})


func turn_to_stone() -> void:
	petrified += 1
	stone_s = float(_sig().get("stone_s", 4.0))
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_ALVISS_STONE"))


func _draw() -> void:
	var reach: float = float(_sig().get("beam_radius_px", 40.0))
	for beam: Dictionary in beams:
		var at: Vector2 = Vector2(beam["pos"]) - global_position
		draw_circle(at, reach, Color(1.0, 0.95, 0.7, 0.22))
		draw_arc(at, reach, 0.0, TAU, 28, Color(1.0, 0.9, 0.5, 0.6), 1.5)
	super._draw()

## The world re-centres under the Heroes (WorldRoot.origin_shifted): move what this boss left on the ground with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for beam: Dictionary in beams:
		beam["pos"] = Vector2(beam["pos"]) - shift_px


## The Dawn secret: turned to stone three times.
func secret_earned() -> String:
	return "the_dawn" if petrified >= 3 else ""
