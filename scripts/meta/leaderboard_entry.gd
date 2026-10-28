class_name LeaderboardEntry
extends RefCounted
## One score for the shared leaderboard (owner request, see
## leaderboard-api/README.md): the player's name, Hero, time survived, level,
## kills, weapons and upgrades (passive items) with their levels, and the game
## version. The Worker checks the same rules again (leaderboard-api/src/board.js).

const NAME_SECTION := "leaderboard"
const NAME_KEY := "name"


## Keeps letters, numbers, spaces, - and _; trims; cuts to the length limit.
static func clean_name(raw: String) -> String:
	var cleaned: String = ""
	for i: int in raw.length():
		var code: int = raw.unicode_at(i)
		var ok: bool = (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 48 and code <= 57) \
				or code == 32 or code == 45 or code == 95
		if ok and not (code == 32 and cleaned.ends_with(" ")):
			cleaned += char(code)
	cleaned = cleaned.strip_edges()
	return cleaned.substr(0, Data.cfg_int("leaderboard.max_name_length")).strip_edges()


## False when the run can't go on the board (debug options used, or too short).
static func can_submit(run: RunState) -> bool:
	return run != null and not run.debug_used and int(run.elapsed_s) >= 1


static func build(run: RunState, player: Player, player_name: String) -> Dictionary:
	var weapons: Array = []
	for weapon: WeaponInstance in player.weapons:
		weapons.append({"id": weapon.id(), "level": weapon.level})
	var passives: Array = []
	for passive_id: String in player.passives:
		passives.append({"id": passive_id, "level": int(player.passives[passive_id])})
	return {
		"name": clean_name(player_name),
		"hero": str(player.hero.get("id", "")),
		"time_s": int(run.elapsed_s),
		"level": run.level,
		"kills": run.kills,
		"weapons": weapons,
		"passives": passives,
		"version": str(ProjectSettings.get_setting("application/config/version", "")),
	}


## The name typed last time, so players don't retype it every run.
static func load_name() -> String:
	var file := ConfigFile.new()
	if file.load(Data.cfg_string("leaderboard.profile_file")) != OK:
		return ""
	return clean_name(str(file.get_value(NAME_SECTION, NAME_KEY, "")))


static func save_name(player_name: String) -> void:
	var file := ConfigFile.new()
	var path: String = Data.cfg_string("leaderboard.profile_file")
	file.load(path)
	file.set_value(NAME_SECTION, NAME_KEY, clean_name(player_name))
	file.save(path)


# --- Showing a row ------------------------------------------------------------

## "#1  Ari · Heracles · 10:00 · Lv 20 · 900 kills", then weapons and upgrades.
static func describe(rank: int, entry: Dictionary) -> String:
	var hero: Dictionary = HeroRules.find(str(entry.get("hero", "")))
	var hero_name: String = _tr(str(hero.get("name_key", ""))) if not hero.is_empty() else str(entry.get("hero", ""))
	var lines: PackedStringArray = [
		_tr("UI_LB_ROW") % [rank, str(entry.get("name", "")), hero_name, TextFormat.run_time(float(entry.get("time_s", 0))),
			int(entry.get("level", 0)), int(entry.get("kills", 0))],
		_tr("UI_LB_WEAPONS") % _items(entry.get("weapons", []), true),
		_tr("UI_LB_UPGRADES") % _items(entry.get("passives", []), false),
	]
	return "\n".join(lines)


static func _items(raw: Variant, weapons: bool) -> String:
	var parts: PackedStringArray = []
	for item: Variant in (raw if raw is Array else []):
		if not item is Dictionary:
			continue
		var id: String = str(item.get("id", ""))
		var level: int = int(item.get("level", 0))
		var key: String = ""
		if weapons:
			var weapon: Dictionary = GameAuthority.find_weapon(id)
			key = WeaponInstance.name_key_at(weapon, maxi(level, 1)) if not weapon.is_empty() else ""
		else:
			key = str(LevelUpRules.passive_data(id).get("name_key", ""))
		parts.append(_tr("UI_LB_ITEM") % [_tr(key) if key != "" else id, level])
	return ", ".join(parts) if not parts.is_empty() else _tr("UI_LB_NONE")


static func _tr(key: String) -> String:
	return TranslationServer.translate(key)
