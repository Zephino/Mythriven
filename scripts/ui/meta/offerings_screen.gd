class_name OfferingsScreen
extends MenuScreen
## Offerings (GAME_DESIGN.md: Gods / Offerings; Screens / Offerings): every
## god ever bound, its level, what the next level unlocks, and its gold cost.
## Offering raises the level at once and saves.


func build() -> void:
	set_title(tr_key("UI_OFFERINGS") + "  ·  " + tr_key("UI_GOLD_BANKED") % SaveGame.gold())
	var any: bool = false
	for god: Dictionary in GodRules.all():
		var id: String = str(god.get("id", ""))
		if not GodLevels.bound_ever(id):
			continue
		any = true
		var name: String = tr_key(str(god.get("name_key", id)))
		var cost: int = GodLevels.next_cost(id)
		if cost < 0:
			add_line(tr_key("OFFERING_ROW_MAX") % [name, GodLevels.level(id)])
			continue
		var text: String = tr_key("OFFERING_ROW") % [name, GodLevels.level(id), tr_key(GodLevels.next_unlock_key(id)), cost]
		add_button(text, _offer.bind(id), SaveGame.gold() >= cost)
	if not any:
		add_line(tr_key("OFFERING_NONE"))


func _offer(god_id: String) -> void:
	GodLevels.offer(god_id)
	refresh()
