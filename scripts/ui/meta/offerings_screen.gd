class_name OfferingsScreen
extends MenuScreen
## Offerings (GAME_DESIGN.md: Gods / Offerings; Screens / Offerings): every god as a card (owner decision
## 10/31/2026: item cards) with its picture, pantheon and role, its level, what the next level gives, and a button
## with its gold cost. Offering raises the level at once and saves. Gods never bound show greyed, saying how to
## meet them.


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	set_title(tr_key("UI_OFFERINGS") + "  ·  " + tr_key("UI_GOLD_BANKED") % SaveGame.gold())
	for god: Dictionary in GodRules.all():
		var id: String = str(god.get("id", ""))
		var face: Texture2D = UiTheme.god_face(id, 1)
		var kind: String = tr_key("PANTHEON_" + str(god.get("pantheon", "")).to_upper()) + "  ·  " + tr_key(str(god.get("role_key", "")))
		if not GodLevels.bound_ever(id):
			add_card(face, tr_key("COMPENDIUM_UNKNOWN_GOD"), [kind, tr_key("OFFERING_NONE")], "", "", Callable(), false, true, true)
			continue
		var name: String = tr_key(str(god.get("name_key", id)))
		var level: String = tr_key("OFFERING_LEVEL") % GodLevels.level(id)
		var cost: int = GodLevels.next_cost(id)
		if cost < 0:
			add_card(face, name, [kind, tr_key("OFFERING_MAXED")], level)
			continue
		add_card(face, name, [kind, tr_key("OFFERING_NEXT") % tr_key(GodLevels.next_unlock_key(id))], level,
				tr_key("OFFERING_COST") % cost, _offer.bind(id), SaveGame.gold() >= cost)


func _offer(god_id: String) -> void:
	GodLevels.offer(god_id)
	refresh()
