class_name AuraPattern
extends FirePattern
## Aura (Shade): every attack hits all enemies within radius_px × Area around
## the player; with "lifesteal_hp", each enemy hit heals the player a little.


func fire(weapon: WeaponInstance, player: Player, _aim: Dictionary, combat: CombatSystem) -> void:
	var settings: Dictionary = weapon.stats()
	var aura_radius: float = float(settings.get("radius_px", 40.0)) * player.stats.area_mult() * float(settings.get("area", 1.0))
	var hits: int = combat.hit_circle(player.position, aura_radius, weapon, player, 1.0)
	var lifesteal: float = float(settings.get("lifesteal_hp", 0.0))
	if hits > 0 and lifesteal > 0.0:
		GameAuthority.heal_player(player, lifesteal * hits)
	combat.effects.spawn_aura(player.position, aura_radius, Elements.color(weapon.element()), weapon.data.has("evolved_from"))
