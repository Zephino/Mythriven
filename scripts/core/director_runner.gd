class_name DirectorRunner
extends Node
## Runs a shot list (DirectorMode) one step at a time while the game plays:
## each step is done, then the runner waits for the step's "seconds" (only the
## "wait", "walk" and "quit" commands take time). When a chapter's steps are done
## (or the Hero dies) it starts the next chapter's run, or quits after the last.
## The commands themselves live
## in DirectorCommands. Added by main.gd only when DirectorMode.is_active().

var _steps: Array = []
var _index: int = 0
var _wait_left: float = 0.0
var _commands: DirectorCommands
var _ended_s: float = -1.0
var _quit_all: bool = false


func _ready() -> void:
	var list: Dictionary = DirectorMode.current()
	_steps = list.get("steps", [])
	_commands = DirectorCommands.new()
	_commands.setup(self)
	add_child(_commands)
	if bool(list.get("god_mode", true)):
		_commands.run({"do": "god_mode", "on": true})
	if GameAuthority.run != null:
		GameAuthority.run.debug_used = true
	GameAuthority.run_ended.connect(_on_run_ended)
	print("Director mode: %d steps" % _steps.size())


func _process(delta: float) -> void:
	if _ended_s >= 0.0:
		_ended_s -= delta
		if _ended_s <= 0.0:
			if not _quit_all and DirectorMode.advance():
				get_tree().paused = false
				get_tree().reload_current_scene()
			else:
				get_tree().quit()
		return
	if _wait_left > 0.0:
		_wait_left -= delta
		return
	if _index >= _steps.size():
		_finish()
		return
	var step: Dictionary = _steps[_index]
	_index += 1
	print("Director mode: step %d/%d %s" % [_index, _steps.size(), JSON.stringify(step)])
	_wait_left = _commands.run(step)
	if str(step.get("do", "")) == "quit":
		_quit_all = true
		_finish()


## The Hero died (not expected with god mode on): stop after a moment.
func _on_run_ended(_run: RunState) -> void:
	_finish()


func _finish() -> void:
	if _ended_s < 0.0:
		_ended_s = Data.cfg_float("director.end_delay_s")
