class_name StrikePattern
extends FirePattern
## Random strikes (Spark): each attack calls `count` strikes down on random
## enemies in range (or random spots when none), hitting everything inside a
## small circle.


func fire(weapon: WeaponInstance, player: Player, aim: Dictionary, combat: CombatSystem) -> void:
	var settings: Dictionary = weapon.stats()
	var area: float = player.stats.area_mult() * float(settings.get("area", 1.0))
	var strike_radius: float = float(settings.get("radius_px", 16.0)) * area
	var reach: float = float(settings.get("range_px", 200.0))
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	for k: int in maxi(int(settings.get("count", 1)), 1):
		var target: int = int(aim.get("target", -1)) if k == 0 else -1
		if target == -1:
			var nearby: PackedInt32Array = combat.enemies.query(player.position, reach)
			if not nearby.is_empty():
				target = nearby[rng.randi_range(0, nearby.size() - 1)]
		var center: Vector2 = combat.enemies.positions[target] if target != -1 else \
				player.position + Vector2.from_angle(rng.randf() * TAU) * rng.randf() * reach
		combat.hit_circle(center, strike_radius, weapon, player, 1.0)
		combat.effects.spawn_ring(center, strike_radius, combat.effect_color(weapon))
