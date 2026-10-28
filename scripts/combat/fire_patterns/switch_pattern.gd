class_name SwitchPattern
extends FirePattern
## Melee or ranged by distance (Tomoe Gozen's Sword and Bow): a sword slash
## when an enemy is within 2 tiles, arrows when they're farther.

var _sword := ArcPattern.new()
var _bow := ProjectilePattern.new(ProjectileManager.FLIGHT)


func fire(weapon: WeaponInstance, player: Player, aim: Dictionary, combat: CombatSystem) -> void:
	# Thousand-Arrow Ride (evolved): during a charge, arrows fire on every attack.
	var charging: bool = player.kit != null and player.kit.has_method("is_charging") and bool(player.kit.call("is_charging"))
	if bool(weapon.data.get("charge_arrows", false)) and charging:
		_bow.fire(weapon, player, aim, combat)
		return
	if bool(aim.get("melee", false)):
		_sword.fire(weapon, player, aim, combat)
	else:
		_bow.fire(weapon, player, aim, combat)
