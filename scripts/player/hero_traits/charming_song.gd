extends HeroKit
## Orpheus (docs/PACK_2_PLAN.md: the Underworld's Hero). Legend Trait, Charming Song: every every_s seconds his song
## charms the monsters round him (up to max_charmed, never bosses) for charm_s: they do no harm to Heroes and turn on
## the monsters near them, striking them for strike_mult x their own contact damage. As his song moved beasts and
## stones (Ovid, Metamorphoses 10-11). Passive, Outsinging the Sirens: +10% attack speed for him and the allies near
## him (he drowned out the Sirens' song, Apollonius, Argonautica 4).

var _song_in: float = 0.0
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
	queue_redraw()


## Charms the monsters round him (EnemyManager.charm: they fight the monsters near them).
func _sing(enemies: EnemyManager) -> void:
	var reach: float = float(trait_data().get("radius_px", 120.0)) * player.stats.area_mult()
	var count: int = 0
	for slot: int in enemies.query(player.position, reach):
		if count >= int(trait_data().get("max_charmed", 10)):
			break
		if bool(enemies.type_of(slot).get("boss", false)) or enemies.positions[slot].distance_to(player.position) > reach:
			continue
		enemies.charm(slot, float(trait_data().get("charm_s", 3.5)) * player.stats.status_duration_mult(), player)
		count += 1
	_ring_s = 0.6


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
	for i: int in enemies.capacity:
		if enemies.active[i] == 0 or enemies.charmed[i] == 0 or enemies.charmed_by[i] != player.player_id:
			continue
		var at: Vector2 = enemies.positions[i] - player.position + Vector2(0, -enemies.radius[i] - 9.0 + bob)
		draw_line(at, at + Vector2(0, -6), color, 1.5)
		draw_circle(at + Vector2(-1.5, 0), 2.0, color)
		draw_line(at + Vector2(0, -6), at + Vector2(3, -4), color, 1.5)
