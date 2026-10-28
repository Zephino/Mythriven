extends Node
## Autoload "Localization". All player-facing text goes through tr() with keys
## from res://localization/text.csv (GAME_DESIGN.md: Translation-ready text).
## This script switches Godot's built-in pseudo-localization on and off, using
## the settings in config.json, so hard-coded or clipped text is easy to spot.

signal changed

const SETTINGS := "internationalization/pseudolocalization/"

var pseudo_enabled: bool = false


func set_pseudo(enabled: bool) -> void:
	pseudo_enabled = enabled
	ProjectSettings.set_setting(SETTINGS + "expansion_ratio", Data.cfg_float("localization.pseudo_expansion_ratio"))
	ProjectSettings.set_setting(SETTINGS + "prefix", Data.cfg_string("localization.pseudo_prefix"))
	ProjectSettings.set_setting(SETTINGS + "suffix", Data.cfg_string("localization.pseudo_suffix"))
	ProjectSettings.set_setting(SETTINGS + "replace_with_accents", Data.cfg_bool("localization.pseudo_accents"))
	ProjectSettings.set_setting(SETTINGS + "double_vowels", Data.cfg_bool("localization.pseudo_double_vowels"))
	ProjectSettings.set_setting(SETTINGS + "fake_bidi", Data.cfg_bool("localization.pseudo_fake_bidi"))
	ProjectSettings.set_setting(SETTINGS + "skip_placeholders", Data.cfg_bool("localization.pseudo_skip_placeholders"))
	TranslationServer.pseudolocalization_enabled = enabled
	TranslationServer.reload_pseudolocalization()
	# Ask every Label and Button to look up its text again.
	get_tree().root.propagate_notification(NOTIFICATION_TRANSLATION_CHANGED)
	changed.emit()
