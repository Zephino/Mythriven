class_name TyphonBoss
extends BossController
## Typhon, 30:00, father of monsters (docs/PACK_2_PLAN.md: the Underworld; GAME_DESIGN.md Act II bosses). Signature,
## the hundred heads: serpent heads strike from all round the arena edge, volleys of shots closing in from every
## side, more of them and more often each phase. From phase 2 his storms sweep everyone round the arena, the wind
## turning the other way each phase. Sources: Hesiod, Theogony 820-868; Apollodorus, Library 1.6.3.

var _volley_in: float = 2.0
## Which way the storm turns (1 or -1) and where the heads last struck from (for drawing them).
var storm_dir: float = 1.0
var heads_at := PackedVector2Array()
var heads_left: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _per_phase(key: String, fallback: float) -> float:
	var list: Array = _sig().get(key, [fallback])
	return float(list[mini(phase_index, list.size() - 1)])


func _on_phase_started(index: int) -> void:
	storm_dir = -1.0 if index % 2 == 1 else 1.0
	if index > 0:
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_TYPHON_STORM"))


func signature(delta: float) -> void:
	var bosses: BossManager = GameAuthority.bosses
	var center: Vector2 = bosses.arena_center if bosses != null else position_now()
	var radius: float = bosses.arena_radius if bosses != null and bosses.arena_radius > 0.0 else 260.0
	heads_left = maxf(heads_left - delta, 0.0)
	_volley_in -= delta
	if _volley_in <= 0.0 and target != null:
		_volley_in = _per_phase("volley_every_s", 5.0)
		_volley(center, radius)
	# The storm sweeps everyone round the arena.
	var storm: float = _per_phase("storm_px_s", 0.0)
	if storm > 0.0 and broken_s <= 0.0:
		for player: Player in GameAuthority.players:
			if player.alive:
				var out: Vector2 = player.position - center
				if out.length() > 8.0:
					GameAuthority.push_player(player, out.normalized().orthogonal() * storm * storm_dir * delta)


## Serpent heads strike from points round the arena edge, each shooting at the Hero.
func _volley(center: Vector2, radius: float) -> void:
	if GameAuthority.enemy_shots == null:
		return
	var count: int = int(_per_phase("heads_per_volley", 6.0))
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var start: float = rng.randf() * TAU
	heads_at = PackedVector2Array()
	for k: int in count:
		var from: Vector2 = center + Vector2.from_angle(start + TAU * k / count) * radius * 0.95
		heads_at.append(from)
		var aim: Vector2 = (target.position - from).normalized()
		GameAuthority.enemy_shots.fire(from, aim * float(_sig().get("shot_speed_px_s", 95.0)), 4.0,
				float(_sig().get("shot_damage", 7.0)) * _damage_mult(), "typhon", "wind", EnemyProjectiles.BOSS)
	heads_left = 1.0


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in heads_at.size():
		heads_at[i] -= shift_px


func _draw() -> void:
	super._draw()
	if heads_left <= 0.0 or not is_alive():
		return
	# Each head rears up for a moment where it struck from: a serpent's neck and head, fading.
	for from: Vector2 in heads_at:
		var at: Vector2 = from - global_position
		var c := Color(0.35, 0.55, 0.25, heads_left)
		draw_line(at + Vector2(0, 8), at, c, 4.0)
		draw_circle(at, 4.0, c)
		draw_circle(at + Vector2(1.5, -1), 1.2, Color(1.0, 0.7, 0.2, heads_left))
