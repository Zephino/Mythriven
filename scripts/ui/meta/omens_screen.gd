class_name OmensScreen
extends MenuScreen
## Omens (GAME_DESIGN.md: Omens): switch challenge modifiers on or off for
## your next runs. They stack, each adds gold, and records are kept per Omen set.


func build() -> void:
	var active: PackedStringArray = OmenRules.active()
	set_title(tr_key("UI_OMENS") + "  ·  " + tr_key("UI_OMENS_BONUS") % roundi((Banking.bonus_mult(active, false) - 1.0) * 100.0))
	for omen: Dictionary in OmenRules.all():
		var id: String = str(omen.get("id", ""))
		var on: bool = active.has(id)
		var text: String = tr_key("OMEN_ROW") % [tr_key(str(omen.get("name_key", id))), tr_key(str(omen.get("desc_key", ""))),
			int(omen.get("gold_bonus_pct", 0))]
		add_button((tr_key("UI_ON_MARK") if on else tr_key("UI_OFF_MARK")) + " " + text, _toggle.bind(id, not on))


func _toggle(omen_id: String, on: bool) -> void:
	OmenRules.set_active(omen_id, on)
	refresh()
