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
## COMMANDS lists every "do" and the keys it needs; the commands are described
## in tools/video/README.md.

const ARG_PREFIX := "--director="
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
	"walk": ["seconds"],
	"autopilot": ["on"],
	"auto_pick": ["on"],
	"hud": ["on"],
	"zoom": ["value"],
	"quit": [],
}

static var _cache: Dictionary = {}
static var _loaded: bool = false


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


## Checks shot list text. Returns {"list": Dictionary, "errors": PackedStringArray}.
static func parse(text: String) -> Dictionary:
	var errors := PackedStringArray()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		return {"list": {}, "errors": PackedStringArray(["The shot list must be a JSON object."])}
	var list: Dictionary = parsed
	if not list.get("steps", null) is Array:
		errors.append("The shot list needs a \"steps\" array.")
	else:
		var steps: Array = list["steps"]
		for i: int in steps.size():
			if not steps[i] is Dictionary:
				errors.append("Step %d is not an object." % (i + 1))
				continue
			var step: Dictionary = steps[i]
			var command: String = str(step.get("do", ""))
			if not COMMANDS.has(command):
				errors.append("Step %d: unknown command \"%s\"." % [i + 1, command])
				continue
			for key: String in COMMANDS[command]:
				if not step.has(key):
					errors.append("Step %d (%s): missing \"%s\"." % [i + 1, command, key])
	return {"list": list if errors.is_empty() else {}, "errors": errors}


## Picks the Hero, level, and seed named in the shot list. Called before the menus would show.
static func prepare() -> void:
	var list: Dictionary = shot_list()
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
