class_name Unraveling
extends Node2D
## The Unraveling (GAME_DESIGN.md: Run arc): it begins at 33:00, or as soon as
## the 30:00 boss falls. A ring centred where the player stood, with the world
## outside fraying into threads. The ring is a wall: players can't leave it.
## Every 30 s it closes in by a step (a short visible squeeze), with a
## countdown at the top of the screen, until it closes onto the players and
## the run ends (owner decision 10/31/2026: was a slow shrink with damage
## outside). The run ends through a visible, fair threat instead of inflated
## enemy HP. Numbers: config run_arc.unraveling_*.

var active: bool = false
var center := Vector2.ZERO
var start_radius: float = 0.0
var started_s: float = 0.0

var _tick: float = 0.0
var _label: Label


func _ready() -> void:
	CoopMirror.attach(self, "unraveling")
	z_index = 30
	var layer := CanvasLayer.new()
	layer.layer = 11
	add_child(layer)
	_label = Label.new()
	_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_label.offset_top = Data.cfg_float("ui.banner_offset_px") + Data.cfg_float("ui.banner_font_px") * 1.6
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.visible = false
	layer.add_child(_label)


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


## The ring's radius after `steps` closes: each takes a share of the starting size.
func _closed(steps: int) -> float:
	return maxf(start_radius * (1.0 - Data.cfg_float("run_arc.unraveling_step_pct") * steps), 0.0)


## The ring's radius now. Every step_s it closes by one step, squeezing in
## over step_anim_s so everyone sees it coming.
func radius() -> float:
	if not active:
		return INF
	var since: float = GameAuthority.run.elapsed_s - started_s
	var step_s: float = Data.cfg_float("run_arc.unraveling_step_s")
	var steps: int = int(since / step_s)
	if steps <= 0:
		return start_radius
	var squeeze: float = clampf((since - steps * step_s) / Data.cfg_float("run_arc.unraveling_step_anim_s"), 0.0, 1.0)
	return lerpf(_closed(steps - 1), _closed(steps), squeeze)


## Seconds until the ring next closes in.
func next_close_s() -> float:
	var step_s: float = Data.cfg_float("run_arc.unraveling_step_s")
	return step_s - fmod(GameAuthority.run.elapsed_s - started_s, step_s)


## True once the ring has closed all the way (the run is over).
func closed() -> bool:
	return active and radius() <= 0.0


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
		_label.visible = false
		return
	_hold_inside()
	if closed():
		_close_on_players()
		return
	_label.visible = true
	_label.text = tr("UNRAVELING_NEXT_CLOSE") % maxi(ceili(next_close_s()), 1)
	_tick -= delta
	if _tick <= 0.0:
		_tick = Data.cfg_float("combat.contact_damage_interval_s")
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(center) > radius():
				GameAuthority.damage_player_over_time(player, outside_dps() * Data.cfg_float("combat.contact_damage_interval_s"))
				if not player.alive:
					player.cause_of_death = "unraveling"
	queue_redraw()


## The ring is a wall: a Hero who reaches it stays on the inside (each device
## keeps its own Hero in, like a boss arena's edge).
func _hold_inside() -> void:
	var reach: float = radius()
	for player: Player in GameAuthority.players:
		if not (player.is_local or GameAuthority.decides()):
			continue
		var limit: float = maxf(reach - player.body_radius, 0.0)
		var offset: Vector2 = player.position - center
		if offset.length() > limit:
			GameAuthority.place_player(player, center + offset.limit_length(limit))


## The ring has closed onto the players: the run is over, even in the F1 god
## mode (owner request 10/31/2026).
func _close_on_players() -> void:
	_label.visible = false
	if not GameAuthority.decides():
		return
	for player: Player in GameAuthority.players:
		if player.alive:
			player.god_mode = false
			GameAuthority.damage_player_over_time(player, player.max_hp * 100.0)
			player.cause_of_death = "unraveling"
	var run: RunState = GameAuthority.run
	if run != null and not run.ended:
		run.ended = true
		GameAuthority.run_ended.emit(run)


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


# --- Co-op (CoopMirror) ------------------------------------------------------------------

func net_capture() -> Variant:
	return [active, center, start_radius, started_s]


func net_apply(state: Variant) -> void:
	active = bool(state[0])
	center = state[1]
	start_radius = float(state[2])
	started_s = float(state[3])
