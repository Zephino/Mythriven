class_name GodTrial
extends Node2D
## God trials at shrines (GAME_DESIGN.md: Shrine types). A glowing ring forms
## around the shrine:
##   Duel       the god fights as a mini-boss with 2 attack patterns, scaled to
##              the run time; regular spawns drop to 30%. Leaving the ring or
##              taking more than 60 s fails.
##   Endurance  survive 40 s inside the ring while the god unleashes hazards;
##              the god can't be damaged. Leaving the ring fails.
##   Chase      the god flees around the ring; touch them 3 times within 40 s
##              while they leave decoys.
## Winning binds the god; failing makes the shrine vanish. Attacks come from
## the shared pattern library (pattern_runner.gd).

signal finished(won: bool, god_id: String)

var shrines: Shrines
var patterns: PatternRunner
var spawner: EnemySpawner

var active: bool = false
var shrine: Dictionary = {}
var kind: String = ""
var center := Vector2.ZERO
var ring_radius: float = 0.0
var time_left: float = 0.0
var touches: int = 0

var _player: Player
var _avatar_slot: int = -1
var _god_pos := Vector2.ZERO
var _god_vel := Vector2.ZERO
var _decoys: Array[Dictionary] = []
var _decoy_timer: float = 0.0
var _pattern_timer: float = 0.0
var _pattern_index: int = 0
var _label: Label


func _ready() -> void:
	z_index = 2
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


## Starts the trial of `trial_shrine`'s god for `player`.
func begin(trial_shrine: Dictionary, player: Player) -> void:
	shrine = trial_shrine
	_player = player
	kind = str((shrine["god"].get("shrine", {}) as Dictionary).get("type", ""))
	center = shrine["pos"]
	var view: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	ring_radius = minf(view.x, view.y) * 0.5 * Data.cfg_float("gods.trial_ring_radius_screens")
	touches = 0
	_pattern_timer = Data.cfg_float("gods.trial_first_attack_s")
	_pattern_index = 0
	_decoys.clear()
	active = true
	match kind:
		"trial_duel":
			time_left = Data.cfg_float("gods.duel_time_limit_s")
			_avatar_slot = GameAuthority.spawn_enemy(Data.cfg_string("gods.duel_avatar_enemy"), center)
			if _avatar_slot != -1:
				GameAuthority.enemies.tint_override[_avatar_slot] = Color.html(str(shrine["god"].get("placeholder_color", "#ffffff")))
			if spawner != null:
				spawner.rate_mult = Data.cfg_float("gods.duel_spawn_rate")
		"trial_endurance":
			time_left = Data.cfg_float("gods.endurance_s")
		"trial_chase":
			time_left = Data.cfg_float("gods.chase_s")
			_god_pos = center
			_god_vel = Vector2.ZERO
			_decoy_timer = Data.cfg_float("gods.chase_decoy_every_s")
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("TRIAL_" + kind.to_upper() + "_BANNER") % tr(str(shrine["god"].get("name_key", ""))))


func _process(delta: float) -> void:
	if not active:
		return
	if _player == null or not is_instance_valid(_player) or not _player.alive:
		_end(false)
		return
	if GameAuthority.run != null and GameAuthority.run.boss_arena_active:
		_call_off()
		return
	time_left -= delta
	var inside: bool = _player.position.distance_to(center) <= ring_radius
	match kind:
		"trial_duel":
			var enemies: EnemyManager = GameAuthority.enemies
			if _avatar_slot == -1 or enemies.active[_avatar_slot] == 0:
				_end(true)
				return
			_attack(enemies.positions[_avatar_slot], delta)
			if not inside or time_left <= 0.0:
				_end(false)
				return
		"trial_endurance":
			_attack(center, delta)
			if not inside:
				_end(false)
				return
			if time_left <= 0.0:
				_end(true)
				return
		"trial_chase":
			_chase(delta)
			if touches >= Data.cfg_int("gods.chase_touches"):
				_end(true)
				return
			if time_left <= 0.0:
				_end(false)
				return
	_label.visible = true
	if kind == "trial_chase":
		_label.text = tr("TRIAL_STATUS_CHASE") % [maxi(ceili(time_left), 0), touches, Data.cfg_int("gods.chase_touches")]
	else:
		_label.text = tr("TRIAL_STATUS_TIME") % maxi(ceili(time_left), 0)
	queue_redraw()


func _attack(origin: Vector2, delta: float) -> void:
	_pattern_timer -= delta
	if _pattern_timer > 0.0 or patterns == null:
		return
	_pattern_timer = Data.cfg_float("gods.trial_attack_every_s")
	var list: Array = (shrine["god"].get("shrine", {}) as Dictionary).get("patterns", ["radial_burst"])
	var pattern_id: String = str(list[_pattern_index % list.size()])
	_pattern_index += 1
	var scale: float = RunArc.hp_mult(GameAuthority.run.arc_s())
	patterns.run({"pattern": pattern_id}, origin, _player.position, str(shrine["god"].get("element", "")), "god_" + str(shrine["god_id"]),
			scale * Data.cfg_float("gods.trial_damage_mult"))


## The god flees from the player around the ring, leaving decoys.
func _chase(delta: float) -> void:
	var speed: float = _player.move_speed * Data.cfg_float("gods.chase_speed_mult")
	var away: Vector2 = (_god_pos - _player.position).normalized()
	var wander := Vector2.from_angle(GameAuthority.run.elapsed_s * 1.7).rotated(float(touches))
	_god_vel = (away + wander * 0.6).normalized() * speed
	_god_pos += _god_vel * delta
	if _god_pos.distance_to(center) > ring_radius * 0.9:
		_god_pos = center + (_god_pos - center).normalized() * ring_radius * 0.9
	var reach: float = Data.cfg_float("gods.chase_touch_px") + _player.body_radius
	if _player.position.distance_to(_god_pos) <= reach:
		touches += 1
		var rng: RandomNumberGenerator = GameAuthority.run.rng.world
		_god_pos = center + Vector2.from_angle(rng.randf() * TAU) * ring_radius * rng.randf_range(0.4, 0.8)
	_decoy_timer -= delta
	if _decoy_timer <= 0.0 and _decoys.size() < Data.cfg_int("gods.chase_max_decoys"):
		_decoy_timer = Data.cfg_float("gods.chase_decoy_every_s")
		_decoys.append({"pos": _god_pos, "dir": Vector2.from_angle(GameAuthority.run.rng.world.randf() * TAU)})
	for decoy: Dictionary in _decoys.duplicate():
		decoy["pos"] = Vector2(decoy["pos"]) + Vector2(decoy["dir"]) * speed * 0.8 * delta
		if Vector2(decoy["pos"]).distance_to(center) > ring_radius * 0.9:
			decoy["dir"] = -Vector2(decoy["dir"])
		if _player.position.distance_to(decoy["pos"]) <= reach:
			_decoys.erase(decoy)


func _end(won: bool) -> void:
	_stop()
	var god_id: String = str(shrine.get("god_id", ""))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("TRIAL_WON" if won else "TRIAL_FAILED"))
	if won and shrines != null and is_instance_valid(_player):
		shrines.offer_binding(shrine, _player)
	elif shrines != null:
		shrines.shrines.erase(shrine)
	finished.emit(won, god_id)
	queue_redraw()


## A boss arrived: the trial stops without failing and the shrine stays, so
## it can be tried again after the fight (fairness rules: bosses are duels).
func _call_off() -> void:
	_stop()
	queue_redraw()


func _stop() -> void:
	active = false
	_label.visible = false
	# The boss arena sets its own spawn rate; leave it alone during a fight.
	if spawner != null and not (GameAuthority.run != null and GameAuthority.run.boss_arena_active):
		spawner.rate_mult = 1.0
	if kind == "trial_duel" and _avatar_slot != -1 and GameAuthority.enemies.active[_avatar_slot] != 0:
		GameAuthority.enemies.remove_quietly(_avatar_slot)
	_avatar_slot = -1
	_decoys.clear()


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	center -= shift_px
	_god_pos -= shift_px
	for decoy: Dictionary in _decoys:
		decoy["pos"] = Vector2(decoy["pos"]) - shift_px


func _draw() -> void:
	if not active:
		return
	var color := Color.html(str(shrine["god"].get("placeholder_color", "#ffffff")))
	draw_arc(center, ring_radius, 0.0, TAU, 64, color, 3.0)
	if kind == "trial_endurance":
		draw_circle(center, 9.0, color)
	elif kind == "trial_chase":
		draw_circle(_god_pos, 7.0, color)
		for decoy: Dictionary in _decoys:
			draw_circle(decoy["pos"], 7.0, color)
