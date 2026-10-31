class_name BestiaryScreen
extends MenuScreen
## The Bestiary (GAME_DESIGN.md: Collections): every creature defeated, with
## its kills; weakness and resistance after 25 kills (or a recap tip); its myth
## summary, with source, after 100. Unmet creatures show as a dark shape and "???".
## Laid out as a list with a detail panel (owner decision 10/31/2026): pictures and names on the left, the chosen
## creature's picture, numbers and myth on the right.

var _chosen: String = ""


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	set_title(tr_key("UI_BESTIARY"))
	var boxes: Array = add_split()
	var list: VBoxContainer = boxes[0]
	var detail: VBoxContainer = boxes[1]
	var first: Button = null
	var shown: Array = []
	var met: int = 0
	var total: int = 0
	for enemy: Variant in Data.get_file(DeathRecap.ENEMIES_FILE):
		if not enemy is Dictionary or bool(enemy.get("placeholder", false)) or bool(enemy.get("hidden_in_bestiary", false)) \
				or str(enemy.get("id", "")) == "trial_avatar":
			continue
		var id: String = str(enemy.get("id", ""))
		var known: bool = Bestiary.kills(id) > 0
		total += 1
		met += 1 if known else 0
		var picture: Texture2D = UiTheme.portrait(PixelArt.find("enemies/" + id), 2)
		var name: String = tr_key(str(enemy.get("name_key", id))) if known else tr_key("BESTIARY_UNKNOWN")
		var item: Button = add_list_item(list, picture, name, func() -> void:
			_chosen = id
			_show(detail, enemy, picture))
		if not known:
			silhouette(item)             # a dark shape until it's met
		if first == null or id == _chosen:
			first = item
			shown = [enemy, picture]
	# The one looked at last (or the first), chosen and shown.
	if first != null:
		first.set_pressed_no_signal(true)
		_show(detail, shown[0], shown[1])
	set_title(tr_key("UI_BESTIARY") + "  ·  " + tr_key("BESTIARY_FOUND") % [met, total])


func _show(detail: VBoxContainer, enemy: Dictionary, picture: Texture2D) -> void:
	var id: String = str(enemy.get("id", ""))
	var kills: int = Bestiary.kills(id)
	if kills <= 0:
		fill_detail(detail, null, tr_key("BESTIARY_UNKNOWN"), [tr_key("BESTIARY_NOT_MET")], [])
		return
	var facts: PackedStringArray = [tr_key("BESTIARY_DEFEATED") % kills]
	if Bestiary.weakness_known(id):
		facts.append(tr_key("BESTIARY_WEAKNESS") % [_element_list(enemy.get("weak")), _element_list(enemy.get("resist"))])
	else:
		facts.append(tr_key("BESTIARY_WEAKNESS_LOCKED") % Data.cfg_int("bestiary.weakness_kills"))
	var story: PackedStringArray = []
	if Bestiary.myth_known(id):
		story.append(tr_key("ENEMY_%s_MYTH" % id.to_upper()))
		story.append(tr_key("UI_SOURCE") % str(enemy.get("myth_source", "")))
	else:
		story.append(tr_key("BESTIARY_MYTH_LOCKED") % Data.cfg_int("bestiary.myth_kills"))
	fill_detail(detail, picture, tr_key(str(enemy.get("name_key", id))), facts, story)


func _element_list(value: Variant) -> String:
	var names: PackedStringArray = []
	for element: Variant in (value if value is Array else ([value] if value != null and str(value) != "" else [])):
		names.append(tr_key(str(Elements.element(str(element)).get("name_key", element))))
	return ", ".join(names) if not names.is_empty() else tr_key("UI_LB_NONE")
