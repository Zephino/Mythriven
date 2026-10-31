class_name Hazard
extends Node2D
## Base for the level hazards in the hazard library (GAME_DESIGN.md: Content
## reuse rules): each level's "hazard" data picks one by its "type" and the
## run director turns it on for a while every interval_s. Hazards pause
## during boss arenas.
##   strikes  HazardStrikes   telegraphed strikes (thunderstorm, Divine Storm)
##   weather  HazardWeather   push wind and/or shrinking vision (blizzard, sandstorm, mist)
##   lights   HazardLights    wandering lights that herd monsters onto the Heroes (the Slavic Wilds)

var active: bool = false
## True while a boss arena is up (hazards pause during boss fights).
var paused: bool = false
var _data: Dictionary = {}


## Makes the hazard for a level's "hazard" data.
static func create(data: Dictionary) -> Hazard:
	match str(data.get("type", "strikes")):
		"weather":
			return HazardWeather.new()
		"lights":
			return HazardLights.new()
	return HazardStrikes.new()


func begin(data: Dictionary) -> void:
	_data = data
	active = true
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and str(data.get("name_key", "")) != "":
		banner.show_text(tr(str(data["name_key"])))


func end() -> void:
	active = false


func on_origin_shifted(_shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	pass


# --- Co-op (CoopMirror; subclasses add their own state) ------------------------------------

func net_capture() -> Variant:
	return [active, paused, _data]


func net_apply(state: Variant) -> void:
	active = bool(state[0])
	paused = bool(state[1])
	_data = state[2]
