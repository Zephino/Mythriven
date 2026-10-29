class_name OmenRules
extends RefCounted
## Omens and Swift Mode (GAME_DESIGN.md: Omens; Swift Mode). Omens are
## challenge modifiers chosen in the Hall of Legends, unlocked after first
## reaching 10:00; they stack, add gold, and records are kept per Omen set.
## Swift Mode is a faster, higher-reward version of a level whose 30:00 boss
## you've beaten. Both are applied to the run and the players here.

const FILE := "omens.json"


static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	return found


static func unlocked() -> bool:
	return not SaveGame.list("omens_unlocked").is_empty()


## The Omens the player turned on (only once Omens are unlocked).
static func active() -> PackedStringArray:
	if not unlocked():
		return PackedStringArray()
	return PackedStringArray(SaveGame.setting("omens_active", []))


static func set_active(omen_id: String, on: bool) -> void:
	var chosen: PackedStringArray = active()
	if on and not chosen.has(omen_id):
		chosen.append(omen_id)
	elif not on and chosen.has(omen_id):
		chosen.remove_at(chosen.find(omen_id))
	SaveGame.set_setting("omens_active", Array(chosen))


## Sets a new run's multipliers from its Omens and Swift Mode.
static func apply_to_run(run: RunState, omens: PackedStringArray, swift: bool) -> void:
	run.omens = omens
	run.swift = swift
	for omen: Dictionary in all():
		if not omens.has(str(omen.get("id", ""))):
			continue
		var effect: Dictionary = omen.get("effect", {})
		run.enemy_speed_mult *= float(effect.get("enemy_speed_mult", 1.0))
		run.spawn_mult *= float(effect.get("spawn_mult", 1.0))
		run.omen_charge_mult *= float(effect.get("god_charge_mult", 1.0))
	if swift:
		run.arc_scale = Data.cfg_float("swift.arc_time_scale")
		run.enemy_speed_mult *= Data.cfg_float("swift.enemy_speed_mult")
		run.spawn_mult *= Data.cfg_float("swift.spawn_mult")
		run.xp_mult *= Data.cfg_float("swift.xp_mult")


## Applies the player-side effects (Omen of Frailty; Swift Mode speed).
static func apply_to_player(player: Player, run: RunState) -> void:
	for omen: Dictionary in all():
		if run.omens.has(str(omen.get("id", ""))):
			var max_hp_pct: float = float((omen.get("effect", {}) as Dictionary).get("max_hp_pct", 0.0))
			if max_hp_pct != 0.0:
				player.stats.add_bonus("max_hp", max_hp_pct / 100.0)
	if run.swift:
		player.stats.add_bonus("move_speed", Data.cfg_float("swift.player_speed_mult") - 1.0)
		player.projectile_speed_mult *= Data.cfg_float("swift.projectile_speed_mult")
	player.refresh_stats()
	player.hp = player.max_hp


## The key records are kept under for this run's Omens ("" with none).
static func set_key(omens: PackedStringArray) -> String:
	var sorted: Array = Array(omens)
	sorted.sort()
	return "+".join(PackedStringArray(sorted))
