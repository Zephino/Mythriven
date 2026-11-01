class_name SnowQueenBoss
extends BossController
## The Snow Queen, 30:00 (docs/PACK_10_PLAN.md: the Glass Mountain; the design's boss, Andersen's). Signature, the kiss
## and the ice puzzle: every so often her kiss freezes the nearest Hero for a moment (they can't move, and are Chilled).
## Pieces of ice lie on the frozen lake; gather four and the word is made, and her spell breaks (her guard breaks).
## Source: Hans Christian Andersen, "The Snow Queen" (1844): her kisses, and the pieces of ice Kai must fit into the word
## "Eternity" to be free.

var pieces: Array[Vector2] = []
var gathered: int = 0
var spells_broken: int = 0
var kisses: int = 0
var _piece_in: float = 4.0
var _kiss_in: float = 6.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	var reach: float = float(_sig().get("piece_reach_px", 14.0))
	for i: int in range(pieces.size() - 1, -1, -1):
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(pieces[i]) <= reach + player.body_radius:
				pieces.remove_at(i)
				gather_piece()
				break
	_piece_in -= delta
	if _piece_in <= 0.0:
		_piece_in = float(_sig().get("piece_every_s", 6.0))
		lay_piece()
	_kiss_in -= delta
	if _kiss_in <= 0.0:
		_kiss_in = float(_sig().get("kiss_every_s", 9.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			kiss(near)


func lay_piece() -> void:
	if pieces.size() >= int(_sig().get("max_pieces", 3)):
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	pieces.append(centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 200.0))


func gather_piece() -> void:
	gathered += 1
	if gathered >= int(_sig().get("word_pieces", 4)):
		gathered = 0
		spells_broken += 1
		guard_break()
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_SNOW_QUEEN_WORD"))


## Her kiss: the Hero freezes for a moment.
func kiss(player: Player) -> void:
	kisses += 1
	player.rooted_s = maxf(player.rooted_s, float(_sig().get("freeze_s", 1.5)))
	player.statuses.apply("chill")
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(player.position, 24.0, Color(0.8, 0.95, 1.0), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the ice pieces move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in pieces.size():
		pieces[i] -= shift_px


## The pieces of ice, and how many of the word's pieces are gathered.
func _draw() -> void:
	for at: Vector2 in pieces:
		var p: Vector2 = at - global_position
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -7), p + Vector2(5, 0), p + Vector2(0, 7), p + Vector2(-5, 0)]), Color(0.8, 0.95, 1.0, 0.9))
		draw_arc(p, 12.0, 0.0, TAU, 20, Color(1, 1, 1, 0.4), 1.0)
	super._draw()
	if is_alive():
		var top: Vector2 = position_now() - global_position + Vector2(-9, -GameAuthority.enemies.radius[slot] - 30.0)
		for k: int in int(_sig().get("word_pieces", 4)):
			draw_rect(Rect2(top + Vector2(k * 5, 0), Vector2(4, 4)), Color(0.8, 0.95, 1.0) if k < gathered else Color(1, 1, 1, 0.2))
