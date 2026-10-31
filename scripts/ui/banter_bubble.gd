class_name BanterBubble
extends CanvasLayer
## Hero and god banter (GAME_DESIGN.md: Hero and god banter): a portrait and
## a one-sentence text bubble in the bottom-left corner for 3 s. Never pauses
## the game; lines queue. Can be switched off (config banter.enabled; a
## Settings toggle comes in Phase 19). Portraits are placeholder colour squares.

var _panel: PanelContainer
var _portrait: ColorRect
var _face: TextureRect
var _name: Label
var _text: Label
var _queue: Array[Dictionary] = []
var _left: float = 0.0


## Co-op: the host passes every line on to the joining players (CoopHost).
signal said(line: Dictionary)


func _ready() -> void:
	add_to_group("banter_bubble")
	layer = 31
	process_mode = Node.PROCESS_MODE_ALWAYS
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var root := SafeAreaBox.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_panel)
	_place()
	var row := HBoxContainer.new()
	_panel.add_child(row)
	_portrait = ColorRect.new()
	_portrait.custom_minimum_size = Vector2.ONE * Data.cfg_float("banter.portrait_px")
	row.add_child(_portrait)
	# The speaker's face over their colour (owner request 10/31/2026).
	_face = TextureRect.new()
	_face.set_anchors_preset(Control.PRESET_FULL_RECT)
	_face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.add_child(_face)
	var column := VBoxContainer.new()
	row.add_child(column)
	_name = Label.new()
	_name.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	column.add_child(_name)
	_text = Label.new()
	_text.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size.x = Data.cfg_float("banter.width_px")
	column.add_child(_text)
	_panel.visible = false


## Queues a line from banter.json ({} is ignored).
func say_line(line: Dictionary) -> void:
	_place()
	if line.is_empty():
		return
	said.emit(line)
	if not Data.cfg_bool("banter.enabled") or not Settings.flag("banter"):
		return
	Meta.note_banter(str(line.get("text_key", "")))
	_queue.append(line)
	if not _panel.visible:
		_next()


func current_line() -> Dictionary:
	return {} if _queue.is_empty() and not _panel.visible else {"text": _text.text}


func _process(delta: float) -> void:
	if not _panel.visible:
		return
	_left -= delta
	if _left <= 0.0:
		_next()


func _next() -> void:
	if _queue.is_empty():
		_panel.visible = false
		return
	var line: Dictionary = _queue.pop_front()
	var speaker: String = str(line.get("speaker", ""))
	var god: Dictionary = GodRules.find(speaker)
	var hero: Dictionary = HeroRules.find(speaker)
	var who: Dictionary = god if not god.is_empty() else hero
	var art: Dictionary = PixelArt.god(speaker) if not god.is_empty() else PixelArt.find(speaker)
	if who.is_empty():
		var boss: Dictionary = BossManager.find(speaker)
		who = {"name_key": boss.get("name_key", ""), "placeholder_color": Data.cfg_string("bosses.banter_color")}
		art = PixelArt.boss(str(boss.get("enemy", "")))
	var color := Color.html(str(who.get("placeholder_color", "#ffffff")))
	_face.texture = UiTheme.portrait(art, 1)
	_portrait.color = color.darkened(0.6) if _face.texture != null else color
	_name.text = tr(str(who.get("name_key", "")))
	_text.text = tr(str(line.get("text_key", "")))
	_panel.visible = true
	_left = Data.cfg_float("banter.display_s")


## Bottom-left, or bottom-right when the joystick setting moves the god
## buttons to the left, so the bubble never covers them.
func _place() -> void:
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")
	var right: bool = Settings.text("joystick_side") == "right"
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT if right else Control.PRESET_BOTTOM_LEFT)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN if right else Control.GROW_DIRECTION_END
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	# Equal offsets on each axis; the panel then grows to its text from that corner.
	_panel.offset_left = -margin_px if right else margin_px
	_panel.offset_right = _panel.offset_left
	_panel.offset_bottom = -margin_px - Data.cfg_float("banter.bottom_offset_px")
	_panel.offset_top = _panel.offset_bottom
