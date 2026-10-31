class_name ResonanceLayer
extends SummonLayer
## God summons plus the five launch Resonance summons (GAME_DESIGN.md: Divine
## Resonance and Patronage; Two more launch gods):
##   Sun and Snow        alternating desert-heat and blizzard waves; enemies hit by both explode and are Sundered (−50% Armor, 8 s)
##   Storm Over the Sea  a surge Soaks everything for 6 s while lightning keeps chaining through every Soaked enemy
##   Burning Greenwood   wild blooms spread for 10 s; enemies crossing them Burn and are Poisoned
##   Frozen Deluge       a wave freezes everything in its path for 6 s (frozen enemies take Shatter from physical hits)
##   Eye of Ra           a sun-lioness charges across the screen, Burning and Smiting; every boss's Guard gauge +50%
## Pack 2 (owner approved 10/31/2026):
##   Torch in the Dark   Hecate's torches circle the Hero, burning and Hexing everything they pass
##   The Chosen Slain    weakened monsters on screen fall, and half of them rise to fight for the Hero
##   The Flood and Sun   a flood soaks and sweeps the screen, then sunlight strikes every Soaked monster
##   Thrym's Wedding     the hammer comes down in a ring round the Hero, stunning everything it hits
## Pack 3 (owner approved 10/31/2026):
##   Thunder and Earth   threads bind every monster on screen, then lightning strikes each one bound
##   The Air-Maiden's Prayer  the World Egg's shell round every Hero, while Ukko's strikes fall on the crowds
##   Thunder on the Waves     a surge Soaks the screen, then Ukko's strikes fall on the crowds

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
		"thunder_and_earth":
			for slot: int in _enemies_in(view):
				if not _is_boss(slot):
					GameAuthority.enemies.statuses.apply_stun(slot, float(s.get("bind_s", 2.5)) * duration_mult)
				GameAuthority.damage_enemy(slot, float(s.get("damage", 30.0)), player, Vector2.ZERO, "lightning", 0.5)
		"airmaidens_prayer":
			run({"id": "", "placeholder_color": str(resonance.get("color", "#ffffff")),
					"summon": {"effect": "world_egg", "duration_s": float(s.get("shell_s", 5.0))}}, player)
			run({"id": "", "placeholder_color": str(resonance.get("color", "#ffffff")),
					"summon": {"effect": "thunder_axe", "duration_s": 3.0, "strikes": int(s.get("strikes", 6)),
							"strike_radius_px": 40.0, "damage": float(s.get("damage", 45.0))}}, player)
		"thunder_on_the_waves":
			for slot: int in _enemies_in(view):
				_soak(slot, 6.0 * duration_mult)
			run({"id": "", "placeholder_color": str(resonance.get("color", "#ffffff")),
					"summon": {"effect": "thunder_axe", "duration_s": 3.0, "strikes": int(s.get("strikes", 10)),
							"strike_radius_px": 44.0, "damage": float(s.get("damage", 40.0))}}, player)
		"chosen_slain":
			var rising: int = 0
			for slot: int in _enemies_in(view):
				var enemies: EnemyManager = GameAuthority.enemies
				if _is_boss(slot) or enemies.active[slot] == 0 or enemies.charmed[slot] != 0 \
						or enemies.hp[slot] > enemies.max_hp[slot] * float(s.get("below_hp_fraction", 0.35)):
					continue
				var type_id: String = str(enemies.type_of(slot).get("id", ""))
				var at: Vector2 = enemies.positions[slot]
				GameAuthority.kill_enemy(slot, player)
				rising += 1
				if rising % 2 == 0 and rising <= int(s.get("max_risen", 10)) * 2:
					var risen: int = GameAuthority.spawn_enemy(type_id, at)
					if risen != -1:
						GameAuthority.enemies.charm(risen, float(s.get("risen_s", 10.0)), player)
		"flood_and_sun":
			for slot: int in _enemies_in(view):
				_soak(slot, 6.0 * duration_mult)
				GameAuthority.damage_enemy(slot, float(s.get("damage", 15.0)), player, Vector2.RIGHT * 140.0, "water", 0.0)
		"thryms_wedding":
			var reach: float = float(s.get("ring_radius_px", 90.0)) * player.stats.area_mult()
			for slot: int in _enemies_near(player.position, reach):
				GameAuthority.damage_enemy(slot, float(s.get("damage", 35.0)), player,
						(GameAuthority.enemies.positions[slot] - player.position).normalized() * 160.0, "lightning", 0.5)
				if not _is_boss(slot) and GameAuthority.enemies.active[slot] != 0:
					GameAuthority.enemies.statuses.apply_stun(slot, float(s.get("stun_s", 2.5)) * duration_mult)
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
		"res_torch_in_the_dark":
			effect["tick"] = float(effect["tick"]) - delta
			if float(effect["tick"]) <= 0.0:
				effect["tick"] = float(s.get("tick_s", 0.5))
				for at: Vector2 in torch_positions(effect, player):
					for slot: int in _enemies_near(at, float(s.get("torch_radius_px", 18.0)) * area):
						GameAuthority.damage_enemy(slot, float(s.get("damage", 12.0)), player, Vector2.ZERO, "fire", 0.5)
						if GameAuthority.enemies.active[slot] != 0:
							GameAuthority.enemies.statuses.apply(slot, "hex", player.stats.status_duration_mult())
		"res_flood_and_sun":
			# Halfway through, the sun comes out over the flood and strikes every Soaked monster once.
			if k >= 0.5 and not bool(effect.get("sun", false)):
				effect["sun"] = true
				for slot: int in _enemies_in(view):
					if GameAuthority.enemies.statuses.has(slot, "soaked"):
						GameAuthority.damage_enemy(slot, float(s.get("holy_damage", 35.0)), player, Vector2.ZERO, "holy", 0.5)
		_:
			super._step(effect, player, delta)


## Torch in the Dark: where Hecate's torches are now, circling the Hero.
func torch_positions(effect: Dictionary, player: Player) -> PackedVector2Array:
	var s: Dictionary = effect["s"]
	var out := PackedVector2Array()
	var n: int = int(s.get("torches", 6))
	for i: int in n:
		out.append(player.position + Vector2.from_angle(float(effect["t"]) * 2.2 + TAU * i / n) * float(s.get("ring_radius_px", 70.0)) * player.stats.area_mult())
	return out


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


## Resonances in their two gods' styles (owner request 10/31/2026): Sun and Snow alternates Sekhmet's scorching wind
## with a blizzard; Frozen Deluge is Poseidon's wave frozen white; Storm Over the Sea is driving rain with lightning
## leaping between the soaked; the Eye of Ra is a blazing sun charging across.
func _draw() -> void:
	super._draw()
	for effect: Dictionary in _effects:
		var view: Rect2 = effect["view"]
		var t: float = float(effect["t"])
		var fade: float = 1.0 - clampf(t / maxf(float(effect["duration"]), 0.01), 0.0, 1.0)
		match str(effect["kind"]):
			"res_sun_and_snow":
				if effect.has("band_x"):
					if int(effect["wave"]) % 2 == 0:
						_draw_wind(view, float(effect["band_x"]), float(effect["band_w"]), t)
					else:
						_draw_blizzard(view, float(effect["band_x"]), float(effect["band_w"]), t)
			"res_frozen_deluge":
				if effect.has("band_x"):
					_draw_wave(view, float(effect["band_x"]), float(effect["band_w"]), t)
					_draw_blizzard(view, float(effect["band_x"]), float(effect["band_w"]), t)
			"res_storm_over_the_sea":
				draw_rect(view, Color(Elements.color("water"), 0.12 * fade))
				_draw_rain(view, t, fade)
				_draw_chains(view, t)
			"res_eye_of_ra":
				if effect.has("at"):
					_draw_eye(effect["at"], float((effect["s"] as Dictionary).get("radius_px", 60.0)), t)
			"res_torch_in_the_dark":
				var player: Player = effect["player"]
				if is_instance_valid(player):
					for at: Vector2 in torch_positions(effect, player):
						draw_line(at + Vector2(0, 6), at + Vector2(0, -2), Color(0.45, 0.3, 0.18, fade), 2.0)
						draw_circle(at + Vector2(0, -5), 5.0 + sin(t * 18.0 + at.x) * 1.0, Color(1.0, 0.6, 0.2, 0.85 * fade))
						draw_circle(at + Vector2(0, -6), 2.5, Color(1.0, 0.95, 0.6, fade))
			"res_thunder_and_earth":
				draw_rect(view, Color(0.7, 0.75, 1.0, 0.12 * fade))
				var shown: int = 0
				for slot: int in _enemies_in(view):
					var at: Vector2 = GameAuthority.enemies.positions[slot]
					draw_line(at + Vector2(-4, -90) * fade, at, Color(Elements.color("lightning"), fade), 2.0)
					shown += 1
					if shown >= 30:
						break
			"res_thunder_on_the_waves":
				draw_rect(view, Color(Elements.color("water"), 0.18 * fade))
				_draw_rain(view, t, fade)
			"res_chosen_slain":
				# Ravens and pale light descending over the field.
				draw_rect(view, Color(0.85, 0.8, 0.6, 0.12 * fade))
				for b: int in 10:
					var at := Vector2(lerpf(view.position.x, view.end.x, fmod(b * 0.31 + t * 0.2, 1.0)), view.position.y + view.size.y * (0.1 + 0.08 * b))
					draw_line(at + Vector2(-5, -2), at, Color(0.1, 0.1, 0.12, fade), 2.0)
					draw_line(at, at + Vector2(5, -2), Color(0.1, 0.1, 0.12, fade), 2.0)
			"res_flood_and_sun":
				var k: float = clampf(t / maxf(float(effect["duration"]), 0.01), 0.0, 1.0)
				draw_rect(view, Color(Elements.color("water"), 0.25 * fade))
				_draw_rain(view, t, fade * 0.6)
				if k >= 0.5:
					for r: int in 12:
						var x: float = view.position.x + view.size.x * (r + 0.5) / 12.0
						draw_line(Vector2(x - 30.0, view.position.y), Vector2(x + 30.0, view.end.y), Color(1.0, 0.9, 0.5, 0.35 * fade), 6.0)
			"res_thryms_wedding":
				var player: Player = effect["player"]
				if is_instance_valid(player):
					var reach: float = float((effect["s"] as Dictionary).get("ring_radius_px", 90.0)) * player.stats.area_mult()
					var k: float = clampf(t / maxf(float(effect["duration"]), 0.01), 0.0, 1.0)
					draw_arc(player.position, reach * (0.3 + 0.7 * k), 0.0, TAU, 40, Color(Elements.color("lightning"), fade), 4.0)
					draw_arc(player.position, reach * (0.25 + 0.7 * k), 0.0, TAU, 40, Color(1, 1, 0.9, fade), 1.5)
					var head: Vector2 = player.position + Vector2(0, -60.0 * (1.0 - minf(k * 3.0, 1.0)))
					draw_rect(Rect2(head + Vector2(-8, -5), Vector2(16, 10)), Color(0.6, 0.62, 0.68, fade))
					draw_line(head, head + Vector2(0, 14), Color(0.45, 0.3, 0.18, fade), 3.0)


## A band of driving snow.
func _draw_blizzard(view: Rect2, x: float, width: float, t: float) -> void:
	var ice: Color = Elements.color("ice")
	draw_rect(Rect2(x - width * 0.5, view.position.y, width, view.size.y), Color(ice, 0.3))
	for i: int in 30:
		var y: float = view.position.y + fmod(i * 41.0 + t * 90.0, view.size.y)
		var sx: float = x - width * 0.5 + fmod(i * 29.0 + t * 200.0, width)
		draw_circle(Vector2(sx, y), 1.5, Color(1, 1, 1, 0.9))


## Slanting rain over the whole screen.
func _draw_rain(view: Rect2, t: float, fade: float) -> void:
	for i: int in 40:
		var x: float = view.position.x + fmod(i * 83.0 + t * 60.0, view.size.x)
		var y: float = view.position.y + fmod(i * 47.0 + t * 400.0, view.size.y)
		draw_line(Vector2(x, y), Vector2(x - 3.0, y + 9.0), Color(0.75, 0.85, 1.0, 0.6 * fade), 1.0)


## Lightning leaping between soaked enemies on screen, a few new links each moment.
func _draw_chains(view: Rect2, t: float) -> void:
	var soaked: Array[int] = []
	for slot: int in _enemies_in(view):
		if GameAuthority.enemies.statuses.soaked[slot] > 0.0:
			soaked.append(slot)
			if soaked.size() >= 12:
				break
	var flick: int = int(t * 10.0)
	for i: int in range(1, soaked.size()):
		if (i + flick) % 3 == 0:
			continue
		var a: Vector2 = GameAuthority.enemies.positions[soaked[i - 1]]
		var b: Vector2 = GameAuthority.enemies.positions[soaked[i]]
		var side: Vector2 = (b - a).normalized().orthogonal()
		var points := PackedVector2Array([a, a.lerp(b, 0.33) + side * sin(i + flick) * 5.0,
				a.lerp(b, 0.66) - side * cos(i + flick) * 5.0, b])
		draw_polyline(points, Color(Elements.color("lightning"), 0.6), 3.0)
		draw_polyline(points, Color(1, 1, 0.9), 1.0)


## The Eye of Ra: a blazing sun with flames streaming round it.
func _draw_eye(at: Vector2, radius: float, t: float) -> void:
	var fire: Color = Elements.color("fire")
	draw_circle(at, radius, Color(fire, 0.25))
	for k: int in 12:
		var a: float = TAU * k / 12.0 + t * 2.0
		var r: float = radius * (0.55 + 0.15 * sin(t * 12.0 + k))
		draw_line(at + Vector2.from_angle(a) * radius * 0.3, at + Vector2.from_angle(a) * r, Color(1.0, 0.75, 0.3, 0.85), 3.0)
	draw_circle(at, radius * 0.32, Color(1.0, 0.85, 0.4))
	draw_circle(at, radius * 0.18, Color(1, 1, 0.9))
