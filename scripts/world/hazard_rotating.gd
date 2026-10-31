class_name HazardRotating
extends Hazard
## The "rotating" hazard (GAME_DESIGN.md: the Crossroads, "rotates every Age between all hazards"): each time the
## hazard comes, it is the next one in turn from the other levels (their "hazard" data, listed in "from_levels"), run
## by its own hazard script as a child. Data: from_levels, and the usual first_s / interval_s / duration_s.

var current: Hazard
var turn: int = 0


func begin(data: Dictionary) -> void:
	_data = data
	active = true
	var levels: Array = data.get("from_levels", [])
	if levels.is_empty():
		return
	var level: Dictionary = GameAuthority.find_level(str(levels[turn % levels.size()]))
	turn += 1
	var next: Dictionary = level.get("hazard", {})
	if next.is_empty():
		return
	if current != null:
		current.queue_free()
	current = Hazard.create(next)
	add_child(current)
	current.begin(next)


func end() -> void:
	super.end()
	if current != null:
		current.end()


func _process(_delta: float) -> void:
	if current != null:
		current.paused = paused


func on_origin_shifted(shift_px: Vector2, shift_chunks: Vector2i) -> void:
	if current != null:
		current.on_origin_shifted(shift_px, shift_chunks)
