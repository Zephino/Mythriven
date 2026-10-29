class_name BossHud
extends CanvasLayer
## Boss bars (GAME_DESIGN.md: Bosses / Classic boss ideas): for each boss in
## the fight, its name and phase, an HP bar, the Guard gauge under it (gold;
## flashing while broken), weakness and resistance shown in their element
## colours, and a cast bar with the attack's name ("Serpent Hair — 1.5 s").

var bosses: BossManager

var _box: VBoxContainer
## One row per boss slot: {"name", "hp", "guard", "weak", "cast"}.
var _rows: Array[Dictionary] = []


func _ready() -> void:
	layer = 11
	var root := SafeAreaBox.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_box = VBoxContainer.new()
	_box.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_box.offset_top = Data.cfg_float("ui.min_touch_target_px") * 1.6
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_box)
	for _i: int in 2:
		_rows.append(_make_row())


func _process(_delta: float) -> void:
	var alive: Array[BossController] = []
	if bosses != null:
		for controller: BossController in bosses.controllers:
			if controller.is_alive():
				alive.append(controller)
	for i: int in _rows.size():
		var row: Dictionary = _rows[i]
		var box: VBoxContainer = row["box"]
		box.visible = i < alive.size()
		if box.visible:
			_fill(row, alive[i])


func _fill(row: Dictionary, boss: BossController) -> void:
	var type: Dictionary = GameAuthority.enemies.type_of(boss.slot)
	(row["name"] as Label).text = tr("BOSS_BAR_NAME") % [tr(str(boss.data.get("name_key", ""))), boss.phase_index + 1]
	var hp: ProgressBar = row["hp"]
	hp.max_value = 1.0
	hp.value = boss.hp_fraction()
	var guard: ProgressBar = row["guard"]
	guard.max_value = 1.0
	guard.value = 1.0 if boss.broken_s > 0.0 else boss.guard / maxf(boss.guard_max, 1.0)
	guard.modulate = Color.WHITE if boss.broken_s <= 0.0 or int(boss.broken_s * 6.0) % 2 == 0 else Color(1, 1, 1, 0.3)
	var weak: Label = row["weak"]
	weak.text = tr("BOSS_WEAK_RESIST") % [_elements(type.get("weak")), _elements(type.get("resist"))]
	var cast: Label = row["cast"]
	cast.visible = not boss.cast.is_empty()
	if cast.visible:
		cast.text = tr("BOSS_CAST") % [tr(str(boss.cast.get("name_key", ""))), maxf(boss.cast_left, 0.0)]


func _elements(value: Variant) -> String:
	var ids: Array = value if value is Array else ([value] if value != null and str(value) != "" else [])
	var names := PackedStringArray()
	for id: Variant in ids:
		names.append(tr(str(Elements.element(str(id)).get("name_key", id))))
	return ", ".join(names) if not names.is_empty() else "-"


func _make_row() -> Dictionary:
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.custom_minimum_size.x = Data.cfg_float("bosses.bar_width_px")
	_box.add_child(box)
	var title := Label.new()
	title.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var hp := ProgressBar.new()
	hp.show_percentage = false
	hp.custom_minimum_size.y = Data.cfg_float("bosses.bar_height_px")
	hp.modulate = Color.html(Data.cfg_string("bosses.hp_bar_color"))
	box.add_child(hp)
	var guard := ProgressBar.new()
	guard.show_percentage = false
	guard.custom_minimum_size.y = Data.cfg_float("bosses.guard_bar_height_px")
	guard.self_modulate = Color.html(Data.cfg_string("bosses.guard_bar_color"))
	box.add_child(guard)
	var weak := Label.new()
	weak.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	weak.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(weak)
	var cast := Label.new()
	cast.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	cast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cast.add_theme_color_override("font_color", Color.html(Data.cfg_string("bosses.cast_text_color")))
	box.add_child(cast)
	box.visible = false
	return {"box": box, "name": title, "hp": hp, "guard": guard, "weak": weak, "cast": cast}
