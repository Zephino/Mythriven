class_name BisclavretBoss
extends BossController
## Bisclavret, 10:00 (docs/PACK_5_PLAN.md: Ossory). Signature, the hidden clothes: his clothes lie somewhere in the
## arena. A Hero who stands on them for a moment turns him back into a man for a few seconds: he can't fight and takes
## double damage. Then he is a wolf again and the clothes are hidden somewhere else. Source: Marie de France,
## Bisclavret (12th c.): without his clothes he must stay a wolf; given them back, he becomes a man.

var clothes := Vector2.INF
var man_s: float = 0.0
var turned: int = 0
var _held: float = 0.0
var _hide_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "bisclavret_man" if man_s > 0.0 else "bisclavret"


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("man_damage_taken", 2.0)) if man_s > 0.0 else amount


func hide_clothes() -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	clothes = centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(80.0, float(_sig().get("hide_px", 200.0)))
	_held = 0.0


func signature(delta: float) -> void:
	if not is_alive():
		return
	if man_s > 0.0:
		man_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(man_s, 0.2))
		if man_s <= 0.0:
			_hide_in = float(_sig().get("rehide_s", 3.0))
		return
	if clothes == Vector2.INF:
		_hide_in -= delta
		if _hide_in <= 0.0:
			hide_clothes()
		return
	var on: bool = false
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(clothes) <= float(_sig().get("clothes_reach_px", 18.0)) + player.body_radius:
			on = true
	_held = _held + delta if on else 0.0
	if _held >= float(_sig().get("restore_s", 1.5)):
		turn_back()


## He has his clothes again: a man for a few seconds.
func turn_back() -> void:
	turned += 1
	man_s = float(_sig().get("man_s", 6.0))
	clothes = Vector2.INF
	_held = 0.0
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_BISCLAVRET_MAN"))


## The bundle of clothes on the ground, and a ring showing how long a Hero has stood on it.
func _draw() -> void:
	super._draw()
	if clothes == Vector2.INF or not is_alive():
		return
	var at: Vector2 = clothes - global_position
	draw_rect(Rect2(at + Vector2(-7, -4), Vector2(14, 8)), Color(0.55, 0.35, 0.2))
	draw_rect(Rect2(at + Vector2(-5, -6), Vector2(10, 4)), Color(0.75, 0.7, 0.55))
	draw_arc(at, 18.0, 0.0, TAU, 24, Color(1, 1, 1, 0.5), 1.0)
	if _held > 0.0:
		draw_arc(at, 18.0, -PI / 2, -PI / 2 + TAU * _held / float(_sig().get("restore_s", 1.5)), 24, Color(1.0, 0.9, 0.5), 2.0)


## The King's Mercy secret: he was given his clothes back at least twice.
func secret_earned() -> String:
	return "the_kings_mercy" if turned >= 2 else ""
