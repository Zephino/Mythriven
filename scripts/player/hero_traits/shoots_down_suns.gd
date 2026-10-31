extends HeroKit
## Hou Yi (docs/BONUS_LEVELS_PLAN.md: unlocked by defeating the Ten Suns). Legend Trait, shoots down suns: every
## every_s seconds he looses a great arrow at the strongest boss or flying monster within range (else the toughest
## monster), double damage against bosses and flyers. Passive, divine archer: +5% crit chance. Source: the Huainanzi
## (Yi shoots down nine suns and the monsters that plagued the land).

var _shot_in: float = 0.0
var _streak_from := Vector2.ZERO
var _streak_to := Vector2.ZERO
var _streak_s: float = 0.0


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	player.stats.add_bonus("crit", float(passive_data().get("crit_pct", 0.0)) / 100.0)
	_shot_in = float(trait_data().get("every_s", 6.0)) * 0.5


func hud_text() -> String:
	return tr("HUD_SHOOTS_DOWN_SUNS") % ceili(maxf(_shot_in, 0.0))


func _process(delta: float) -> void:
	_streak_s = maxf(_streak_s - delta, 0.0)
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null or player == null or GameAuthority.run == null or not player.alive:
		queue_redraw()
		return
	_shot_in -= delta
	if _shot_in <= 0.0:
		var target: int = pick(enemies)
		if target != -1:
			_shot_in = float(trait_data().get("every_s", 6.0))
			shoot(enemies, target)
	queue_redraw()


func _favoured(enemies: EnemyManager, slot: int) -> bool:
	var type: Dictionary = enemies.type_of(slot)
	return bool(type.get("boss", false)) or bool(type.get("flies", false))


## The strongest boss or flyer within range, else the toughest monster; never an animal or a charmed one. -1 if none.
func pick(enemies: EnemyManager) -> int:
	var best: int = -1
	var best_score: float = -1.0
	for slot: int in enemies.query(player.position, float(trait_data().get("range_px", 420.0))):
		if bool(enemies.type_of(slot).get("animal", false)) or enemies.charmed[slot] != 0:
			continue
		var score: float = enemies.hp[slot] + (1000000.0 if _favoured(enemies, slot) else 0.0)
		if score > best_score:
			best_score = score
			best = slot
	return best


func shoot(enemies: EnemyManager, slot: int) -> void:
	var damage: float = float(trait_data().get("damage", 60.0)) * (1.0 + player.stats.might())
	if _favoured(enemies, slot):
		damage *= float(trait_data().get("boss_flyer_mult", 2.0))
	_streak_from = player.position
	_streak_to = enemies.positions[slot]
	_streak_s = 0.3
	GameAuthority.damage_enemy(slot, damage, player, (_streak_to - _streak_from).normalized() * 80.0, "physical", 0.0)


## The great arrow's streak of light.
func _draw() -> void:
	if _streak_s <= 0.0:
		return
	var a: float = _streak_s / 0.3
	draw_line(_streak_from - player.position, _streak_to - player.position, Color(1.0, 0.85, 0.4, a), 3.0)
	draw_line(_streak_from - player.position, _streak_to - player.position, Color(1, 1, 1, a), 1.0)
