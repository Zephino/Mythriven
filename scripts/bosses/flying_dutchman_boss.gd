class_name FlyingDutchmanBoss
extends BossController
## The Flying Dutchman, 30:00 (docs/PACK_12_PLAN.md: Hy-Brasil; the design's boss). Signature, the phantom ship: by turns
## it is a phantom (it can't be hurt, and sails straight across the arena, striking whoever it passes over) and a solid
## ship, hove to, firing on marked spots round the Heroes. Its crew send letters drifting after the Heroes, letters home
## to the long dead: a Hero they reach is Hexed. Sources: Barrington, A Voyage to Botany Bay (1795); "Vanderdecken's
## Message Home", Blackwood's Magazine (1821).

var phantom: bool = true
var letters: Array[Vector2] = []
var letters_taken: int = 0
var marks: Array = []
var _left: float = -1.0
var _heading := Vector2.RIGHT
var _shot_in: float = 0.0
var _letter_in: float = 4.0
var _passed: Dictionary = {}


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "flying_dutchman_phantom" if phantom else "flying_dutchman"


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return 0.0 if phantom else amount


## As a phantom it sails on its own course; solid, it lies hove to.
func _move(delta: float) -> void:
	if not phantom:
		return
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	var at: Vector2 = position_now()
	if at.distance_to(centre) > 230.0 and _heading.dot(centre - at) < 0.0:
		_heading = (centre - at).normalized().rotated(GameAuthority.run.rng.combat.randf_range(-0.5, 0.5))
	facing = _heading
	GameAuthority.enemies.positions[slot] = at + _heading * float(_sig().get("sail_px_s", 150.0)) * delta


func signature(delta: float) -> void:
	for i: int in range(marks.size() - 1, -1, -1):
		marks[i]["left"] = float(marks[i]["left"]) - delta
		if float(marks[i]["left"]) <= 0.0:
			_shot(marks[i]["pos"])
			marks.remove_at(i)
	if not is_alive():
		return
	if _left < 0.0:
		_left = float(_sig().get("phantom_s", 6.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null and near.position != position_now():
			_heading = (near.position - position_now()).normalized()
	_left -= delta
	if _left <= 0.0:
		phantom = not phantom
		_left = float(_sig().get("phantom_s" if phantom else "solid_s", 6.0))
		_shot_in = 0.5
	if phantom:
		_pass_over(delta)
	else:
		_shot_in -= delta
		if _shot_in <= 0.0:
			_shot_in = float(_sig().get("shot_every_s", 1.0))
			for player: Player in GameAuthority.players:
				if player.alive:
					marks.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 1.0))})
	_drift_letters(delta)


## Sailing through the Heroes as a phantom: each is struck at most once a second.
func _pass_over(delta: float) -> void:
	for player: Player in GameAuthority.players:
		var wait: float = maxf(float(_passed.get(player, 0.0)) - delta, 0.0)
		_passed[player] = wait
		if player.alive and wait <= 0.0 and player.position.distance_to(position_now()) <= float(_sig().get("pass_radius_px", 34.0)) + player.body_radius:
			_passed[player] = 1.0
			GameAuthority.damage_player(player, float(_sig().get("pass_damage", 14.0)), str(data.get("id", "")), position_now())


func _drift_letters(delta: float) -> void:
	_letter_in -= delta
	if _letter_in <= 0.0:
		_letter_in = float(_sig().get("letter_every_s", 7.0))
		if letters.size() < int(_sig().get("max_letters", 3)):
			letters.append(position_now())
	for i: int in range(letters.size() - 1, -1, -1):
		var near: Player = GameAuthority.enemies.nearest_player(letters[i])
		if near == null:
			continue
		letters[i] = letters[i].move_toward(near.position, float(_sig().get("letter_px_s", 30.0)) * delta)
		if near.alive and letters[i].distance_to(near.position) <= float(_sig().get("letter_reach_px", 12.0)) + near.body_radius:
			letters.remove_at(i)
			take_letter(near)


## A letter for the long dead: an ill omen.
func take_letter(player: Player) -> void:
	letters_taken += 1
	player.statuses.apply("hex")
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and letters_taken == 1:
		banner.show_text(tr("BOSS_FLYING_DUTCHMAN_LETTER"))


func _shot(at: Vector2) -> void:
	var reach: float = float(_sig().get("shot_radius_px", 28.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("shot_damage", 12.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.35, 0.35, 0.35), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks and letters move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for m: Dictionary in marks:
		m["pos"] = Vector2(m["pos"]) - shift_px
	for i: int in letters.size():
		letters[i] -= shift_px


## The marked spots under fire, and the drifting letters (folded, sealed in red).
func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	for m: Dictionary in marks:
		draw_arc(Vector2(m["pos"]) - global_position, float(_sig().get("shot_radius_px", 28.0)), 0.0, TAU, 20, area_color, 1.5)
	for at: Vector2 in letters:
		var p: Vector2 = at - global_position
		draw_rect(Rect2(p + Vector2(-6, -4), Vector2(12, 8)), Color(0.9, 0.86, 0.72))
		draw_line(p + Vector2(-6, -4), p, Color(0.6, 0.55, 0.45), 1.0)
		draw_line(p + Vector2(6, -4), p, Color(0.6, 0.55, 0.45), 1.0)
		draw_circle(p, 1.5, Color(0.7, 0.1, 0.1))
	super._draw()
