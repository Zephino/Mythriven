class_name FirePattern
extends RefCounted
## Base for reusable fire patterns (GAME_DESIGN.md: Weapons). A weapon's data
## names its pattern; a new weapon is mostly a data entry.


## Fires one attack. `aim` comes from Targeting.pick.
func fire(_weapon: WeaponInstance, _player: Player, _aim: Dictionary, _combat: CombatSystem) -> void:
	push_error("FirePattern.fire must be overridden")
