class_name WallWatcherBoss
extends BossController
## The Watcher on the Wall, 10:00 (docs/PACK_13_PLAN.md: the City of Brass). Signature, the vision: every so often a
## vision beckons from far across the arena and draws the nearest Hero toward it; a Hero who reaches it "throws himself
## down" (hurt badly). Any blow on the Watcher while it beckons breaks the vision. Source: "The City of Brass", One
## Thousand and One Nights (the men who climbed the wall saw a vision beckoning and threw themselves down).

var vision := Vector2.INF
var visions_broken: int = 0
var fallen: int = 0
var _drawn: Player
var _left: float = 0.0
var _beckon_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if vision != Vector2.INF:
		visions_broken += 1
		_end()
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		_end()
		return
	if vision != Vector2.INF:
		_left -= delta
		if _drawn != null and _drawn.alive:
			if not (_drawn.kit != null and _drawn.kit.controls_movement()):
				_drawn.position = _drawn.position.move_toward(vision, float(_sig().get("pull_px_s", 70.0)) * delta)
			if _drawn.position.distance_to(vision) <= float(_sig().get("reach_px", 16.0)) + _drawn.body_radius:
				fallen += 1
				GameAuthority.damage_player(_drawn, float(_sig().get("fall_damage", 20.0)), str(data.get("id", "")), vision)
				_end()
				return
		if _left <= 0.0:
			_end()
		return
	_beckon_in -= delta
	if _beckon_in <= 0.0:
		_beckon_in = float(_sig().get("beckon_every_s", 7.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			beckon(near)


func beckon(player: Player) -> void:
	_drawn = player
	var away: Vector2 = player.position - position_now()
	if away.length() < 1.0:
		away = Vector2.RIGHT
	vision = player.position + away.normalized() * float(_sig().get("vision_px", 200.0))
	_left = float(_sig().get("beckon_s", 3.5))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and visions_broken + fallen == 0:
		banner.show_text(tr("BOSS_WALL_WATCHER_BECKONS"))


func _end() -> void:
	vision = Vector2.INF
	_drawn = null


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the vision moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if vision != Vector2.INF:
		vision -= shift_px


## The beckoning vision: a pale, shimmering figure, with a faint thread to the Hero it draws.
func _draw() -> void:
	if vision != Vector2.INF and is_alive():
		var p: Vector2 = vision - global_position
		draw_circle(p, 14.0, Color(1.0, 0.9, 0.7, 0.2))
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -14), p + Vector2(6, 8), p + Vector2(-6, 8)]), Color(1.0, 0.95, 0.85, 0.7))
		draw_circle(p + Vector2(0, -16), 3.0, Color(1.0, 0.95, 0.85, 0.8))
		if _drawn != null:
			draw_line(p, _drawn.position - global_position, Color(1.0, 0.9, 0.7, 0.3), 1.0)
	super._draw()
