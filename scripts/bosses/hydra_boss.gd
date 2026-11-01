class_name HydraBoss
extends BossController
## The Lernaean Hydra, 30:00 (docs/PACK_7_PLAN.md: Lerna; the design's boss). Signature, the heads: it starts with nine
## heads and grows another every few seconds; the more heads, the faster it attacks. A Fire hit sears a neck, as Iolaus
## did with his torches, and a head is lost. Its last head is immortal: it can't be brought below 1 HP until a Hero
## buries that head under the rock that appears, and then it dies. Sources: Hesiod, Theogony 313-318; Apollodorus,
## Library 2.5.2.

var heads: int = 9
var buried: bool = false
var rock := Vector2.INF
var seared: int = 0
var _grow_in: float = 8.0
var _sear_ready: float = 0.0
var _bury_held: float = 0.0
var _base_every: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "hydra"


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	var after: float = float((data.get("guard_gauge", {}) as Dictionary).get("damage_taken_mult", 1.5)) if broken_s > 0.0 else 1.0
	return cap_lethal(amount * after) / after


## The immortal head: never below 1 HP until it is buried.
func cap_lethal(amount: float) -> float:
	if buried or not is_alive():
		return amount
	var hp: float = GameAuthority.enemies.hp[slot]
	if amount >= hp - 1.0:
		_show_rock()
		return maxf(hp - 1.0, 0.0)
	return amount


func on_element_hit(element: String) -> void:
	if element == "fire" and _sear_ready <= 0.0 and heads > 1:
		heads -= 1
		seared += 1
		_sear_ready = float(_sig().get("sear_cooldown_s", 1.0))
		_apply_heads()


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _base_every < 0.0:
		data = data.duplicate(true)
		_base_every = float(data.get("attack_every_s", 2.5))
		heads = int(_sig().get("start_heads", 9))
		_apply_heads()
	_sear_ready = maxf(_sear_ready - delta, 0.0)
	_grow_in -= delta
	if _grow_in <= 0.0:
		_grow_in = float(_sig().get("grow_every_s", 8.0))
		heads = mini(heads + 1, int(_sig().get("max_heads", 14)))
		_apply_heads()
	if rock == Vector2.INF:
		return
	var on: bool = false
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(rock) <= float(_sig().get("rock_reach_px", 18.0)) + player.body_radius:
			on = true
	_bury_held = _bury_held + delta if on else 0.0
	if _bury_held >= float(_sig().get("bury_s", 1.5)):
		bury()


## More heads, faster attacks.
func _apply_heads() -> void:
	data["attack_every_s"] = _base_every * 9.0 / float(maxi(heads, 1))


func _show_rock() -> void:
	if rock != Vector2.INF:
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	rock = position_now() + Vector2.from_angle(rng.randf() * TAU) * float(_sig().get("rock_px", 120.0))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_HYDRA_IMMORTAL"))


## The immortal head is buried under the rock: the Hydra dies.
func bury() -> void:
	buried = true
	rock = Vector2.INF
	var near: Player = GameAuthority.enemies.nearest_player(position_now())
	GameAuthority.kill_enemy(slot, near)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the rock moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if rock != Vector2.INF:
		rock -= shift_px


func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	# One small head-mark per head above it.
	var top: Vector2 = position_now() - global_position + Vector2(0, -GameAuthority.enemies.radius[slot] - 30.0)
	for k: int in heads:
		draw_circle(top + Vector2((k - (heads - 1) * 0.5) * 6.0, 0), 2.0, Color(0.4, 0.7, 0.35))
	if rock != Vector2.INF:
		var at: Vector2 = rock - global_position
		draw_circle(at, 12.0, Color(0.5, 0.48, 0.44))
		draw_circle(at + Vector2(-3, -3), 7.0, Color(0.66, 0.64, 0.6))
		if _bury_held > 0.0:
			draw_arc(at, 20.0, -PI / 2, -PI / 2 + TAU * _bury_held / float(_sig().get("bury_s", 1.5)), 24, Color(1.0, 0.9, 0.5), 2.0)


## Iolaus' Brands secret: five necks seared with Fire.
func secret_earned() -> String:
	return "iolaus_brands" if seared >= 5 else ""
