class_name OracleScreen
extends MenuScreen
## The Oracle (GAME_DESIGN.md: Secret unlocks; after the Oracle of Delphi):
## after every 5 runs she offers one cryptic hint about an undiscovered secret. Each hint is a card, marked when
## fulfilled (owner decision 10/31/2026: the menus' information laid out tidily).


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	set_title(tr_key("UI_ORACLE"))
	var runs: int = int((SaveGame.data()["oracle"] as Dictionary).get("runs", 0))
	add_section(tr_key("UI_ORACLE"))
	add_line(tr_key("ORACLE_NEXT") % maxi(Data.cfg_int("meta.oracle_runs_per_hint") - runs, 0))
	var hints: PackedStringArray = SecretRules.hints()
	if hints.is_empty():
		add_card(null, tr_key("ORACLE_SILENT"), [tr_key("ORACLE_NONE")], "", "", Callable(), true, true)
	for i: int in hints.size():
		var secret: Dictionary = SecretRules.find(hints[i])
		var found: bool = SecretRules.is_found(hints[i])
		add_card(null, tr_key("ORACLE_HINT") % (i + 1), ["“" + tr_key(str(secret.get("hint_key", ""))) + "”"],
				tr_key("ORACLE_FULFILLED") if found else "")
