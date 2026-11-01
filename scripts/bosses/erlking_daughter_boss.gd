class_name ErlkingDaughterBoss
extends BossController
## The Erlking's Daughter, 10:00 (docs/PACK_7_PLAN.md: Alfheim). Signature, the dance: every so often a dance ring
## appears round a Hero. Stay inside it until the dance ends; step out and her elf-shot strikes you (damage and Shock),
## as she struck Sir Oluf when he would not dance. Sources: J. G. Herder, "Erlkonigs Tochter" (1778, from the Danish
## ballad); the Old English charm "Wid faerstice" (elf-shot).

## The ring: where, whose, and how long the dance has left (dance_left > 0 while it lasts).
var ring := Vector2.INF
var dancer: Player
var dance_left: float = 0.0
var danced: int = 0
var struck: int = 0
var _dance_in: float = 5.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	if dance_left > 0.0:
		if dancer == null or not is_instance_valid(dancer) or not dancer.alive:
			dance_left = 0.0
			return
		if dancer.position.distance_to(ring) > float(_sig().get("ring_radius_px", 50.0)):
			strike(dancer)
			return
		dance_left -= delta
		if dance_left <= 0.0:
			danced += 1
			ring = Vector2.INF
		return
	_dance_in -= delta
	if _dance_in <= 0.0:
		_dance_in = float(_sig().get("dance_every_s", 9.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			invite(near)


func invite(player: Player) -> void:
	dancer = player
	ring = player.position
	dance_left = float(_sig().get("dance_s", 3.0))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and danced + struck == 0:
		banner.show_text(tr("BOSS_ERLKING_DAUGHTER_DANCE"))


## The dancer stepped out: elf-shot.
func strike(player: Player) -> void:
	struck += 1
	dance_left = 0.0
	ring = Vector2.INF
	GameAuthority.damage_player(player, float(_sig().get("shot_damage", 18.0)), str(data.get("id", "")), position_now())
	player.statuses.apply("shock")
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_bolt(player.position, Color(1.0, 0.92, 0.6), true, true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the ring moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if ring != Vector2.INF:
		ring -= shift_px


## The dance ring, shrinking as the dance nears its end.
func _draw() -> void:
	if dance_left > 0.0 and ring != Vector2.INF and is_alive():
		var at: Vector2 = ring - global_position
		var reach: float = float(_sig().get("ring_radius_px", 50.0))
		draw_arc(at, reach, 0.0, TAU, 40, Color(1.0, 0.92, 0.6, 0.8), 2.0)
		draw_arc(at, reach * dance_left / float(_sig().get("dance_s", 3.0)), 0.0, TAU, 32, Color(1.0, 0.92, 0.6, 0.35), 1.0)
		for k: int in 8:
			var spot: Vector2 = at + Vector2.from_angle(TAU * k / 8.0 + Time.get_ticks_msec() * 0.002) * reach
			draw_circle(spot, 2.0, Color(0.95, 1.0, 0.85, 0.8))
	super._draw()


## The Full Dance secret: three dances danced to the end, and never stepped out of one.
func secret_earned() -> String:
	return "the_full_dance" if danced >= 3 and struck == 0 else ""
