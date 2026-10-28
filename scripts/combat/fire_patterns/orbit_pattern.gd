class_name OrbitPattern
extends FirePattern
## Orbiting projectiles (Glimmer): each attack sends `count` lights circling
## the player for `lifetime_s`, evenly spaced; each light hits the same enemy
## at most once per hit_interval.


func fire(weapon: WeaponInstance, player: Player, _aim: Dictionary, combat: CombatSystem) -> void:
	if combat.projectiles == null:
		return
	var settings: Dictionary = weapon.stats()
	var count: int = maxi(int(settings.get("count", 1)), 1)
	for k: int in count:
		combat.projectiles.launch_orbit(weapon, player, TAU * k / count, settings)
