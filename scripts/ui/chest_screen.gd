class_name ChestScreen
extends CanvasLayer
## The chest reveal (GAME_DESIGN.md: Discovery and feel / Chest reveal):
## 1. The seal: a ring in the level's pantheon style (the Aegean Shore's is a
##    Greek meander; decorative pattern only, never writing).
## 2. The build-up (about 1.5 s): the seal spins and cracks while light leaks
##    out and a rising note plays; the light's colour previews the reward
##    (bronze 1 upgrade, silver 2, gold 3 or an evolution).
## 3. The reveal: rewards rise one at a time with a short sound each.
## 4. An evolution shows the weapon and passive flying together and fusing
##    into the new weapon, and a "New recipe discovered" banner.
## The whole reveal takes at most 3 s, pauses the game, and can be skipped
## with a tap or key after 0.5 s.

var _root: Control
var _seal: Node2D
var _lines: VBoxContainer
var _fuse_left: Label
var _fuse_right: Label
var _fuse_result: Label
var _plan: Dictionary = {}
var _evolved: Array[Dictionary] = []
var _t: float = 0.0
var _notes_played: int = 0
var _shown: int = 0
var _texts: PackedStringArray = []
var _audio: AudioStreamPlayer
## Asks which god infuses a weapon when two are eligible (after the reveal).
var infusion_choice: InfusionChoiceScreen


func _ready() -> void:
	add_to_group("chest_screen")
	add_to_group(CoopChoices.MODAL)
	layer = 45
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color.html(Data.cfg_string("chests.dim_color"))
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)
	_seal = Node2D.new()
	_seal.draw.connect(_draw_seal)
	_root.add_child(_seal)
	_lines = VBoxContainer.new()
	_lines.set_anchors_preset(Control.PRESET_CENTER)
	_lines.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_lines.grow_vertical = Control.GROW_DIRECTION_BOTH
	_lines.position.y += Data.cfg_float("chests.lines_offset_px")
	_root.add_child(_lines)
	_fuse_left = _make_label()
	_fuse_right = _make_label()
	_fuse_result = _make_label()
	_audio = AudioStreamPlayer.new()
	_audio.volume_db = Data.cfg_float("pickups.sound_volume_db")
	add_child(_audio)
	visible = false


func is_open() -> bool:
	return visible


## Shows a chest's plan (ChestRules.build) and the evolutions it caused.
func play(plan: Dictionary, evolved: Array[Dictionary]) -> void:
	_plan = plan
	_evolved = evolved
	_t = 0.0
	_notes_played = 0
	_shown = 0
	_texts = _reward_texts()
	for child: Node in _lines.get_children():
		child.queue_free()
	for label: Label in [_fuse_left, _fuse_right, _fuse_result]:
		label.visible = false
	visible = true
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _t < Data.cfg_float("chests.reveal_skip_after_s"):
		return
	var pressed: bool = (event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton
			or event is InputEventScreenTouch) and event.is_pressed()
	if pressed:
		get_viewport().set_input_as_handled()
		_close()


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	var buildup: float = _buildup_s()
	var note_every: float = buildup / maxf(Data.cfg_float("chests.buildup_notes"), 1.0)
	while _t < buildup and _t >= _notes_played * note_every:
		_play_note(Data.cfg_float("pickups.sound_base_hz") * pow(2.0, _notes_played * 2.0 / 12.0))
		_notes_played += 1
	if _t >= buildup:
		var step: float = Data.cfg_float("chests.reveal_step_s")
		while _shown < _texts.size() and _t >= buildup + _shown * step:
			_add_line(_texts[_shown])
			_shown += 1
		_animate_fuse(_t - buildup)
	_seal.queue_redraw()
	if _t >= Data.cfg_float("chests.reveal_max_s"):
		_close()


func _close() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = false
	if _plan.has("choose") and infusion_choice != null:
		infusion_choice.ask(_plan["choose"])
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	for recipe: Dictionary in _evolved:
		if bool(recipe.get("new", false)) and banner != null:
			banner.show_text(tr("CODEX_NEW_RECIPE") % _weapon_name(str(recipe["into"]), 1))


func _buildup_s() -> float:
	return Data.cfg_float("chests.fast_buildup_s") if Data.cfg_bool("chests.fast_chests") else Data.cfg_float("chests.buildup_s")


func _reward_texts() -> PackedStringArray:
	var texts := PackedStringArray()
	for reward: Dictionary in _plan.get("rewards", []):
		match str(reward.get("kind", "")):
			"evolution":
				texts.append(tr("CHEST_EVOLUTION") % [_weapon_name(str(reward["weapon"]), 8),
						tr(str(LevelUpRules.passive_data(str(reward["passive"])).get("name_key", ""))), _weapon_name(str(reward["into"]), 1)])
			"weapon_up":
				texts.append(tr("CHEST_LEVEL_UP") % [_weapon_name(str(reward["id"]), int(reward["to"])), int(reward["to"])])
			"passive_up":
				texts.append(tr("CHEST_LEVEL_UP") % [tr(str(LevelUpRules.passive_data(str(reward["id"])).get("name_key", ""))),
						int(reward["to"])])
			"gold":
				texts.append(tr("CHEST_GOLD") % TextFormat.whole(float(reward.get("amount", 0.0))))
			"infusion":
				texts.append(str(reward.get("text", "")))
	return texts


## The weapon and passive names fly together and fuse into the evolved name.
func _animate_fuse(since: float) -> void:
	if _evolved.is_empty():
		return
	var recipe: Dictionary = _evolved[0]
	var fuse: float = Data.cfg_float("chests.fuse_s")
	var view: Vector2 = get_viewport().get_visible_rect().size
	var center := Vector2(view.x * 0.5, view.y * 0.5 + Data.cfg_float("chests.fuse_offset_px"))
	var k: float = clampf(since / fuse, 0.0, 1.0)
	_fuse_left.text = _weapon_name(str(recipe["weapon"]), 8)
	_fuse_right.text = tr(str(LevelUpRules.passive_data(str(recipe["passive"])).get("name_key", "")))
	_fuse_result.text = _weapon_name(str(recipe["into"]), 1)
	_fuse_left.visible = k < 1.0
	_fuse_right.visible = k < 1.0
	_fuse_result.visible = k >= 1.0
	_fuse_left.position = Vector2(lerpf(view.x * 0.1, center.x - _fuse_left.size.x * 0.5, k), center.y)
	_fuse_right.position = Vector2(lerpf(view.x * 0.9 - _fuse_right.size.x, center.x - _fuse_right.size.x * 0.5, k), center.y)
	_fuse_result.position = Vector2(center.x - _fuse_result.size.x * 0.5, center.y)


func _draw_seal() -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var center := Vector2(view.x * 0.5, view.y * 0.5 - Data.cfg_float("chests.seal_offset_px"))
	var radius: float = Data.cfg_float("chests.seal_radius_px")
	var progress: float = clampf(_t / maxf(_buildup_s(), 0.01), 0.0, 1.0)
	var light := Color.html(str((Data.cfg("chests.tier_colors") as Dictionary).get(str(_plan.get("tier", "bronze")), "#ffffff")))
	_seal.draw_circle(center, radius * (0.6 + 0.9 * progress), Color(light, 0.25 + 0.45 * progress))
	var spin: float = _t * Data.cfg_float("chests.seal_spin_rad_s") * progress
	var style: String = str(GameAuthority.run.level_data.get("seal", "greek_meander")) if GameAuthority.run != null else "greek_meander"
	_draw_seal_pattern(style, center, radius, spin, Color.html(Data.cfg_string("chests.seal_color")))
	var cracks: int = int(progress * 6.0)
	for c: int in cracks:
		var a: float = TAU * c / 6.0 + 0.4
		_seal.draw_line(center + Vector2.from_angle(a) * radius * 0.3, center + Vector2.from_angle(a + 0.2) * radius, light, 2.0)


## The seal in the level's pantheon style (decorative patterns, never writing):
## a Greek meander ring, a Norse interlaced band, an Egyptian scarab clasp, or a
## Celtic knot of interlaced loops, or the eight-pointed star of Shamash (Mesopotamian seals and boundary stones).
func _draw_seal_pattern(style: String, center: Vector2, radius: float, spin: float, color: Color) -> void:
	var steps: int = Data.cfg_int("chests.meander_steps")
	var points := PackedVector2Array()
	match style:
		"norse_band":
			_seal.draw_arc(center, radius, 0.0, TAU, 48, color, 2.0)
			_seal.draw_arc(center, radius * 0.8, 0.0, TAU, 48, color, 2.0)
			for k: int in steps * 2:
				var a: float = spin + TAU * k / (steps * 2.0)
				_seal.draw_line(center + Vector2.from_angle(a) * radius * 0.8, center + Vector2.from_angle(a + 0.25) * radius, color, 2.0)
				_seal.draw_line(center + Vector2.from_angle(a) * radius, center + Vector2.from_angle(a + 0.25) * radius * 0.8, color, 2.0)
		"egyptian_scarab":
			_seal.draw_arc(center, radius, 0.0, TAU, 48, color, 2.0)
			_seal.draw_set_transform(center, spin, Vector2(0.55, 0.75))
			_seal.draw_arc(Vector2.ZERO, radius * 0.6, 0.0, TAU, 32, color, 2.0)
			_seal.draw_set_transform(Vector2.ZERO)
			for side: float in [-1.0, 1.0]:
				_seal.draw_arc(center + Vector2(side * radius * 0.35, 0).rotated(spin), radius * 0.55, PI * 0.5 - side * PI * 0.5 - 0.9,
						PI * 0.5 - side * PI * 0.5 + 0.9, 12, color, 2.0)
		"seigaiha":
			# Seigaiha, the old Japanese pattern of overlapping waves: rows of half-rings.
			_seal.draw_arc(center, radius, 0.0, TAU, 48, color, 2.0)
			for row: int in 3:
				for k: int in 4:
					var at: Vector2 = center + Vector2((k - 1.5) * radius * 0.45 + (row % 2) * radius * 0.22, (row - 1) * radius * 0.4)
					_seal.draw_arc(at, radius * 0.22, PI, TAU, 10, color, 2.0)
		"slavic_rhombus":
			# Rows of rhombuses, the old embroidery pattern of the Slavic lands.
			_seal.draw_arc(center, radius, 0.0, TAU, 48, color, 2.0)
			for k: int in 8:
				var a: float = spin + TAU * k / 8.0
				var mid: Vector2 = center + Vector2.from_angle(a) * radius * 0.62
				var side: float = radius * 0.2
				_seal.draw_polyline(PackedVector2Array([mid + Vector2(0, -side), mid + Vector2(side, 0), mid + Vector2(0, side),
						mid + Vector2(-side, 0), mid + Vector2(0, -side)]), color, 2.0)
			_seal.draw_polyline(PackedVector2Array([center + Vector2(0, -radius * 0.3), center + Vector2(radius * 0.3, 0),
					center + Vector2(0, radius * 0.3), center + Vector2(-radius * 0.3, 0), center + Vector2(0, -radius * 0.3)]), color, 2.0)
		"persian_rosette":
			# A twelve-petalled rosette, as carved on the old stone palaces of Iran.
			_seal.draw_arc(center, radius, 0.0, TAU, 48, color, 2.0)
			for k: int in 12:
				var a: float = spin + TAU * k / 12.0
				_seal.draw_arc(center + Vector2.from_angle(a) * radius * 0.5, radius * 0.22, 0.0, TAU, 12, color, 2.0)
			_seal.draw_arc(center, radius * 0.2, 0.0, TAU, 24, color, 2.0)
		"mesopotamian_star":
			_seal.draw_arc(center, radius, 0.0, TAU, 48, color, 2.0)
			for k: int in 8:
				var a: float = spin + TAU * k / 8.0
				points = PackedVector2Array([center + Vector2.from_angle(a - 0.18) * radius * 0.28,
						center + Vector2.from_angle(a) * radius * 0.85, center + Vector2.from_angle(a + 0.18) * radius * 0.28])
				_seal.draw_polyline(points, color, 2.0)
			_seal.draw_arc(center, radius * 0.22, 0.0, TAU, 24, color, 2.0)
		"celtic_knot":
			for k: int in 4:
				var a: float = spin + TAU * k / 4.0
				_seal.draw_arc(center + Vector2.from_angle(a) * radius * 0.45, radius * 0.55, 0.0, TAU, 32, color, 2.0)
			_seal.draw_arc(center, radius, 0.0, TAU, 48, color, 2.0)
		_:
			# The meander ring: a square wave around a circle, spinning as it cracks.
			var depth: float = radius * 0.18
			for k: int in steps * 4 + 1:
				var a: float = spin + TAU * k / (steps * 4.0)
				var outer: bool = (k >> 1) % 2 == 0
				points.append(center + Vector2.from_angle(a) * (radius + (depth if outer else 0.0)))
			_seal.draw_polyline(points, color, 2.0)


func _add_line(text: String) -> void:
	var label := Label.new()
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = text
	_lines.add_child(label)
	_play_note(Data.cfg_float("pickups.tier_sound_hz"))


func _play_note(hz: float) -> void:
	_audio.stream = PickupAudio.make_blip(hz, Data.cfg_float("pickups.sound_length_s"))
	_audio.play()


func _make_label() -> Label:
	var label := Label.new()
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.visible = false
	_root.add_child(label)
	return label


func _weapon_name(weapon_id: String, level: int) -> String:
	return tr(WeaponInstance.name_key_at(GameAuthority.find_weapon(weapon_id), level))
