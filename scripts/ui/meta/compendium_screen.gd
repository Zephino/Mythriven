class_name CompendiumScreen
extends MenuScreen
## The Pantheon Compendium (GAME_DESIGN.md: Collections; Hero and god banter):
## every god bound, grouped by pantheon, with its offering level and a short,
## sourced summary of its real myths; every Resonance discovered; and the
## Words of Legend, every banter line heard. A list with a detail panel (owner decision 10/31/2026): the gods by
## pantheon, then Resonances and Words of Legend, on the left; the chosen one on the right.

var _chosen: String = ""


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	set_title(tr_key("UI_COMPENDIUM"))
	var boxes: Array = add_split()
	var list: VBoxContainer = boxes[0]
	var detail: VBoxContainer = boxes[1]
	var entries: Dictionary = {}           # id → [button, Callable that shows it]
	var pantheons: PackedStringArray = []
	for god: Dictionary in GodRules.all():
		if not pantheons.has(str(god.get("pantheon", ""))):
			pantheons.append(str(god.get("pantheon", "")))
	for pantheon: String in pantheons:
		add_list_heading(list, tr_key("PANTHEON_" + pantheon.to_upper()))
		for god: Dictionary in GodRules.all():
			if str(god.get("pantheon", "")) != pantheon:
				continue
			var id: String = str(god.get("id", ""))
			var known: bool = GodLevels.bound_ever(id)
			var picture: Texture2D = UiTheme.god_face(id, 2)
			var show_god: Callable = func() -> void: _show_god(detail, god, picture)
			var item: Button = add_list_item(list, picture, tr_key(str(god.get("name_key", id))) if known else tr_key("COMPENDIUM_UNKNOWN_GOD"),
					func() -> void:
						_chosen = id
						show_god.call())
			if not known:
				silhouette(item)
			entries[id] = [item, show_god]
	add_list_heading(list, tr_key("COMPENDIUM_MORE"))
	var show_resonances: Callable = func() -> void: _show_resonances(detail)
	entries["resonances"] = [add_list_item(list, null, tr_key("COMPENDIUM_RESONANCES"), func() -> void:
		_chosen = "resonances"
		show_resonances.call()), show_resonances]
	var show_words: Callable = func() -> void: _show_words(detail)
	entries["words"] = [add_list_item(list, null, tr_key("COMPENDIUM_WORDS_TITLE"), func() -> void:
		_chosen = "words"
		show_words.call()), show_words]
	var pick: String = _chosen if entries.has(_chosen) else str(entries.keys()[0])
	(entries[pick][0] as Button).set_pressed_no_signal(true)
	(entries[pick][1] as Callable).call()


func _show_god(detail: VBoxContainer, god: Dictionary, picture: Texture2D) -> void:
	var id: String = str(god.get("id", ""))
	var kind: String = tr_key("PANTHEON_" + str(god.get("pantheon", "")).to_upper()) + "  ·  " + tr_key(str(god.get("role_key", "")))
	if not GodLevels.bound_ever(id):
		fill_detail(detail, null, tr_key("COMPENDIUM_UNKNOWN_GOD"), [kind, tr_key("COMPENDIUM_NOT_MET")], [])
		return
	fill_detail(detail, picture, tr_key(str(god.get("name_key", id))), [kind, tr_key("OFFERING_LEVEL") % GodLevels.level(id)],
			[tr_key("GOD_%s_MYTH" % id.to_upper()), tr_key("UI_SOURCE") % str(god.get("lore_source", ""))])


func _show_resonances(detail: VBoxContainer) -> void:
	var found: PackedStringArray = Profile.get_list(EvolutionRules.CODEX_SECTION, ResonanceManager.PROFILE_KEY)
	var lines: PackedStringArray = []
	for resonance: Dictionary in ResonanceManager.all():
		if found.has(str(resonance.get("id", ""))):
			lines.append(tr_key(str(resonance.get("name_key", ""))) + " — " + tr_key(str(resonance.get("desc_key", ""))))
		else:
			lines.append(tr_key("COMPENDIUM_UNKNOWN_GOD"))
	fill_detail(detail, null, tr_key("COMPENDIUM_RESONANCES"), [tr_key("BESTIARY_FOUND") % [found.size(), ResonanceManager.all().size()]], lines)


func _show_words(detail: VBoxContainer) -> void:
	var lines: PackedStringArray = []
	for text_key: Variant in SaveGame.list("words"):
		lines.append("“" + tr_key(str(text_key)) + "”")
	fill_detail(detail, null, tr_key("COMPENDIUM_WORDS_TITLE"), [tr_key("COMPENDIUM_WORDS") % lines.size()], lines)
