class_name Critters
extends Node2D
## Wildlife (docs/WORLD_PLAN.md: 2; owner request 10/31/2026), from data/art/critters/<level>.json:
##   small ground animals  wander, and scatter when a Hero comes near
##   birds                 peck on the ground, and fly off when a Hero comes near
##   insects               flutter about (fireflies only at night)
## They're only for looks: nothing hits them and they hurt no one. At most world.critters_max are out at once, pooled,
## appearing just off screen and leaving when far away, so they never slow the game. Each device has its own.
## Large animals (enemies.json "animal") are real creatures that can be hurt: the deciding game lets at most
## world.large_animals_max of the level's own roam near the party.

## Each {"name", "kind", "pos", "vel", "state" (0 idle, 1 moving, 2 fleeing or flying), "t", "anim", "home"}.
var _critters: Array[Dictionary] = []
var _art: Dictionary = {}
var _by_kind: Dictionary = {}
var _animals: PackedStringArray = []
var _animal_slots: Array = []
var _spawn_s: float = 0.0
var _animal_s: float = 0.0
var _rng := RandomNumberGenerator.new()


func setup(level: Dictionary) -> void:
	z_as_relative = false
	z_index = Data.cfg_int("world.critters_z")
	_rng.randomize()
	var id: String = str(level.get("id", ""))
	_art = PixelArt.find("critters/" + id)
	if not _art.is_empty():
		var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(PixelArt.ART_DIR + "critters/" + id + ".json"))
		var info: Dictionary = (raw as Dictionary).get("critters", {}) if raw is Dictionary else {}
		for name: String in info:
			var kind: String = str(info[name]["kind"])
			if not _by_kind.has(kind):
				_by_kind[kind] = []
			(_by_kind[kind] as Array).append(name)
	# The level's own large animals: those of its people's land.
	var tradition: String = {"greek": "greek", "norse": "norse", "egyptian": "egyptian", "irish": "irish", "welsh": "irish", "mesopotamian": "mesopotamian", "finnish": "norse"}.get(str(level.get("region", "")), "")
	# An animal that names its levels (the Underworld's black cattle) lives only there; the rest by their land.
	var level_id: String = str(level.get("id", ""))
	var own: PackedStringArray = []
	var by_land: PackedStringArray = []
	for entry: Variant in Data.get_file("enemies.json"):
		if not (entry is Dictionary and bool(entry.get("animal", false))):
			continue
		if entry.has("levels"):
			if (entry["levels"] as Array).has(level_id):
				own.append(str(entry["id"]))
		elif str(entry.get("tradition", "")) == tradition:
			by_land.append(str(entry["id"]))
	_animals = own if not own.is_empty() else by_land


func count() -> int:
	return _critters.size()


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for critter: Dictionary in _critters:
		critter["pos"] = Vector2(critter["pos"]) - shift_px
		critter["home"] = Vector2(critter["home"]) - shift_px


func _quiet() -> bool:
	var run: RunState = GameAuthority.run
	return run == null or run.boss_arena_active or (Flora.current != null and not Flora.current.enabled)


func _process(delta: float) -> void:
	var hero: Player = GameAuthority.local_player()
	if hero == null or _quiet():
		if not _critters.is_empty():
			_critters.clear()
			queue_redraw()
		return
	var view: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	_spawn_s -= delta
	if _spawn_s <= 0.0 and not _art.is_empty():
		_spawn_s = Data.cfg_float("world.critter_spawn_s")
		if _critters.size() < Data.cfg_int("world.critters_max"):
			_spawn(hero.position, view)
	for critter: Dictionary in _critters.duplicate():
		_step(critter, delta)
		if Vector2(critter["pos"]).distance_to(hero.position) > view.length() * 0.9:
			_critters.erase(critter)
	_tick_animals(hero, view, delta)
	queue_redraw()


func _spawn(near: Vector2, view: Vector2) -> void:
	var kinds: Array = ["ground", "ground", "bird", "bird", "insect"]
	if _night():
		kinds.append("firefly")
		kinds.append("firefly")
	var kind: String = kinds[_rng.randi_range(0, kinds.size() - 1)]
	var names: Array = _by_kind.get(kind, [])
	if names.is_empty():
		return
	# Just off screen, or for insects and fireflies anywhere a little way from the Hero.
	var at: Vector2 = near + Vector2.from_angle(_rng.randf() * TAU) * view.length() * _rng.randf_range(0.42, 0.55)
	if kind in ["insect", "firefly"]:
		at = near + Vector2(_rng.randf_range(-0.5, 0.5) * view.x, _rng.randf_range(-0.5, 0.5) * view.y)
	_critters.append({"name": names[_rng.randi_range(0, names.size() - 1)], "kind": kind, "pos": at, "vel": Vector2.ZERO,
			"state": 0, "t": 0.0, "anim": _rng.randf(), "home": at})


func _night() -> bool:
	var run: RunState = GameAuthority.run
	return run != null and str(RunArc.age_at(run.arc_s())) in ["night", "deep_night"]


func _nearest_hero(at: Vector2) -> float:
	var best: float = INF
	for player: Player in GameAuthority.players:
		if player.alive:
			best = minf(best, player.position.distance_to(at))
	return best


func _hero_away(at: Vector2) -> Vector2:
	var best: Player = null
	for player: Player in GameAuthority.players:
		if player.alive and (best == null or player.position.distance_to(at) < best.position.distance_to(at)):
			best = player
	return (at - best.position).normalized() if best != null and best.position != at else Vector2.RIGHT


func _step(c: Dictionary, delta: float) -> void:
	c["t"] = float(c["t"]) - delta
	c["anim"] = float(c["anim"]) + delta
	var at: Vector2 = c["pos"]
	var scare: float = Data.cfg_float("world.critter_scare_px")
	match str(c["kind"]):
		"ground":
			if _nearest_hero(at) < scare:
				c["state"] = 2
				c["vel"] = _hero_away(at) * Data.cfg_float("world.critter_flee_speed")
			elif float(c["t"]) <= 0.0:
				c["t"] = _rng.randf_range(0.8, 2.5)
				c["state"] = 1 if _rng.randf() < 0.5 else 0
				c["vel"] = Vector2.from_angle(_rng.randf() * TAU) * Data.cfg_float("world.critter_walk_speed") if int(c["state"]) == 1 else Vector2.ZERO
		"bird":
			if int(c["state"]) != 2 and _nearest_hero(at) < scare * 1.3:
				c["state"] = 2
				c["vel"] = (_hero_away(at) + Vector2(0, -0.6)).normalized() * Data.cfg_float("world.critter_fly_speed")
		"insect", "firefly":
			var home: Vector2 = c["home"]
			var k: float = float(c["anim"])
			c["pos"] = home + Vector2(sin(k * 1.3) * 18.0 + sin(k * 3.1) * 5.0, cos(k * 1.7) * 10.0)
			return
	c["pos"] = at + Vector2(c["vel"]) * delta


func _draw() -> void:
	if _art.is_empty():
		return
	var frames: Dictionary = _art["frames"]
	for c: Dictionary in _critters:
		var name: String = str(c["name"])
		var flying: bool = str(c["kind"]) == "bird" and int(c["state"]) == 2
		var key: String = name + "_fly" if flying and frames.has(name + "_fly") else name
		var list: Array = frames.get(key, [])
		if list.is_empty():
			continue
		var moving: bool = int(c["state"]) != 0 or str(c["kind"]) in ["insect", "firefly"]
		var rate: float = 8.0 if moving else 1.5
		var texture: ImageTexture = list[int(float(c["anim"]) * rate) % list.size()]
		var left: bool = Vector2(c["vel"]).x < 0.0
		var at: Vector2 = c["pos"]
		draw_set_transform(at, 0.0, Vector2(-1.0 if left else 1.0, 1.0))
		draw_texture(texture, -Vector2(texture.get_width() * 0.5, texture.get_height()))
		draw_set_transform(Vector2.ZERO)


# --- Large animals (they can be hurt) ------------------------------------------------------------------------------

func _tick_animals(hero: Player, view: Vector2, delta: float) -> void:
	if _animals.is_empty() or not GameAuthority.decides() or GameAuthority.enemies == null:
		return
	_animal_slots = _animal_slots.filter(func(slot: int) -> bool:
		return GameAuthority.enemies.active[slot] != 0 and _animals.has(str(GameAuthority.enemies.type_of(slot)["id"])))
	_animal_s -= delta
	if _animal_s > 0.0 or _animal_slots.size() >= Data.cfg_int("world.large_animals_max"):
		return
	_animal_s = Data.cfg_float("world.large_animal_spawn_s")
	var rng: RandomNumberGenerator = GameAuthority.run.rng.spawns
	var at: Vector2 = hero.position + Vector2.from_angle(rng.randf() * TAU) * view.length() * 0.55
	var slot: int = GameAuthority.spawn_enemy(_animals[rng.randi_range(0, _animals.size() - 1)], at)
	if slot != -1:
		_animal_slots.append(slot)
