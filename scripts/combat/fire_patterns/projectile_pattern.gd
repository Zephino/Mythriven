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
	# Runo Song: each cast uses the next element of its cycle (Fire → Ice → Lightning).
	var cycle: Array = (weapon.data.get("element_cycle", []) as Array).duplicate()
	# Väinämöinen's Divine Link: bound gods' elements join his song cycle.
	if not cycle.is_empty() and str((player.hero.get("divine_link", {}) as Dictionary).get("id", "")) == "gods_join_song":
		for element: String in player.god_elements:
			if element != "" and not cycle.has(element):
				cycle.append(element)
	# Song of Creation (evolved): casts every element of the cycle at once.
	if not cycle.is_empty() and bool(weapon.data.get("cast_all_elements", false)):
		for element: Variant in cycle:
			var each: Dictionary = settings.duplicate()
			each["element"] = str(element)
			_launch(weapon, player, direction.rotated(0.15 * (cycle.find(element) - 1)), each, combat)
		return
	if not cycle.is_empty():
		settings = settings.duplicate()
		settings["element"] = str(cycle[(weapon.attacks_made - 1) % cycle.size()])
	_launch(weapon, player, direction, settings, combat)


func _launch(weapon: WeaponInstance, player: Player, direction: Vector2, settings: Dictionary, combat: CombatSystem) -> void:
	var count: int = maxi(int(settings.get("count", 1)), 1)
	var spread: float = deg_to_rad(float(settings.get("spread_deg", 0.0)))
	var speed: float = float(settings.get("speed_px_s", 200.0)) * player.projectile_speed_mult
	var lift: float = float(settings.get("lift_px_s", 0.0))
	for k: int in count:
		var offset: float = 0.0 if count == 1 else spread * (float(k) / (count - 1) - 0.5)
		var velocity: Vector2 = direction.rotated(offset) * speed + Vector2(0.0, -lift)
		# Thrown and shot from the Hero's hand (owner request 10/31/2026).
		combat.projectiles.launch(weapon, player, player.hand_position(), velocity, flight_kind, settings)
