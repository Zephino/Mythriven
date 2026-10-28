extends HeroKit
## Cú Chulainn. Legend Trait, Salmon Leap: every 8 s he leaps 3 tiles in his
## movement direction (straight up if standing still), untargetable for
## 0.8 s, landing with a shockwave (radius 2 tiles, knockback). A shadow shows
## where he'll land.
## Passive, Battle Frenzy: below 30% HP, +30% attack speed and +15% Area.

var _cooldown: float = 0.0
var _leap_left: float = 0.0
var _leap_from := Vector2.ZERO
var _leap_to := Vector2.ZERO
var _frenzy: bool = false


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	_cooldown = float(trait_data().get("interval_s", 8.0))
	z_index = -1


func is_leaping() -> bool:
	return _leap_left > 0.0


func controls_movement() -> bool:
	return is_leaping()


func is_untargetable() -> bool:
	return is_leaping()


func attack_speed_bonus() -> float:
	return float(passive_data().get("attack_speed_pct", 0.0)) / 100.0 if _frenzy else 0.0


func hud_text() -> String:
	if _frenzy:
		return tr("HUD_BATTLE_FRENZY")
	return tr("HUD_SALMON_LEAP") % ceili(_cooldown)


func _process(delta: float) -> void:
	if not player.alive:
		return
	_update_frenzy()
	if is_leaping():
		_leap_left -= delta
		var duration: float = float(trait_data().get("untargetable_s", 0.8))
		var t: float = clampf(1.0 - _leap_left / duration, 0.0, 1.0)
		player.position = _leap_from.lerp(_leap_to, t)
		player.velocity = Vector2.ZERO
		if _leap_left <= 0.0:
			_land()
		queue_redraw()
		return
	_cooldown -= delta
	if _cooldown <= 0.0:
		_start_leap()


func _start_leap() -> void:
	_cooldown = float(trait_data().get("interval_s", 8.0))
	_leap_left = float(trait_data().get("untargetable_s", 0.8))
	_leap_from = player.position
	var distance: float = float(trait_data().get("distance_tiles", 3)) * Data.cfg_float("world.tile_px")
	# Straight up if standing still: he lands where he started.
	var direction: Vector2 = player.velocity.normalized() if player.velocity != Vector2.ZERO else Vector2.ZERO
	_leap_to = _leap_from + direction * distance


func _land() -> void:
	queue_redraw()
	var reach: float = float(trait_data().get("landing_radius_tiles", 2)) * Data.cfg_float("world.tile_px")
	reach *= player.stats.area_mult()
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies != null:
		for slot: int in enemies.query(player.position, reach + enemies.max_radius()):
			var away: Vector2 = (enemies.positions[slot] - player.position).normalized()
			GameAuthority.damage_enemy(slot, float(trait_data().get("landing_damage", 0.0)), player,
					away * float(trait_data().get("landing_knockback", 0.0)), Elements.PHYSICAL)
	var layer: EffectLayer = effect_layer()
	if layer != null:
		layer.spawn_ring(player.position, reach, Color.html(Data.cfg_string("heroes.leap_ring_color")))


func _update_frenzy() -> void:
	var low: bool = player.hp < player.max_hp * float(passive_data().get("hp_below", 0.3))
	if low == _frenzy:
		return
	_frenzy = low
	var area: float = float(passive_data().get("area_pct", 0.0)) / 100.0
	player.stats.add_bonus("area", area if low else -area)


## The landing shadow while mid-leap.
func _draw() -> void:
	if not is_leaping():
		return
	var radius: float = Data.cfg_float("player.placeholder_size_px") * 0.6
	draw_circle(to_local(_leap_to), radius, Color.html(Data.cfg_string("heroes.leap_shadow_color")))
