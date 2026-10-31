class_name HazardStrikes
extends Hazard
## The "strikes" hazard from the hazard library (GAME_DESIGN.md: Content reuse
## rules): the Aegean Shore's thunderstorm, and later the Divine Storm event.
## While active, telegraphed strikes land at random spots near the players:
## an orange ground marker grows for telegraph_s, then the strike hurts every
## player and enemy inside it. Settings come from the level's "hazard" data.
## Markers are a small fixed pool. Data: strikes_per_s, radius_px,
## telegraph_s, damage, element, range_px, color.

const MAX_MARKERS := 16

var _strike_budget: float = 0.0
var _marker_pos := PackedVector2Array()
var _marker_left := PackedFloat32Array()


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
		# The bolt itself, from the sky (owner request 10/31/2026).
		effects.spawn_bolt(at, Color.html(str(_data.get("color", "#ffffff"))), true, true)


func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var reach: float = float(_data.get("radius_px", 30.0))
	var full: float = maxf(float(_data.get("telegraph_s", 1.0)), 0.01)
	for i: int in MAX_MARKERS:
		if _marker_left[i] < 0.0:
			continue
		var filled: float = clampf(1.0 - _marker_left[i] / full, 0.0, 1.0)
		draw_arc(_marker_pos[i], reach, 0.0, TAU, 24, area_color, 1.5)
		draw_circle(_marker_pos[i], reach * filled, Color(area_color, area_color.a * 0.4))
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
