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
	box.focus_entered.connect(func() -> void: _ask(box, label))


## True in a browser on a phone or tablet.
static func needed() -> bool:
	return OS.has_feature("web") and SafeArea.is_handheld()


static func _ask(box: Control, label: String) -> void:
	var question: String = label if label != "" else TranslationServer.translate(str(box.get("placeholder_text")))
	var current: String = str(box.get("text"))
	var answer: Variant = JavaScriptBridge.eval("window.prompt(%s, %s)" % [JSON.stringify(question), JSON.stringify(current)], true)
	# Let go of the box so tapping it again asks again.
	box.release_focus()
	if not answer is String:
		return
	if box is LineEdit:
		var line := box as LineEdit
		line.text = (answer as String).left(line.max_length) if line.max_length > 0 else answer
		line.text_changed.emit(line.text)
	elif box is TextEdit:
		(box as TextEdit).text = answer
		(box as TextEdit).text_changed.emit()
