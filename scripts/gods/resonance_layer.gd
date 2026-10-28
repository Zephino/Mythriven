class_name ResonanceLayer
extends SummonLayer
## God summons plus the five launch Resonance summons (GAME_DESIGN.md: Divine
## Resonance and Patronage; Two more launch gods):
##   Sun and Snow        alternating desert-heat and blizzard waves; enemies hit by both explode and are Sundered (−50% Armor, 8 s)
##   Storm Over the Sea  a surge Soaks everything for 6 s while lightning keeps chaining through every Soaked enemy
##   Burning Greenwood   wild blooms spread for 10 s; enemies crossing them Burn and are Poisoned
##   Frozen Deluge       a wave freezes everything in its path for 6 s (frozen enemies take Shatter from physical hits)
##   Eye of Ra           a sun-lioness charges across the screen, Burning and Smiting; every boss's Guard gauge +50%

var ground: GroundEffects


## Starts a Resonance summon for `player` (`resonance` from resonances.json).
func run_resonance(resonance: Dictionary, player: Player) -> void:
	var s: Dictionary = resonance.get("summon", {})
	var view: Rect2 = visible_rect()
	var effect: Dictionary = {"kind": "res_" + str(s.get("effect", "")), "t": 0.0, "duration": float(s.get("duration_s", 3.0)),
			"player": player, "god": {}, "s": s, "hit": {}, "color": Color.html(str(resonance.get("color", "#ffffff"))),
			"view": view, "marks": {}, "wave": -1, "tick": 0.0}
	var duration_mult: float = player.stats.status_duration_mult()
	match str(s.get("effect", "")):
		"storm_over_the_sea":
			for slot: int in _enemies_in(view):
				_soak(slot, float(s.get("soak_s", 6.0)) * duration_mult)
		"burning_greenwood":
			if ground != null:
				var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
				for _k: int in int(s.get("blooms", 8)):
					var at := Vector2(rng.randf_range(view.position.x, view.end.x), rng.randf_range(view.position.y, view.end.y))
					var reach: float = float(s.get("bloom_radius_px", 30.0)) * player.stats.area_mult()
					ground.add(at, reach, float(s.get("duration_s", 10.0)), float(s.get("bloom_dps", 10.0)) * 0.5, "fire", player)
					ground.add(at, reach, float(s.get("duration_s", 10.0)), float(s.get("bloom_dps", 10.0)) * 0.5, "earth", player)
		"eye_of_ra":
			get_tree().call_group("bosses", "add_guard_fraction", float(s.get("guard_fill", 0.5)))
	if _effects.size() >= MAX_EFFECTS:
		_effects.pop_front()
	_effects.append(effect)


func _step(effect: Dictionary, player: Player, delta: float) -> void:
	var s: Dictionary = effect["s"]
	var k: float = clampf(float(effect["t"]) / maxf(float(effect["duration"]), 0.01), 0.0, 1.0)
	var view: Rect2 = effect["view"]
	var area: float = player.stats.area_mult()
	match str(effect["kind"]):
		"res_sun_and_snow":
			var waves: int = int(s.get("waves", 4))
			var wave: int = mini(int(k * waves), waves - 1)
			if wave != int(effect["wave"]):
				effect["wave"] = wave
				(effect["hit"] as Dictionary).clear()
			var local_k: float = k * waves - wave
			var element: String = "fire" if wave % 2 == 0 else "ice"
			effect["color"] = Elements.color(element)
			_hit_band(effect, player, view, local_k, view.size.x * 0.12 * area, float(s.get("damage", 20.0)), element, 1.0)
			_mark_both(effect, player, element)
		"res_storm_over_the_sea":
			effect["tick"] = float(effect["tick"]) - delta
			if float(effect["tick"]) <= 0.0:
				effect["tick"] = float(s.get("chain_interval_s", 0.5))
				for slot: int in _enemies_in(view):
					if GameAuthority.enemies.statuses.has(slot, "soaked"):
						GameAuthority.damage_enemy(slot, float(s.get("damage", 14.0)), player, Vector2.ZERO, "lightning", 0.2)
		"res_frozen_deluge":
			var before: Dictionary = (effect["hit"] as Dictionary).duplicate()
			_hit_band(effect, player, view, k, view.size.x * 0.15 * area, float(s.get("damage", 15.0)), "ice", 0.0)
			for slot: Variant in (effect["hit"] as Dictionary).keys():
				var index: int = int(slot)
				if before.has(slot) or GameAuthority.enemies.active[index] == 0:
					continue
				if _is_boss(index):
					GameAuthority.enemies.statuses.apply(index, "chill", 1.0, false)
				else:
					GameAuthority.enemies.statuses.freeze(index, float(s.get("freeze_s", 6.0)) * player.stats.status_duration_mult())
		"res_eye_of_ra":
			var center := Vector2(lerpf(view.position.x, view.end.x, k), view.get_center().y)
			effect["at"] = center
			var before: Dictionary = (effect["hit"] as Dictionary).duplicate()
			_hit_circle(effect, player, center, float(s.get("radius_px", 60.0)) * area, float(s.get("damage", 40.0)), "fire", Vector2.RIGHT, 1.0)
			for slot: Variant in (effect["hit"] as Dictionary).keys():
				if not before.has(slot) and GameAuthority.enemies.active[int(slot)] != 0:
					GameAuthority.enemies.statuses.apply(int(slot), "smite", player.stats.status_duration_mult())
		_:
			super._step(effect, player, delta)


## Sun and Snow: an enemy hit by both the heat and the cold explodes and is Sundered.
func _mark_both(effect: Dictionary, player: Player, element: String) -> void:
	var s: Dictionary = effect["s"]
	var marks: Dictionary = effect["marks"]
	var bit: int = 1 if element == "fire" else 2
	for slot: Variant in (effect["hit"] as Dictionary).keys():
		var mask: int = int(marks.get(slot, 0))
		if mask & bit != 0:
			continue
		mask |= bit
		marks[slot] = mask
		var index: int = int(slot)
		if mask == 3 and GameAuthority.enemies.active[index] != 0:
			var at: Vector2 = GameAuthority.enemies.positions[index]
			GameAuthority.enemies.statuses.apply_sunder(index, float(s.get("sunder_s", 8.0)), float(s.get("sunder_armor_mult", 0.5)))
			for other: int in _enemies_near(at, float(s.get("explode_radius_px", 28.0)) * player.stats.area_mult()):
				GameAuthority.damage_enemy(other, float(s.get("explode_damage", 25.0)), player, Vector2.ZERO, "physical", 0.0)
			var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
			if effects != null:
				effects.spawn_ring(at, float(s.get("explode_radius_px", 28.0)), Color.WHITE)


func _soak(slot: int, seconds: float) -> void:
	var st: EnemyStatuses = GameAuthority.enemies.statuses
	st.soaked[slot] = maxf(st.soaked[slot], seconds)


func _draw() -> void:
	super._draw()
	for effect: Dictionary in _effects:
		var color: Color = effect["color"]
		var view: Rect2 = effect["view"]
		match str(effect["kind"]):
			"res_sun_and_snow", "res_frozen_deluge":
				if effect.has("band_x"):
					var w: float = float(effect["band_w"])
					draw_rect(Rect2(float(effect["band_x"]) - w * 0.5, view.position.y, w, view.size.y), Color(color, 0.35))
			"res_storm_over_the_sea":
				draw_rect(view, Color(color, 0.1))
			"res_eye_of_ra":
				if effect.has("at"):
					draw_circle(effect["at"], float((effect["s"] as Dictionary).get("radius_px", 60.0)), Color(color, 0.5))
