class_name ArcPattern
extends FirePattern
## Melee arc: hits every enemy inside a pie slice in front of the player
## (range_px × Area, arc_deg wide), toward the aimed direction. Optional
## "quake" data adds a ground ring on every Nth attack (Heracles' Great Club).


func fire(weapon: WeaponInstance, player: Player, aim: Dictionary, combat: CombatSystem) -> void:
	var direction: Vector2 = aim.get("direction", player.facing)
	if direction == Vector2.ZERO:
		direction = player.facing
	var area: float = player.stats.area_mult() * weapon.stat("area", 1.0)
	var reach: float = weapon.stat("range_px") * area
	var spread: float = deg_to_rad(weapon.stat("arc_deg"))
	combat.hit_sector(player.position, direction, reach, spread, weapon, player, 1.0)
	combat.effects.spawn_arc(player.position, direction.angle(), reach, spread, combat.effect_color(weapon))
	var quake: Dictionary = weapon.data.get("quake", {})
	var every: int = int(quake.get("every", 0))
	if every > 0 and weapon.attacks_made % every == 0:
		var center: Vector2 = player.position + direction * reach * 0.5
		var quake_radius: float = float(quake.get("radius_px", 0.0)) * area
		combat.hit_circle(center, quake_radius, weapon, player, float(quake.get("damage_mult", 1.0)))
		combat.effects.spawn_ring(center, quake_radius, combat.effect_color(weapon))
