class_name ProjectilePattern
extends FirePattern
## Throws `count` projectiles toward the aimed direction, fanned out by
## spread_deg. "thrown_arc" lobs them upward so gravity pulls them down
## (Throwing Axe); "boomerang" sends them out and back (Bladed Discus).

var flight_kind: int = ProjectileManager.FLIGHT


func _init(kind: int) -> void:
	flight_kind = kind


func fire(weapon: WeaponInstance, player: Player, aim: Dictionary, combat: CombatSystem) -> void:
	if combat.projectiles == null:
		return
	var direction: Vector2 = aim.get("direction", player.facing)
	if direction == Vector2.ZERO:
		direction = player.facing
	var settings: Dictionary = weapon.stats()
	var count: int = maxi(int(settings.get("count", 1)), 1)
	var spread: float = deg_to_rad(float(settings.get("spread_deg", 0.0)))
	var speed: float = float(settings.get("speed_px_s", 200.0))
	var lift: float = float(settings.get("lift_px_s", 0.0))
	for k: int in count:
		var offset: float = 0.0 if count == 1 else spread * (float(k) / (count - 1) - 0.5)
		var velocity: Vector2 = direction.rotated(offset) * speed + Vector2(0.0, -lift)
		combat.projectiles.launch(weapon, player, player.position, velocity, flight_kind, settings)
