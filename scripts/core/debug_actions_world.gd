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
