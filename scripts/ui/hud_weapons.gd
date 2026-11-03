class_name HudWeapons
extends VBoxContainer
## The Hero's weapons down the left edge of the screen during a run (owner request 11/03/2026: a spot on the screen
## to see them and what level they are): one slot per weapon carried, with its picture and its level ("MAX" at the
## top level, "EVO" once evolved), and faint empty slots for the ones still free: the weapons first
## (level_up.max_weapons), then, after a small gap, the spells (level_up.max_spells; owner request: 5 weapons and
## 3 spells).
## It rebuilds only when a weapon is gained, levelled, evolved or infused.

var _shown: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", int(Data.cfg_float("ui.hud_weapon_gap_px")))


func _process(_delta: float) -> void:
	var player: Player = GameAuthority.local_player()
	var weapons: Array[WeaponInstance] = player.weapons if player != null else ([] as Array[WeaponInstance])
	var key: String = ""
	for weapon: WeaponInstance in weapons:
		key += "%s:%d:%s|" % [weapon.id(), weapon.level, weapon.infusion]
	if key == _shown:
		return
	_shown = key
	_rebuild(weapons)


func _rebuild(weapons: Array[WeaponInstance]) -> void:
	for child: Node in get_children():
		child.queue_free()
	var side: float = Data.cfg_float("ui.hud_weapon_slot_px")
	for spells: bool in [false, true]:
		if spells:
			var gap := Control.new()                                                     # weapons above, spells below
			gap.custom_minimum_size.y = Data.cfg_float("ui.hud_weapon_gap_px") * 2.0
			gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(gap)
		var held: Array[WeaponInstance] = []
		for weapon: WeaponInstance in weapons:
			if LevelUpRules.is_spell(weapon.data) == spells:
				held.append(weapon)
		_rebuild_group(held, LevelUpRules.slot_limit(spells), side, "spell" if spells else "weapon")


func _rebuild_group(weapons: Array[WeaponInstance], slots: int, side: float, kind: String) -> void:
	for i: int in slots:
		var line := HBoxContainer.new()
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.set_meta("slot_kind", kind)
		add_child(line)
		var slot := PanelContainer.new()
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.custom_minimum_size = Vector2(side, side)
		line.add_child(slot)
		if i >= weapons.size():
			slot.modulate = Color(1, 1, 1, Data.cfg_float("ui.hud_weapon_empty_alpha"))
			continue
		var weapon: WeaponInstance = weapons[i]
		var icon := TextureRect.new()
		icon.texture = UiTheme.weapon_icon(weapon.data)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		var level := Label.new()                                                         # the level, beside it
		level.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		level.text = level_text(weapon)
		level.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		level.add_theme_font_size_override("font_size", roundi(ThemeDB.get_default_theme().default_font_size * Data.cfg_float("ui.hud_weapon_level_scale")))
		level.add_theme_color_override("font_outline_color", Color.BLACK)
		level.add_theme_constant_override("outline_size", 4)
		if weapon.data.has("evolved_from") or weapon.level >= weapon.max_level():
			level.add_theme_color_override("font_color", Color.html(Data.cfg_string("ui.menu_heading_color")))
		level.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(level)


## What a slot shows beside its weapon: its level, "MAX" at the top level, or "EVO" once evolved.
static func level_text(weapon: WeaponInstance) -> String:
	if weapon.data.has("evolved_from"):
		return TranslationServer.translate("UI_HUD_WEAPON_EVOLVED")
	if weapon.level >= weapon.max_level():
		return TranslationServer.translate("UI_HUD_WEAPON_MAX")
	return TranslationServer.translate("UI_HUD_WEAPON_LEVEL") % weapon.level
