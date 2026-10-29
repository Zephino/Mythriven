class_name Unraveling
extends Node2D
## The Unraveling (GAME_DESIGN.md: Run arc): it begins at 33:00, or as soon as
## the 30:00 boss falls. A ring centred where the player stood shrinks by 10%
## per minute while the world outside frays into threads; outside it, players
## take damage that keeps rising. The run ends through a visible, fair threat
## instead of inflated enemy HP.

var active: bool = false
var center := Vector2.ZERO
var start_radius: float = 0.0
var started_s: float = 0.0

var _tick: float = 0.0


func _ready() -> void:
	z_index = 30


func begin() -> void:
	var player: Player = GameAuthority.local_player()
	if active or player == null or GameAuthority.run == null:
		return
	active = true
	center = player.position
	var view: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	start_radius = view.x * 0.5 * Data.cfg_float("run_arc.unraveling_start_radius_screens")
	started_s = GameAuthority.run.elapsed_s
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("UNRAVELING_BEGINS"))


## The ring's radius now: 10% smaller every minute.
func radius() -> float:
	if not active:
		return INF
	var minutes: float = (GameAuthority.run.elapsed_s - started_s) / 60.0
	return start_radius * pow(1.0 - Data.cfg_float("run_arc.unraveling_shrink_pct_per_min"), minutes)


## Damage per second outside the ring, rising with time.
func outside_dps() -> float:
	var minutes: float = (GameAuthority.run.elapsed_s - started_s) / 60.0
	return Data.cfg_float("run_arc.unraveling_dps") * (1.0 + minutes * Data.cfg_float("run_arc.unraveling_dps_growth_per_min"))


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	center -= shift_px


func _process(delta: float) -> void:
	var run: RunState = GameAuthority.run
	if run == null or run.ended:
		return
	if not active and run.arc_s() >= Data.cfg_float("run_arc.unraveling_latest_start_s"):
		begin()
	if not active:
		return
	_tick -= delta
	if _tick <= 0.0:
		_tick = Data.cfg_float("combat.contact_damage_interval_s")
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(center) > radius():
				GameAuthority.damage_player_over_time(player, outside_dps() * Data.cfg_float("combat.contact_damage_interval_s"))
				if not player.alive:
					player.cause_of_death = "unraveling"
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	var reach: float = radius()
	var fray := Color.html(Data.cfg_string("run_arc.unraveling_color"))
	draw_arc(center, reach, 0.0, TAU, 128, Color(fray, 1.0), 3.0)
	# The world outside frays: a wide dark band beyond the ring, with loose threads.
	draw_arc(center, reach + 600.0, 0.0, TAU, 128, Color(fray, 0.55), 1200.0)
	var threads: int = 48
	for k: int in threads:
		var a: float = TAU * k / threads + GameAuthority.run.elapsed_s * 0.05
		var from: Vector2 = center + Vector2.from_angle(a) * reach
		draw_line(from, from + Vector2.from_angle(a + sin(GameAuthority.run.elapsed_s + k) * 0.6) * 24.0, Color(fray, 0.9), 1.0)
