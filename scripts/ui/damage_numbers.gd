class_name DamageNumbers
extends Node2D
## Floating damage numbers from a fixed pool of labels (GAME_DESIGN.md: Game
## feel). Crits are bigger and orange; weakness hits are big and yellow with
## "!", resisted hits small and grey; damage over time is small. Reactions
## show their name. When every label is in use, the oldest is reused.
## Can be switched off (ui.damage_numbers_enabled; a Settings option later).

var _labels: Array[Label] = []
var _age := PackedFloat32Array()
var _next: int = 0


func setup() -> void:
	z_index = 20
	var count: int = Data.cfg_int("ui.damage_number_pool")
	_age.resize(count)
	for i: int in count:
		var label := Label.new()
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_constant_override("outline_size", Data.cfg_int("ui.damage_number_outline_px"))
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.visible = false
		add_child(label)
		_labels.append(label)
		_age[i] = -1.0


## `kind` is "normal", "crit", "weak", "resist", or "dot".
func show_number(value: float, at: Vector2, kind: String) -> void:
	if not Data.cfg_bool("ui.damage_numbers_enabled"):
		return
	var style: Dictionary = (Data.cfg("ui.damage_number_styles") as Dictionary).get(kind, {})
	var text: String = TextFormat.whole(value)
	if kind == "weak":
		text = tr("UI_WEAK_HIT") % text
	_show(text, at, int(style.get("font_px", 8)), Color.html(str(style.get("color", "#ffffff"))))


## Floating text such as a reaction's name.
func show_text(text: String, at: Vector2, color: Color) -> void:
	_show(text, at, Data.cfg_int("ui.reaction_text_font_px"), color)


func _show(text: String, at: Vector2, font_px: int, color: Color) -> void:
	if _labels.is_empty():
		return
	var label: Label = _labels[_next]
	_age[_next] = 0.0
	_next = (_next + 1) % _labels.size()
	label.text = text
	label.add_theme_font_size_override("font_size", font_px)
	label.add_theme_color_override("font_color", color)
	label.reset_size()
	label.position = at - label.size * 0.5
	label.modulate.a = 1.0
	label.visible = true


func on_enemy_damaged(_slot: int, amount: float, kind: String, at: Vector2) -> void:
	show_number(amount, at, kind)


func on_reaction(reaction_id: String, at: Vector2, _reach: float) -> void:
	var reaction: Dictionary = Elements.reaction(reaction_id)
	show_text(tr(str(reaction.get("name_key", reaction_id))), at, Color.html(str(reaction.get("color", "#ffffff"))))


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for label: Label in _labels:
		label.position -= shift_px


func _process(delta: float) -> void:
	var life: float = Data.cfg_float("ui.damage_number_life_s")
	var rise: float = Data.cfg_float("ui.damage_number_rise_px_s")
	for i: int in _labels.size():
		if _age[i] < 0.0:
			continue
		_age[i] += delta
		var label: Label = _labels[i]
		if _age[i] >= life:
			_age[i] = -1.0
			label.visible = false
			continue
		label.position.y -= rise * delta
		label.modulate.a = 1.0 - _age[i] / life
