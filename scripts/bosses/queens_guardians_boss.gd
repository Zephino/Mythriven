class_name QueensGuardiansBoss
extends BossController
## The Queen's Guardians, 20:00 (docs/PACK_13_PLAN.md: the City of Brass). Signature, the turning blades: their swords
## sweep round them in a turning cross; a Hero the blades pass over is cut. Jewels from the queen's bier lie in the arena:
## a Hero who takes one gets some gold, but the guardians strike them down at once. Source: "The City of Brass", One
## Thousand and One Nights (the two automatons with swords who guard the dead queen's jewels).

var angle: float = 0.0
var cuts: int = 0
var jewels: Array[Vector2] = []
var jewels_taken: int = 0
var _hurt_wait: Dictionary = {}
var _jewel_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func blade_hits(at: Vector2) -> bool:
	var me: Vector2 = position_now()
	var n: int = int(_sig().get("arms", 4))
	for k: int in n:
		var tip: Vector2 = me + Vector2.from_angle(angle + k * TAU / n) * float(_sig().get("blade_px", 110.0))
		if Geometry2D.get_closest_point_to_segment(at, me, tip).distance_to(at) <= float(_sig().get("blade_width_px", 10.0)):
			return true
	return false


func signature(delta: float) -> void:
	if not is_alive():
		return
	angle = wrapf(angle + float(_sig().get("turn_rad_s", 1.2)) * delta, 0.0, TAU)
	for player: Player in GameAuthority.players:
		var wait: float = maxf(float(_hurt_wait.get(player, 0.0)) - delta, 0.0)
		_hurt_wait[player] = wait
		if player.alive and wait <= 0.0 and blade_hits(player.position):
			_hurt_wait[player] = float(_sig().get("hit_every_s", 0.5))
			cuts += 1
			GameAuthority.damage_player(player, float(_sig().get("blade_damage", 8.0)), str(data.get("id", "")), position_now())
	var reach: float = float(_sig().get("jewel_reach_px", 14.0))
	for i: int in range(jewels.size() - 1, -1, -1):
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(jewels[i]) <= reach + player.body_radius:
				jewels.remove_at(i)
				take_jewel(player)
				break
	_jewel_in -= delta
	if _jewel_in <= 0.0:
		_jewel_in = float(_sig().get("jewel_again_s", 12.0))
		var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		while jewels.size() < int(_sig().get("jewels", 2)):
			jewels.append(centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 180.0))


## A jewel from the queen's bier: gold, and the guardians' swords.
func take_jewel(player: Player) -> void:
	jewels_taken += 1
	GameAuthority.collect_gold(player, float(_sig().get("jewel_gold", 5.0)))
	GameAuthority.damage_player(player, float(_sig().get("jewel_damage", 15.0)), str(data.get("id", "")), position_now())
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and jewels_taken == 1:
		banner.show_text(tr("BOSS_QUEENS_GUARDIANS_JEWEL"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the jewels move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in jewels.size():
		jewels[i] -= shift_px


## The four sword-blades turning round them, and the queen's jewels glittering on the ground.
func _draw() -> void:
	if is_alive():
		var me: Vector2 = position_now() - global_position
		var n: int = int(_sig().get("arms", 4))
		for k: int in n:
			var tip: Vector2 = me + Vector2.from_angle(angle + k * TAU / n) * float(_sig().get("blade_px", 110.0))
			draw_line(me, tip, Color(0.85, 0.88, 0.92, 0.85), 3.0)
			draw_line(me, tip, Color(1, 1, 1, 0.25), float(_sig().get("blade_width_px", 10.0)) * 2.0)
		for at: Vector2 in jewels:
			var p: Vector2 = at - global_position
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -5), p + Vector2(4, 0), p + Vector2(0, 5), p + Vector2(-4, 0)]), Color(0.3, 0.85, 0.6))
			draw_circle(p + Vector2(-1, -1), 1.0, Color.WHITE)
	super._draw()


## The Queen Untouched secret: beaten without anyone taking the queen's jewels.
func secret_earned() -> String:
	return "the_queen_untouched" if jewels_taken == 0 else ""
