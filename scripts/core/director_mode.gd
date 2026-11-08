class_name DirectorMode
extends RefCounted
## Director mode: a tool for the AI that films the game (tools/video/). A player
## cannot turn it on: it needs a debug build, not the web build, and the
## command-line argument --director=<path to a shot list .json> after "--",
## which only someone starting the game with a terminal or the recording
## container can give. It skips the menus, picks the Hero and level named in
## the shot list, then DirectorRunner runs the shot list's steps (jump around
## the map, set the time, mob density and HP, and more). Runs are marked
## debug_used, so they never reach the leaderboard.
##
## A shot list is a JSON object: {"hero": "heracles", "level": "aegean_shore",
## "seed": 1234, "god_mode": true, "steps": [{"do": "wait", "seconds": 3}, ...]}.
## For several Heroes or levels in one video, give {"chapters": [ {...}, {...} ]}
## instead: each chapter is a shot list of its own (hero, level, seed, steps) and
## the game starts a new run for the next one when a chapter's steps are done.
## COMMANDS lists every "do" and the keys it needs; the commands are described
## in tools/video/README.md.

const ARG_PREFIX := "--director="
## Optional: --director-go=<file>. The shot list waits (the game stays paused) until that file exists,
## so a recorder can start filming first.
const GO_PREFIX := "--director-go="
const COMMANDS := {
	"wait": ["seconds"],
	"set_time": ["seconds"],
	"next_age": [],
	"teleport": [],
	"density": ["mult"],
	"enemy_hp": ["mult"],
	"auto_spawn": ["on"],
	"fill": [],
	"spawn": ["type", "count"],
	"kill_all": [],
	"elite": [],
	"god_mode": ["on"],
	"heal": [],
	"player_hp": ["fraction"],
	"levels": ["count"],
	"max_build": [],
	"give_weapon": ["id"],
	"loadout": ["weapons"],
	"walk": ["seconds"],
	"autopilot": ["on"],
	"auto_pick": ["on"],
	"hud": ["on"],
	"zoom": ["value"],
	"quit": [],
}

static var _cache: Dictionary = {}
static var _loaded: bool = false
## Which chapter is being filmed (kept while the scene reloads between chapters).
static var chapter_index: int = 0
## True once the shot list has started (the go file, if any, has appeared).
static var started: bool = false


## True only in a debug, non-web build started with --director=<shot list>.
static func is_active() -> bool:
	return OS.is_debug_build() and not OS.has_feature("web") and not shot_list().is_empty()


## The validated shot list ({} when there isn't one or it has errors).
static func shot_list() -> Dictionary:
	if not _loaded:
		_loaded = true
		_cache = _load(OS.get_cmdline_user_args())
	return _cache


## The path after --director= in the arguments ("" when absent).
static func path_from_args(args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with(ARG_PREFIX):
			return arg.substr(ARG_PREFIX.length())
	return ""


## The file after --director-go= in the arguments ("" when absent).
static func go_file() -> String:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with(GO_PREFIX):
			return arg.substr(GO_PREFIX.length())
	return ""


## Checks shot list text. Returns {"list": Dictionary, "errors": PackedStringArray}.
static func parse(text: String) -> Dictionary:
	var errors := PackedStringArray()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		return {"list": {}, "errors": PackedStringArray(["The shot list must be a JSON object."])}
	var list: Dictionary = parsed
	if list.has("chapters"):
		var chapters: Variant = list["chapters"]
		if not chapters is Array or (chapters as Array).is_empty():
			errors.append("\"chapters\" must be a list with at least one chapter.")
		else:
			for i: int in (chapters as Array).size():
				var chapter: Variant = (chapters as Array)[i]
				if not chapter is Dictionary:
					errors.append("Chapter %d is not an object." % (i + 1))
				else:
					_check_steps(chapter as Dictionary, "Chapter %d: " % (i + 1), errors)
	else:
		_check_steps(list, "", errors)
	return {"list": list if errors.is_empty() else {}, "errors": errors}


## The chapters of a shot list (a list without "chapters" is one chapter).
static func chapters_of(list: Dictionary) -> Array:
	if list.has("chapters"):
		return list["chapters"]
	return [list] if not list.is_empty() else []


## The chapter being filmed now.
static func current() -> Dictionary:
	var all: Array = chapters_of(shot_list())
	return all[mini(chapter_index, all.size() - 1)] if not all.is_empty() else {}


## Moves to the next chapter. False when that was the last one.
static func advance() -> bool:
	if chapter_index + 1 >= chapters_of(shot_list()).size():
		return false
	chapter_index += 1
	return true


static func _check_steps(holder: Dictionary, prefix: String, errors: PackedStringArray) -> void:
	if not holder.get("steps", null) is Array:
		errors.append(prefix + "needs a \"steps\" array.")
		return
	var steps: Array = holder["steps"]
	for i: int in steps.size():
		if not steps[i] is Dictionary:
			errors.append("%sStep %d is not an object." % [prefix, i + 1])
			continue
		var step: Dictionary = steps[i]
		var command: String = str(step.get("do", ""))
		if not COMMANDS.has(command):
			errors.append("%sStep %d: unknown command \"%s\"." % [prefix, i + 1, command])
			continue
		for key: String in COMMANDS[command]:
			if not step.has(key):
				errors.append("%sStep %d (%s): missing \"%s\"." % [prefix, i + 1, command, key])


## Picks the Hero, level, and seed named in the shot list. Called before the menus would show.
static func prepare() -> void:
	var list: Dictionary = current()
	var hero_id: String = str(list.get("hero", ""))
	if HeroRules.find(hero_id).is_empty():
		hero_id = str(HeroRules.all()[0].get("id", ""))
	GameAuthority.selected_hero_id = hero_id
	Meta.level_id = str(list.get("level", Data.cfg_string("run.default_level")))
	GameAuthority.next_seed = int(list.get("seed", 0))


static func _load(args: PackedStringArray) -> Dictionary:
	var path: String = path_from_args(args)
	if path == "":
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Director mode: cannot open the shot list at %s" % path)
		return {}
	var result: Dictionary = parse(file.get_as_text())
	for message: String in result["errors"]:
		push_error("Director mode: " + message)
	return result["list"]
