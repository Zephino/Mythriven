class_name WebTextInput
extends RefCounted
## Typing on a phone in the web version: a browser game can't bring up the
## phone's keyboard by itself, so tapping a text box there opens the
## browser's own text box instead (it always shows the keyboard), and what's
## typed goes into the game's box. Does nothing on PC, in apps, or in the
## desktop browser, where typing works as usual.


## Call once for each LineEdit or TextEdit. `label` is what the pop-up asks
## (already translated; the box's hint is used when empty).
static func attach(box: Control, label: String = "") -> void:
	if not needed():
		return
	box.gui_input.connect(func(event: InputEvent) -> void: _on_input(box, label, event))


## One pop-up per tap (on the finger lifting), never again straight after one closes.
static func _on_input(box: Control, label: String, event: InputEvent) -> void:
	var lifted: bool = (event is InputEventMouseButton and not (event as InputEventMouseButton).pressed) \
			or (event is InputEventScreenTouch and not (event as InputEventScreenTouch).pressed)
	if not lifted or Time.get_ticks_msec() < int(box.get_meta("web_text_quiet_until", 0)):
		return
	box.accept_event()
	# A tap arrives as both a touch and a mouse click: ask only once.
	box.set_meta("web_text_quiet_until", Time.get_ticks_msec() + 100000)
	_ask.call_deferred(box, label)


## True in a browser on a phone or tablet.
static func needed() -> bool:
	return OS.has_feature("web") and SafeArea.is_handheld()


static func _ask(box: Control, label: String) -> void:
	var question: String = label if label != "" else TranslationServer.translate(str(box.get("placeholder_text")))
	var current: String = str(box.get("text"))
	var answer: Variant = JavaScriptBridge.eval("window.prompt(%s, %s)" % [JSON.stringify(question), JSON.stringify(current)], true)
	# The tap that opened it can echo back as the pop-up closes; ignore taps for a moment.
	box.set_meta("web_text_quiet_until", Time.get_ticks_msec() + 600)
	if not answer is String:
		return
	if box is LineEdit:
		var line := box as LineEdit
		line.text = (answer as String).left(line.max_length) if line.max_length > 0 else answer
		line.text_changed.emit(line.text)
	elif box is TextEdit:
		(box as TextEdit).text = answer
		(box as TextEdit).text_changed.emit()
