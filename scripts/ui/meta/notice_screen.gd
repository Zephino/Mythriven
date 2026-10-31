class_name NoticeScreen
extends MenuScreen
## A short message over the menus, with OK to close it (or no button while
## the game is busy, e.g. checking that this account isn't playing elsewhere).

var _title_key: String = ""
var _text_key: String = ""
var _with_ok: bool = true
## Text already filled in (used instead of _text_key), and buttons instead of OK: [[label key, Callable], ...].
var _text: String = ""
var _choices: Array = []


static func make(title_key: String, text_key: String, with_ok: bool = true) -> NoticeScreen:
	var screen := NoticeScreen.new()
	screen._title_key = title_key
	screen._text_key = text_key
	screen._with_ok = with_ok
	return screen


## A question with its own buttons (each closes the notice, then does its thing).
static func ask(title_key: String, text: String, choices: Array) -> NoticeScreen:
	var screen := NoticeScreen.make(title_key, "", false)
	screen._text = text
	screen._choices = choices
	return screen


func _ready() -> void:
	super._ready()
	layer = 110


func has_back() -> bool:
	return _with_ok


func build() -> void:
	set_title(tr_key(_title_key))
	add_line(_text if _text != "" else tr_key(_text_key))
	for choice: Array in _choices:
		var then: Callable = choice[1]
		add_button(tr_key(str(choice[0])), func() -> void:
			close()
			then.call())
	if _with_ok:
		add_button(tr_key("UI_OK"), close)
