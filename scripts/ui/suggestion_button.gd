class_name SuggestionButton
extends Button
## An optional, external feature-request link. No player data or game state is
## sent automatically; GitHub handles the suggestion form and sign-in.

const REQUEST_URL := "https://github.com/Zephino/Mythriven/issues/new?template=feature_request.yml"


func _ready() -> void:
	text = "UI_SUGGEST_FEATURE"
	tooltip_text = "UI_SUGGEST_FEATURE_HINT"
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	# Open on the press event so browsers allow the new tab on Web exports.
	var result: Error = OS.shell_open(REQUEST_URL)
	if result != OK:
		push_warning("SuggestionButton: could not open feature request URL (error %d)" % result)
