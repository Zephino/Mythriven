class_name SettingsScreen
extends MenuScreen
## Settings (GAME_DESIGN.md: Screens / Settings; Accessibility settings): each
## row shows a setting and its value; pressing it steps to the next value.
## Saved at once. Opened from the title screen and the pause menu, so a
## change made mid-run takes effect when the screen closes (or at once, for
## volume, text size, and effect opacity). Below them: Fullscreen, and for the
## web version Install app and Update app (AppActions).

## The rows, in order. Each is a key in config settings.defaults.
const ROWS: PackedStringArray = [
	"volume_pct", "text_size_pct", "effect_opacity_pct", "shake", "flash", "damage_numbers", "element_icons",
	"colorblind", "auto_summon", "auto_collect", "control_size_pct", "joystick_side", "banter", "tips",
]

## A note under the app buttons (how to install on this device, updating…).
var _app_message: String = ""


func build() -> void:
	set_title(tr_key("UI_SETTINGS"))
	for key: String in ROWS:
		add_button(tr_key("UI_SETTING_" + key.to_upper()) % value_text(key), _on_row.bind(key))
	add_button(tr_key("UI_SETTING_RESET_TIPS"), _on_reset_tips, not Onboarding.seen().is_empty())
	add_button(tr_key("UI_CLOUD_SAVE"), func() -> void: open_child(CloudSaveScreen.new()))
	_build_app()


func _build_app() -> void:
	if AppActions.can_fullscreen():
		add_button(tr_key("UI_FULLSCREEN") % tr_key("UI_SETTING_ON" if AppActions.is_fullscreen() else "UI_SETTING_OFF"), _on_fullscreen)
	if AppActions.is_web():
		var installed: bool = AppActions.install_state() == "installed"
		add_button(tr_key("UI_INSTALLED_APP" if installed else "UI_INSTALL_APP"), _on_install, not installed)
		var playing: bool = Net.active() or (GameAuthority.run != null and not GameAuthority.run.ended)
		add_button(tr_key("UI_UPDATE_APP"), _on_update, not playing)
		if playing:
			add_line(tr_key("UI_UPDATE_IN_RUN"))
	if _app_message != "":
		add_line(tr_key(_app_message))


func _on_fullscreen() -> void:
	AppActions.toggle_fullscreen()
	# The browser switches a moment later.
	await get_tree().create_timer(0.4).timeout
	refresh()


func _on_install() -> void:
	match AppActions.install_state():
		"ready":
			_app_message = ""
			AppActions.install()
		"ios":
			_app_message = "UI_INSTALL_IOS"
		_:
			_app_message = "UI_INSTALL_UNAVAILABLE"
	refresh()


func _on_update() -> void:
	_app_message = "UI_UPDATING"
	refresh()
	Meta.cloud.play_lock.release()
	AppActions.update_now()


## How a setting's current value reads on its row.
static func value_text(key: String) -> String:
	var current: Variant = Settings.value(key)
	if current is bool:
		return TranslationServer.translate("UI_SETTING_ON" if current else "UI_SETTING_OFF")
	if key.ends_with("_pct"):
		return TranslationServer.translate("UI_SETTING_PERCENT") % roundi(float(current))
	if key == "auto_collect":
		return TranslationServer.translate("UI_AUTO_COLLECT_" + str(current).to_upper())
	return TranslationServer.translate("UI_SETTING_VALUE_" + str(current).to_upper())


func _on_row(key: String) -> void:
	Settings.step(key)
	Settings.apply(get_tree())
	refresh()
	_focus_row(key)


func _on_reset_tips() -> void:
	Onboarding.reset()
	refresh()


## Puts focus back on the row just changed, so stepping through values with a
## gamepad or keyboard doesn't jump back to the top.
func _focus_row(key: String) -> void:
	var index: int = ROWS.find(key) + (1 if _back.visible else 0)
	if index >= 0 and index < _buttons.size():
		focus_later(_buttons[index])


## Settings read once per run pick up the change here.
func close() -> void:
	Settings.apply(get_tree())
	GameAuthority.auto_collect = Settings.text("auto_collect")
	if GameAuthority.gods != null:
		GameAuthority.gods.auto_summon = Settings.flag("auto_summon")
	super.close()
