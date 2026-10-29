class_name DeathRecap
extends RefCounted
## The results screen's recap (GAME_DESIGN.md: Death recap; Screens /
## Results): what felled you (with its element) and what dealt the most damage
## in the last 10 seconds; your build (weapons with levels, evolutions, and
## infusions; passives; gods and their levels; Resonances used; your top
## weapon's share of damage); progress (time, milestones, Labors, kills, level,
## gold banked, personal best); new unlocks; and one tip.

const ENEMIES_FILE := "enemies.json"


## Returns {"lines": PackedStringArray, "tip": String}.
static func build(run: RunState, player: Player, tracker: RunTracker, banked: int, best_before: float) -> Dictionary:
	var lines: PackedStringArray = []
	var killer: String = player.cause_of_death if player != null else ""
	if killer != "":
		lines.append(_tr("RECAP_FELLED_BY") % describe_source(killer))
		var recent: String = tracker.top_recent_source(run.elapsed_s)
		if recent != "" and recent != killer:
			lines.append(_tr("RECAP_MOST_DAMAGE") % describe_source(recent))
	var elements: PackedStringArray = []
	if player != null:
		var weapons: PackedStringArray = []
		for weapon: WeaponInstance in player.weapons:
			weapons.append(_tr("RECAP_ITEM") % [_tr(weapon.name_key()), weapon.level])
			if not elements.has(weapon.element()):
				elements.append(weapon.element())
		lines.append(_tr("UI_LB_WEAPONS") % (", ".join(weapons) if not weapons.is_empty() else _tr("UI_LB_NONE")))
		var passives: PackedStringArray = []
		for passive_id: String in player.passives:
			passives.append(_tr("RECAP_ITEM") % [_tr(str(LevelUpRules.passive_data(passive_id).get("name_key", passive_id))), int(player.passives[passive_id])])
		lines.append(_tr("UI_LB_UPGRADES") % (", ".join(passives) if not passives.is_empty() else _tr("UI_LB_NONE")))
		elements.append_array(player.god_elements)
	var gods: PackedStringArray = []
	for god_id: String in tracker.gods_bound:
		gods.append(_tr("RECAP_ITEM") % [_tr(str(GodRules.find(god_id).get("name_key", god_id))), GodLevels.level(god_id)])
	lines.append(_tr("RECAP_GODS") % (", ".join(gods) if not gods.is_empty() else _tr("UI_LB_NONE")))
	if not tracker.resonances_fired.is_empty():
		var used: PackedStringArray = []
		for resonance_id: String in tracker.resonances_fired:
			used.append(_tr(str(ResonanceManager.find_id(resonance_id).get("name_key", resonance_id))))
		lines.append(_tr("RECAP_RESONANCES") % ", ".join(used))
	var top: Array = tracker.top_weapon()
	if str(top[0]) != "":
		lines.append(_tr("RECAP_TOP_WEAPON") % [_tr(str(LeaderboardEntry._weapon_data(str(top[0])).get("name_key", top[0]))), roundi(float(top[1]) * 100.0)])
	lines.append(_tr("UI_SURVIVED") % TextFormat.run_time(run.elapsed_s))
	lines.append(_tr("UI_RESULTS_LINE") % [run.level, run.kills])
	if not tracker.bosses_defeated.is_empty():
		var bosses: PackedStringArray = []
		for boss_id: String in tracker.bosses_defeated:
			bosses.append(_tr(str(_enemy(boss_id).get("name_key", boss_id))))
		lines.append(_tr("RECAP_MILESTONES") % ", ".join(bosses))
	if tracker.labors_done > 0:
		lines.append(_tr("RECAP_LABORS") % tracker.labors_done)
	lines.append(_tr("RECAP_GOLD") % banked)
	if best_before <= 0.0 or run.elapsed_s > best_before:
		lines.append(_tr("RECAP_NEW_BEST"))
	else:
		lines.append(_tr("RECAP_BEST") % TextFormat.run_time(best_before))
	lines.append_array(tracker.new_unlocks)
	var context: Dictionary = {"killer": killer, "killer_type": _enemy(killer), "elements": elements,
		"gods": tracker.gods_bound.size(), "arc_s": run.arc_s(), "evolutions": tracker.evolutions}
	var tip: Dictionary = TipRules.pick(context)
	return {"lines": lines, "tip": str(tip.get("text", ""))}


## "Medusa (Earth)", "Sekhmet's trial (Fire)", "Lightning strike", ...
static func describe_source(source: String) -> String:
	var element: String = source_element(source)
	var name: String = source_name(source)
	return name if element == "" else _tr("RECAP_WITH_ELEMENT") % [name, _tr(str(Elements.element(element).get("name_key", element)))]


static func source_name(source: String) -> String:
	var enemy: Dictionary = _enemy(source)
	if not enemy.is_empty():
		return _tr(str(enemy.get("name_key", source)))
	if source.begins_with("god_"):
		return _tr("RECAP_TRIAL_OF") % _tr(str(GodRules.find(source.trim_prefix("god_")).get("name_key", source)))
	if source == "unraveling":
		return _tr("AGE_UNRAVELING_NAME")
	return _tr("SOURCE_" + source.to_upper())


static func source_element(source: String) -> String:
	var enemy: Dictionary = _enemy(source)
	if not enemy.is_empty():
		return str(enemy.get("element", ""))
	if source.begins_with("god_"):
		return str(GodRules.find(source.trim_prefix("god_")).get("element", ""))
	return ""


static func _enemy(enemy_id: String) -> Dictionary:
	var listed: Variant = Data.get_file(ENEMIES_FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary and str(entry.get("id", "")) == enemy_id:
			return entry
	return {}


static func _tr(key: String) -> String:
	return TranslationServer.translate(key)
