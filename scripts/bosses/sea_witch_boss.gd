class_name SeaWitchBoss
extends BossController
## The Sea Witch, 30:00 (docs/PACK_13_PLAN.md: the Sea King's Hall; the design's boss, Andersen's). Signature, the
## cauldron: every so often she brews in her cauldron, healing while it bubbles; a Hero who stands at the cauldron for a
## moment spills it, and she is stunned. Every so often she takes the nearest Hero's voice (Hexed and held for a moment).
## Source: Andersen, "The Little Mermaid" (1837).

var cauldron := Vector2.INF
var brewing_s: float = 0.0
var spilled: int = 0
var voices: int = 0
## Health she has healed by brewing (in hit points).
var brewed: float = 0.0
var _brew_in: float = 6.0
var _voice_in: float = 5.0
var _held: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and cauldron == Vector2.INF:
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		cauldron = centre + Vector2(-float(_sig().get("cauldron_px", 120.0)), 0.0)


func signature(delta: float) -> void:
	if not is_alive():
		return
	if brewing_s > 0.0:
		brewing_s -= delta
		var enemies: EnemyManager = GameAuthority.enemies
		var heal: float = minf(enemies.max_hp[slot] * float(_sig().get("heal_per_s", 0.015)) * delta, enemies.max_hp[slot] - enemies.hp[slot])
		enemies.hp[slot] += heal
		brewed += heal
		var on: bool = false
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(cauldron) <= float(_sig().get("cauldron_reach_px", 20.0)) + player.body_radius:
				on = true
		_held = _held + delta if on else 0.0
		if _held >= float(_sig().get("spill_s", 1.5)):
			spill()
	else:
		_brew_in -= delta
		if _brew_in <= 0.0:
			_brew_in = float(_sig().get("brew_every_s", 14.0))
			brewing_s = float(_sig().get("brew_s", 6.0))
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null and spilled == 0:
				banner.show_text(tr("BOSS_SEA_WITCH_BREWS"))
	_voice_in -= delta
	if _voice_in <= 0.0:
		_voice_in = float(_sig().get("voice_every_s", 10.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			take_voice(near)


## The cauldron goes over: the brew is lost and she is stunned.
func spill() -> void:
	spilled += 1
	brewing_s = 0.0
	_held = 0.0
	GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], float(_sig().get("spilled_stun_s", 3.0)))
	cast = {}
	if patterns != null:
		patterns.clear()


## She takes a Hero's voice in payment.
func take_voice(player: Player) -> void:
	voices += 1
	player.statuses.apply("hex")
	player.rooted_s = maxf(player.rooted_s, float(_sig().get("voice_hold_s", 1.0)))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and voices == 1:
		banner.show_text(tr("BOSS_SEA_WITCH_VOICE"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the cauldron moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if cauldron != Vector2.INF:
		cauldron -= shift_px


## Her black cauldron, bubbling green while she brews, with a ring filling while a Hero tips it over.
func _draw() -> void:
	if cauldron != Vector2.INF and is_alive():
		var p: Vector2 = cauldron - global_position
		draw_circle(p, 12.0, Color(0.12, 0.12, 0.14))
		draw_rect(Rect2(p + Vector2(-13, -6), Vector2(26, 3)), Color(0.22, 0.22, 0.26))
		if brewing_s > 0.0:
			draw_circle(p + Vector2(0, -6), 8.0, Color(0.35, 0.75, 0.4))
			for k: int in 3:
				draw_circle(p + Vector2(-5 + k * 5, -10 - fmod(brewing_s * 12.0 + k * 4.0, 10.0)), 2.0, Color(0.6, 0.95, 0.6, 0.8))
		if _held > 0.0:
			draw_arc(p, 20.0, -PI / 2, -PI / 2 + TAU * _held / float(_sig().get("spill_s", 1.5)), 24, Color(1.0, 0.9, 0.5), 2.0)
	super._draw()
