extends HeroKit
## Beowulf (docs/PACK_2_PLAN.md: Jotunheim's Hero). Legend Trait, Grip: every every_s seconds he seizes a monster
## within reach (an elite first, else the toughest; never a boss) and hurls it ahead of him: it takes double the
## landing damage, and everything where it lands is hit too. As he tore off Grendel's arm bare-handed (Beowulf
## 740-836). Passive, the strength of thirty men: his hits knock monsters back 50% further (Beowulf 379-381).

var _grip_in: float = 0.0
## Where the last throw flew from and to, and how long its arc still shows.
var _arc_from := Vector2.ZERO
var _arc_to := Vector2.ZERO
var _arc_s: float = 0.0


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	_grip_in = float(trait_data().get("every_s", 9.0)) * 0.5


func knockback_mult() -> float:
	return 1.0 + float(passive_data().get("knockback_pct", 0.0)) / 100.0


func hud_text() -> String:
	return tr("HUD_GRIP") % ceili(maxf(_grip_in, 0.0))


func _process(delta: float) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null or player == null or GameAuthority.run == null or GameAuthority.run.ended or not player.alive:
		return
	_arc_s = maxf(_arc_s - delta, 0.0)
	_grip_in -= delta
	if _grip_in <= 0.0:
		var slot: int = _pick(enemies)
		if slot != -1:
			_grip_in = float(trait_data().get("every_s", 9.0))
			_throw(enemies, slot)
	queue_redraw()


## An elite within reach first, else the toughest monster within reach; never a boss. -1 if none.
func _pick(enemies: EnemyManager) -> int:
	var reach: float = float(trait_data().get("reach_px", 60.0))
	var best: int = -1
	var best_score: float = -1.0
	for slot: int in enemies.query(player.position, reach + enemies.max_radius()):
		if bool(enemies.type_of(slot).get("boss", false)) or bool(enemies.type_of(slot).get("animal", false)):
			continue
		if enemies.positions[slot].distance_to(player.position) > reach + enemies.radius[slot]:
			continue
		var score: float = enemies.hp[slot] + (100000.0 if enemies.is_elite(slot) else 0.0)
		if score > best_score:
			best_score = score
			best = slot
	return best


func _throw(enemies: EnemyManager, slot: int) -> void:
	var land: Vector2 = player.position + player.facing.normalized() * float(trait_data().get("throw_px", 150.0))
	_arc_from = enemies.positions[slot]
	_arc_to = land
	_arc_s = 0.4
	enemies.positions[slot] = land
	var damage: float = float(trait_data().get("land_damage", 40.0)) * (1.0 + player.stats.might())
	var reach: float = float(trait_data().get("land_radius_px", 40.0)) * player.stats.area_mult()
	GameAuthority.damage_enemy(slot, damage * float(trait_data().get("thrown_damage_mult", 2.0)), player, Vector2.ZERO, "physical", 0.0)
	for other: int in enemies.query(land, reach + enemies.max_radius()):
		if other != slot and enemies.positions[other].distance_to(land) <= reach:
			GameAuthority.damage_enemy(other, damage, player, (enemies.positions[other] - land).normalized() * 160.0, "physical", 0.0)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(land, reach, Color(0.85, 0.75, 0.55), true)


## The throw: a dusty arc from where he seized it to where it lands.
func _draw() -> void:
	if _arc_s <= 0.0:
		return
	var a: Vector2 = _arc_from - player.position
	var b: Vector2 = _arc_to - player.position
	var points := PackedVector2Array()
	for k: int in 9:
		var t: float = k / 8.0
		points.append(a.lerp(b, t) + Vector2(0, -sin(t * PI) * 30.0))
	draw_polyline(points, Color(0.9, 0.85, 0.7, _arc_s / 0.4), 2.0)
