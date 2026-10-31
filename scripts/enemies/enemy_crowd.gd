class_name EnemyCrowd
extends RefCounted
## How the horde presses in (for EnemyManager): enemies push each other apart
## (bigger ones push smaller ones aside, at most `separation_max_neighbors`
## checked each), can't stand inside a player (so crowds form a ring), and
## each touching enemy damages a player once per contact interval, on its own
## timer (no invulnerability frames).


## Pushes overlapping enemies apart; bigger enemies push smaller ones aside.
## Each enemy checks at most `separation_max_neighbors` neighbours.
static func separate(m: EnemyManager) -> void:
	var max_neighbors: int = Data.cfg_int("performance.separation_max_neighbors")
	# Monsters far off screen aren't pushed apart until they come near (performance, owner request 10/31/2026).
	var heroes: PackedVector2Array = EnemyMovement.hero_positions()
	var far_sq: float = Data.cfg_float("performance.lod_far_px") ** 2
	for i: int in m.capacity:
		if m.active[i] == 0 or EnemyMovement.is_far(m.positions[i], heroes, far_sq):
			continue
		var checked: int = 0
		var mass_i: float = m.radius[i] * m.radius[i]
		for j: int in m.query(m.positions[i], m.radius[i] + m.max_radius()):
			if j == i:
				continue
			checked += 1
			if checked > max_neighbors:
				break
			var offset: Vector2 = m.positions[i] - m.positions[j]
			var min_dist: float = m.radius[i] + m.radius[j]
			var dist: float = offset.length()
			if dist >= min_dist:
				continue
			var away: Vector2 = offset / dist if dist > 0.001 else Vector2.RIGHT.rotated(float(i))
			var mass_j: float = m.radius[j] * m.radius[j]
			m.positions[i] += away * (min_dist - dist) * (mass_j / (mass_i + mass_j))
		_push_out_of_players(m, i)


## Enemies can't stand inside a player, so crowds form a ring around them.
static func _push_out_of_players(m: EnemyManager, i: int) -> void:
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		var offset: Vector2 = m.positions[i] - player.position
		var min_dist: float = m.radius[i] + player.body_radius
		var dist: float = offset.length()
		if dist < min_dist:
			var away: Vector2 = offset / dist if dist > 0.001 else Vector2.RIGHT
			m.positions[i] = player.position + away * min_dist


## Each touching enemy damages the player once per contact interval, on its own timer.
static func contact(m: EnemyManager, delta: float) -> void:
	var interval: float = Data.cfg_float("combat.contact_damage_interval_s")
	var margin: float = Data.cfg_float("enemies.contact_margin_px")
	var slack: float = Data.cfg_float("enemies.contact_query_slack_px")
	for i: int in m.capacity:
		if m.active[i] != 0 and m.contact_timer[i] > 0.0:
			m.contact_timer[i] -= delta
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		var reach: float = player.body_radius + m.max_radius() + margin
		for i: int in m.query(player.position, reach + slack):
			if m.contact_timer[i] > 0.0:
				continue
			if m.positions[i].distance_to(player.position) <= player.body_radius + m.radius[i] + margin:
				m.contact_timer[i] = interval
				var data: Dictionary = m.types[m.kind[i]]
				# Wild animals do no harm (docs/WORLD_PLAN.md: 2), nor do monsters charmed by Orpheus' song.
				if float(data["contact_damage"]) <= 0.0 or m.charmed[i] == 1:
					continue
				GameAuthority.damage_player(player, float(data["contact_damage"]) * m.damage_mult(i), str(data["id"]), m.positions[i])
				# Skadi's Blessing: enemies that touch you are Chilled.
				var touch_status: String = str(player.god_flags.get("contact_status", ""))
				if touch_status != "":
					m.statuses.apply(i, touch_status)
				GameAuthority.status_player_from_enemy(player, str(data.get("element", "")))
