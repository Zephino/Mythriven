class_name FeastMagicianBoss
extends BossController
## The Magician of the Feast, 20:00 (docs/PACK_11_PLAN.md: Dinas Emrys). Signature, the sleeping music: every so often
## he plays (a short warning first); every Hero who is not standing in one of the two tubs of cold water falls asleep for
## a moment (can't move), and he heals a little for each sleeper. Source: "Lludd and Llefelys" (the third plague: the
## mighty man of magic whose music put the court to sleep; Lludd kept awake in a vessel of cold water).

var tubs: Array[Vector2] = []
## Seconds until the music plays (INF while he is not about to play).
var playing_in: float = INF
var sleepers: int = 0
var _play_in: float = 6.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and tubs.is_empty():
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		var off: float = float(_sig().get("tub_px", 90.0))
		tubs.append(centre + Vector2(-off, 0.0))
		tubs.append(centre + Vector2(off, 0.0))


func in_tub(player: Player) -> bool:
	for at: Vector2 in tubs:
		if player.position.distance_to(at) <= float(_sig().get("tub_radius_px", 22.0)) + player.body_radius:
			return true
	return false


func signature(delta: float) -> void:
	if not is_alive():
		return
	if playing_in != INF:
		playing_in -= delta
		if playing_in <= 0.0:
			play()
		return
	_play_in -= delta
	if _play_in <= 0.0:
		_play_in = float(_sig().get("play_every_s", 12.0))
		playing_in = float(_sig().get("telegraph_s", 2.0))
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_FEAST_MAGICIAN_MUSIC"))


## The music plays: whoever isn't in the cold water falls asleep.
func play() -> void:
	playing_in = INF
	var enemies: EnemyManager = GameAuthority.enemies
	for player: Player in GameAuthority.players:
		if player.alive and not in_tub(player):
			sleepers += 1
			player.rooted_s = maxf(player.rooted_s, float(_sig().get("sleep_s", 2.5)))
			enemies.hp[slot] = minf(enemies.hp[slot] + enemies.max_hp[slot] * float(_sig().get("heal_per_sleeper", 0.03)), enemies.max_hp[slot])


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the tubs move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in tubs.size():
		tubs[i] -= shift_px


## The two tubs of cold water, and notes of music rising from him before he plays.
func _draw() -> void:
	if is_alive():
		var r: float = float(_sig().get("tub_radius_px", 22.0))
		for at: Vector2 in tubs:
			var p: Vector2 = at - global_position
			draw_circle(p, r, Color(0.45, 0.32, 0.2))
			draw_circle(p, r - 3.0, Color(0.55, 0.75, 0.9))
		if playing_in != INF:
			var me: Vector2 = position_now() - global_position
			for k: int in 3:
				var at: Vector2 = me + Vector2(-14.0 + k * 14.0, -34.0 - fmod(playing_in * 20.0 + k * 7.0, 16.0))
				draw_circle(at, 2.0, Color(1.0, 0.95, 0.6))
				draw_line(at + Vector2(2, 0), at + Vector2(2, -7), Color(1.0, 0.95, 0.6), 1.0)
	super._draw()
