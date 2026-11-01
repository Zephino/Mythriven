class_name ObrazileNecromancerBoss
extends BossController
## The Necromancer of O'Brazile, 20:00 (docs/PACK_12_PLAN.md: Hy-Brasil). Signature, the spell: his spell holds the
## island, and while it holds he takes only a quarter of the damage. Three piles of driftwood lie on the shore: a Hero who
## stands at one for a moment lights it, and each fire burning weakens the spell; with all three burning at once it breaks
## (his guard breaks). The fires burn out after a while. Source: "O-Brazile, or the Inchanted Island" (1675: the sailors'
## fire on the shore broke the necromancer's spell).

## The driftwood piles: {"pos", "burn"} (seconds of fire left; 0 = unlit).
var piles: Array = []
var lit: int = 0
var spells_broken: int = 0
var _held: Array[float] = [0.0, 0.0, 0.0]
var _all_burning: bool = false


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0 and piles.is_empty():
		var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
		var n: int = int(_sig().get("piles", 3))
		for k: int in n:
			piles.append({"pos": centre + Vector2.from_angle(k * TAU / n - PI / 2) * float(_sig().get("pile_px", 120.0)), "burn": 0.0})
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_OBRAZILE_NECROMANCER_SPELL"))


func burning() -> int:
	var n: int = 0
	for p: Dictionary in piles:
		if float(p["burn"]) > 0.0:
			n += 1
	return n


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	var base: float = float(_sig().get("spell_damage_taken", 0.25))
	return amount * minf(base + (1.0 - base) * burning() / maxf(piles.size(), 1.0), 1.0)


func signature(delta: float) -> void:
	if not is_alive():
		return
	var reach: float = float(_sig().get("reach_px", 18.0))
	for i: int in piles.size():
		if float(piles[i]["burn"]) > 0.0:
			piles[i]["burn"] = maxf(float(piles[i]["burn"]) - delta, 0.0)
			_held[i] = 0.0
			continue
		var on: bool = false
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(piles[i]["pos"]) <= reach + player.body_radius:
				on = true
		_held[i] = _held[i] + delta if on else 0.0
		if _held[i] >= float(_sig().get("light_s", 1.5)):
			light(i)
	var all: bool = burning() == piles.size() and not piles.is_empty()
	if all and not _all_burning:
		spells_broken += 1
		guard_break()
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_OBRAZILE_NECROMANCER_BROKEN"))
	_all_burning = all


func light(i: int) -> void:
	lit += 1
	_held[i] = 0.0
	piles[i]["burn"] = float(_sig().get("burn_s", 12.0))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the piles move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for p: Dictionary in piles:
		p["pos"] = Vector2(p["pos"]) - shift_px


## The driftwood piles: grey wood, burning or not, with a ring filling while a Hero lights one.
func _draw() -> void:
	if is_alive():
		for i: int in piles.size():
			var at: Vector2 = Vector2(piles[i]["pos"]) - global_position
			draw_line(at + Vector2(-9, 4), at + Vector2(9, -2), Color(0.55, 0.5, 0.42), 3.0)
			draw_line(at + Vector2(-8, -2), at + Vector2(8, 5), Color(0.5, 0.45, 0.38), 3.0)
			if float(piles[i]["burn"]) > 0.0:
				draw_colored_polygon(PackedVector2Array([at + Vector2(-7, 2), at + Vector2(0, -16), at + Vector2(7, 2)]), Color(0.95, 0.5, 0.15))
				draw_colored_polygon(PackedVector2Array([at + Vector2(-3, 1), at + Vector2(0, -9), at + Vector2(3, 1)]), Color(1.0, 0.88, 0.45))
			if _held[i] > 0.0:
				draw_arc(at, 18.0, -PI / 2, -PI / 2 + TAU * _held[i] / float(_sig().get("light_s", 1.5)), 24, Color(1.0, 0.8, 0.4), 2.0)
	super._draw()


## The Spell Broken secret: his spell broken twice, then beaten.
func secret_earned() -> String:
	return "the_spell_broken" if spells_broken >= 2 else ""
