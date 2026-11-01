class_name GreatSprigganBoss
extends BossController
## The Spriggan, 30:00 (docs/PACK_12_PLAN.md: the Knockers' Deep; the design's boss). Signature, the swelling: every so
## often he swells to a giant's size (slow, hard to hurt, stamping out rings), then shrinks again, spent for a moment
## (double damage). Gold lies in his cairn: a Hero who stands at it for a moment takes some (run gold), and that makes him
## swell at once. Source: Robert Hunt, Popular Romances of the West of England (1865: the spriggans who guard buried
## treasure and can swell to the size of giants); Bottrell (1870-73).

## "normal", "swollen" or "spent".
var state: String = "normal"
var swells: int = 0
var gold_taken: int = 0
var cairn := Vector2.INF
var cairn_full: bool = true
var _left: float = -1.0
var _stomp_in: float = 0.0
var _held: float = 0.0
var _regold_in: float = 0.0
var _base_radius: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "great_spriggan_swollen" if state == "swollen" else "great_spriggan"


func _on_phase_started(index: int) -> void:
	if index == 0 and cairn == Vector2.INF:
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		cairn = centre + Vector2(float(_sig().get("cairn_px", 130.0)), 0.0)


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	match state:
		"swollen":
			return amount * float(_sig().get("swollen_damage_taken", 0.4))
		"spent":
			return amount * float(_sig().get("spent_damage_taken", 2.0))
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _base_radius < 0.0:
		_base_radius = GameAuthority.enemies.radius[slot]
	if _left < 0.0:
		_left = float(_sig().get("normal_s", 10.0))
	_watch_cairn(delta)
	_left -= delta
	match state:
		"normal":
			if _left <= 0.0:
				swell()
		"swollen":
			_stomp_in -= delta
			if _stomp_in <= 0.0:
				_stomp_in = float(_sig().get("stomp_every_s", 1.5))
				_stomp()
			if _left <= 0.0:
				_set_state("spent", float(_sig().get("spent_s", 3.0)))
		"spent":
			GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], 0.2)
			if _left <= 0.0:
				_set_state("normal", float(_sig().get("normal_s", 10.0)))


func _set_state(to: String, seconds: float) -> void:
	state = to
	_left = seconds
	if _base_radius > 0.0:
		GameAuthority.enemies.radius[slot] = _base_radius * (float(_sig().get("swollen_radius_mult", 1.8)) if to == "swollen" else 1.0)


## He swells to a giant's size.
func swell() -> void:
	if state == "swollen":
		return
	swells += 1
	if _base_radius < 0.0:
		_base_radius = GameAuthority.enemies.radius[slot]
	_set_state("swollen", float(_sig().get("swell_s", 5.0)))
	_stomp_in = 0.5
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and swells == 1:
		banner.show_text(tr("BOSS_GREAT_SPRIGGAN_SWELLS"))


func _watch_cairn(delta: float) -> void:
	if not cairn_full:
		_regold_in -= delta
		if _regold_in <= 0.0:
			cairn_full = true
		return
	var on: Player = null
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(cairn) <= float(_sig().get("cairn_reach_px", 20.0)) + player.body_radius:
			on = player
	_held = _held + delta if on != null else 0.0
	if on != null and _held >= float(_sig().get("take_s", 1.0)):
		take_gold(on)


## A Hero takes gold from his cairn: the Spriggan swells in his rage.
func take_gold(player: Player) -> void:
	gold_taken += 1
	_held = 0.0
	cairn_full = false
	_regold_in = float(_sig().get("regold_s", 15.0))
	GameAuthority.collect_gold(player, float(_sig().get("gold", 10.0)))
	swell()


func _stomp() -> void:
	var at: Vector2 = position_now()
	var reach: float = float(_sig().get("stomp_radius_px", 100.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("stomp_damage", 14.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.45, 0.38, 0.3), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the cairn moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if cairn != Vector2.INF:
		cairn -= shift_px


## His cairn of grey stones, with gold glinting in it while it is full.
func _draw() -> void:
	if cairn != Vector2.INF and is_alive():
		var p: Vector2 = cairn - global_position
		for k: int in 6:
			draw_circle(p + Vector2(-8 + (k % 3) * 8, -(k / 3) * 6), 5.0, Color(0.5, 0.48, 0.46))
		if cairn_full:
			for k: int in 4:
				draw_circle(p + Vector2(-6 + k * 4, -4 - (k % 2) * 3), 1.5, Color(1.0, 0.85, 0.3))
		if _held > 0.0:
			draw_arc(p, 20.0, -PI / 2, -PI / 2 + TAU * _held / float(_sig().get("take_s", 1.0)), 24, Color(1.0, 0.9, 0.5), 2.0)
	super._draw()


## Let It Lie secret: beaten without anyone taking gold from his cairn.
func secret_earned() -> String:
	return "let_it_lie" if gold_taken == 0 else ""
