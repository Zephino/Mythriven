class_name RunLog
extends RefCounted
## Writes a basic log at the end of every run (GAME_DESIGN.md: build phase 6):
## time, cause of death, and build. Used for balancing now and by the death
## recap in Phase 15. Not progression, so it isn't part of the save file.


## Returns the file path written, or "" on failure.
static func write(run: RunState, run_players: Array[Player]) -> String:
	var folder: String = Data.cfg_string("run_log.folder")
	DirAccess.make_dir_recursive_absolute(folder)
	var stamp: String = Time.get_datetime_string_from_system(false, false).replace(":", "-")
	var path: String = "%s/run_%s_%d.json" % [folder, stamp, run.seed_value]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("RunLog: can't write %s (error %d)" % [path, FileAccess.get_open_error()])
		return ""
	file.store_string(JSON.stringify(to_dictionary(run, run_players), "  "))
	file.close()
	return path


static func to_dictionary(run: RunState, run_players: Array[Player]) -> Dictionary:
	var players_out: Array = []
	for player: Player in run_players:
		var weapons: Array = []
		for weapon: WeaponInstance in player.weapons:
			weapons.append({"id": weapon.id(), "level": weapon.level})
		players_out.append({
			"player_id": player.player_id,
			"cause_of_death": player.cause_of_death,
			"weapons": weapons,
			"passives": player.passives.duplicate(),
		})
	return {
		"version": str(ProjectSettings.get_setting("application/config/version", "")),
		"date": Time.get_datetime_string_from_system(),
		"level_id": str(run.level.get("id", "")),
		"seed": run.seed_value,
		"time_s": snappedf(run.elapsed_s, 0.01),
		"kills": run.kills,
		"level_reached": run.level,
		"gold": run.gold,
		"players": players_out,
	}
