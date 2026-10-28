class_name SummonLayer
extends Node2D
## Plays god summons (GAME_DESIGN.md: Gods / Blessing, trigger, and summon).
## Summons last 2–6 s and are made of a few shared moving shapes (bands that
## sweep the screen, a travelling circle, rings), all inside the effect
## budgets. They're enhanced by the summoner's stats: damage through the
## damage formula (Might, crits), sizes by Area, statuses by status duration.
##   Wheel of Fortune (Tyche)        pulls every pickup; kills drop double for 5 s
##   Heart of the Greenwood (Cernunnos) full heal, 5 s invulnerable, roots nearby enemies, stags charge across
##   Hammer's Return (Thor)          a hammer flies out and back, calling lightning on what it passes
##   Winter's Hunt (Skadi)           freezes every non-boss enemy 4 s while ice arrows rain; bosses Chilled
##   Breath of the Desert (Sekhmet)  a scorching wind sweeps the screen, Burning everything 4 s
##   Earthshaker (Poseidon)          a tidal wave crosses the screen, then the ground quakes (Soak, stun)
##   Sun Barque (Ra)                 a blazing sun crosses the screen, Holy damage and Smite
##   Crow Storm (the Morrígan)       Hexes every enemy and marks the 5 strongest as fated (+100% damage taken)

const MAX_EFFECTS := 8

var orbs: XpOrbs
var gold: GoldPickups

## Each {"kind", "t", "duration", "player", "god", "s" (summon data), "hit": {slot: true}, ...}.
var _effects: Array[Dictionary] = []


func _ready() -> void:
	z_index = 6


func active_count() -> int:
	return _effects.size()


## Starts `god`'s summon for `player`.
func run(god: Dictionary, player: Player) -> void:
	var s: Dictionary = god.get("summon", {})
	var effect: Dictionary = {"kind": str(s.get("effect", "")), "t": 0.0, "duration": float(s.get("duration_s", 2.0)),
			"player": player, "god": god, "s": s, "hit": {}, "color": Color.html(str(god.get("placeholder_color", "#ffffff")))}
	var area: float = player.stats.area_mult()
	var view: Rect2 = visible_rect()
	effect["view"] = view
	match effect["kind"]:
		"wheel_of_fortune":
			if orbs != null:
				orbs.pull_all()
			if gold != null:
				gold.pull_all()
			GameAuthority.run.double_drops_until_s = GameAuthority.run.elapsed_s + float(s.get("duration_s", 5.0))
			GameAuthority.run.drop_mult_bonus = float(s.get("drop_mult", 2.0))
		"heart_of_the_greenwood":
			GameAuthority.heal_player(player, player.max_hp)
			player.invulnerable_s = maxf(player.invulnerable_s, float(s.get("invulnerable_s", 5.0)))
			for slot: int in _enemies_near(player.position, float(s.get("root_radius_px", 160.0)) * area):
				if not _is_boss(slot):
					GameAuthority.enemies.statuses.apply_stun(slot, float(s.get("root_s", 3.0)) * player.stats.status_duration_mult())
		"winters_hunt":
			for slot: int in _enemies_in(view):
				if _is_boss(slot):
					GameAuthority.enemies.statuses.apply(slot, "chill", 1.0, false)
				else:
					GameAuthority.enemies.statuses.freeze(slot, float(s.get("freeze_s", 4.0)) * player.stats.status_duration_mult())
			effect["arrow_budget"] = 0.0
		"crow_storm":
			var strongest: Array[int] = []
			for slot: int in _enemies_in(view):
				GameAuthority.enemies.statuses.apply(slot, "hex", player.stats.status_duration_mult())
				strongest.append(slot)
			strongest.sort_custom(func(a: int, b: int) -> bool: return GameAuthority.enemies.hp[a] > GameAuthority.enemies.hp[b])
			for k: int in mini(int(s.get("fated_count", 5)), strongest.size()):
				GameAuthority.enemies.statuses.apply_fated(strongest[k], float(s.get("fated_s", 6.0)), float(s.get("fated_damage_taken", 1.0)))
			effect["marked"] = strongest.slice(0, mini(int(s.get("fated_count", 5)), strongest.size()))
		"earthshaker":
			effect["quaked"] = false
	if _effects.size() >= MAX_EFFECTS:
		_effects.pop_front()
	_effects.append(effect)


## The world area on screen around the camera.
func visible_rect() -> Rect2:
	var size: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	var camera: Camera2D = get_viewport().get_camera_2d()
	var center: Vector2 = camera.get_screen_center_position() if camera != null else Vector2.ZERO
	return Rect2(center - size * 0.5, size)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for effect: Dictionary in _effects:
		var view: Rect2 = effect["view"]
		view.position -= shift_px
		effect["view"] = view


func _process(delta: float) -> void:
	for effect: Dictionary in _effects.duplicate():
		effect["t"] = float(effect["t"]) + delta
		if not is_instance_valid(effect["player"]) or GameAuthority.enemies == null:
			_effects.erase(effect)
			continue
		var player: Player = effect["player"]
		_step(effect, player, delta)
		if float(effect["t"]) >= float(effect["duration"]):
			_finish(effect, player)
			_effects.erase(effect)
	queue_redraw()


func _step(effect: Dictionary, player: Player, delta: float) -> void:
	var s: Dictionary = effect["s"]
	var k: float = clampf(float(effect["t"]) / maxf(float(effect["duration"]), 0.01), 0.0, 1.0)
	var view: Rect2 = effect["view"]
	var area: float = player.stats.area_mult()
	match str(effect["kind"]):
		"heart_of_the_greenwood":
			var stags: int = int(s.get("stags", 3))
			for i: int in stags:
				var y: float = view.position.y + view.size.y * (i + 1.0) / (stags + 1.0)
				var x: float = lerpf(view.position.x, view.end.x, k)
				_hit_circle(effect, player, Vector2(x, y), float(s.get("stag_width_px", 24.0)) * area, float(s.get("stag_damage", 25.0)),
						"earth", Vector2.RIGHT, 0.5)
		"hammers_return":
			var reach: float = view.size.x * float(s.get("reach_screens", 0.5))
			var out: float = k * 2.0 if k < 0.5 else (1.0 - k) * 2.0
			if k >= 0.5 and not effect.has("turned"):
				effect["turned"] = true
				(effect["hit"] as Dictionary).clear()
			var center: Vector2 = player.position + player.facing * reach * out
			effect["at"] = center
			_hit_circle(effect, player, center, float(s.get("radius_px", 22.0)) * area, float(s.get("damage", 40.0)), "lightning",
					player.facing, 1.0)
		"winters_hunt":
			effect["arrow_budget"] = float(effect["arrow_budget"]) + float(s.get("arrows_per_s", 20.0)) * delta
			var targets: Array[int] = _enemies_in(view)
			while float(effect["arrow_budget"]) >= 1.0:
				effect["arrow_budget"] = float(effect["arrow_budget"]) - 1.0
				if targets.is_empty():
					break
				var slot: int = targets[GameAuthority.run.rng.combat.randi_range(0, targets.size() - 1)]
				GameAuthority.damage_enemy(slot, float(s.get("arrow_damage", 15.0)), player, Vector2.ZERO, "ice", 0.0)
		"breath_of_the_desert":
			_hit_band(effect, player, view, k, view.size.x * 0.12 * area, float(s.get("damage", 25.0)), "fire", 0.0)
			for slot: Variant in (effect["hit"] as Dictionary).keys():
				if GameAuthority.enemies.active[int(slot)] != 0:
					var st: EnemyStatuses = GameAuthority.enemies.statuses
					st.burn[int(slot)] = maxf(st.burn[int(slot)], float(s.get("burn_s", 4.0)) * player.stats.status_duration_mult())
		"earthshaker":
			_hit_band(effect, player, view, minf(k * 1.5, 1.0), view.size.x * 0.1 * area, float(s.get("wave_damage", 30.0)), "water", 1.0)
		"sun_barque":
			var center := Vector2(lerpf(view.position.x, view.end.x, k), view.get_center().y + sin(k * PI) * -view.size.y * 0.2)
			effect["at"] = center
			_hit_circle(effect, player, center, float(s.get("radius_px", 70.0)) * area, float(s.get("damage", 45.0)), "holy",
					Vector2.ZERO, 1.0)


func _finish(effect: Dictionary, player: Player) -> void:
	if str(effect["kind"]) != "earthshaker":
		return
	var s: Dictionary = effect["s"]
	for slot: int in _enemies_in(effect["view"]):
		GameAuthority.damage_enemy(slot, float(s.get("quake_damage", 25.0)), player, Vector2.ZERO, "earth", 0.0)
		if GameAuthority.enemies.active[slot] != 0 and not _is_boss(slot):
			GameAuthority.enemies.statuses.apply_stun(slot, float(s.get("stun_s", 1.5)))
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		var view: Rect2 = effect["view"]
		effects.spawn_ring(player.position, view.size.x * 0.5, effect["color"])


## A vertical band sweeping left to right at progress `k`; hits each enemy once.
func _hit_band(effect: Dictionary, player: Player, view: Rect2, k: float, width: float, damage: float, element: String,
		status_chance: float) -> void:
	var x: float = lerpf(view.position.x - width, view.end.x + width, k)
	effect["band_x"] = x
	effect["band_w"] = width
	var hit: Dictionary = effect["hit"]
	for slot: int in _enemies_in(view):
		if not hit.has(slot) and absf(GameAuthority.enemies.positions[slot].x - x) <= width * 0.5:
			hit[slot] = true
			GameAuthority.damage_enemy(slot, damage, player, Vector2.RIGHT * 120.0, element, status_chance)


func _hit_circle(effect: Dictionary, player: Player, center: Vector2, reach: float, damage: float, element: String,
		push: Vector2, status_chance: float) -> void:
	var hit: Dictionary = effect["hit"]
	for slot: int in _enemies_near(center, reach):
		if not hit.has(slot):
			hit[slot] = true
			GameAuthority.damage_enemy(slot, damage, player, push * 120.0, element, status_chance)


func _enemies_near(center: Vector2, reach: float) -> Array[int]:
	var found: Array[int] = []
	var enemies: EnemyManager = GameAuthority.enemies
	for slot: int in enemies.query(center, reach + enemies.max_radius()):
		if enemies.positions[slot].distance_to(center) <= reach + enemies.radius[slot]:
			found.append(slot)
	return found


func _enemies_in(view: Rect2) -> Array[int]:
	var found: Array[int] = []
	var enemies: EnemyManager = GameAuthority.enemies
	for slot: int in enemies.query(view.get_center(), view.size.length() * 0.5):
		if view.has_point(enemies.positions[slot]):
			found.append(slot)
	return found


func _is_boss(slot: int) -> bool:
	return bool(GameAuthority.enemies.type_of(slot).get("boss", false))


func _draw() -> void:
	for effect: Dictionary in _effects:
		var color: Color = effect["color"]
		var fade: float = 1.0 - clampf(float(effect["t"]) / maxf(float(effect["duration"]), 0.01), 0.0, 1.0)
		var view: Rect2 = effect["view"]
		var player: Player = effect["player"]
		match str(effect["kind"]):
			"breath_of_the_desert", "earthshaker":
				if effect.has("band_x"):
					var w: float = float(effect["band_w"])
					draw_rect(Rect2(float(effect["band_x"]) - w * 0.5, view.position.y, w, view.size.y), Color(color, 0.35))
			"hammers_return", "sun_barque":
				if effect.has("at"):
					var reach: float = float((effect["s"] as Dictionary).get("radius_px", 22.0)) * player.stats.area_mult()
					draw_circle(effect["at"], reach, Color(color, 0.5))
			"heart_of_the_greenwood":
				var k: float = 1.0 - fade
				var stags: int = int((effect["s"] as Dictionary).get("stags", 3))
				for i: int in stags:
					var y: float = view.position.y + view.size.y * (i + 1.0) / (stags + 1.0)
					draw_circle(Vector2(lerpf(view.position.x, view.end.x, k), y), 8.0, Color(color, 0.7))
			"winters_hunt", "crow_storm":
				draw_rect(view, Color(color, 0.12 * fade))
			"wheel_of_fortune":
				draw_arc(player.position, 30.0 + 60.0 * (1.0 - fade), 0.0, TAU, 32, Color(color, fade), 3.0)
