class_name RunDirector
extends Node
## Runs the run arc (GAME_DESIGN.md: Core loop and run arc): announces each
## new Age, sends elites at 5:00, 15:00, 25:00 and at random times after
## 5:00 (1 modifier, 2 in Deep Night), and starts the level's hazard (the
## Aegean Shore's thunderstorm) on its timer. Hazards pause while a boss
## arena is up. Bosses (Phase 13) and world events (Phase 14) hook in here.

var spawner: EnemySpawner
var hazard: HazardStrikes

var _age: String = ""
var _table: Dictionary = {}
var _elite_times: Array = []
var _next_random_elite_s: float = INF
var _hazard_next_s: float = INF
var _hazard_left_s: float = 0.0


func _ready() -> void:
	var run: RunState = GameAuthority.run
	if run == null:
		return
	_table = RunArc.wave_table(run.level_data)
	var elites: Dictionary = _table.get("elites", {})
	_elite_times = (elites.get("times_s", Data.cfg("run_arc.elite_times_s")) as Array).duplicate()
	_next_random_elite_s = float(elites.get("random_after_s", INF)) + _random_elite_gap()
	var hazard_data: Dictionary = run.level_data.get("hazard", {})
	if not hazard_data.is_empty():
		_hazard_next_s = float(hazard_data.get("first_s", hazard_data.get("interval_s", 90.0)))


func _process(delta: float) -> void:
	var run: RunState = GameAuthority.run
	if run == null or run.ended:
		return
	var age: String = RunArc.age_at(run.elapsed_s)
	if age != _age:
		_age = age
		GameAuthority.age_changed.emit(age)
	_tick_elites(run.elapsed_s)
	_tick_hazard(run, delta)


## The current Age id.
func age() -> String:
	return _age


## Sends an elite now: a type allowed in this Age, with its modifiers.
func spawn_elite() -> int:
	if spawner == null or GameAuthority.run == null:
		return -1
	var seconds: float = GameAuthority.run.elapsed_s
	var allowed: Array[String] = []
	for type_id: Variant in (_table.get("elites", {}) as Dictionary).get("types", []):
		var data: Dictionary = _enemy_data(str(type_id))
		if (data.get("ages", []) as Array).has(RunArc.age_at(seconds)) or RunArc.age_at(seconds) == RunArc.UNRAVELING:
			allowed.append(str(type_id))
	if allowed.is_empty():
		return -1
	var rng: RandomNumberGenerator = GameAuthority.run.rng.spawns
	var type_id: String = allowed[rng.randi_range(0, allowed.size() - 1)]
	return spawner.spawn_elite(type_id, EliteState.roll(RunArc.elite_modifier_count(seconds), rng))


## Starts the level's hazard now (debug menu, Divine Storm).
func start_hazard(seconds: float = -1.0) -> void:
	if hazard == null or GameAuthority.run == null:
		return
	var data: Dictionary = GameAuthority.run.level_data.get("hazard", {})
	_hazard_left_s = seconds if seconds > 0.0 else float(data.get("duration_s", 15.0))
	hazard.begin(data)


func _tick_elites(seconds: float) -> void:
	# Elites fill the gaps between bosses: none join a boss fight.
	if GameAuthority.run.boss_arena_active:
		return
	while not _elite_times.is_empty() and seconds >= float(_elite_times[0]):
		_elite_times.pop_front()
		spawn_elite()
	if seconds >= _next_random_elite_s:
		_next_random_elite_s = seconds + _random_elite_gap()
		spawn_elite()


func _tick_hazard(run: RunState, delta: float) -> void:
	if hazard == null:
		return
	var paused: bool = run.boss_arena_active
	hazard.paused = paused
	if _hazard_left_s > 0.0:
		if not paused:
			_hazard_left_s -= delta
		if _hazard_left_s <= 0.0:
			hazard.end()
		return
	if run.elapsed_s >= _hazard_next_s and not paused:
		var data: Dictionary = run.level_data.get("hazard", {})
		_hazard_next_s = run.elapsed_s + float(data.get("interval_s", 90.0))
		start_hazard()


func _random_elite_gap() -> float:
	var gaps: Array = (_table.get("elites", {}) as Dictionary).get("random_interval_s", [180, 240])
	if GameAuthority.run == null or gaps.size() < 2:
		return 200.0
	return GameAuthority.run.rng.spawns.randf_range(float(gaps[0]), float(gaps[1]))


func _enemy_data(type_id: String) -> Dictionary:
	var listed: Variant = Data.get_file(EnemyManager.ENEMIES_FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary and str(entry.get("id", "")) == type_id:
			return entry
	return {}
