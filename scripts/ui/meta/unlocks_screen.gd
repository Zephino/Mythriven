class_name UnlocksScreen
extends MenuScreen
## Unlocks (GAME_DESIGN.md: Gold sinks; Screens): buy Heroes and weapons with
## banked gold; see how the others are earned (achievements, bosses, secrets);
## equip a cosmetic you've found. Purchases save at once.


func build() -> void:
	set_title(tr_key("UI_UNLOCKS") + "  ·  " + tr_key("UI_GOLD_BANKED") % SaveGame.gold())
	add_line(tr_key("UI_UNLOCKS_HEROES"))
	for hero: Dictionary in HeroRules.all():
		var unlock: Dictionary = hero.get("unlock", {})
		var name: String = tr_key(str(hero.get("name_key", "")))
		if HeroRules.is_unlocked(hero):
			if str(unlock.get("type", "starting")) != "starting":
				add_line(tr_key("UI_UNLOCKED_ROW") % name)
		else:
			_offer(name, unlock, "hero", str(hero.get("id", "")))
	add_line(tr_key("UI_UNLOCKS_WEAPONS"))
	for weapon: Variant in Data.get_file(GameAuthority.WEAPONS_FILE):
		if not weapon is Dictionary or not (weapon as Dictionary).has("unlock"):
			continue
		var unlock: Dictionary = weapon["unlock"]
		if not ["gold", "achievement", "secret"].has(str(unlock.get("type", ""))):
			continue
		var name: String = tr_key(str(weapon.get("name_key", "")))
		if LevelUpRules.is_unlocked(weapon, "weapons_unlocked"):
			add_line(tr_key("UI_UNLOCKED_ROW") % name)
		else:
			_offer(name, unlock, "weapon", str(weapon.get("id", "")))
	add_line(tr_key("UI_UNLOCKS_COSMETICS"))
	var owned: Array = SaveGame.list("cosmetics")
	if owned.is_empty():
		add_line(tr_key("UI_NONE_YET"))
	var equipped: String = str(SaveGame.setting("cosmetic", ""))
	for cosmetic_id: Variant in owned:
		var id: String = str(cosmetic_id)
		var name: String = tr_key(str(Rewards.cosmetic(id).get("name_key", id)))
		add_button(tr_key("UI_COSMETIC_ON") % name if equipped == id else tr_key("UI_COSMETIC_OFF") % name,
				_equip.bind("" if equipped == id else id))


## A locked Hero or weapon: a buy button for gold unlocks, else how to earn it.
func _offer(name: String, unlock: Dictionary, kind: String, id: String) -> void:
	match str(unlock.get("type", "")):
		"gold":
			var cost: int = int(unlock.get("cost", 0))
			add_button(tr_key("UI_BUY_ROW") % [name, cost], _buy.bind(kind, id, cost), SaveGame.gold() >= cost)
		"achievement":
			var achievement: String = str(unlock.get("achievement", ""))
			var key: String = "ACH_%s_NAME" % achievement.to_upper()
			add_line(tr_key("UI_LOCKED_ACHIEVEMENT") % [name, tr_key(key)])
		"defeat_boss":
			add_line(tr_key("UI_LOCKED_BOSS") % name)
		_:
			add_line(tr_key("UI_LOCKED_SECRET") % name)


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
