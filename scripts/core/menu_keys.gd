class_name MenuKeys
extends RefCounted
## W A S D move between buttons in every menu and pop-up, like the arrow keys
## (owner request 10/31/2026); Space or Enter presses the selected button
## (Godot's own ui_accept). Added to Godot's built-in ui_* actions at startup,
## so the arrow keys and gamepad keep working. Text boxes still take the
## letters as typing.

const KEYS := {"ui_up": KEY_W, "ui_left": KEY_A, "ui_down": KEY_S, "ui_right": KEY_D}


static func install() -> void:
	for action: String in KEYS:
		var key := InputEventKey.new()
		key.physical_keycode = KEYS[action]
		if not InputMap.action_has_event(action, key):
			InputMap.action_add_event(action, key)
	var space := InputEventKey.new()
	space.physical_keycode = KEY_SPACE
	if not InputMap.action_has_event("ui_accept", space):
		InputMap.action_add_event("ui_accept", space)
