class_name FjalarAndGalarBoss
extends BossController
## Fjalar and Galar, 20:00 (docs/PACK_6_PLAN.md: Svartalfheim). Signature, the mead vats: three vats stand in the arena
## (Odrerir, Bodn and Son) and while any stands, the brothers heal. A Hero who stands at a vat for a moment tips it
## over. After a while they brew new ones. Source: Snorri, Skaldskaparmal 1 (the dwarves Fjalar and Galar kill Kvasir
## and brew the mead of poetry from his blood in the vats Odrerir, Bodn and Son).

## The vats still standing: {"pos": Vector2, "held": float}.
var vats: Array = []
var tipped: int = 0
var _brew_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	if vats.is_empty():
		_brew_in -= delta
		if _brew_in <= 0.0:
			brew()
		return
	var enemies: EnemyManager = GameAuthority.enemies
	enemies.hp[slot] = minf(enemies.hp[slot] + enemies.max_hp[slot] * float(_sig().get("heal_per_vat_s", 0.004)) * vats.size() * delta, enemies.max_hp[slot])
	var reach: float = float(_sig().get("vat_reach_px", 20.0))
	for i: int in range(vats.size() - 1, -1, -1):
		var on: bool = false
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(vats[i]["pos"]) <= reach + player.body_radius:
				on = true
		vats[i]["held"] = float(vats[i]["held"]) + delta if on else 0.0
		if float(vats[i]["held"]) >= float(_sig().get("tip_s", 1.0)):
			vats.remove_at(i)
			tipped += 1
	if vats.is_empty():
		_brew_in = float(_sig().get("brew_every_s", 15.0))


func brew() -> void:
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	var turn: float = GameAuthority.run.rng.combat.randf() * TAU
	for k: int in 3:
		vats.append({"pos": centre + Vector2.from_angle(turn + TAU * k / 3.0) * float(_sig().get("vat_px", 150.0)), "held": 0.0})
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_FJALAR_BREW"))


## The three vats of mead, a ring filling as a Hero tips one.
func _draw() -> void:
	for vat: Dictionary in vats:
		var at: Vector2 = Vector2(vat["pos"]) - global_position
		draw_rect(Rect2(at + Vector2(-9, -10), Vector2(18, 16)), Color(0.42, 0.28, 0.14))
		draw_rect(Rect2(at + Vector2(-8, -10), Vector2(16, 3)), Color(0.85, 0.55, 0.2))
		draw_rect(Rect2(at + Vector2(-9, -4), Vector2(18, 2)), Color(0.3, 0.3, 0.32))
		if float(vat["held"]) > 0.0:
			draw_arc(at, 20.0, -PI / 2, -PI / 2 + TAU * float(vat["held"]) / float(_sig().get("tip_s", 1.0)), 24, Color(1.0, 0.85, 0.4), 2.0)
	super._draw()

## The world re-centres under the Heroes (WorldRoot.origin_shifted): move what this boss left on the ground with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for vat: Dictionary in vats:
		vat["pos"] = Vector2(vat["pos"]) - shift_px
