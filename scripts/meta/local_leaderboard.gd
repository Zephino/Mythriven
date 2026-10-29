class_name LocalLeaderboard
extends RefCounted
## The leaderboard kept on this device (owner request, 2026-10-29): used until
## the shared online board is set up (OnlineConfig.can_post() is false). Same
## rows and order as the online board (leaderboard-api/src/board.js): longest
## time first, then level, then kills, then the earlier score. On the web the
## file lives in the browser's storage.

## Tests point this at a scratch file.
static var path_override: String = ""


static func path() -> String:
	return path_override if path_override != "" else Data.cfg_string("leaderboard.local_file")


static func load_entries() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if not FileAccess.file_exists(path()):
		return rows
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path())) != OK:
		return rows
	for row: Variant in (json.data.get("entries", []) if json.data is Dictionary else []):
		if row is Dictionary:
			rows.append(row)
	rows.sort_custom(_before)
	return rows


## Saves `entry` and returns true if it made this device's board. The same run
## sent twice (a double tap on Submit) is only kept once.
static func add(entry: Dictionary) -> bool:
	var rows: Array[Dictionary] = load_entries()
	for row: Dictionary in rows:
		if _same_run(row, entry):
			return true
	var saved: Dictionary = entry.duplicate(true)
	saved["date"] = Time.get_datetime_string_from_system(true) + "Z"
	rows.append(saved)
	rows.sort_custom(_before)
	rows.resize(mini(rows.size(), Data.cfg_int("leaderboard.local_max_entries")))
	var file := FileAccess.open(path(), FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"entries": rows}, "  "))
	return rows.has(saved)


## True when `a` ranks above `b`.
static func _before(a: Dictionary, b: Dictionary) -> bool:
	for key: String in ["time_s", "level", "kills"]:
		if int(a.get(key, 0)) != int(b.get(key, 0)):
			return int(a.get(key, 0)) > int(b.get(key, 0))
	return str(a.get("date", "")) < str(b.get("date", ""))


static func _same_run(a: Dictionary, b: Dictionary) -> bool:
	for key: String in ["name", "hero"]:
		if str(a.get(key, "")) != str(b.get(key, "")):
			return false
	# Numbers read back from the file are floats, so compare them as whole numbers.
	for key: String in ["time_s", "level", "kills"]:
		if int(a.get(key, 0)) != int(b.get(key, 0)):
			return false
	return true
