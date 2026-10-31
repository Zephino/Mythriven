class_name UnlocksScreen
extends MenuScreen
## Unlocks (GAME_DESIGN.md: Gold sinks; Screens): buy Heroes and weapons with
## banked gold; see how the others are earned (achievements, bosses, secrets);
## equip a cosmetic you've found. Purchases save at once. Each is a card with its picture (owner decision
## 10/31/2026: item cards): a price button, how to earn it, or Unlocked.


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	set_title(tr_key("UI_UNLOCKS") + "  ·  " + tr_key("UI_GOLD_BANKED") % SaveGame.gold())
	add_section(tr_key("UI_UNLOCKS_HEROES"))
	for hero: Dictionary in HeroRules.all():
		var unlock: Dictionary = hero.get("unlock", {})
		if str(unlock.get("type", "starting")) == "starting":
			continue
		var picture: Texture2D = UiTheme.portrait(PixelArt.find(str(hero.get("id", ""))), 1)
		_item(picture, tr_key(str(hero.get("name_key", ""))), tr_key(str(hero.get("tradition_key", ""))), unlock,
				HeroRules.is_unlocked(hero), "hero", str(hero.get("id", "")))
	add_section(tr_key("UI_UNLOCKS_WEAPONS"))
	for weapon: Variant in Data.get_file(GameAuthority.WEAPONS_FILE):
		if not weapon is Dictionary or not (weapon as Dictionary).has("unlock"):
			continue
		var unlock: Dictionary = weapon["unlock"]
		if not ["gold", "achievement", "secret"].has(str(unlock.get("type", ""))):
			continue
		_item(UiTheme.weapon_icon(weapon), tr_key(str(weapon.get("name_key", ""))), tr_key(str(weapon.get("desc_key", ""))), unlock,
				LevelUpRules.is_unlocked(weapon, "weapons_unlocked"), "weapon", str(weapon.get("id", "")))
	add_section(tr_key("UI_UNLOCKS_COSMETICS"))
	var owned: Array = SaveGame.list("cosmetics")
	if owned.is_empty():
		add_card(null, tr_key("UI_NONE_YET"), [tr_key("UNLOCK_COSMETICS_HOW")], "", "", Callable(), true, true)
	var equipped: String = str(SaveGame.setting("cosmetic", ""))
	for cosmetic_id: Variant in owned:
		var id: String = str(cosmetic_id)
		var on: bool = equipped == id
		add_card(null, tr_key(str(Rewards.cosmetic(id).get("name_key", id))), [], tr_key("UNLOCK_EQUIPPED") if on else "",
				tr_key("UNLOCK_TAKE_OFF") if on else tr_key("UNLOCK_EQUIP"), _equip.bind("" if on else id))


## A Hero or weapon: Unlocked; a price button for gold unlocks; or how to earn it.
func _item(picture: Texture2D, name: String, about: String, unlock: Dictionary, owned: bool, kind: String, id: String) -> void:
	var lines: PackedStringArray = [about] if about != "" and not about.begins_with("WEAPON_") else []
	if owned:
		add_card(picture, name, lines, tr_key("UNLOCK_UNLOCKED"))
		return
	match str(unlock.get("type", "")):
		"gold":
			var cost: int = int(unlock.get("cost", 0))
			add_card(picture, name, lines, "", tr_key("OFFERING_COST") % cost, _buy.bind(kind, id, cost), SaveGame.gold() >= cost)
		"achievement":
			var key: String = "ACH_%s_NAME" % str(unlock.get("achievement", "")).to_upper()
			lines.append(tr_key("UNLOCK_HOW_ACHIEVEMENT") % tr_key(key))
			add_card(picture, name, lines, "", "", Callable(), true, true, true)
		"defeat_boss":
			lines.append(tr_key("UNLOCK_HOW_BOSS"))
			add_card(picture, name, lines, "", "", Callable(), true, true, true)
		_:
			add_card(picture, tr_key("BESTIARY_UNKNOWN"), [tr_key("UNLOCK_HOW_SECRET")], "", "", Callable(), true, true, true)


func _buy(kind: String, id: String, cost: int) -> void:
	if SaveGame.spend_gold(cost):
		if kind == "hero":
			HeroRules.unlock(id)
		else:
			SaveGame.add_to("weapons_unlocked", id)
	refresh()


func _equip(cosmetic_id: String) -> void:
	SaveGame.set_setting("cosmetic", cosmetic_id)
	refresh()
