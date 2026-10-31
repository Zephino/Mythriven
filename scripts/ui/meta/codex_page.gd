class_name CodexPage
extends MenuScreen
## The Codex as a page of the Hall of Legends (owner decision 10/31/2026: the Hall's pages open inside it): every
## evolution recipe as a card with the evolved weapon's picture (discovered: "weapon + passive"; not yet: a dark
## shape and a hint), then the infusions and Resonances found. The run's own Codex (CodexScreen) is unchanged.


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	set_title(tr_key("UI_CODEX"))
	var recipes: Array[Dictionary] = EvolutionRules.all_recipes()
	var found: int = recipes.filter(func(recipe: Dictionary) -> bool: return EvolutionRules.is_discovered(str(recipe["into"]))).size()
	add_section(tr_key("CODEX_RECIPES") % [found, recipes.size()])
	for recipe: Dictionary in recipes:
		var weapon_data: Dictionary = GameAuthority.find_weapon(str(recipe["weapon"]))
		var into_data: Dictionary = GameAuthority.find_weapon(str(recipe["into"]))
		var weapon: String = tr_key(WeaponInstance.name_key_at(weapon_data, 8))
		var picture: Texture2D = UiTheme.weapon_icon(into_data)
		if EvolutionRules.is_discovered(str(recipe["into"])):
			var passive: String = tr_key(str(LevelUpRules.passive_data(str(recipe["passive"])).get("name_key", "")))
			add_card(picture, tr_key(WeaponInstance.name_key_at(into_data, 1)), [tr_key("CODEX_MADE_FROM") % [weapon, passive]])
		else:
			add_card(picture, tr_key("BESTIARY_UNKNOWN"), [tr_key("CODEX_HINT") % weapon], "", "", Callable(), true, true, true)
	var infusions: PackedStringArray = Profile.get_list(EvolutionRules.CODEX_SECTION, Infusions.CODEX_KEY)
	add_section(tr_key("CODEX_INFUSIONS") % infusions.size())
	if infusions.is_empty():
		add_card(null, tr_key("UI_NONE_YET"), [tr_key("CODEX_INFUSIONS_HOW")], "", "", Callable(), true, true)
	for entry: String in infusions:
		var parts: PackedStringArray = entry.split("+")
		var data: Dictionary = GameAuthority.find_weapon(parts[0]) if parts.size() == 2 else {}
		if data.is_empty():
			continue
		var weapon := WeaponInstance.new(data, null)
		weapon.level = weapon.max_level()
		Infusions.infuse(weapon, parts[1])
		add_card(UiTheme.weapon_icon(data), Infusions.display_name(weapon), [tr_key(str(GodRules.find(parts[1]).get("name_key", parts[1])))])
	var resonances: PackedStringArray = Profile.get_list(EvolutionRules.CODEX_SECTION, ResonanceManager.PROFILE_KEY)
	add_section(tr_key("CODEX_RESONANCES") % [resonances.size(), ResonanceManager.all().size()])
	for resonance: Dictionary in ResonanceManager.all():
		if resonances.has(str(resonance["id"])):
			add_card(null, tr_key(str(resonance["name_key"])), [tr_key(str(resonance["desc_key"]))])
		else:
			add_card(null, tr_key("BESTIARY_UNKNOWN"), [tr_key("CODEX_RESONANCE_HOW")], "", "", Callable(), true, true)
