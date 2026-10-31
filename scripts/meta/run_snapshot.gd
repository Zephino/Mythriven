class_name RunSnapshot
extends RefCounted
## Taking over a run on another device (owner decisions 10/31/2026, GAME_DESIGN.md: Cloud saves across PC and
## phone): while a solo run is played with cloud saves on, PlayLock sends this snapshot with each beat. Another device
## that opens the game can take the run over: the whole build carries over (level, time, Hero level and XP, weapons,
## passives, stats, gods and their meters, gold, tokens, ropes, the world's used shrines and chests, bosses beaten),
## and the fight that was on screen starts fresh. The old device steps aside without banking anything.
##
## It's a roguelike: there is no saving a run for later. The snapshot only lives with the device's claim to play, so
## leaving a run (or closing the game) still ends it, and only a run still being played can be taken over.

const VERSION := 1


## The local solo run as plain values, or {} when there's nothing that can be taken over (no run, co-op, ended).
static func capture() -> Dictionary:
	var run: RunState = GameAuthority.run
	var player: Player = GameAuthority.local_player()
	if run == null or run.ended or player == null or not player.alive or Net.active() or player.hero.is_empty():
		return {}
	var slots: Array = []
	if GameAuthority.gods != null:
		for slot: Dictionary in GameAuthority.gods.gods_of(player):
			slots.append({"id": str(slot["id"]), "meter": float(slot["meter"]), "mult": float(slot.get("blessing_mult", 1.0))})
	var kit: Dictionary = {}
	if player.kit != null:
		for name: String in ["labor_index", "progress", "completed", "lessons"]:
			if player.kit.get(name) != null:
				kit[name] = player.kit.get(name)
	var bosses: BossManager = GameAuthority.bosses
	var unraveling: Unraveling = bosses.unraveling if bosses != null else null
	return {
		"v": VERSION,
		"hero": str(player.hero.get("id", "")),
		"level_id": str(run.level_data.get("id", "")),
		"seed": run.seed_value,
		"swift": run.swift,
		"omens": Array(run.omens),
		"run": CoopCodec.run_state(run),
		"more": [run.debug_used, run.xp_mult, run.drop_mult_bonus, run.reroll_tokens, run.banish_tokens, run.ropes,
			run.arc_scale, run.enemy_speed_mult, run.spawn_mult, run.omen_charge_mult],
		"banished": Array(run.banished),
		"poi": run.poi_state.duplicate(true),
		"build": CoopCodec.build(player),
		"hp": player.hp,
		"player": [player.revives_used, player.gold_spent, player.gold_mult, player.extra_projectiles,
			player.projectile_speed_mult],
		"flags": player.god_flags.duplicate(true),
		"element": player.element_damage.duplicate(true),
		"gods": slots,
		"kit": kit,
		"beaten": Array(bosses.defeated_indices) if bosses != null else [],
		"unravel_s": run.elapsed_s - unraveling.started_s if unraveling != null and unraveling.active else -1.0,
	}


## True when `snap` is a run this game can rebuild (a known Hero and level, a matching snapshot version).
static func usable(snap: Variant) -> bool:
	return snap is Dictionary and int((snap as Dictionary).get("v", 0)) == VERSION \
			and not HeroRules.find(str(snap.get("hero", ""))).is_empty() \
			and not GameAuthority.find_level(str(snap.get("level_id", ""))).is_empty()


## The question's details: "Heracles, 12:30, Aegean Shore".
static func summary(snap: Dictionary) -> String:
	var hero: String = TranslationServer.translate(str(HeroRules.find(str(snap.get("hero", ""))).get("name_key", "")))
	var level: String = TranslationServer.translate(str(GameAuthority.find_level(str(snap.get("level_id", ""))).get("name_key", "")))
	var run: Array = snap.get("run", [0.0])
	var seconds: int = int(float(run[0]) if not run.is_empty() else 0.0)
	return "%s, %d:%02d, %s" % [hero, seconds / 60, seconds % 60, level]


## Before the run is built: the Hero, level, seed, Swift Mode and Omens to start it with.
static func prepare(snap: Dictionary) -> void:
	GameAuthority.selected_hero_id = str(snap["hero"])
	GameAuthority.next_seed = int(snap.get("seed", 0))
	Meta.level_id = str(snap["level_id"])
	Meta.swift = bool(snap.get("swift", false))
	Meta.takeover = snap


## After the run is built (Main): puts the build, the run's numbers and the world's state back.
static func restore(snap: Dictionary) -> void:
	var run: RunState = GameAuthority.run
	var player: Player = GameAuthority.local_player()
	if run == null or player == null:
		return
	CoopCodec.apply_run_state(run, snap.get("run", []))
	run.boss_arena_active = false
	var more: Array = snap.get("more", [])
	if more.size() >= 10:
		run.debug_used = bool(more[0])
		run.xp_mult = float(more[1])
		run.drop_mult_bonus = float(more[2])
		run.reroll_tokens = int(more[3])
		run.banish_tokens = int(more[4])
		run.ropes = int(more[5])
		run.arc_scale = float(more[6])
		run.enemy_speed_mult = float(more[7])
		run.spawn_mult = float(more[8])
		run.omen_charge_mult = float(more[9])
	run.banished = PackedStringArray(snap.get("banished", []))
	run.poi_state = (snap.get("poi", {}) as Dictionary).duplicate(true)
	# The build: the bonus dict already holds every passive, stat card, Blessing and Omen, so nothing is re-applied.
	for stat: String in player.stats.bonus:
		player.stats.bonus[stat] = 0.0
	CoopCodec.apply_build(player, snap.get("build", []))
	player.god_flags = (snap.get("flags", {}) as Dictionary).duplicate(true)
	player.element_damage = (snap.get("element", {}) as Dictionary).duplicate(true)
	var numbers: Array = snap.get("player", [])
	if numbers.size() >= 5:
		player.revives_used = int(numbers[0])
		player.gold_spent = float(numbers[1])
		player.gold_mult = float(numbers[2])
		player.extra_projectiles = int(numbers[3])
		player.projectile_speed_mult = float(numbers[4])
	player.hp = clampf(float(snap.get("hp", player.max_hp)), 1.0, player.max_hp)
	var gods: GodManager = GameAuthority.gods
	if gods != null:
		var slots: Array = []
		for entry: Variant in snap.get("gods", []):
			var god: Dictionary = GodRules.find(str(entry.get("id", "")))
			if not god.is_empty():
				slots.append({"id": str(entry["id"]), "god": god, "meter": float(entry.get("meter", 0.0)),
					"blessing_mult": float(entry.get("mult", 1.0))})
		gods.set_slots(player, slots)
		gods._refresh_links(player)
	if player.kit != null:
		var kit: Dictionary = snap.get("kit", {})
		for name: String in kit:
			if player.kit.get(name) != null:
				player.kit.set(name, kit[name])
	var bosses: BossManager = GameAuthority.bosses
	if bosses != null:
		bosses.skip_beaten(snap.get("beaten", []))
		var unravel_s: float = float(snap.get("unravel_s", -1.0))
		if unravel_s >= 0.0 and bosses.unraveling != null:
			bosses.unraveling.begin()
			bosses.unraveling.started_s = run.elapsed_s - unravel_s
