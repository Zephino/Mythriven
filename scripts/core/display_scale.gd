extends Node
## Autoload "DisplayScale". On phones and tablets, makes everything (menus,
## HUD, buttons, text, and the world) bigger than on PC, on top of the normal
## screen scaling, so it's easy to read and tap. Size: ui.handheld_scale.


func _ready() -> void:
	if SafeArea.is_handheld():
		get_tree().root.content_scale_factor = Data.cfg_float("ui.handheld_scale")
