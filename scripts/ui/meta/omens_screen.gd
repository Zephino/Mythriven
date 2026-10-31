class_name OmensScreen
extends MenuScreen
## Omens (GAME_DESIGN.md: Omens): switch challenge modifiers on or off for
## your next runs. They stack, each adds gold, and records are kept per Omen set. Each Omen is a card with its
## gold bonus and an On/Off button (owner decision 10/31/2026: item cards).


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	var active: PackedStringArray = OmenRules.active()
	var bonus: String = tr_key("UI_OMENS_BONUS") % roundi((Banking.bonus_mult(active, false) - 1.0) * 100.0)
	set_title(tr_key("UI_OMENS") + "  ·  " + bonus)
	add_section(tr_key("OMENS_TOTAL") % bonus)
	for omen: Dictionary in OmenRules.all():
		var id: String = str(omen.get("id", ""))
		var on: bool = active.has(id)
		add_card(null, tr_key(str(omen.get("name_key", id))), [tr_key(str(omen.get("desc_key", "")))],
				tr_key("OMEN_GOLD") % int(omen.get("gold_bonus_pct", 0)), tr_key("OMEN_ON") if on else tr_key("OMEN_OFF"),
				_toggle.bind(id, not on), true, not on)


func _toggle(omen_id: String, on: bool) -> void:
	OmenRules.set_active(omen_id, on)
	refresh()
