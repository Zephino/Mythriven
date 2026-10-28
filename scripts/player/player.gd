class_name Player
extends Node2D
## One player's Hero in the world (placeholder square until Phase 9).
## Created only through GameAuthority.spawn_player, which keeps the list of
## players. Facing is the last direction the player moved in. Health changes
## only through GameAuthority, so co-op can later run them on the host.

var player_id: int = 0
var is_local: bool = true
var input: PlayerInput = null
var move_speed: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT

var max_hp: float = 0.0
var hp: float = 0.0
var armor: float = 0.0
var body_radius: float = 0.0
var alive: bool = true
## Debug-menu god mode: takes no damage.
var god_mode: bool = false
## Enemy, boss, or hazard id that dealt the final blow (for the run log).
var cause_of_death: String = ""

var _shown_hp: float = -1.0


func _ready() -> void:
	move_speed = Data.cfg_float("player.placeholder_move_speed")
	max_hp = Data.cfg_float("player.placeholder_max_hp")
	hp = max_hp
	armor = Data.cfg_float("player.placeholder_armor")
	body_radius = Data.cfg_float("player.body_radius_px")


func _process(delta: float) -> void:
	if input != null and alive:
		step(input.get_move_vector(), delta)
	elif not alive:
		velocity = Vector2.ZERO
	if hp != _shown_hp:
		_shown_hp = hp
		queue_redraw()


## Moves by one frame in `direction` (a unit vector or zero) and updates facing.
func step(direction: Vector2, delta: float) -> void:
	velocity = direction * move_speed
	position += velocity * delta
	if direction != Vector2.ZERO and direction != facing:
		facing = direction
		queue_redraw()


func _draw() -> void:
	var size_px: float = Data.cfg_float("player.placeholder_size_px")
	var color := Color.html(Data.cfg_string("player.placeholder_color"))
	if not alive:
		color = Color.html(Data.cfg_string("player.fallen_color"))
	draw_rect(Rect2(Vector2(-size_px, -size_px) * 0.5, Vector2(size_px, size_px)), color)
	# A small dot on the facing side shows which way the player last moved.
	var marker_px: float = Data.cfg_float("player.facing_marker_px")
	var marker_color := Color.html(Data.cfg_string("player.facing_marker_color"))
	draw_circle(facing * (size_px * 0.5 - marker_px * 0.5), marker_px * 0.5, marker_color)
	_draw_hp_bar()


## HP bar over the Hero (GAME_DESIGN.md: HUD).
func _draw_hp_bar() -> void:
	var width: float = Data.cfg_float("player.hp_bar_width_px")
	var height: float = Data.cfg_float("player.hp_bar_height_px")
	var top_left := Vector2(-width * 0.5, -Data.cfg_float("player.hp_bar_offset_px"))
	draw_rect(Rect2(top_left, Vector2(width, height)), Color.html(Data.cfg_string("player.hp_bar_back_color")))
	var fraction: float = clampf(hp / max_hp, 0.0, 1.0) if max_hp > 0.0 else 0.0
	draw_rect(Rect2(top_left, Vector2(width * fraction, height)), Color.html(Data.cfg_string("player.hp_bar_color")))
