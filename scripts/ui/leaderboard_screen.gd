class_name LeaderboardScreen
extends MenuScreen
## The shared leaderboard (owner request): the best runs from every player
## (or, until online scores are set up, the best runs on this device),
## each with their Hero, time survived, level, kills, weapons, and upgrades.
## Opens from the title, the Hall of Legends, Hero select and the death screen.
##
## Laid out as a ranked table (owner request 10/31/2026: "look more professional"), in the menus' frame over the
## painted backdrop: a header row, then one row per run with its rank (the top three in gold, silver and bronze), the
## Hero's portrait, the player's name and Hero, the weapons' icons, and time, level and kills in their own columns.
## The player's own runs are lit. Tapping a row opens its whole build underneath. Keyboard, gamepad and touch all
## work; Esc / B closes it.

## Column widths, from config leaderboard.column_px: rank, portrait, name, weapons, time, level, kills.
enum Col { RANK, PORTRAIT, NAME, WEAPONS, TIME, LEVEL, KILLS }

var _client: LeaderboardClient
## null while loading; then the entries (or an error).
var _entries: Variant = null
var _error: String = ""
## The row whose build is open (-1 = none).
var _open_row: int = -1


func _ready() -> void:
	_client = LeaderboardClient.new()
	add_child(_client)
	_client.board_loaded.connect(_on_board_loaded)
	super._ready()
	_load()


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func _load() -> void:
	_entries = null
	_error = ""
	_open_row = -1
	refresh()
	_client.fetch()


func _on_board_loaded(entries: Array[Dictionary], error: String) -> void:
	_entries = entries
	_error = error
	refresh()


func build() -> void:
	set_title(tr_key("UI_LEADERBOARD_LOCAL") if LeaderboardClient.is_local() else tr_key("UI_LEADERBOARD"))
	# Refresh in the title bar, beside Back.
	_top_slot.visible = true
	_top_slot.size_flags_horizontal = Control.SIZE_SHRINK_END
	var again := Button.new()
	again.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	again.text = tr_key("UI_LB_REFRESH")
	again.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 2.0, Data.cfg_float("ui.min_touch_target_px"))
	again.disabled = _entries == null
	again.pressed.connect(_load)
	_top_slot.add_child(again)
	_buttons.append(again)
	if LeaderboardClient.is_local():
		add_note(tr_key("UI_LB_LOCAL_NOTE"))
	if _entries == null:
		add_note(tr_key("UI_LB_LOADING"))
		return
	if _error != "":
		add_note(tr_key("UI_LB_LOAD_FAILED") % _error)
		return
	var entries: Array = _entries
	if entries.is_empty():
		add_note(tr_key("UI_LB_EMPTY"))
		return
	var wide: bool = _column.custom_minimum_size.x >= Data.cfg_float("leaderboard.weapons_from_px")
	_rows.add_child(_header(wide))
	var mine: String = LeaderboardEntry.load_name().to_lower()
	for i: int in mini(entries.size(), Data.cfg_int("leaderboard.rows_shown")):
		var entry: Dictionary = entries[i]
		_rows.add_child(_row(i, entry, wide, mine != "" and str(entry.get("name", "")).to_lower() == mine))


## The column names over the table.
func _header(wide: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var texts: Array = ["UI_LB_COL_RANK", "", "UI_LB_COL_PLAYER", "UI_LB_COL_WEAPONS", "UI_LB_COL_TIME", "UI_LB_COL_LEVEL", "UI_LB_COL_KILLS"]
	for col: int in texts.size():
		if col == Col.WEAPONS and not wide:
			continue
		var label := small(tr_key(str(texts[col])) if str(texts[col]) != "" else "")
		label.size_flags_horizontal = Control.SIZE_FILL
		_size_cell(label, col)
		label.horizontal_alignment = _align(col)
		row.add_child(label)
	var holder := MarginContainer.new()
	holder.add_theme_constant_override("margin_left", 7)
	holder.add_theme_constant_override("margin_right", 7)
	holder.add_child(row)
	return holder


## One run: rank, portrait, name and Hero, weapons, time, level, kills; its build underneath when opened.
func _row(index: int, entry: Dictionary, wide: bool, mine: bool) -> Control:
	var card := PanelContainer.new()
	card.focus_mode = Control.FOCUS_ALL
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	var normal: StyleBoxFlat = _row_style(index, mine, false)
	var lit: StyleBoxFlat = _row_style(index, mine, true)
	card.add_theme_stylebox_override("panel", normal)
	card.focus_entered.connect(func() -> void: card.add_theme_stylebox_override("panel", lit))
	card.focus_exited.connect(func() -> void: card.add_theme_stylebox_override("panel", normal))
	card.gui_input.connect(func(event: InputEvent) -> void:
		var tapped: bool = event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
				and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
		if tapped or event.is_action_pressed("ui_accept"):
			card.accept_event()
			_open_row = -1 if _open_row == index else index
			refresh())
	_buttons.append(card)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(box)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 6)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(line)
	# Rank: the top three in gold, silver and bronze.
	var rank := heading("%d" % (index + 1))
	rank.autowrap_mode = TextServer.AUTOWRAP_OFF
	rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var medals: Array = Data.cfg("leaderboard.medal_colors")
	rank.add_theme_color_override("font_color", Color.html(str(medals[index])) if index < medals.size()
			else Color.html(Data.cfg_string("ui.menu_small_color")))
	_size_cell(rank, Col.RANK)
	line.add_child(rank)
	var hero: Dictionary = HeroRules.find(str(entry.get("hero", "")))
	var portrait: Texture2D = UiTheme.portrait(PixelArt.find(str(entry.get("hero", ""))), 2)
	var face := picture_box(portrait, Data.cfg_float("leaderboard.portrait_px")) if portrait != null else Control.new()
	_size_cell(face, Col.PORTRAIT)
	line.add_child(face)
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", -2)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_label := Label.new()
	name_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	name_label.text = str(entry.get("name", ""))
	name_label.clip_text = true
	if mine:
		name_label.add_theme_color_override("font_color", Color.html(Data.cfg_string("ui.menu_heading_color")))
	who.add_child(name_label)
	var hero_label := small(tr_key(str(hero.get("name_key", ""))) if not hero.is_empty() else str(entry.get("hero", "")))
	hero_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	hero_label.clip_text = true
	who.add_child(hero_label)
	line.add_child(who)
	if wide:
		var icons := HBoxContainer.new()
		icons.add_theme_constant_override("separation", 1)
		_size_cell(icons, Col.WEAPONS)
		for weapon: Variant in (entry.get("weapons", []) as Array).slice(0, 6):
			if weapon is Dictionary:
				var data: Dictionary = LeaderboardEntry._weapon_data(str(weapon.get("id", "")))
				var icon: Texture2D = UiTheme.weapon_icon(data) if not data.is_empty() else null
				if icon != null:
					icons.add_child(picture_box(icon, Data.cfg_float("leaderboard.weapon_icon_px")))
		line.add_child(icons)
	for pair: Array in [[Col.TIME, TextFormat.run_time(float(entry.get("time_s", 0)))], [Col.LEVEL, str(int(entry.get("level", 0)))],
			[Col.KILLS, TextFormat.whole(float(entry.get("kills", 0)))]]:
		var cell := Label.new()
		cell.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		cell.text = str(pair[1])
		cell.horizontal_alignment = _align(int(pair[0]))
		if int(pair[0]) == Col.TIME:
			cell.add_theme_color_override("font_color", Color.html(Data.cfg_string("ui.menu_heading_color")))
		_size_cell(cell, int(pair[0]))
		line.add_child(cell)
	# The whole build, when the row is opened.
	if _open_row == index:
		box.add_child(HSeparator.new())
		for text: String in LeaderboardEntry.describe(index + 1, entry).split("\n").slice(1):
			var detail := small(text)
			detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
			box.add_child(detail)
		var version: String = str(entry.get("version", ""))
		if version != "":
			box.add_child(small(tr_key("UI_LB_PLAYED_ON") % version))
	return card


func _size_cell(control: Control, col: int) -> void:
	var widths: Array = Data.cfg("leaderboard.column_px")
	var width: float = float(widths[col])
	if width > 0.0:
		control.custom_minimum_size.x = width
	else:
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _align(col: int) -> HorizontalAlignment:
	if col == Col.RANK:
		return HORIZONTAL_ALIGNMENT_CENTER
	return HORIZONTAL_ALIGNMENT_RIGHT if col >= Col.TIME else HORIZONTAL_ALIGNMENT_LEFT


## A row's box: soft, with a coloured edge for the top three, gold for the player's own runs, brighter when chosen.
func _row_style(index: int, mine: bool, lit: bool) -> StyleBoxFlat:
	var style := card_style()
	var medals: Array = Data.cfg("leaderboard.medal_colors")
	var gold := Color.html(Data.cfg_string("ui.menu_heading_color"))
	if index < medals.size():
		style.border_color = Color.html(str(medals[index]))
		style.border_width_left = 3
	if mine:
		style.bg_color = Color(gold.r, gold.g, gold.b, 0.14)
	if lit:
		style.bg_color = style.bg_color.lightened(0.15)
		style.border_color = gold
		style.set_border_width_all(2)
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	return style
