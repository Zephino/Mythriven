extends HeroKit
## Gilgamesh (docs/PACK_2_PLAN.md: the Land Between the Rivers' Hero). Legend Trait, Enkidu fights beside him: his
## companion runs out to the nearest monster within reach of Gilgamesh, strikes it and everything round it with his
## axe, then comes back to his side; monsters can't harm him. Enkidu's blows grow with Gilgamesh's Might and level.
## Source: Epic of Gilgamesh, Tablets I-VI (Enkidu, made from clay, fights beside him against Humbaba and the Bull of
## Heaven). Passive, two-thirds divine: +10% Max HP and Might (Tablet I: two-thirds of him god, one-third man).
## Shared by every Hero with a companion who fights beside them (the trait's "art" names the picture): Rostam's horse
## Rakhsh, who killed the lion of the first labour and woke him against the dragon (the Shahnameh), uses it too.
## Passives here are percentages: max_hp_pct, might_pct, move_speed_pct.

const ART := "companions/enkidu"
const PASSIVE_STATS := {"max_hp_pct": "max_hp", "might_pct": "might", "move_speed_pct": "move_speed"}

## Enkidu's place in the world, and the monster he is after (-1 when none).
var enkidu_pos := Vector2.ZERO
var prey: int = -1
var _strike_in: float = 0.0
var _swing_s: float = 0.0
var _stride: float = 0.0
var _face_left: bool = false


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	var passive: Dictionary = passive_data()
	for key: String in PASSIVE_STATS:
		if passive.has(key):
			player.stats.add_bonus(PASSIVE_STATS[key], float(passive[key]) / 100.0)
	enkidu_pos = player.position + Vector2(-20, 0)


func _process(delta: float) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if player == null or GameAuthority.run == null or GameAuthority.run.ended:
		return
	var t: Dictionary = trait_data()
	var speed: float = float(t.get("speed_px_s", 125.0))
	_swing_s = maxf(_swing_s - delta, 0.0)
	_strike_in -= delta
	# Never left far behind (a long dash, a teleport): he catches up at once.
	if enkidu_pos.distance_to(player.position) > float(t.get("leash_px", 170.0)) * 2.0:
		enkidu_pos = player.position + Vector2(-20, 0)
	var goal: Vector2 = player.position + Vector2(-20 if not player.facing.x < 0.0 else 20, 4)
	if enemies != null and player.alive:
		if prey == -1 or not _good_prey(enemies, prey):
			prey = _pick(enemies)
		if prey != -1:
			goal = enemies.positions[prey]
	var step: Vector2 = (goal - enkidu_pos).limit_length(speed * delta)
	if step.length() > 0.5:
		_face_left = step.x < 0.0
	enkidu_pos += step
	_stride += step.length()
	if prey != -1 and enemies != null and enkidu_pos.distance_to(enemies.positions[prey]) <= float(t.get("strike_reach_px", 20.0)) + enemies.radius[prey] \
			and _strike_in <= 0.0:
		_strike_in = float(t.get("strike_every_s", 0.8))
		_strike(enemies)
	queue_redraw()


func _good_prey(enemies: EnemyManager, slot: int) -> bool:
	return enemies.active[slot] != 0 and not bool(enemies.type_of(slot).get("animal", false)) and enemies.charmed[slot] == 0 \
			and enemies.positions[slot].distance_to(player.position) <= float(trait_data().get("leash_px", 170.0))


## The nearest monster within reach of Gilgamesh (never an animal), or -1.
func _pick(enemies: EnemyManager) -> int:
	var reach: float = float(trait_data().get("leash_px", 170.0))
	var best: int = -1
	var best_d: float = INF
	for slot: int in enemies.query(player.position, reach):
		if not _good_prey(enemies, slot):
			continue
		var d: float = enemies.positions[slot].distance_to(enkidu_pos)
		if d < best_d:
			best_d = d
			best = slot
	return best


func strike_damage() -> float:
	return float(trait_data().get("strike_damage", 14.0)) * (1.0 + player.stats.might()) * (1.0 + 0.05 * float(GameAuthority.run.level if GameAuthority.run != null else 1))


func _strike(enemies: EnemyManager) -> void:
	_swing_s = 0.25
	var at: Vector2 = enemies.positions[prey]
	var reach: float = float(trait_data().get("strike_radius_px", 26.0)) * player.stats.area_mult()
	for slot: int in enemies.query(at, reach + enemies.max_radius()):
		if enemies.charmed[slot] == 0 and not bool(enemies.type_of(slot).get("animal", false)) \
				and enemies.positions[slot].distance_to(at) <= reach + enemies.radius[slot]:
			GameAuthority.damage_enemy(slot, strike_damage(), player, (enemies.positions[slot] - enkidu_pos).normalized() * 90.0, "physical", 0.0)


## Enkidu himself, and the sweep of his axe as he strikes.
func _draw() -> void:
	if player == null:
		return
	var at: Vector2 = enkidu_pos - player.position
	var art: Dictionary = PixelArt.find(str(trait_data().get("art", ART)))
	if not art.is_empty():
		PixelArt.draw_standing(self, art, at, _face_left, Color.WHITE, true, _stride)
	else:
		draw_circle(at, 6.0, Color("#8a6a44"))
	if _swing_s > 0.0:
		var dir: float = PI if _face_left else 0.0
		draw_arc(at + Vector2(0, -14), 16.0, dir - 1.0, dir + 1.0, 10, Color(1, 0.95, 0.8, _swing_s / 0.25), 2.0)
