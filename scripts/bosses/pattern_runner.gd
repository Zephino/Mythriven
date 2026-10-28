class_name PatternRunner
extends Node2D
## The shared attack pattern library (GAME_DESIGN.md: Bosses / Pattern
## library), used by bosses and god trials: radial burst, spiral, aimed fan,
## line sweep, ground circles, charge with trail, falling strikes with
## shadows, summon adds, and safe zone. Every attack is telegraphed for
## 0.6–1.5 s first: orange ground markers for area attacks, a red flash at the
## caster before shots fire. Shots use the boss projectile budget; lingering
## trail patches use the ground hazard budget.
## A pattern's settings: {"pattern": id, "telegraph_s", "damage", plus its own
## values}; anything missing comes from config patterns.<id>.

signal charge_started(from: Vector2, to: Vector2, duration_s: float)

## Running attacks: each {"id", "t", "telegraph", "origin", "target", "p", "element", "source", "step", "fired"}.
var _jobs: Array[Dictionary] = []
## Lingering hazard patches: {"at", "radius", "left", "damage", "source", "tick"}.
var _patches: Array[Dictionary] = []


func _ready() -> void:
	z_index = 3


## Starts a pattern from `origin` aimed at `target`. `damage_mult` scales its damage.
func run(pattern: Dictionary, origin: Vector2, target: Vector2, element: String, source_id: String,
		damage_mult: float = 1.0) -> float:
	var id: String = str(pattern.get("pattern", ""))
	var p: Dictionary = (Data.cfg("patterns." + id) as Dictionary).duplicate() if Data.cfg("patterns").has(id) else {}
	p.merge(pattern, true)
	p["damage"] = float(p.get("damage", 5.0)) * damage_mult
	var range_s: Array = Data.cfg("bosses.telegraph_s")
	var telegraph: float = clampf(float(p.get("telegraph_s", 0.8)), float(range_s[0]), float(range_s[1]))
	_jobs.append({"id": id, "t": 0.0, "telegraph": telegraph, "origin": origin, "target": target, "p": p,
			"element": element, "source": source_id, "step": 0.0, "fired": 0})
	if id == "charge_trail":
		charge_started.emit(origin, target, telegraph + float(p.get("charge_s", 0.8)))
	return telegraph + float(p.get("duration_s", 0.0))


func busy() -> bool:
	return not _jobs.is_empty()


func clear() -> void:
	_jobs.clear()
	_patches.clear()
	queue_redraw()


## Moves a running job's origin (a caster that moves while winding up).
func set_origin(origin: Vector2) -> void:
	for job: Dictionary in _jobs:
		job["origin"] = origin


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for job: Dictionary in _jobs:
		job["origin"] -= shift_px
		job["target"] -= shift_px
		if job.has("spots"):
			var spots: PackedVector2Array = job["spots"]
			for i: int in spots.size():
				spots[i] -= shift_px
			job["spots"] = spots
	for patch: Dictionary in _patches:
		patch["at"] -= shift_px


func _process(delta: float) -> void:
	for job: Dictionary in _jobs.duplicate():
		job["t"] = float(job["t"]) + delta
		if not job.has("spots"):
			job["spots"] = _spots_for(job)
		if float(job["t"]) < float(job["telegraph"]):
			continue
		if _fire(job, delta):
			_jobs.erase(job)
	for patch: Dictionary in _patches.duplicate():
		patch["left"] = float(patch["left"]) - delta
		patch["tick"] = float(patch["tick"]) - delta
		if float(patch["tick"]) <= 0.0:
			patch["tick"] = Data.cfg_float("combat.contact_damage_interval_s")
			_hurt_circle(patch["at"], float(patch["radius"]), float(patch["damage"]), str(patch["source"]))
		if float(patch["left"]) <= 0.0:
			_patches.erase(patch)
	queue_redraw()


## Ground positions decided when the job starts, so the telegraph shows where they'll land.
func _spots_for(job: Dictionary) -> PackedVector2Array:
	var spots := PackedVector2Array()
	var p: Dictionary = job["p"]
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat if GameAuthority.run != null else RandomNumberGenerator.new()
	match str(job["id"]):
		"ground_circles", "falling_strikes":
			var spread: float = float(p.get("spread_px", 120.0))
			for _k: int in int(p.get("count", 5)):
				spots.append(Vector2(job["target"]) + Vector2.from_angle(rng.randf() * TAU) * rng.randf() * spread)
		"safe_zone":
			for _k: int in int(p.get("safe_count", 2)):
				spots.append(Vector2(job["origin"]) + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0.3, 0.8)
						* float(p.get("radius_px", 200.0)))
		"charge_trail":
			var from: Vector2 = job["origin"]
			var to: Vector2 = job["target"]
			for k: int in int(p.get("trail_patches", 6)):
				spots.append(from.lerp(to, (k + 1.0) / (int(p.get("trail_patches", 6)) + 1.0)))
	return spots


## Fires (or keeps firing) a job. Returns true when it's finished.
func _fire(job: Dictionary, delta: float) -> bool:
	var p: Dictionary = job["p"]
	var origin: Vector2 = job["origin"]
	var target: Vector2 = job["target"]
	var aim: Vector2 = (target - origin).normalized() if target != origin else Vector2.RIGHT
	var damage: float = float(p.get("damage", 5.0))
	var speed: float = float(p.get("speed_px_s", 80.0))
	var shot_radius: float = float(p.get("shot_radius_px", 4.0))
	match str(job["id"]):
		"radial_burst":
			_ring(origin, int(p.get("count", 12)), randf() * TAU, speed, shot_radius, damage, job)
			return true
		"aimed_fan":
			var count: int = int(p.get("count", 5))
			var spread: float = deg_to_rad(float(p.get("spread_deg", 40.0)))
			for k: int in count:
				var offset: float = 0.0 if count == 1 else spread * (float(k) / (count - 1) - 0.5)
				_shot(origin, aim.rotated(offset) * speed, shot_radius, damage, job)
			return true
		"spiral":
			job["step"] = float(job["step"]) - delta
			if float(job["step"]) <= 0.0:
				job["step"] = float(p.get("every_s", 0.12))
				var arms: int = int(p.get("arms", 3))
				var turn: float = float(job["fired"]) * deg_to_rad(float(p.get("turn_deg", 14.0)))
				_ring(origin, arms, turn, speed, shot_radius, damage, job)
				job["fired"] = int(job["fired"]) + 1
			return float(job["t"]) >= float(job["telegraph"]) + float(p.get("duration_s", 2.0))
		"line_sweep":
			_hurt_strip(origin, aim, float(p.get("length_px", 260.0)), float(p.get("width_px", 28.0)), damage, str(job["source"]))
			_flash_ring(origin + aim * float(p.get("length_px", 260.0)) * 0.5, float(p.get("width_px", 28.0)), job)
			return true
		"ground_circles":
			for spot: Vector2 in job["spots"]:
				_hurt_circle(spot, float(p.get("radius_px", 26.0)), damage, str(job["source"]))
				_flash_ring(spot, float(p.get("radius_px", 26.0)), job)
			return true
		"falling_strikes":
			var spots: PackedVector2Array = job["spots"]
			var every: float = float(p.get("every_s", 0.15))
			while int(job["fired"]) < spots.size() and float(job["t"]) >= float(job["telegraph"]) + int(job["fired"]) * every:
				var spot: Vector2 = spots[int(job["fired"])]
				_hurt_circle(spot, float(p.get("radius_px", 22.0)), damage, str(job["source"]))
				_flash_ring(spot, float(p.get("radius_px", 22.0)), job)
				job["fired"] = int(job["fired"]) + 1
			return int(job["fired"]) >= spots.size()
		"charge_trail":
			for spot: Vector2 in job["spots"]:
				_add_patch(spot, float(p.get("trail_radius_px", 16.0)), float(p.get("trail_s", 2.0)), damage * 0.5, str(job["source"]))
			return true
		"summon_adds":
			for k: int in int(p.get("count", 4)):
				var offset := Vector2.from_angle(TAU * k / maxf(float(p.get("count", 4)), 1.0)) * 40.0
				GameAuthority.spawn_enemy(str(p.get("enemy", "shade_swarm")), origin + offset)
			return true
		"safe_zone":
			_hurt_outside(origin, float(p.get("radius_px", 200.0)), job["spots"], float(p.get("safe_radius_px", 40.0)), damage,
					str(job["source"]))
			_flash_ring(origin, float(p.get("radius_px", 200.0)), job)
			return true
	return true


func _ring(origin: Vector2, count: int, start: float, speed: float, shot_radius: float, damage: float, job: Dictionary) -> void:
	for k: int in count:
		_shot(origin, Vector2.from_angle(start + TAU * k / maxf(count, 1)) * speed, shot_radius, damage, job)


func _shot(origin: Vector2, velocity: Vector2, shot_radius: float, damage: float, job: Dictionary) -> void:
	if GameAuthority.enemy_shots != null:
		GameAuthority.enemy_shots.fire(origin, velocity, shot_radius, damage, str(job["source"]), str(job["element"]),
				EnemyProjectiles.BOSS)


func _hurt_circle(at: Vector2, reach: float, damage: float, source_id: String) -> void:
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, damage, source_id, at)


func _hurt_strip(from: Vector2, direction: Vector2, length: float, width: float, damage: float, source_id: String) -> void:
	for player: Player in GameAuthority.players:
		var offset: Vector2 = player.position - from
		var along: float = offset.dot(direction)
		if player.alive and along >= 0.0 and along <= length and absf(offset.cross(direction)) <= width * 0.5 + player.body_radius:
			GameAuthority.damage_player(player, damage, source_id, from)


func _hurt_outside(center: Vector2, reach: float, safe: PackedVector2Array, safe_radius: float, damage: float,
		source_id: String) -> void:
	for player: Player in GameAuthority.players:
		if not player.alive or player.position.distance_to(center) > reach:
			continue
		var is_safe: bool = false
		for spot: Vector2 in safe:
			is_safe = is_safe or player.position.distance_to(spot) <= safe_radius
		if not is_safe:
			GameAuthority.damage_player(player, damage, source_id, center)


func _add_patch(at: Vector2, reach: float, seconds: float, damage: float, source_id: String) -> void:
	if _patches.size() >= Data.cfg_int("effect_budgets.max_ground_hazards"):
		_patches.pop_front()
	_patches.append({"at": at, "radius": reach, "left": seconds, "damage": damage, "source": source_id, "tick": 0.0})


func _flash_ring(at: Vector2, reach: float, job: Dictionary) -> void:
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Elements.color(str(job["element"])) if str(job["element"]) != "" else Color.WHITE)


func _draw() -> void:
	var area := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	var fire_flash := Color.html(Data.cfg_string("bosses.fire_telegraph_color"))
	var safe_color := Color.html(Data.cfg_string("bosses.safe_zone_color"))
	for job: Dictionary in _jobs:
		var p: Dictionary = job["p"]
		var k: float = clampf(float(job["t"]) / maxf(float(job["telegraph"]), 0.01), 0.0, 1.0)
		var origin: Vector2 = job["origin"]
		var target: Vector2 = job["target"]
		match str(job["id"]):
			"radial_burst", "aimed_fan", "spiral":
				if k < 1.0 and int(k * 8.0) % 2 == 0:
					draw_circle(origin, 10.0 + 6.0 * k, fire_flash)
			"line_sweep":
				if k < 1.0:
					var aim: Vector2 = (target - origin).normalized() if target != origin else Vector2.RIGHT
					var half: Vector2 = aim.orthogonal() * float(p.get("width_px", 28.0)) * 0.5
					var end: Vector2 = origin + aim * float(p.get("length_px", 260.0))
					draw_colored_polygon(PackedVector2Array([origin + half, end + half, end - half, origin - half]), Color(area, area.a * 0.35 * k + 0.1))
			"charge_trail":
				if k < 1.0:
					draw_line(origin, target, area, 3.0)
			"safe_zone":
				if k < 1.0:
					draw_arc(origin, float(p.get("radius_px", 200.0)), 0.0, TAU, 48, area, 2.0)
					for spot: Vector2 in job.get("spots", PackedVector2Array()):
						draw_circle(spot, float(p.get("safe_radius_px", 40.0)), safe_color)
			_:
				for i: int in (job.get("spots", PackedVector2Array()) as PackedVector2Array).size():
					var spot: Vector2 = job["spots"][i]
					if str(job["id"]) == "falling_strikes" and i < int(job["fired"]):
						continue
					var reach: float = float(p.get("radius_px", 24.0))
					draw_arc(spot, reach, 0.0, TAU, 20, area, 1.5)
					draw_circle(spot, reach * k, Color(area, area.a * 0.4))
	for patch: Dictionary in _patches:
		draw_circle(patch["at"], float(patch["radius"]), Color(area, area.a * 0.3))
