extends HeroKit
## Orpheus (docs/PACK_2_PLAN.md: the Underworld's Hero). Legend Trait, Charming Song: every every_s seconds his song
## charms the monsters round him (up to max_charmed, never bosses) for charm_s: they do no harm to Heroes and turn on
## the monsters near them, striking them for strike_mult x their own contact damage. As his song moved beasts and
## stones (Ovid, Metamorphoses 10-11). Passive, Outsinging the Sirens: +10% attack speed for him and the allies near
## him (he drowned out the Sirens' song, Apollonius, Argonautica 4).

## Charmed enemy slot -> seconds left.
var charmed: Dictionary = {}
var _song_in: float = 0.0
var _strike_in: float = 0.0
var _ring_s: float = 0.0


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	_song_in = float(trait_data().get("every_s", 12.0)) * 0.5


func attack_speed_bonus() -> float:
	return float(passive_data().get("attack_speed_pct", 0.0)) / 100.0


func ally_attack_speed_bonus(ally: Player) -> float:
	if player == null or not player.alive or ally.position.distance_to(player.position) > float(passive_data().get("ally_radius_px", 160.0)):
		return 0.0
	return float(passive_data().get("attack_speed_pct", 0.0)) / 100.0


func hud_text() -> String:
	return tr("HUD_SONG") % ceili(maxf(_song_in, 0.0))


func _process(delta: float) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null or player == null or GameAuthority.run == null or GameAuthority.run.ended:
		return
	_ring_s = maxf(_ring_s - delta, 0.0)
	_song_in -= delta
	if _song_in <= 0.0 and player.alive:
		_song_in = float(trait_data().get("every_s", 12.0))
		_sing(enemies)
	# Charmed monsters turn on the monsters round them.
	_strike_in -= delta
	var striking: bool = _strike_in <= 0.0
	if striking:
		_strike_in = float(trait_data().get("strike_every_s", 0.5))
	for slot: Variant in charmed.keys():
		var i: int = int(slot)
		charmed[slot] = float(charmed[slot]) - delta
		if enemies.active[i] == 0 or float(charmed[slot]) <= 0.0:
			if enemies.active[i] != 0:
				enemies.charmed[i] = 0
			charmed.erase(slot)
			continue
		if striking:
			_strike(enemies, i)
	queue_redraw()


func _sing(enemies: EnemyManager) -> void:
	var reach: float = float(trait_data().get("radius_px", 120.0)) * player.stats.area_mult()
	var count: int = 0
	for slot: int in enemies.query(player.position, reach):
		if count >= int(trait_data().get("max_charmed", 10)):
			break
		if bool(enemies.type_of(slot).get("boss", false)) or enemies.positions[slot].distance_to(player.position) > reach:
			continue
		enemies.charmed[slot] = 1
		charmed[slot] = float(trait_data().get("charm_s", 3.5)) * player.stats.status_duration_mult()
		count += 1
	_ring_s = 0.6


func _strike(enemies: EnemyManager, i: int) -> void:
	var reach: float = float(trait_data().get("strike_reach_px", 40.0))
	var data: Dictionary = enemies.type_of(i)
	var damage: float = float(data.get("contact_damage", 0.0)) * float(trait_data().get("strike_mult", 2.0))
	if damage <= 0.0:
		return
	for other: int in enemies.query(enemies.positions[i], reach + enemies.max_radius()):
		if other != i and enemies.charmed[other] == 0 and enemies.positions[other].distance_to(enemies.positions[i]) <= reach:
			GameAuthority.damage_enemy(other, damage, player, Vector2.ZERO, "physical", 0.0)
			return


func _exit_tree() -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null:
		return
	for slot: Variant in charmed.keys():
		if int(slot) < enemies.charmed.size():
			enemies.charmed[int(slot)] = 0


## The song: a ring of notes spreading out as he sings, and a small note bobbing over each charmed monster.
func _draw() -> void:
	var color := Color.html(Data.cfg_string("heroes.song_color"))
	if _ring_s > 0.0:
		var k: float = 1.0 - _ring_s / 0.6
		draw_arc(Vector2.ZERO, 20.0 + k * float(trait_data().get("radius_px", 120.0)), 0.0, TAU, 40, Color(color, 1.0 - k), 2.0)
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null:
		return
	var bob: float = sin(Time.get_ticks_msec() * 0.008) * 2.0
	for slot: Variant in charmed.keys():
		var i: int = int(slot)
		if enemies.active[i] == 0:
			continue
		var at: Vector2 = enemies.positions[i] - player.position + Vector2(0, -enemies.radius[i] - 9.0 + bob)
		draw_line(at, at + Vector2(0, -6), color, 1.5)
		draw_circle(at + Vector2(-1.5, 0), 2.0, color)
		draw_line(at + Vector2(0, -6), at + Vector2(3, -4), color, 1.5)
