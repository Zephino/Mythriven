class_name SimurghCall
extends Node2D
## The Simurgh (docs/PACK_3_PLAN.md: Mazandaran; GAME_DESIGN.md: Gods added with Acts II-III). Not a god and has no
## shrine. In Mazandaran, elites drop her feathers to the Hero nearest; once a Hero holds 3, the moment they fall below
## the danger line one feather burns and she comes: a full heal and a wind that clears every enemy shot. As in the
## Shahnameh, she gave Zal her feathers to burn in need, and came to heal Rudaba and Rostam.
## Config: simurgh.feathers_to_call, simurgh.call_below_hp_fraction, simurgh.flight_s.

## Feathers each Hero holds (player id -> count).
var feathers: Dictionary = {}
## Seconds left of her flight across the screen, and where she flies over.
var flight_s: float = 0.0
## Times she has come this run (Zal's Feathers secret: 3).
var calls: int = 0
var _over := Vector2.ZERO


func _ready() -> void:
	z_index = 20
	GameAuthority.elite_killed.connect(_on_elite_killed)


func count(player: Player) -> int:
	return int(feathers.get(player.player_id, 0))


func _on_elite_killed(at: Vector2, _enemy_type: Dictionary, is_copy: bool) -> void:
	if is_copy or not GameAuthority.decides():
		return
	var nearest: Player = null
	for player: Player in GameAuthority.players:
		if player.alive and (nearest == null or player.position.distance_to(at) < nearest.position.distance_to(at)):
			nearest = player
	if nearest == null:
		return
	feathers[nearest.player_id] = count(nearest) + 1
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and nearest.is_local:
		banner.show_text(tr("SIMURGH_FEATHER") % [count(nearest), Data.cfg_int("simurgh.feathers_to_call")])


func _process(delta: float) -> void:
	flight_s = maxf(flight_s - delta, 0.0)
	for player: Player in GameAuthority.players:
		if player.alive and count(player) >= Data.cfg_int("simurgh.feathers_to_call") \
				and player.hp < player.max_hp * Data.cfg_float("simurgh.call_below_hp_fraction"):
			call_her(player)
	queue_redraw()


## Burns a feather: she heals the Hero fully and her wings blow away every enemy shot.
func call_her(player: Player) -> void:
	feathers[player.player_id] = count(player) - 1
	calls += 1
	if calls >= 3 and player.is_local:
		Meta.note_secret("zals_feathers")
	GameAuthority.heal_player(player, player.max_hp)
	if GameAuthority.enemy_shots != null:
		GameAuthority.enemy_shots.clear_all()
	flight_s = Data.cfg_float("simurgh.flight_s")
	_over = player.position
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("SIMURGH_CALLED"))


## Her flight: the great bird sweeping over the Hero, wind streaming behind her.
func _draw() -> void:
	if flight_s <= 0.0:
		return
	var full: float = maxf(Data.cfg_float("simurgh.flight_s"), 0.01)
	var k: float = 1.0 - flight_s / full
	var at: Vector2 = _over + Vector2(lerpf(-260.0, 260.0, k), -70.0 + sin(k * PI) * -20.0)
	var art: Dictionary = PixelArt.find("summons/simurgh")
	for w: int in 6:
		draw_line(at + Vector2(-20 - w * 14, 6 + w * 3), at + Vector2(-60 - w * 20, 10 + w * 4), Color(0.85, 0.95, 1.0, 0.5 * (1.0 - k)), 2.0)
	if not art.is_empty():
		draw_set_transform(at, 0.0, Vector2(2.0, 2.0))
		PixelArt.draw_standing(self, art, Vector2.ZERO, false, Color.WHITE, true, k * 400.0)
		draw_set_transform(Vector2.ZERO)
	draw_circle(_over, 30.0 * (1.0 - k) + 10.0, Color(0.6, 1.0, 0.8, 0.3 * (1.0 - k)))
