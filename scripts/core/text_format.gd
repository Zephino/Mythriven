class_name TextFormat
extends RefCounted
## Numbers and times shown to players go through these helpers, never by
## gluing text together (GAME_DESIGN.md: Translation-ready text).


## "12:05" style run time (minutes can exceed 59).
static func run_time(seconds: float) -> String:
	var total: int = maxi(floori(seconds), 0)
	return TranslationServer.translate("FORMAT_RUN_TIME") % [floori(total / 60.0), total % 60]


## Whole number, as shown in damage numbers and counters.
static func whole(value: float) -> String:
	return TranslationServer.translate("FORMAT_WHOLE_NUMBER") % roundi(value)
