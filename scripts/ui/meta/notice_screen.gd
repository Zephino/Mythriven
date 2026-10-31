class_name NoticeScreen
extends MenuScreen
## A short message over the menus, with OK to close it (or no button while
## the game is busy, e.g. checking that this account isn't playing elsewhere).

var _title_key: String = ""
var _text_key: String = ""
var _with_ok: bool = true


static func make(title_key: String, text_key: String, with_ok: bool = true) -> NoticeScreen:
	var screen := NoticeScreen.new()
	screen._title_key = title_key
	screen._text_key = text_key
	screen._with_ok = with_ok
	return screen


func _ready() -> void:
	super._ready()
	layer = 110


func has_back() -> bool:
	return _with_ok


func build() -> void:
	set_title(tr_key(_title_key))
	add_line(tr_key(_text_key))
	if _with_ok:
		add_button(tr_key("UI_OK"), close)
