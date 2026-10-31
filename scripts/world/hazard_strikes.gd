class_name HazardStrikes
extends Hazard
## The "strikes" hazard from the hazard library (GAME_DESIGN.md: Content reuse
## rules): the Aegean Shore's thunderstorm, and later the Divine Storm event.
## While active, telegraphed strikes land at random spots near the players:
## an orange ground marker grows for telegraph_s, then the strike hurts every
## player and enemy inside it. Settings come from the level's "hazard" data.
## Markers are a small fixed pool. Data: strikes_per_s, radius_px,
## telegraph_s, damage, element, range_px, color, look ("" = bolts from the sky; "chasm" = the Underworld's
## collapsing chasms: cracks glow and spread, then the ground drops away into a dark pit that closes again).

const MAX_MARKERS := 16
## How long a chasm stays open after it collapses (look "chasm").
const CHASM_OPEN_S := 1.2

var _strike_budget: float = 0.0
var _marker_pos := PackedVector2Array()
var _marker_left := PackedFloat32Array()
## Chasms that just opened (look "chasm"): where, and how long until they close.
var _hole_pos := PackedVector2Array()
var _hole_left := PackedFloat32Array()


func _ready() -> void:
	z_index = 4
	_marker_pos.resize(MAX_MARKERS)
	_marker_left.resize(MAX_MARKERS)
	for i: int in MAX_MARKERS:
		_marker_left[i] = -1.0
	# The level's hazard and the Divine Storm event each have their own (RunSystems names them).
	CoopMirror.attach(self, "strikes_" + name)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in MAX_MARKERS:
		_marker_pos[i] -= shift_px


func _process(delta: float) -> void:
	var any_marker: bool = false
	if _look() == "bramble" or _look() == "flood":
		_slow_in_patches()
	for h: int in range(_hole_left.size() - 1, -1, -1):
		_hole_left[h] -= delta
		any_marker = true
		if _hole_left[h] <= 0.0:
			_hole_left.remove_at(h)
			_hole_pos.remove_at(h)
	for i: int in MAX_MARKERS:
		if _marker_left[i] < 0.0:
			continue
		any_marker = true
		_marker_left[i] -= delta
		if _marker_left[i] <= 0.0:
			_marker_left[i] = -1.0
			_strike(_marker_pos[i])
	if active and not paused and GameAuthority.run != null:
		_strike_budget += float(_data.get("strikes_per_s", 1.0)) * delta
		while _strike_budget >= 1.0:
			_strike_budget -= 1.0
			_place_marker()
	if any_marker or active:
		queue_redraw()


func _place_marker() -> void:
	var targets: Array[Player] = []
	for player: Player in GameAuthority.players:
		if player.alive:
			targets.append(player)
	if targets.is_empty():
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.world
	var center: Vector2 = targets[rng.randi_range(0, targets.size() - 1)].position
	var at: Vector2 = center + Vector2.from_angle(rng.randf() * TAU) * rng.randf() * float(_data.get("range_px", 200.0))
	for i: int in MAX_MARKERS:
		if _marker_left[i] < 0.0:
			_marker_pos[i] = at
			_marker_left[i] = maxf(float(_data.get("telegraph_s", 1.0)), Data.cfg_float("enemies.min_attack_telegraph_s"))
			return


func _strike(at: Vector2) -> void:
	var reach: float = float(_data.get("radius_px", 30.0))
	var damage: float = float(_data.get("damage", 10.0))
	var element: String = str(_data.get("element", "lightning"))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, damage, "hazard_" + str(_data.get("type", "strikes")), at)
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies != null:
		for slot: int in enemies.query(at, reach + enemies.max_radius()):
			if enemies.positions[slot].distance_to(at) <= reach + enemies.radius[slot]:
				GameAuthority.damage_enemy(slot, damage, null, Vector2.ZERO, element, 0.5)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color.html(str(_data.get("color", "#ffffff"))), true)
		if _look() == "chasm" or _look() == "rockslide":
			_hole_pos.append(at)
			_hole_left.append(CHASM_OPEN_S)
		elif _look() == "bramble":
			_hole_pos.append(at)
			_hole_left.append(float(_data.get("bramble_s", 7.0)))
		elif _look() == "flood":
			_hole_pos.append(at)
			_hole_left.append(float(_data.get("flood_s", 6.0)))
		else:
			# The bolt itself, from the sky (owner request 10/31/2026).
			effects.spawn_bolt(at, Color.html(str(_data.get("color", "#ffffff"))), true, true)


## Heroes slowed by this hazard right now (player id -> true), so it lets go only of those it holds.
var _slowed: Dictionary = {}
## A flood band's shape: wide along the ground, narrow across.
const FLOOD_SHAPE := Vector2(2.2, 0.8)


## True when `at` is inside lingering patch `h` (a bramble thicket, or a flood band).
func in_patch(at: Vector2, h: int, pad: float = 0.0) -> bool:
	var reach: float = float(_data.get("radius_px", 30.0)) + pad
	var d: Vector2 = at - _hole_pos[h]
	if _look() == "flood":
		d = Vector2(d.x / FLOOD_SHAPE.x, d.y / FLOOD_SHAPE.y)
	return d.length() <= reach


## Brambles and floods slow every Hero standing in them (and let go when they wither or the hazard pauses). Flood
## water also puts out burning on Heroes and monsters (docs/PACK_2_PLAN.md: floods).
func _slow_in_patches() -> void:
	var slow: float = float(_data.get("flood_slow" if _look() == "flood" else "bramble_slow", 0.4))
	for player: Player in GameAuthority.players:
		var caught: bool = false
		if not paused:
			for h: int in _hole_pos.size():
				if in_patch(player.position, h, player.body_radius):
					caught = true
					break
		if caught:
			player.slow_zone_mult = slow
			_slowed[player.player_id] = true
			if _look() == "flood":
				player.statuses.timers.erase("burn")
		elif _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
			_slowed.erase(player.player_id)
	var enemies: EnemyManager = GameAuthority.enemies
	if _look() == "flood" and enemies != null and Engine.get_process_frames() % 10 == 0:
		var reach: float = float(_data.get("radius_px", 30.0)) * FLOOD_SHAPE.x
		for h: int in _hole_pos.size():
			for slot: int in enemies.query(_hole_pos[h], reach):
				if enemies.statuses.burn[slot] > 0.0 and in_patch(enemies.positions[slot], h):
					enemies.statuses.remove(slot, "burn")


func _exit_tree() -> void:
	for player: Player in GameAuthority.players:
		if is_instance_valid(player) and _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
	_slowed.clear()


func _look() -> String:
	return str(_data.get("look", ""))


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var reach: float = float(_data.get("radius_px", 30.0))
	var full: float = maxf(float(_data.get("telegraph_s", 1.0)), 0.01)
	var glow := Color.html(str(_data.get("color", "#ffffff")))
	# Open chasms: a dark pit with a glowing rim, closing up again.
	for h: int in _hole_left.size():
		var open: float = clampf(_hole_left[h] / CHASM_OPEN_S, 0.0, 1.0)
		if _look() == "flood":
			# Flood water spreading across the plain in a long band, ripples on it, draining away at the end.
			var wet: float = clampf(_hole_left[h] / 1.0, 0.0, 1.0)
			draw_set_transform(_hole_pos[h], 0.0, FLOOD_SHAPE)
			draw_circle(Vector2.ZERO, reach, Color(glow.darkened(0.25), 0.55 * wet))
			draw_circle(Vector2.ZERO, reach * 0.8, Color(glow, 0.45 * wet))
			for r: int in 3:
				var ring: float = fmod(Time.get_ticks_msec() / 1000.0 * 0.4 + r / 3.0, 1.0)
				draw_arc(Vector2.ZERO, reach * (0.3 + 0.6 * ring), 0.0, TAU, 24, Color(0.85, 0.95, 1.0, 0.35 * wet * (1.0 - ring)), 1.0)
			draw_set_transform(Vector2.ZERO)
			continue
		if _look() == "bramble":
			# A thicket of thorny brambles, withering away at the end.
			var life: float = clampf(_hole_left[h] / 1.0, 0.0, 1.0)
			for b: int in 9:
				var at_b: Vector2 = _hole_pos[h] + Vector2.from_angle(b * 2.4 + h) * reach * (0.2 + 0.09 * b)
				draw_circle(at_b, 6.0, Color(glow.darkened(0.3), 0.85 * life))
				draw_circle(at_b + Vector2(-1, -1), 4.0, Color(glow, 0.9 * life))
				draw_line(at_b, at_b + Vector2.from_angle(b * 1.7) * 7.0, Color(0.55, 0.35, 0.25, life), 1.0)
				if b % 3 == 0:
					draw_circle(at_b + Vector2(2, -2), 1.2, Color(0.95, 0.9, 0.95, life))
			continue
		if _look() == "rockslide":
			# The boulder that came down, and the rubble round it, settling into the snow.
			for r: int in 5:
				var bit: Vector2 = _hole_pos[h] + Vector2.from_angle(r * 1.3 + h) * reach * (0.3 + 0.12 * r)
				draw_circle(bit, 2.5 + (r % 2), Color(glow.darkened(0.2), open))
			draw_circle(_hole_pos[h], reach * 0.45, Color(glow.darkened(0.35), open))
			draw_circle(_hole_pos[h] + Vector2(-2, -3), reach * 0.3, Color(glow, open))
			continue
		draw_set_transform(_hole_pos[h], 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, reach * (0.4 + 0.6 * open), Color(glow, 0.35 * open))
		draw_circle(Vector2.ZERO, reach * (0.3 + 0.6 * open), Color(0.04, 0.03, 0.05, 0.9 * open))
		draw_set_transform(Vector2.ZERO)
	for i: int in MAX_MARKERS:
		if _marker_left[i] < 0.0:
			continue
		var filled: float = clampf(1.0 - _marker_left[i] / full, 0.0, 1.0)
		draw_arc(_marker_pos[i], reach, 0.0, TAU, 24, area_color, 1.5)
		draw_circle(_marker_pos[i], reach * filled, Color(area_color, area_color.a * 0.4))
		if _look() == "flood":
			# The water rising: a widening band of wet ground.
			draw_set_transform(_marker_pos[i], 0.0, FLOOD_SHAPE)
			draw_circle(Vector2.ZERO, reach * filled, Color(glow, 0.3))
			draw_set_transform(Vector2.ZERO)
			continue
		if _look() == "bramble":
			# Thorny shoots creep out across the ground before the thicket springs up.
			for k: int in 6:
				var tip: Vector2 = _marker_pos[i] + Vector2.from_angle(TAU * k / 6.0 + i) * reach * filled
				draw_line(_marker_pos[i], tip, Color(glow, 0.8), 2.0)
			continue
		if _look() == "rockslide":
			# A boulder tumbling down: its shadow grows on the ground, the rock falling onto it.
			draw_circle(_marker_pos[i], reach * 0.45 * filled, Color(0, 0, 0, 0.35))
			var fall: Vector2 = _marker_pos[i] + Vector2(0, -90.0 * (1.0 - filled))
			draw_circle(fall, reach * 0.4, glow.darkened(0.3))
			draw_circle(fall + Vector2(-2, -3), reach * 0.26, glow)
			continue
		if _look() == "chasm":
			# Glowing cracks spread out from the middle as the ground gives way.
			for k: int in 5:
				var dir := Vector2.from_angle(TAU * k / 5.0 + i * 0.7)
				var bend := dir.rotated(0.6 if k % 2 == 0 else -0.6)
				var a: Vector2 = _marker_pos[i]
				var b: Vector2 = a + dir * reach * 0.5 * filled
				var c: Vector2 = b + bend * reach * 0.45 * filled
				draw_polyline(PackedVector2Array([a, b, c]), Color(glow, 0.5 + 0.5 * filled), 1.5)
			continue
		# Sparks crackle on the spot as the strike builds.
		if int(filled * 12.0) % 2 == 0:
			var spark: Vector2 = _marker_pos[i] + Vector2.from_angle(filled * 17.0 + i) * reach * 0.5
			draw_line(spark, spark + Vector2(3, -5), Color.html(str(_data.get("color", "#ffffff"))), 1.0)


func net_capture() -> Variant:
	return [super.net_capture(), CoopMirror.pack_points(_marker_pos), _marker_left]


func net_apply(state: Variant) -> void:
	super.net_apply(state[0])
	_marker_pos = CoopMirror.unpack_points(state[1])
	_marker_left = state[2]
