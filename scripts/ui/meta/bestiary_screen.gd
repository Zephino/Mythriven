class_name BestiaryScreen
extends MenuScreen
## The Bestiary (GAME_DESIGN.md: Collections): every creature defeated, with
## its kills; weakness and resistance after 25 kills (or a recap tip); its myth
## summary, with source, after 100. Unmet creatures show as "???".


func build() -> void:
	set_title(tr_key("UI_BESTIARY"))
	for enemy: Variant in Data.get_file(DeathRecap.ENEMIES_FILE):
		if not enemy is Dictionary or bool(enemy.get("placeholder", false)) or bool(enemy.get("hidden_in_bestiary", false)) \
				or str(enemy.get("id", "")) == "trial_avatar":
			continue
		var id: String = str(enemy.get("id", ""))
		var kills: int = Bestiary.kills(id)
		if kills <= 0:
			add_line(tr_key("BESTIARY_UNKNOWN"))
			continue
		var lines: PackedStringArray = [tr_key("BESTIARY_ROW") % [tr_key(str(enemy.get("name_key", id))), kills]]
		if Bestiary.weakness_known(id):
			lines.append(tr_key("BESTIARY_WEAKNESS") % [_element_list(enemy.get("weak")), _element_list(enemy.get("resist"))])
		else:
			lines.append(tr_key("BESTIARY_WEAKNESS_LOCKED") % Data.cfg_int("bestiary.weakness_kills"))
		if Bestiary.myth_known(id):
			lines.append(tr_key("ENEMY_%s_MYTH" % id.to_upper()))
			lines.append(tr_key("UI_SOURCE") % str(enemy.get("myth_source", "")))
		else:
			lines.append(tr_key("BESTIARY_MYTH_LOCKED") % Data.cfg_int("bestiary.myth_kills"))
		add_line("\n".join(lines))


func _element_list(value: Variant) -> String:
	var names: PackedStringArray = []
	for element: Variant in (value if value is Array else ([value] if value != null and str(value) != "" else [])):
		names.append(tr_key(str(Elements.element(str(element)).get("name_key", element))))
	return ", ".join(names) if not names.is_empty() else tr_key("UI_LB_NONE")
