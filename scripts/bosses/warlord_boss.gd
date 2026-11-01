class_name WarlordBoss
extends BossController
## The Warlord, 30:00 (docs/PACK_8_PLAN.md: Ghorvast, the game's own invented realm). Signature, the war banner: he
## plants his banner in the arena, and while it stands he takes far less damage. A Hero who stands at the banner for a
## moment tears it down; after a while he plants a new one.

var banner := Vector2.INF
var torn: int = 0
var _plant_in: float = 2.0
var _held: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("banner_damage_taken", 0.3)) if banner != Vector2.INF else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if banner == Vector2.INF:
		_plant_in -= delta
		if _plant_in <= 0.0:
			plant()
		return
	var on: bool = false
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(banner) <= float(_sig().get("banner_reach_px", 18.0)) + player.body_radius:
			on = true
	_held = _held + delta if on else 0.0
	if _held >= float(_sig().get("tear_s", 1.5)):
		tear_down()


func plant() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	banner = position_now() + Vector2.from_angle(rng.randf() * TAU) * float(_sig().get("plant_px", 90.0))
	_held = 0.0
	var b: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if b != null and torn == 0:
		b.show_text(tr("BOSS_WARLORD_BANNER"))


func tear_down() -> void:
	torn += 1
	banner = Vector2.INF
	_plant_in = float(_sig().get("replant_s", 12.0))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the banner moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if banner != Vector2.INF:
		banner -= shift_px


## The war banner on its pole, and a line from it to him while it shields him.
func _draw() -> void:
	if banner != Vector2.INF and is_alive():
		var at: Vector2 = banner - global_position
		draw_line(at, at + Vector2(0, -34), Color(0.35, 0.25, 0.15), 2.0)
		draw_colored_polygon(PackedVector2Array([at + Vector2(1, -34), at + Vector2(16, -30), at + Vector2(1, -24)]), Color(0.6, 0.12, 0.1))
		draw_line(at, position_now() - global_position, Color(0.8, 0.2, 0.15, 0.3), 1.0)
		if _held > 0.0:
			draw_arc(at, 18.0, -PI / 2, -PI / 2 + TAU * _held / float(_sig().get("tear_s", 1.5)), 24, Color(1.0, 0.9, 0.5), 2.0)
	super._draw()


## The Fallen Banner secret: his banner torn down three times.
func secret_earned() -> String:
	return "the_fallen_banner" if torn >= 3 else ""
