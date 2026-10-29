class_name OracleScreen
extends MenuScreen
## The Oracle (GAME_DESIGN.md: Secret unlocks; after the Oracle of Delphi):
## after every 5 runs she offers one cryptic hint about an undiscovered secret.


func build() -> void:
	set_title(tr_key("UI_ORACLE"))
	var runs: int = int((SaveGame.data()["oracle"] as Dictionary).get("runs", 0))
	add_line(tr_key("ORACLE_NEXT") % maxi(Data.cfg_int("meta.oracle_runs_per_hint") - runs, 0))
	var hints: PackedStringArray = SecretRules.hints()
	if hints.is_empty():
		add_line(tr_key("ORACLE_NONE"))
	for secret_id: String in hints:
		var secret: Dictionary = SecretRules.find(secret_id)
		var found: bool = SecretRules.is_found(secret_id)
		add_line("“" + tr_key(str(secret.get("hint_key", ""))) + "”" + ("  " + tr_key("ORACLE_FULFILLED") if found else ""))
