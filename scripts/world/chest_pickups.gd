class_name ChestPickups
extends Node2D
## Chests lying in the world (GAME_DESIGN.md: Elites; Chest reveal). Every
## elite drops one; bosses and points of interest drop big ones (always
## gold). Walking onto a chest opens it: its rewards are applied and the
## reveal screen plays. A small fixed pool drawn by this node.

const MAX_CHESTS := 16

var reveal: ChestScreen

var _active := PackedByteArray()
var _pos := PackedVector2Array()
var _big := PackedByteArray()


func setup() -> void:
	z_index = 0
	_active.resize(MAX_CHESTS)
	_pos.resize(MAX_CHESTS)
	_big.resize(MAX_CHESTS)


func count() -> int:
	var total: int = 0
	for i: int in MAX_CHESTS:
		total += _active[i]
	return total


## Places a chest. If every slot is full, the oldest is reused.
func drop(at: Vector2, big: bool = false) -> void:
	var slot: int = _active.find(0)
	if slot == -1:
		slot = 0
	_active[slot] = 1
	_pos[slot] = at
	_big[slot] = 1 if big else 0
	queue_redraw()


func on_elite_killed(at: Vector2, _enemy_type: Dictionary, is_copy: bool) -> void:
	if not is_copy:
		drop(at)


## Opens a chest for `player` now (also used by the debug menu).
func open_for(player: Player, big: bool = false) -> void:
	if GameAuthority.run == null:
		return
	var plan: Dictionary = ChestRules.build(player, GameAuthority.run.rng.loot, big)
	var evolved: Array[Dictionary] = ChestRules.apply(player, plan)
	if reveal != null:
		reveal.play(plan, evolved)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in MAX_CHESTS:
		_pos[i] -= shift_px
	queue_redraw()


func _process(_delta: float) -> void:
	var size: float = Data.cfg_float("chests.size_px")
	for i: int in MAX_CHESTS:
		if _active[i] == 0:
			continue
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(_pos[i]) <= size + player.body_radius:
				_active[i] = 0
				queue_redraw()
				open_for(player, _big[i] != 0)
				return


func _draw() -> void:
	var size: float = Data.cfg_float("chests.size_px")
	var body := Color.html(Data.cfg_string("chests.color"))
	var trim := Color.html(Data.cfg_string("chests.trim_color"))
	for i: int in MAX_CHESTS:
		if _active[i] == 0:
			continue
		var scale: float = 1.4 if _big[i] != 0 else 1.0
		var rect := Rect2(_pos[i] - Vector2(size, size * 0.7) * scale, Vector2(size * 2.0, size * 1.4) * scale)
		draw_rect(rect, body)
		draw_rect(rect, trim, false, 1.5)
		draw_line(Vector2(rect.position.x, _pos[i].y - size * 0.2 * scale), Vector2(rect.end.x, _pos[i].y - size * 0.2 * scale), trim, 1.5)
