class_name RunState
extends RefCounted
## Everything about the current run (one Last Stand) that is lost when it
## ends. Owned by GameAuthority. Nothing here persists (persists: false).

var seed_value: int = 0
var level: Dictionary = {}
var rng: RunRng
## Run time in seconds. Stops while the game is paused (level-ups, menus).
var elapsed_s: float = 0.0
var kills: int = 0
var ended: bool = false


func _init(run_seed: int, level_data: Dictionary) -> void:
	seed_value = run_seed
	level = level_data
	rng = RunRng.new(run_seed)
