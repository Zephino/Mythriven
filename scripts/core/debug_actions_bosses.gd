extends Node
## Dev-build only: Phase 13 test options for the debug menu (bosses, Guard
## Breaks, Boons, the Unraveling). Created by RunSystems.

var systems: RunSystems


func _ready() -> void:
	DebugMenu.add_info(self, _info)
	DebugMenu.add_button(self, "DEBUG_SPAWN_MEDUSA", _spawn.bind("medusa", 0))
	DebugMenu.add_button(self, "DEBUG_SPAWN_ACHILLES", _spawn.bind("achilles", 1))
	DebugMenu.add_button(self, "DEBUG_SPAWN_KRONOS", _spawn.bind("kronos", 2))
	DebugMenu.add_button(self, "DEBUG_BREAK_GUARD", _break_guard)
	DebugMenu.add_button(self, "DEBUG_HURT_BOSS", _hurt_boss)
	DebugMenu.add_button(self, "DEBUG_START_UNRAVELING", _start_unraveling)


func _info() -> String:
	var parts := PackedStringArray()
	for boss: BossController in systems.bosses.controllers:
		if boss.is_alive():
			parts.append("%s %d%% (phase %d)" % [tr(str(boss.data.get("name_key", ""))), roundi(boss.hp_fraction() * 100.0), boss.phase_index + 1])
	return tr("DEBUG_BOSS_INFO") % [", ".join(parts) if not parts.is_empty() else "-",
			tr("DEBUG_ON") if systems.unraveling.active else tr("DEBUG_OFF")]


func _spawn(boss_id: String, index: int) -> void:
	systems.bosses.spawn_boss(boss_id, index)


func _break_guard() -> void:
	for boss: BossController in systems.bosses.controllers:
		if boss.is_alive():
			boss.guard_break()


## Takes a boss down to the next phase (or defeats it in its last).
func _hurt_boss() -> void:
	for boss: BossController in systems.bosses.controllers:
		if not boss.is_alive():
			continue
		var enemies: EnemyManager = GameAuthority.enemies
		var phases: Array = boss.data.get("phases", [])
		var next_above: float = float((phases[boss.phase_index] as Dictionary).get("hp_above", 0.0))
		enemies.hp[boss.slot] = enemies.max_hp[boss.slot] * next_above - 1.0
		if enemies.hp[boss.slot] <= 0.0:
			GameAuthority.kill_enemy(boss.slot, GameAuthority.local_player())
		return


func _start_unraveling() -> void:
	systems.unraveling.begin()
