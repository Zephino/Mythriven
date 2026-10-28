class_name DeathScreen
extends CanvasLayer
## Shown when every player has fallen: a title, a short summary, and Retry
## (same Hero and level). The full death recap comes in Phase 15.

var _panel: PanelContainer
var _summary: Label
var _retry: Button


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	root.add_child(_panel)
	var box := VBoxContainer.new()
	_panel.add_child(box)
	var title := Label.new()
	title.text = "UI_FALLEN_TITLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_summary = Label.new()
	_summary.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	box.add_child(_summary)
	_retry = Button.new()
	_retry.text = "UI_RETRY"
	_retry.custom_minimum_size = Vector2(Data.cfg_float("ui.min_touch_target_px") * 3.0, Data.cfg_float("ui.min_touch_target_px"))
	_retry.pressed.connect(_on_retry)
	box.add_child(_retry)
	visible = false


## Shows the screen with one line of summary per entry.
func show_summary(lines: PackedStringArray) -> void:
	_summary.text = "\n".join(lines)
	visible = true
	_retry.grab_focus()


func _on_retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
