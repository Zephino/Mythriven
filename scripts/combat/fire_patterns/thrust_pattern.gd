class_name ThrustPattern
extends FirePattern
## Piercing thrust along a line (the spears: Gáe Bolg, Achilles', Scáthach's, the Bronze Spear): hits every enemy in
## a strip range_px long and width_px wide toward the target. With "on_kill_barbs",
## each enemy it kills bursts into barbs that hit those nearby. A weapon with "count" above 1 thrusts that many
## spears at once: fanned spread_deg apart round the target, or evenly all round the Hero with "ring" (the Phalanx).


func fire(weapon: WeaponInstance, player: Player, aim: Dictionary, combat: CombatSystem) -> void:
	var direction: Vector2 = aim.get("direction", player.facing)
	if direction == Vector2.ZERO:
		direction = player.facing
	var count: int = maxi(1, int(weapon.stat("count", 1.0)))
	var ring: bool = bool(weapon.data.get("ring", false))
	var spread: float = deg_to_rad(weapon.stat("spread_deg", 0.0))
	for i: int in count:
		var turn: float = TAU * i / count if ring else spread * (i - (count - 1) / 2.0)
		_thrust(weapon, player, direction.rotated(turn), combat, i == 0)


func _thrust(weapon: WeaponInstance, player: Player, direction: Vector2, combat: CombatSystem, jab: bool) -> void:
	var area: float = player.stats.area_mult() * weapon.stat("area", 1.0)
	var length: float = weapon.stat("range_px") * area
	var half_width: float = weapon.stat("width_px") * area * 0.5
	var barbs: Dictionary = weapon.data.get("on_kill_barbs", {})
	var middle: Vector2 = player.position + direction * length * 0.5
	for slot: int in combat.enemies.query(middle, length * 0.5 + half_width + combat.enemies.max_radius()):
		var offset: Vector2 = combat.enemies.positions[slot] - player.position
		var along: float = offset.dot(direction)
		var across: float = absf(offset.cross(direction))
		if along < 0.0 or along > length + combat.enemies.radius[slot] or across > half_width + combat.enemies.radius[slot]:
			continue
		var at: Vector2 = combat.enemies.positions[slot]
		combat.hit_enemy(slot, weapon, player, 1.0, direction)
		# Thirty Barbs (evolved): every hit bursts into barbs, not only kills.
		var burst: bool = combat.enemies.active[slot] == 0 or bool(weapon.data.get("barbs_on_every_hit", false))
		if not barbs.is_empty() and burst:
			var barb_radius: float = float(barbs.get("radius_px", 0.0)) * area
			combat.hit_circle(at, barb_radius, weapon, player, float(barbs.get("damage_mult", 0.5)))
			combat.effects.spawn_ring(at, barb_radius, combat.effect_color(weapon))
	var spread: float = 2.0 * atan2(half_width, length)
	combat.effects.spawn_arc(player.position, direction.angle(), length, spread, combat.effect_color(weapon))
	# The spear itself jabs out from the Hero's hand (owner decision 10/31/2026: spears jab, javelins are thrown).
	var art: Dictionary = PixelArt.weapon_art(weapon) if jab else {}
	if not art.is_empty():
		combat.effects.spawn_jab(player.hand_position(), direction.angle(), length * 0.15, art, direction.x < 0.0)
		player.swinging_s = Data.cfg_float("effects.swing_s")
