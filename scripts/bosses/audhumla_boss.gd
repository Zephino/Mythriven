class_name AudhumlaBoss
extends BossController
## Auðumbla, 10:00 (docs/PACK_11_PLAN.md: Ginnungagap). Signature, the salt licks: blocks of salty rime stand about the
## arena; she walks to the nearest and licks it, and every moment she licks heals her. A Hero who stands at a block for a
## moment breaks it; broken blocks grow again after a while. Source: Snorri, Gylfaginning 6 (the cow Auðumbla fed by
## licking the salty rime-blocks).

var blocks: Array[Vector2] = []
var broken: int = 0
## Health she has healed by licking (in hit points).
var licked: float = 0.0
var licking: bool = false
var _held: Array[float] = []
var _regrow_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and blocks.is_empty() and broken == 0:
		_grow_blocks()


func _grow_blocks() -> void:
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	var n: int = int(_sig().get("blocks", 3))
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	while blocks.size() < n:
		blocks.append(centre + Vector2.from_angle(blocks.size() * TAU / n + rng.randf() * 0.6) * float(_sig().get("block_px", 130.0)))
		_held.append(0.0)


func _nearest_block() -> int:
	var best: int = -1
	for i: int in blocks.size():
		if best == -1 or position_now().distance_to(blocks[i]) < position_now().distance_to(blocks[best]):
			best = i
	return best


## She walks to the salt rather than to the Heroes, while there is any.
func _move(delta: float) -> void:
	var b: int = _nearest_block()
	if b == -1:
		super._move(delta)
		return
	var enemies: EnemyManager = GameAuthority.enemies
	var to: Vector2 = blocks[b] - position_now()
	if to.length() > float(_sig().get("lick_px", 30.0)):
		facing = to.normalized()
		enemies.positions[slot] += to.limit_length(float(_sig().get("walk_px_s", 40.0)) * enemies.statuses.speed_mult(slot) * delta)


func signature(delta: float) -> void:
	if not is_alive():
		return
	var reach: float = float(_sig().get("reach_px", 22.0))
	for i: int in range(blocks.size() - 1, -1, -1):
		var on: bool = false
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(blocks[i]) <= reach + player.body_radius:
				on = true
		_held[i] = _held[i] + delta if on else 0.0
		if _held[i] >= float(_sig().get("break_s", 2.0)):
			blocks.remove_at(i)
			_held.remove_at(i)
			broken += 1
			_regrow_in = float(_sig().get("regrow_s", 15.0))
	if blocks.size() < int(_sig().get("blocks", 3)):
		_regrow_in -= delta
		if _regrow_in <= 0.0:
			_grow_blocks()
	var b: int = _nearest_block()
	var was: bool = licking
	licking = b != -1 and position_now().distance_to(blocks[b]) <= float(_sig().get("lick_px", 30.0)) + 1.0
	if licking:
		var enemies: EnemyManager = GameAuthority.enemies
		var heal: float = minf(enemies.max_hp[slot] * float(_sig().get("heal_per_s", 0.02)) * delta, enemies.max_hp[slot] - enemies.hp[slot])
		enemies.hp[slot] += heal
		licked += heal
		if not was and broken == 0 and licked <= heal:
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null:
				banner.show_text(tr("BOSS_AUDHUMLA_LICKS"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the blocks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in blocks.size():
		blocks[i] -= shift_px


## The salt-rime blocks: pale, glittering cubes, with a ring filling while a Hero breaks one.
func _draw() -> void:
	if is_alive():
		for i: int in blocks.size():
			var p: Vector2 = blocks[i] - global_position
			draw_rect(Rect2(p + Vector2(-10, -14), Vector2(20, 18)), Color(0.85, 0.88, 0.92))
			draw_rect(Rect2(p + Vector2(-10, -14), Vector2(20, 4)), Color(0.96, 0.97, 1.0))
			draw_rect(Rect2(p + Vector2(-10, -14), Vector2(20, 18)), Color(0.55, 0.6, 0.7), false, 1.0)
			if _held[i] > 0.0:
				draw_arc(p, 20.0, -PI / 2, -PI / 2 + TAU * _held[i] / float(_sig().get("break_s", 2.0)), 24, Color(1.0, 0.9, 0.5), 2.0)
	super._draw()


## The Hungry Cow secret: beaten while she licked back less than 5% of her health.
func secret_earned() -> String:
	var whole: float = GameAuthority.enemies.max_hp[slot] if slot != -1 and GameAuthority.enemies != null else 1.0
	return "the_hungry_cow" if licked < whole * 0.05 else ""
