class_name GroundPatches
extends Node2D
## Ground features from the hazard library (slow ground, teleport rings): a
## level's "ground_patches" data scatters patches around the players, kept
## near them as they travel (seeded by the run, so the same run seed lays them
## out the same way):
##   slide     frozen ponds: you keep sliding (less grip)
##   slow      quicksand: you move slower
##   teleport  fairy rings, in pairs: stepping into one carries you to the other
##   river     rivers of the dead (the Underworld, docs/PACK_2_PLAN.md): you move slower and they slowly drain HP
##             (drain_hp_per_s; never below 1 HP, so they wear you down but never kill)
## Like every hazard, patches do nothing while a boss arena is up.
## Data: kind, count, radius_px [min, max], color, grip_per_s, speed_mult,
## teleport_cooldown_s, pair_distance_screens.

## A river's shape: this much wider and flatter than a circle of its radius.
const RIVER_SHAPE := Vector2(1.9, 0.6)

## Each patch: {"pos", "radius", "pair" (index of its partner, teleport only)}.
var patches: Array[Dictionary] = []

var _data: Dictionary = {}
var _cooldown: Dictionary = {}


func setup(data: Dictionary) -> void:
	_data = data
	z_index = -5


func _ready() -> void:
	CoopMirror.attach(self, "ground_patches")


func kind() -> String:
	return str(_data.get("kind", ""))


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for patch: Dictionary in patches:
		patch["pos"] = Vector2(patch["pos"]) - shift_px


func _process(delta: float) -> void:
	var player: Player = GameAuthority.local_player()
	if player == null or GameAuthority.run == null or _data.is_empty():
		return
	_keep_near(player)
	var arena: bool = GameAuthority.run.boss_arena_active
	for other: Player in GameAuthority.players:
		other.ground_speed_mult = 1.0
		other.ground_grip_per_s = 0.0
		_cooldown[other.player_id] = maxf(float(_cooldown.get(other.player_id, 0.0)) - delta, 0.0)
		if arena or not other.alive:
			continue
		var index: int = patch_at(other.position)
		if index == -1:
			continue
		match kind():
			"slide":
				other.ground_grip_per_s = float(_data.get("grip_per_s", 2.0))
			"slow":
				other.ground_speed_mult = float(_data.get("speed_mult", 0.5))
			"river":
				other.ground_speed_mult = float(_data.get("speed_mult", 0.6))
				if other.hp > 1.0 and not other.god_mode and (not Net.is_client() or other.is_local):
					GameAuthority.damage_player_over_time(other, minf(float(_data.get("drain_hp_per_s", 2.0)) * delta, other.hp - 1.0))
			"teleport":
				_teleport(other, index)
	queue_redraw()


## The patch under `at`, or -1.
func patch_at(at: Vector2) -> int:
	# Rivers are long and narrow (drawn 1.9 wide by 0.6 tall), so the test squashes to match.
	var squash: Vector2 = RIVER_SHAPE if kind() == "river" else Vector2.ONE
	for i: int in patches.size():
		if ((at - Vector2(patches[i]["pos"])) / squash).length() <= float(patches[i]["radius"]):
			return i
	return -1


func _teleport(player: Player, index: int) -> void:
	if float(_cooldown.get(player.player_id, 0.0)) > 0.0 or player.position.distance_to(patches[index]["pos"]) > float(patches[index]["radius"]) * 0.6:
		return
	var pair: int = int(patches[index].get("pair", -1))
	if pair < 0 or pair >= patches.size():
		return
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(player.position, float(patches[index]["radius"]), Color.html(str(_data.get("color", "#ffffff"))), true)
	GameAuthority.place_player(player, patches[pair]["pos"])
	_cooldown[player.player_id] = float(_data.get("teleport_cooldown_s", 4.0))


## Keeps `count` patches within reach: far ones are moved to the ring ahead.
func _keep_near(player: Player) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	var limit: float = view.x * 1.5
	var count: int = int(_data.get("count", 6))
	var rng: RandomNumberGenerator = GameAuthority.run.rng.world
	var sizes: Array = _data.get("radius_px", [24, 40])
	while patches.size() < count:
		patches.append({"pos": _spot(player, view, rng, patches.is_empty()), "radius": rng.randf_range(float(sizes[0]), float(sizes[1])), "pair": -1})
	if kind() == "teleport":
		for i: int in range(0, patches.size() - 1, 2):
			patches[i]["pair"] = i + 1
			patches[i + 1]["pair"] = i
	for i: int in patches.size():
		if player.position.distance_to(patches[i]["pos"]) > limit:
			if kind() == "teleport" and i % 2 == 1:
				var partner: Vector2 = patches[i - 1]["pos"]
				patches[i]["pos"] = partner + Vector2.from_angle(rng.randf() * TAU) * view.x * float(_data.get("pair_distance_screens", 1.0))
			else:
				patches[i]["pos"] = _spot(player, view, rng, false)


## A spot on the ring 0.6–1.2 screens out (the first may be closer, so it's seen early).
func _spot(player: Player, view: Vector2, rng: RandomNumberGenerator, near: bool) -> Vector2:
	var reach: float = view.x * (rng.randf_range(0.25, 0.45) if near else rng.randf_range(0.6, 1.2))
	return player.position + Vector2.from_angle(rng.randf() * TAU) * reach


func _draw() -> void:
	var color := Color.html(str(_data.get("color", "#ffffff")))
	var faded: bool = GameAuthority.run != null and GameAuthority.run.boss_arena_active
	var t: float = Time.get_ticks_msec() * 0.001
	for patch: Dictionary in patches:
		var radius: float = float(patch["radius"])
		var at: Vector2 = patch["pos"]
		var alpha: float = 0.5 if faded else 1.0
		match kind():
			"teleport":
				_fairy_ring(at, radius, color, alpha, t)
			"slide":
				_frozen_pond(at, radius, color, alpha)
			"slow":
				_quicksand(at, radius, color, alpha, t)
			"river":
				_river(at, radius, color, alpha, t)
			_:
				draw_circle(at, radius, Color(color, 0.7 * alpha))


## A frozen pond (owner request 10/31/2026): pale ice, a darker rim, white streaks of shine and a crack.
func _frozen_pond(at: Vector2, radius: float, color: Color, alpha: float) -> void:
	draw_set_transform(at, 0.0, Vector2(1.0, 0.7))
	draw_circle(Vector2.ZERO, radius, Color(color.darkened(0.25), 0.8 * alpha))
	draw_circle(Vector2.ZERO, radius - 2.0, Color(color, 0.8 * alpha))
	draw_line(Vector2(-radius * 0.5, -radius * 0.3), Vector2(-radius * 0.1, -radius * 0.55), Color(1, 1, 1, 0.8 * alpha), 2.0)
	draw_line(Vector2(radius * 0.1, -radius * 0.2), Vector2(radius * 0.35, -radius * 0.35), Color(1, 1, 1, 0.6 * alpha), 1.5)
	draw_polyline(PackedVector2Array([Vector2(-radius * 0.2, radius * 0.2), Vector2(0, radius * 0.35),
			Vector2(radius * 0.3, radius * 0.3), Vector2(radius * 0.45, radius * 0.5)]), Color(color.darkened(0.4), 0.7 * alpha), 1.0)
	draw_set_transform(Vector2.ZERO)


## Quicksand: wet sand slowly turning round a sinking middle.
func _quicksand(at: Vector2, radius: float, color: Color, alpha: float, t: float) -> void:
	draw_set_transform(at, 0.0, Vector2(1.0, 0.7))
	draw_circle(Vector2.ZERO, radius, Color(color, 0.75 * alpha))
	for ring: int in 3:
		var r: float = radius * (0.3 + 0.22 * ring)
		var spin: float = t * (0.6 - ring * 0.15) + ring
		draw_arc(Vector2.ZERO, r, spin, spin + PI * 1.2, 16, Color(color.darkened(0.3), 0.8 * alpha), 1.5)
	draw_circle(Vector2.ZERO, radius * 0.15, Color(color.darkened(0.45), 0.9 * alpha))
	draw_set_transform(Vector2.ZERO)


## A river of the dead: a long pool of black water, lapping at its banks, with pale shades drifting along it.
func _river(at: Vector2, radius: float, color: Color, alpha: float, t: float) -> void:
	draw_set_transform(at, 0.0, RIVER_SHAPE)
	draw_circle(Vector2.ZERO, radius + 2.0, Color(0.08, 0.07, 0.1, 0.55 * alpha))
	draw_circle(Vector2.ZERO, radius, Color(color, 0.85 * alpha))
	for ring: int in 3:
		var r: float = radius * (0.35 + 0.2 * ring)
		var drift: float = t * 0.4 + ring * 1.7
		draw_arc(Vector2.ZERO, r, drift, drift + PI * 0.7, 12, Color(color.lightened(0.25), 0.5 * alpha), 1.0)
	draw_set_transform(Vector2.ZERO)
	for m: int in 3:
		var along: float = fmod(t * 0.12 + m * 0.33, 1.0)
		var spot: Vector2 = at + Vector2((along - 0.5) * radius * RIVER_SHAPE.x * 1.7, sin(t * 1.3 + m * 2.0) * radius * 0.15 - 3.0)
		var fade: float = sin(along * PI) * 0.55 * alpha
		draw_circle(spot, 2.2, Color(0.85, 0.9, 0.95, fade))
		draw_line(spot + Vector2(0, 2), spot + Vector2(-4, 4), Color(0.85, 0.9, 0.95, fade * 0.6), 1.5)


## A fairy ring: a ring of little mushrooms on darker grass, with motes of light rising in it.
func _fairy_ring(at: Vector2, radius: float, color: Color, alpha: float, t: float) -> void:
	draw_arc(at, radius, 0.0, TAU, 24, Color(0.2, 0.3, 0.15, 0.45 * alpha), 4.0)
	for k: int in 10:
		var spot: Vector2 = at + Vector2.from_angle(TAU * k / 10.0) * Vector2(radius, radius * 0.75)
		draw_line(spot, spot + Vector2(0, -3), Color(0.93, 0.9, 0.8, alpha), 1.5)
		draw_circle(spot + Vector2(0, -3.5), 2.2, Color(0.8, 0.6, 0.45, alpha))
	for m: int in 4:
		var rise: float = fmod(t * 0.5 + m * 0.25, 1.0)
		var mote: Vector2 = at + Vector2(sin(m * 2.1 + t) * radius * 0.5, radius * 0.3 - rise * radius)
		draw_circle(mote, 1.5, Color(color, (1.0 - rise) * alpha))


# --- Co-op (CoopMirror) ------------------------------------------------------------------

func net_capture() -> Variant:
	return CoopMirror.copy_dicts(patches)


func net_apply(state: Variant) -> void:
	patches.assign(state)
