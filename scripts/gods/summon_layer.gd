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
##   Three Ways (Hecate)             three crossroads portals open round the Hero and fling enemies away, Hexed
##   Return of Spring (Persephone)   heals, and flowers bloom round the Hero that root the enemies in them
##   Gungnir (Odin)                  his spear never misses: it strikes the strongest enemies on screen, and his ravens
##                                   mark them (they take more damage)
##   Birds of Rhiannon (Rhiannon)    their song puts every monster on screen to sleep (bosses only slowed)
##   Hounds of Annwn (Arawn)         white, red-eared hounds run out and hunt monsters for the Hero, then are gone
##   Waters of the Abzu (Enki)       fresh water floods the screen: heals every Hero, Soaks every monster
##   Thirteen Winds (Shamash)        winds from every side pin every monster on screen and strike them; tear away
##                                   one of Humbaba's radiances
##   Thunder Axe (Ukko)              lightning strikes fall on the thickest crowds on screen, one after another
##   World Egg (Ilmatar)             a shell of light round every Hero stops every enemy shot for 4 s
##   Falcon Cloak (Freyja)           the Hero flies, unharmed, for a moment; monsters slain meanwhile rise to fight for them

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
			"player": player, "god": god, "s": s, "hit": {}, "color": Color.html(str(god.get("placeholder_color", "#ffffff"))),
			"power": GodLevels.summon_power(str(god.get("id", ""))), "ascended": GodLevels.is_ascended(str(god.get("id", "")))}
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
		"gungnir":
			var strongest: Array[int] = []
			for slot: int in _enemies_in(view):
				strongest.append(slot)
			strongest.sort_custom(func(a: int, b: int) -> bool: return GameAuthority.enemies.hp[a] > GameAuthority.enemies.hp[b])
			strongest = strongest.slice(0, mini(int(s.get("strikes", 6)), strongest.size()))
			effect["targets"] = strongest
			effect["struck"] = 0
		"birds_of_rhiannon":
			for slot: int in _enemies_in(view):
				if _is_boss(slot):
					GameAuthority.enemies.statuses.apply(slot, "chill", 1.0, false)
				else:
					GameAuthority.enemies.statuses.apply_stun(slot, float(s.get("sleep_s", 3.0)) * player.stats.status_duration_mult())
		"waters_of_abzu":
			for each: Player in GameAuthority.players:
				if each.alive:
					GameAuthority.heal_player(each, each.max_hp * float(s.get("heal_pct", 30)) / 100.0)
					each.statuses.timers.erase("burn")
			for slot: int in _enemies_in(view):
				GameAuthority.enemies.statuses.apply(slot, "soaked", player.stats.status_duration_mult(), false)
		"thirteen_winds":
			for slot: int in _enemies_in(view):
				GameAuthority.damage_enemy(slot, float(s.get("damage", 20.0)) * float(effect["power"]), player, Vector2.ZERO, "wind", 0.0)
				if _is_boss(slot):
					GameAuthority.enemies.statuses.apply(slot, "chill", 1.0, false)
				elif GameAuthority.enemies.active[slot] != 0:
					GameAuthority.enemies.statuses.apply_stun(slot, float(s.get("pin_s", 4.0)) * player.stats.status_duration_mult())
			for boss: Node in get_tree().get_nodes_in_group(BossController.GROUP):
				if boss is HumbabaBoss:
					(boss as HumbabaBoss).strip_radiance()
		"world_egg":
			for each: Player in GameAuthority.players:
				if each.alive:
					each.shot_shield_s = maxf(each.shot_shield_s, float(s.get("duration_s", 4.0)))
		"thunder_axe":
			effect["strikes_left"] = int(s.get("strikes", 8))
			effect["tick"] = 0.0
			effect["bolts"] = []
		"hounds_of_annwn":
			var hounds: Array = []
			for k: int in int(s.get("hounds", 5)):
				var hound: int = GameAuthority.spawn_enemy("hound_of_annwn", player.position + Vector2.from_angle(TAU * k / 5.0) * 24.0)
				if hound != -1:
					GameAuthority.enemies.charm(hound, float(s.get("duration_s", 8.0)) + 1.0, player)
					hounds.append(hound)
			effect["hounds"] = hounds
		"falcon_cloak":
			player.invulnerable_s = maxf(player.invulnerable_s, float(s.get("invulnerable_s", 3.0)))
			effect["risen"] = 0
			if not GameAuthority.enemy_killed.is_connected(_on_falcon_kill):
				GameAuthority.enemy_killed.connect(_on_falcon_kill)
		"three_ways":
			# The three ways meet at the Hero: a portal on each road, 120 degrees apart.
			var portals := PackedVector2Array()
			var start: float = GameAuthority.run.rng.combat.randf() * TAU
			for k: int in 3:
				portals.append(player.position + Vector2.from_angle(start + TAU * k / 3.0) * view.size.x * float(s.get("distance_screens", 0.18)))
			effect["portals"] = portals
		"return_of_spring":
			GameAuthority.heal_player(player, player.max_hp * float(s.get("heal_pct", 50)) / 100.0)
			var blooms := PackedVector2Array()
			var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
			for k: int in int(s.get("blooms", 7)):
				blooms.append(player.position + Vector2.from_angle(TAU * k / float(s.get("blooms", 7)) + rng.randf() * 0.4)
						* rng.randf_range(40.0, float(s.get("spread_px", 150.0))) * area)
			effect["blooms"] = blooms
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
		"thunder_axe":
			# Ukko's strikes fall one after another on whichever crowd on screen is thickest.
			effect["tick"] = float(effect["tick"]) - delta
			if float(effect["tick"]) <= 0.0 and int(effect["strikes_left"]) > 0:
				effect["tick"] = float(effect["duration"]) / maxf(float(s.get("strikes", 8)), 1.0)
				effect["strikes_left"] = int(effect["strikes_left"]) - 1
				var at: Vector2 = _densest(view, float(s.get("strike_radius_px", 40.0)) * area)
				if at != Vector2.INF:
					(effect["bolts"] as Array).append(at)
					if (effect["bolts"] as Array).size() > 4:
						(effect["bolts"] as Array).pop_front()
					_hit_circle(effect, player, at, float(s.get("strike_radius_px", 40.0)) * area, float(s.get("damage", 45.0)), "lightning", Vector2.ZERO, 0.5)
					(effect["hit"] as Dictionary).clear()
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
				GameAuthority.damage_enemy(slot, float(s.get("arrow_damage", 15.0)) * float(effect["power"]), player, Vector2.ZERO, "ice", 0.0)
		"breath_of_the_desert":
			_hit_band(effect, player, view, k, view.size.x * 0.12 * area, float(s.get("damage", 25.0)), "fire", 0.0)
			for slot: Variant in (effect["hit"] as Dictionary).keys():
				if GameAuthority.enemies.active[int(slot)] != 0:
					var st: EnemyStatuses = GameAuthority.enemies.statuses
					st.burn[int(slot)] = maxf(st.burn[int(slot)], float(s.get("burn_s", 4.0)) * player.stats.status_duration_mult())
		"earthshaker":
			_hit_band(effect, player, view, minf(k * 1.5, 1.0), view.size.x * 0.1 * area, float(s.get("wave_damage", 30.0)), "water", 1.0)
		"gungnir":
			# One strike after another across the summon, each landing on its target wherever it has moved to.
			var targets: Array = effect["targets"]
			var due: int = mini(int(k * targets.size()) + 1, targets.size())
			while int(effect["struck"]) < due:
				var slot: int = int(targets[int(effect["struck"])])
				effect["struck"] = int(effect["struck"]) + 1
				if GameAuthority.enemies.active[slot] == 0:
					continue
				effect["last_at"] = GameAuthority.enemies.positions[slot]
				GameAuthority.damage_enemy(slot, float(s.get("damage", 90.0)) * float(effect["power"]), player, Vector2.ZERO, "wind", 1.0)
				if GameAuthority.enemies.active[slot] != 0:
					GameAuthority.enemies.statuses.apply_fated(slot, float(s.get("fated_s", 6.0)), float(s.get("fated_damage_taken", 0.5)))
		"three_ways":
			for portal: Vector2 in effect["portals"]:
				for slot: int in _enemies_near(portal, float(s.get("radius_px", 46.0)) * area):
					var hit: Dictionary = effect["hit"]
					if hit.has(slot) or _is_boss(slot):
						continue
					hit[slot] = true
					var away: Vector2 = (GameAuthority.enemies.positions[slot] - player.position).normalized()
					GameAuthority.damage_enemy(slot, float(s.get("damage", 30.0)) * float(effect["power"]), player,
							away * float(s.get("fling_px", 900.0)), "dark", 1.0)
					if GameAuthority.enemies.active[slot] != 0:
						GameAuthority.enemies.statuses.apply(slot, "hex", player.stats.status_duration_mult())
		"return_of_spring":
			for bloom: Vector2 in effect["blooms"]:
				for slot: int in _enemies_near(bloom, float(s.get("bloom_radius_px", 26.0)) * area * minf(k * 4.0, 1.0)):
					if not _is_boss(slot):
						GameAuthority.enemies.statuses.apply_stun(slot, 0.3)
		"sun_barque":
			var center := Vector2(lerpf(view.position.x, view.end.x, k), view.get_center().y + sin(k * PI) * -view.size.y * 0.2)
			effect["at"] = center
			_hit_circle(effect, player, center, float(s.get("radius_px", 70.0)) * area, float(s.get("damage", 45.0)), "holy",
					Vector2.ZERO, 1.0)


## Freyja's cloak: while it lasts, each monster its Hero slays rises again to fight for them (Freyja takes half the
## slain, Grimnismal 14).
func _on_falcon_kill(_slot: int, enemy_type: Dictionary, at: Vector2, killer: Player) -> void:
	for effect: Dictionary in _effects:
		if str(effect["kind"]) != "falcon_cloak" or effect["player"] != killer or bool(enemy_type.get("boss", false)):
			continue
		var s: Dictionary = effect["s"]
		if int(effect["risen"]) >= int(s.get("max_risen", 8)):
			return
		var risen: int = GameAuthority.spawn_enemy(str(enemy_type.get("id", "")), at)
		if risen != -1:
			effect["risen"] = int(effect["risen"]) + 1
			GameAuthority.enemies.charm(risen, float(s.get("risen_s", 6.0)), killer)
		return


func _finish(effect: Dictionary, player: Player) -> void:
	if str(effect["kind"]) == "hounds_of_annwn":
		# The hounds go back to Annwn.
		for hound: Variant in effect.get("hounds", []):
			var slot: int = int(hound)
			if GameAuthority.enemies.active[slot] != 0 and str(GameAuthority.enemies.type_of(slot).get("id", "")) == "hound_of_annwn":
				GameAuthority.enemies.remove_quietly(slot)
		return
	if str(effect["kind"]) != "earthshaker":
		return
	var s: Dictionary = effect["s"]
	for slot: int in _enemies_in(effect["view"]):
		GameAuthority.damage_enemy(slot, float(s.get("quake_damage", 25.0)) * float(effect["power"]), player, Vector2.ZERO, "earth", 0.0)
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
			GameAuthority.damage_enemy(slot, damage * float(effect["power"]), player, Vector2.RIGHT * 120.0, element, status_chance)


func _hit_circle(effect: Dictionary, player: Player, center: Vector2, reach: float, damage: float, element: String,
		push: Vector2, status_chance: float) -> void:
	var hit: Dictionary = effect["hit"]
	for slot: int in _enemies_near(center, reach):
		if not hit.has(slot):
			hit[slot] = true
			GameAuthority.damage_enemy(slot, damage * float(effect["power"]), player, push * 120.0, element, status_chance)


## The middle of the thickest crowd of monsters on screen (sampled), or Vector2.INF when the screen is empty.
func _densest(view: Rect2, reach: float) -> Vector2:
	var on_screen: Array[int] = _enemies_in(view)
	if on_screen.is_empty():
		return Vector2.INF
	var best := Vector2.INF
	var best_count: int = -1
	for k: int in mini(on_screen.size(), 16):
		var at: Vector2 = GameAuthority.enemies.positions[on_screen[(k * 7919) % on_screen.size()]]
		var count: int = _enemies_near(at, reach).size()
		if count > best_count:
			best_count = count
			best = at
	return best


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


## Each summon in its god's style (owner request 10/31/2026), pictures in data/art/summons/: Tyche's wheel turning
## round the Hero, Cernunnos' stags galloping across, Thor's hammer spinning out and back with lightning, Skadi's ice
## arrows raining down, Sekhmet's scorching wind, Poseidon's wave with its foaming crest, Ra's sun barque sailing
## over, and the Morrígan's crows sweeping across.
func _draw() -> void:
	for effect: Dictionary in _effects:
		var color: Color = effect["color"]
		var t: float = float(effect["t"])
		var k: float = clampf(t / maxf(float(effect["duration"]), 0.01), 0.0, 1.0)
		var fade: float = 1.0 - k
		var view: Rect2 = effect["view"]
		var player: Player = effect["player"]
		match str(effect["kind"]):
			"breath_of_the_desert":
				if effect.has("band_x"):
					_draw_wind(view, float(effect["band_x"]), float(effect["band_w"]), t)
			"earthshaker":
				if effect.has("band_x"):
					_draw_wave(view, float(effect["band_x"]), float(effect["band_w"]), t)
			"hammers_return":
				if effect.has("at"):
					var reach: float = float((effect["s"] as Dictionary).get("radius_px", 22.0)) * player.stats.area_mult()
					draw_circle(effect["at"], reach, Color(Elements.color("lightning"), 0.18))
					_draw_bolt_to(player.position, effect["at"], t)
					_draw_picture("hammer", effect["at"], t * 14.0, 1.5, false, 0.0)
			"sun_barque":
				if effect.has("at"):
					var reach: float = float((effect["s"] as Dictionary).get("radius_px", 70.0)) * player.stats.area_mult()
					draw_circle(effect["at"], reach, Color(Elements.color("holy"), 0.22))
					draw_circle(effect["at"], reach * 0.6, Color(Elements.color("holy"), 0.18))
					_draw_picture("sun_barque", effect["at"], 0.0, 2.0, false, 0.0)
			"heart_of_the_greenwood":
				draw_arc(player.position, 18.0 + 10.0 * sin(t * 6.0), 0.0, TAU, 24, Color(Elements.color("earth").lightened(0.4), fade), 2.0)
				var stags: int = int((effect["s"] as Dictionary).get("stags", 3))
				for i: int in stags:
					var y: float = view.position.y + view.size.y * (i + 1.0) / (stags + 1.0)
					_draw_picture("stag", Vector2(lerpf(view.position.x, view.end.x, k), y), 0.0, 1.5, true, t * 60.0)
			"winters_hunt":
				draw_rect(view, Color(Elements.color("ice"), 0.14 * fade))
				_draw_arrows(view, t, fade)
			"crow_storm":
				draw_rect(view, Color(Elements.color("dark"), 0.12 * fade))
				_draw_crows(view, k, t)
				for slot: Variant in effect.get("marked", []):
					if GameAuthority.enemies.active[int(slot)] != 0:
						var at: Vector2 = GameAuthority.enemies.positions[int(slot)]
						draw_arc(at, GameAuthority.enemies.radius[int(slot)] + 5.0, t * 3.0, t * 3.0 + PI * 1.5, 12,
								Color(Elements.color("dark"), fade), 2.0)
			"wheel_of_fortune":
				_draw_wheel(player.position, 26.0 + 50.0 * k, t * 4.0, fade, color)
			"gungnir":
				if effect.has("last_at"):
					var at: Vector2 = effect["last_at"]
					draw_line(at + Vector2(-40, -120) * fade, at, Color(Elements.color("wind").lightened(0.4), fade), 3.0)
					draw_line(at + Vector2(-40, -120) * fade, at, Color(1, 1, 1, fade), 1.0)
					draw_circle(at, 6.0 * fade + 2.0, Color(1, 1, 0.9, 0.6 * fade))
				for slot: Variant in effect.get("targets", []):
					if GameAuthority.enemies.active[int(slot)] != 0:
						var mark: Vector2 = GameAuthority.enemies.positions[int(slot)] + Vector2(0, -GameAuthority.enemies.radius[int(slot)] - 8.0)
						draw_circle(mark, 2.5, Color(0.1, 0.1, 0.12, fade))
						draw_line(mark + Vector2(-4, -1), mark + Vector2(4, -1), Color(0.1, 0.1, 0.12, fade), 1.5)
			"waters_of_abzu":
				draw_rect(view, Color(0.25, 0.55, 0.85, 0.22 * fade))
				for r: int in 9:
					var at: Vector2 = Vector2(lerpf(view.position.x, view.end.x, fmod(r * 0.37, 1.0)), lerpf(view.position.y, view.end.y, fmod(r * 0.61, 1.0)))
					draw_arc(at, 10.0 + 40.0 * k, 0.0, TAU, 20, Color(0.85, 0.95, 1.0, 0.6 * fade), 1.5)
			"thirteen_winds":
				var mid: Vector2 = view.get_center()
				for w: int in 13:
					var from: Vector2 = mid + Vector2.from_angle(TAU * w / 13.0) * view.size.length() * 0.5
					var to: Vector2 = from.lerp(mid, clampf(k * 1.4, 0.0, 1.0))
					draw_line(from, to, Color(1.0, 0.92, 0.6, 0.7 * fade), 2.0)
					draw_line(from.lerp(to, 0.5) + Vector2(0, 4), to + Vector2(0, 4), Color(1, 1, 1, 0.4 * fade), 1.0)
			"world_egg":
				for each: Player in GameAuthority.players:
					if each.alive and each.shot_shield_s > 0.0:
						draw_set_transform(each.position + Vector2(0, -12), 0.0, Vector2(0.8, 1.0))
						draw_circle(Vector2.ZERO, 22.0, Color(0.95, 0.97, 1.0, 0.18 * fade + 0.08))
						draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 32, Color(1.0, 0.95, 0.7, 0.8), 2.0)
						draw_set_transform(Vector2.ZERO)
			"thunder_axe":
				for bolt: Variant in effect.get("bolts", []):
					var at: Vector2 = bolt
					draw_line(at + Vector2(-10, -140), at + Vector2(6, -70), Color(Elements.color("lightning"), fade), 3.0)
					draw_line(at + Vector2(6, -70), at, Color(Elements.color("lightning"), fade), 3.0)
					draw_circle(at, 10.0 * fade + 4.0, Color(1, 1, 0.85, 0.5 * fade))
			"birds_of_rhiannon":
				for b: int in 7:
					var fly: Vector2 = Vector2(lerpf(view.position.x, view.end.x, fmod(k + b * 0.14, 1.0)),
							view.position.y + view.size.y * (0.2 + 0.1 * b) + sin(t * 6.0 + b) * 6.0)
					draw_line(fly + Vector2(-4, -2), fly, Color(0.95, 0.9, 0.6, fade), 1.5)
					draw_line(fly, fly + Vector2(4, -2), Color(0.95, 0.9, 0.6, fade), 1.5)
				draw_rect(view, Color(0.2, 0.25, 0.4, 0.12 * fade))
			"falcon_cloak":
				for i: int in 6:
					var a: float = t * 5.0 + i * TAU / 6.0
					draw_line(player.position + Vector2.from_angle(a) * 14.0, player.position + Vector2.from_angle(a + 0.4) * 22.0,
							Color(0.85, 0.7, 0.5, fade), 2.0)
				draw_arc(player.position, 20.0, 0.0, TAU, 24, Color(Elements.color("holy"), 0.6 * fade), 2.0)
			"three_ways":
				var reach3: float = float((effect["s"] as Dictionary).get("radius_px", 46.0)) * player.stats.area_mult()
				for portal: Vector2 in effect["portals"]:
					draw_line(player.position, portal, Color(Elements.color("dark").lightened(0.3), 0.35 * fade), 2.0)
					_draw_portal(portal, reach3 * minf(k * 5.0, 1.0), t, fade)
			"return_of_spring":
				var reach_b: float = float((effect["s"] as Dictionary).get("bloom_radius_px", 26.0)) * player.stats.area_mult()
				draw_arc(player.position, 18.0 + 30.0 * k, 0.0, TAU, 24, Color(0.6, 0.95, 0.6, fade), 2.0)
				for i: int in (effect["blooms"] as PackedVector2Array).size():
					_draw_bloom(effect["blooms"][i], reach_b * minf(k * 4.0, 1.0), i, fade)


## Hecate's crossroads portal: a dark swirl ringed by violet light, with her torch flames burning round it.
func _draw_portal(at: Vector2, reach: float, t: float, fade: float) -> void:
	var dark: Color = Elements.color("dark")
	draw_circle(at, reach, Color(0.05, 0.02, 0.08, 0.6 * fade))
	for ring: int in 3:
		var spin: float = t * (3.0 + ring) + ring * 2.0
		draw_arc(at, reach * (0.4 + 0.25 * ring), spin, spin + PI * 1.3, 16, Color(dark.lightened(0.4), 0.8 * fade), 2.0)
	for k: int in 3:
		var torch: Vector2 = at + Vector2.from_angle(TAU * k / 3.0 + t) * reach
		draw_circle(torch, 3.0 + sin(t * 12.0 + k), Color(1.0, 0.7, 0.3, fade))
		draw_circle(torch + Vector2(0, -2), 1.6, Color(1.0, 0.95, 0.7, fade))


## Persephone's flowers: a ring of pink and white petals opening on the ground, a green heart in the middle.
func _draw_bloom(at: Vector2, reach: float, seed: int, fade: float) -> void:
	if reach <= 0.5:
		return
	draw_circle(at, reach, Color(0.35, 0.55, 0.3, 0.25 * fade))
	for p: int in 7:
		var petal: Vector2 = at + Vector2.from_angle(TAU * p / 7.0 + seed) * reach * 0.55
		draw_circle(petal, reach * 0.28, Color(0.95, 0.7, 0.8, 0.85 * fade) if (p + seed) % 2 == 0 else Color(0.98, 0.95, 0.92, 0.85 * fade))
	draw_circle(at, reach * 0.22, Color(0.95, 0.85, 0.35, fade))


## A summon picture at `at`, turned by `angle`, scaled; `moving` runs its walk frames by `stride`.
func _draw_picture(name: String, at: Vector2, angle: float, scale: float, moving: bool, stride: float) -> void:
	var art: Dictionary = PixelArt.find("summons/" + name)
	if art.is_empty():
		draw_circle(at, 8.0 * scale, Color.WHITE)
		return
	var texture: ImageTexture = PixelArt.frame(art, moving, stride)
	draw_set_transform(at, angle, Vector2(scale, scale))
	draw_texture(texture, -texture.get_size() * 0.5)
	draw_set_transform(Vector2.ZERO)


## Sekhmet's breath: a wall of scorching wind, sand streaking through it and embers on its front.
func _draw_wind(view: Rect2, x: float, width: float, t: float) -> void:
	var fire: Color = Elements.color("fire")
	draw_rect(Rect2(x - width * 0.5, view.position.y, width, view.size.y), Color(fire, 0.22))
	draw_rect(Rect2(x, view.position.y, width * 0.5, view.size.y), Color(fire.lightened(0.3), 0.18))
	for i: int in 26:
		var y: float = view.position.y + fmod(i * 37.0, view.size.y)
		var sx: float = x - width * 0.5 + fmod(i * 53.0 + t * 300.0, width)
		draw_line(Vector2(sx, y), Vector2(sx + 14.0, y + sin(i + t * 5.0) * 2.0), Color(0.95, 0.8, 0.5, 0.6), 1.0)
	for i: int in 14:
		var y: float = view.position.y + fmod(i * 61.0 + t * 40.0, view.size.y)
		draw_circle(Vector2(x + width * 0.5 - fmod(i * 7.0, 10.0), y), 1.5, Color(1.0, 0.85, 0.4, 0.9))


## Poseidon's wave: deep water behind, a foaming crest at its front.
func _draw_wave(view: Rect2, x: float, width: float, t: float) -> void:
	var water: Color = Elements.color("water")
	draw_rect(Rect2(x - width * 0.5, view.position.y, width, view.size.y), Color(water, 0.35))
	draw_rect(Rect2(x, view.position.y, width * 0.5, view.size.y), Color(water.lightened(0.3), 0.3))
	var front := x + width * 0.5
	var y: float = view.position.y
	while y < view.end.y:
		var bulge: float = 5.0 + 3.0 * sin(y * 0.08 + t * 8.0)
		draw_circle(Vector2(front, y), bulge, Color(0.92, 0.97, 1.0, 0.85))
		y += 9.0


## Thor's lightning crackling from the Hero to the hammer.
func _draw_bolt_to(from: Vector2, to: Vector2, t: float) -> void:
	var points := PackedVector2Array([from])
	var side: Vector2 = (to - from).normalized().orthogonal()
	for s: int in range(1, 6):
		points.append(from.lerp(to, s / 6.0) + side * sin(s * 2.7 + t * 30.0) * 6.0)
	points.append(to)
	draw_polyline(points, Color(Elements.color("lightning"), 0.5), 3.0)
	draw_polyline(points, Color(1, 1, 0.9, 0.9), 1.0)


## Skadi's ice arrows falling across the screen, each landing in a flash.
func _draw_arrows(view: Rect2, t: float, fade: float) -> void:
	var ice: Color = Elements.color("ice")
	for i: int in 24:
		var fall: float = fmod(t * 1.6 + i * 0.137, 1.0)
		var x: float = view.position.x + fmod(i * 97.0, view.size.x)
		var land: float = view.position.y + fmod(i * 61.0 + 40.0, view.size.y)
		var at := Vector2(x + 40.0 * (1.0 - fall), lerpf(land - 120.0, land, fall))
		var dir := Vector2(-0.3, 1.0).normalized()
		draw_line(at - dir * 12.0, at, Color(ice, fade), 2.0)
		draw_line(at - dir * 4.0, at, Color(1, 1, 1, fade), 2.0)
		if fall > 0.85:
			draw_circle(Vector2(x, land), 4.0 * (fall - 0.85) / 0.15 + 1.0, Color(ice, fade * 0.7))


## The Morrígan's crows sweeping across the screen in a ragged flock.
func _draw_crows(view: Rect2, k: float, t: float) -> void:
	for i: int in 14:
		var row: float = fmod(i * 0.37, 1.0)
		var x: float = lerpf(view.position.x - 60.0, view.end.x + 60.0, clampf(k * 1.3 - fmod(i * 0.21, 0.3), 0.0, 1.0))
		var y: float = view.position.y + view.size.y * (0.1 + 0.8 * row) + sin(t * 4.0 + i) * 6.0
		_draw_picture("crow", Vector2(x, y), 0.0, 1.0 + fmod(i * 0.13, 0.5), true, t * 40.0 + i * 3.0)


## Tyche's wheel turning round the Hero as it grows, coins flying off its rim.
func _draw_wheel(at: Vector2, radius: float, turn: float, fade: float, color: Color) -> void:
	var gold := Color(color, fade)
	draw_arc(at, radius, 0.0, TAU, 32, gold, 3.0)
	draw_arc(at, radius * 0.25, 0.0, TAU, 12, gold, 2.0)
	for s: int in 8:
		var d: Vector2 = Vector2.from_angle(turn + TAU * s / 8.0)
		draw_line(at + d * radius * 0.25, at + d * radius, Color(gold, gold.a * 0.8), 1.5)
		draw_circle(at + d * (radius + 6.0 + (1.0 - fade) * 20.0), 2.0, Color(1.0, 0.85, 0.3, fade))
