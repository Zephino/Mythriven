class_name SuggestionButton
extends Button
## Appears only on the main Hero-selection screen. Opens an in-game form;
## players don't need accounts and never leave the game to submit ideas.


func _ready() -> void:
	text = "UI_SUGGEST_FEATURE"
	tooltip_text = "UI_SUGGEST_FEATURE_HINT"
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	var form := SuggestionForm.new()
	form.closed.connect(grab_focus)
	get_tree().current_scene.add_child(form)
