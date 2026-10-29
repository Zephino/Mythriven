class_name SafeAreaBox
extends Control
## A full-screen control that keeps itself inside the safe area (clear of
## phone notches and rounded corners), refitting when the screen size changes.
## Menus and the HUD put their contents in one. On PC it is the whole screen.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_viewport().size_changed.connect(fit)
	fit()


func fit() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var view: Rect2 = get_viewport().get_visible_rect()
	var safe: Rect2 = SafeArea.rect(get_viewport())
	offset_left = safe.position.x - view.position.x
	offset_top = safe.position.y - view.position.y
	offset_right = safe.end.x - view.end.x
	offset_bottom = safe.end.y - view.end.y
