extends HeroKit
## Benkei (docs/PACK_3_PLAN.md: the Land of Legends; unlocked by defeating him). Legend Trait, stands his ground: the
## more monsters round him, the harder he hits (+per_enemy_pct for each one within radius_px, up to max_enemies), as he
## held the bridge at Koromogawa alone. Passive, the seven weapons he carried: +10% Max HP. Source: the Gikeiki.

var _count: int = 0
var _count_in: float = 0.0


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	player.stats.add_bonus("max_hp", float(passive_data().get("max_hp_pct", 0.0)) / 100.0)


## How many monsters stand round him (counted a few times a second).
func surrounded() -> int:
	return _count


func _process(delta: float) -> void:
	_count_in -= delta
	if _count_in > 0.0 or player == null or GameAuthority.enemies == null:
		return
	_count_in = 0.25
	var reach: float = float(trait_data().get("radius_px", 90.0))
	var enemies: EnemyManager = GameAuthority.enemies
	var n: int = 0
	for slot: int in enemies.query(player.position, reach):
		if enemies.charmed[slot] == 0 and not bool(enemies.type_of(slot).get("animal", false)) \
				and enemies.positions[slot].distance_to(player.position) <= reach:
			n += 1
	_count = mini(n, int(trait_data().get("max_enemies", 10)))
	queue_redraw()


func damage_mult(_weapon: WeaponInstance) -> float:
	return 1.0 + _count * float(trait_data().get("per_enemy_pct", 4.0)) / 100.0


func hud_text() -> String:
	return tr("HUD_STANDS_HIS_GROUND") % roundi((damage_mult(null) - 1.0) * 100.0)


## A ring that glows brighter the more he is surrounded.
func _draw() -> void:
	if _count > 0:
		draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 24, Color(1.0, 0.8, 0.4, 0.15 + 0.06 * _count), 2.0)
