class_name SmashPattern
extends FirePattern
## Hammers smash the ground (owner rule 10/31/2026): the hammer swings down
## from overhead onto a spot in front of the Hero (range_px × Area away), and
## everything within smash_radius_px × Area of that spot is hit and knocked
## outward, with a shockwave ring. Optional "quake" data (Quake Hammer) adds a
## wider ground ring on every Nth smash.


func fire(weapon: WeaponInstance, player: Player, aim: Dictionary, combat: CombatSystem) -> void:
	var direction: Vector2 = aim.get("direction", player.facing)
	if direction == Vector2.ZERO:
		direction = player.facing
	var area: float = player.stats.area_mult() * weapon.stat("area", 1.0)
	var impact: Vector2 = player.position + direction * weapon.stat("range_px") * area
	var smash_radius: float = weapon.stat("smash_radius_px") * area
	combat.hit_circle(impact, smash_radius, weapon, player, 1.0)
	var color: Color = combat.effect_color(weapon)
	# The shockwave shows when the hammer lands, at the end of its swing down.
	var lands: float = Data.cfg_float("effects.swing_s") * 0.7
	combat.effects.spawn_ring(impact, smash_radius, color, false, lands)
	combat.effects.spawn_ring(impact, smash_radius * 0.5, color, false, lands)
	# The hammer itself comes down from overhead onto the spot.
	var art: Dictionary = PixelArt.weapon_art(weapon)
	if not art.is_empty():
		var left: bool = direction.x < 0.0
		var up: float = -PI * 0.5
		var spread: float = absf(angle_difference(up, direction.angle()))
		combat.effects.spawn_swing(player.hand_position(), (up + direction.angle()) * 0.5 if not left else
				up + angle_difference(up, direction.angle()) * 0.5, spread, art, left)
		player.swinging_s = Data.cfg_float("effects.swing_s")
	var quake: Dictionary = weapon.data.get("quake", {})
	var every: int = int(quake.get("every", 0))
	if every > 0 and weapon.attacks_made % every == 0:
		var quake_radius: float = float(quake.get("radius_px", 0.0)) * area
		combat.hit_circle(impact, quake_radius, weapon, player, float(quake.get("damage_mult", 1.0)))
		combat.effects.spawn_ring(impact, quake_radius, color, false, lands)
