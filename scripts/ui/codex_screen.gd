class_name CodexScreen
extends CanvasLayer
## The Codex (GAME_DESIGN.md: Clarity and balance): every evolution recipe.
## Discovered recipes show "weapon + passive → evolution"; undiscovered ones
## are silhouettes with a hint. Opens from the pause menu and Hero select.
## Keyboard, gamepad, and touch work; Close is focused first, Esc closes.

signal closed

var _close: Button
var _scroll: ScrollContainer


func _ready() -> void:
	layer = 85
	process_mode = Node.PROCESS_MODE_ALWAYS
	var touch: float = Data.cfg_float("ui.min_touch_target_px")
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var background := ColorRect.new()
	background.color = Color.html(Data.cfg_string("heroes.select_background"))
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, int(margin_px))
	root.add_child(box)
	var top := HBoxContainer.new()
	box.add_child(top)
	var title := Label.new()
	title.text = "UI_CODEX"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	_close = Button.new()
	_close.text = "UI_LB_CLOSE"
	_close.custom_minimum_size = Vector2(touch * 2.0, touch)
	_close.pressed.connect(_on_close)
	top.add_child(_close)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.focus_mode = Control.FOCUS_ALL
	box.add_child(_scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(rows)
	for text: String in lines():
		var row := Label.new()
		row.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.text = text
		rows.add_child(row)
	_close.focus_neighbor_bottom = _close.get_path_to(_scroll)
	_close.grab_focus()


## One line per recipe: discovered, or a silhouette with a hint.
static func lines() -> PackedStringArray:
	var out := PackedStringArray()
	var found: int = 0
	var recipes: Array[Dictionary] = EvolutionRules.all_recipes()
	for recipe: Dictionary in recipes:
		var weapon: String = TranslationServer.translate(WeaponInstance.name_key_at(GameAuthority.find_weapon(str(recipe["weapon"])), 8))
		if EvolutionRules.is_discovered(str(recipe["into"])):
			found += 1
			var passive: String = TranslationServer.translate(str(LevelUpRules.passive_data(str(recipe["passive"])).get("name_key", "")))
			var into: String = TranslationServer.translate(WeaponInstance.name_key_at(GameAuthority.find_weapon(str(recipe["into"])), 1))
			out.append(TranslationServer.translate("CODEX_RECIPE") % [weapon, passive, into])
		else:
			out.append(TranslationServer.translate("CODEX_HIDDEN") % weapon)
	out.insert(0, TranslationServer.translate("CODEX_COUNT") % [found, recipes.size()])
	var infusions: PackedStringArray = Profile.get_list(EvolutionRules.CODEX_SECTION, Infusions.CODEX_KEY)
	out.append(TranslationServer.translate("CODEX_INFUSIONS") % infusions.size())
	for entry: String in infusions:
		var parts: PackedStringArray = entry.split("+")
		var data: Dictionary = GameAuthority.find_weapon(parts[0]) if parts.size() == 2 else {}
		if data.is_empty():
			continue
		var weapon := WeaponInstance.new(data, null)
		weapon.level = weapon.max_level()
		Infusions.infuse(weapon, parts[1])
		out.append("· " + Infusions.display_name(weapon))
	var resonances: PackedStringArray = Profile.get_list(EvolutionRules.CODEX_SECTION, ResonanceManager.PROFILE_KEY)
	out.append(TranslationServer.translate("CODEX_RESONANCES") % [resonances.size(), ResonanceManager.all().size()])
	for resonance: Dictionary in ResonanceManager.all():
		if resonances.has(str(resonance["id"])):
			out.append("· " + TranslationServer.translate(str(resonance["name_key"])) + " — " + TranslationServer.translate(str(resonance["desc_key"])))
	return out


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_on_close()
	elif _scroll.has_focus() and (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up")):
		var step: int = int(Data.cfg_float("ui.min_touch_target_px"))
		if event.is_action_pressed("ui_up") and _scroll.scroll_vertical == 0:
			_close.grab_focus()
		else:
			_scroll.scroll_vertical += step if event.is_action_pressed("ui_down") else -step
		get_viewport().set_input_as_handled()


func _on_close() -> void:
	closed.emit()
	queue_free()
