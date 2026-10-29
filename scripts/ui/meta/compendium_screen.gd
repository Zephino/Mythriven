class_name CompendiumScreen
extends MenuScreen
## The Pantheon Compendium (GAME_DESIGN.md: Collections; Hero and god banter):
## every god bound, grouped by pantheon, with its offering level and a short,
## sourced summary of its real myths; every Resonance discovered; and the
## Words of Legend, every banter line heard.


func build() -> void:
	set_title(tr_key("UI_COMPENDIUM"))
	var pantheons: PackedStringArray = []
	for god: Dictionary in GodRules.all():
		if not pantheons.has(str(god.get("pantheon", ""))):
			pantheons.append(str(god.get("pantheon", "")))
	for pantheon: String in pantheons:
		add_line(tr_key("PANTHEON_" + pantheon.to_upper()))
		for god: Dictionary in GodRules.all():
			if str(god.get("pantheon", "")) != pantheon:
				continue
			var id: String = str(god.get("id", ""))
			if not GodLevels.bound_ever(id):
				add_line("  " + tr_key("COMPENDIUM_UNKNOWN_GOD"))
				continue
			add_line("  " + "\n  ".join([tr_key("COMPENDIUM_GOD_ROW") % [tr_key(str(god.get("name_key", id))), tr_key(str(god.get("role_key", ""))),
				GodLevels.level(id)], tr_key("GOD_%s_MYTH" % id.to_upper()), tr_key("UI_SOURCE") % str(god.get("lore_source", ""))]))
	add_line(tr_key("COMPENDIUM_RESONANCES"))
	var found: PackedStringArray = Profile.get_list(EvolutionRules.CODEX_SECTION, ResonanceManager.PROFILE_KEY)
	for resonance: Dictionary in ResonanceManager.all():
		var known: bool = found.has(str(resonance.get("id", "")))
		add_line("  " + (tr_key(str(resonance.get("name_key", ""))) if known else tr_key("COMPENDIUM_UNKNOWN_GOD")))
	add_line(tr_key("COMPENDIUM_WORDS") % SaveGame.list("words").size())
	for text_key: Variant in SaveGame.list("words"):
		add_line("  “" + tr_key(str(text_key)) + "”")
