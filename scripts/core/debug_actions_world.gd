extends Node
## Dev-build only: Phase 10 test options for the debug menu (Ages, elites,
## chests, evolutions, the thunderstorm). Created by RunSystems.

var systems: RunSystems


func _ready() -> void:
	DebugMenu.add_info(self, _info)
	DebugMenu.add_button(self, "DEBUG_NEXT_AGE", _next_age)
	DebugMenu.add_button(self, "DEBUG_SPAWN_ELITE", _spawn_elite)
	DebugMenu.add_button(self, "DEBUG_OPEN_CHEST", _open_chest)
	DebugMenu.add_button(self, "DEBUG_READY_EVOLUTION", _ready_evolution)
	DebugMenu.add_button(self, "DEBUG_START_STORM", _start_storm)
	DebugMenu.add_button(self, "DEBUG_GO_MOUNTAIN", _go_mountain)
	DebugMenu.add_button(self, "DEBUG_GET_ROPE", _get_rope)
	DebugMenu.add_button(self, "DEBUG_GO_GROVE", _go_grove)


func _info() -> String:
	var run: RunState = GameAuthority.run
	if run == null:
		return ""
	var elites: int = 0
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies != null:
		for i: int in enemies.capacity:
			if enemies.active[i] != 0 and enemies.is_elite(i):
				elites += 1
	return tr("DEBUG_WORLD_INFO") % [tr("AGE_" + RunArc.age_at(run.elapsed_s).to_upper() + "_NAME"),
			RunArc.hp_mult(run.elapsed_s), elites, systems.chests.count(), roundi(run.gold),
			systems.shots.count() if systems.shots != null else 0]


## Jumps the run timer to the start of the next Age.
func _next_age() -> void:
	var run: RunState = GameAuthority.run
	var starts: Dictionary = Data.cfg("run_arc.age_start_s")
	for age: String in RunArc.AGES:
		if float(starts.get(age, 0.0)) > run.elapsed_s:
			run.elapsed_s = float(starts[age])
			DebugMenu.show_result(tr("DEBUG_JUMPED_TO") % TextFormat.run_time(run.elapsed_s))
			return


func _spawn_elite() -> void:
	var slot: int = systems.director.spawn_elite()
	if slot != -1:
		var enemies: EnemyManager = GameAuthority.enemies
		DebugMenu.show_result(tr("DEBUG_ELITE_SPAWNED") % [tr(str(enemies.type_of(slot)["name_key"])),
				", ".join(enemies.elites.mods[slot])])


func _open_chest() -> void:
	var player: Player = GameAuthority.local_player()
	if player != null:
		DebugMenu.toggle()
		systems.chests.open_for(player)


## Makes the first evolvable weapon level 8 and gives its paired passive.
func _ready_evolution() -> void:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return
	for weapon: WeaponInstance in player.weapons:
		var evolution: Variant = weapon.data.get("evolution")
		if weapon.evolved or not evolution is Dictionary:
			continue
		weapon.level = weapon.max_level()
		var passive_id: String = str((evolution as Dictionary).get("passive", ""))
		if int(player.passives.get(passive_id, 0)) == 0:
			var passive: Dictionary = LevelUpRules.passive_data(passive_id)
			player.passives[passive_id] = 1
			player.stats.add_bonus(str(passive.get("stat", "")), float(passive.get("per_level", 0.0)))
			player.refresh_stats()
		DebugMenu.show_result(tr("DEBUG_EVOLUTION_READY") % tr(weapon.name_key()))
		return


func _start_storm() -> void:
	systems.director.start_hazard()


## Puts the Hero at the foot of the nearest mountain, by its handholds (World plan step 5).
func _go_mountain() -> void:
	var player: Player = GameAuthority.local_player()
	var mountains: Mountains = Mountains.current
	if player == null or mountains == null:
		return
	var here: Vector2i = mountains.tile_of(player.position)
	var best: Dictionary = {}
	for ry: int in range(-3, 4):
		for rx: int in range(-3, 4):
			var region: Vector2i = Vector2i(floori((player.position.x + mountains._offset().x) / mountains._region_px), \
					floori((player.position.y + mountains._offset().y) / mountains._region_px)) + Vector2i(rx, ry)
			var m: Dictionary = mountains.plan(region)
			if not m.is_empty() and (best.is_empty() or Vector2(m["c"]).distance_to(here) < Vector2(best["c"]).distance_to(here)):
				best = m
	if best.is_empty():
		DebugMenu.show_result(tr("DEBUG_NONE_FOUND"))
		return
	var foot: Vector2i = Vector2i(best["c"]) + Vector2i(0, int(best["r"]) + 4)
	for spot: Dictionary in best["spots"]:
		if str(spot["kind"]) == "hand" and int(spot["from"]) == 0:
			foot = Vector2i(spot["tile"]) + Vector2i(0, 3)
	GameAuthority.place_player(player, mountains.tile_center(foot))
	DebugMenu.show_result(tr("DEBUG_WENT_MOUNTAIN"))


func _get_rope() -> void:
	if GameAuthority.run != null:
		GameAuthority.run.ropes += 1
		DebugMenu.show_result(tr("UI_ROPES") % GameAuthority.run.ropes)


## Looks for thick forest round the Hero until it finds a hidden grove, and puts them by its way in.
func _go_grove() -> void:
	var player: Player = GameAuthority.local_player()
	var flora: Flora = Flora.current
	if player == null or flora == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var start: Vector2 = player.position
	for attempt: int in 120:
		if not flora.groves.is_empty():
			break
		var spot: Vector2 = start + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(800.0, 8000.0)
		if flora.density_at(spot + flora._offset()) < Data.cfg_float("world.grove_min_density"):
			continue
		player.position = spot
		flora._load_around_players()
	if flora.groves.is_empty():
		player.position = start
		DebugMenu.show_result(tr("DEBUG_NONE_FOUND"))
		return
	var grove: Dictionary = flora.groves.values()[0]
	var at: Vector2 = Vector2(grove["at"]) - flora._offset()
	var gate: Vector2 = Vector2(grove["gate"]) - flora._offset()
	GameAuthority.place_player(player, gate + (gate - at).normalized() * 50.0)
	DebugMenu.show_result(tr("DEBUG_WENT_GROVE"))
