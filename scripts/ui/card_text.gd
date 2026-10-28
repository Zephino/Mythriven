class_name CardText
extends RefCounted
## Translated text for a level-up card: name, what changes, and description.
## Spell cards show their tier change ("Flame → Blaze").


static func title(card: Dictionary) -> String:
	var id: String = str(card.get("id", ""))
	match str(card.get("kind", "")):
		LevelUpRules.WEAPON_NEW, LevelUpRules.WEAPON_UP:
			return _tr(WeaponInstance.name_key_at(GameAuthority.find_weapon(id), maxi(int(card.get("to", 1)), 1)))
		LevelUpRules.PASSIVE_NEW, LevelUpRules.PASSIVE_UP:
			return _tr(str(LevelUpRules.passive_data(id).get("name_key", id)))
		LevelUpRules.STAT:
			return _tr("STAT_" + id.to_upper())
		LevelUpRules.GOLD:
			return _tr("CARD_GOLD_NAME")
		LevelUpRules.HEAL:
			return _tr("CARD_HEAL_NAME")
	return id


## Every line of the card, ready to show on a button.
static func full(card: Dictionary) -> String:
	var lines: PackedStringArray = [title(card)]
	var id: String = str(card.get("id", ""))
	var kind: String = str(card.get("kind", ""))
	match kind:
		LevelUpRules.WEAPON_NEW, LevelUpRules.PASSIVE_NEW:
			lines.append(_tr("CARD_NEW"))
		LevelUpRules.WEAPON_UP, LevelUpRules.PASSIVE_UP:
			lines.append(_tr("CARD_LEVEL_CHANGE") % [int(card["from"]), int(card["to"])])
	if is_tier_change(card):
		var weapon: Dictionary = GameAuthority.find_weapon(id)
		lines.append(_tr("CARD_TIER_CHANGE") % [
			_tr(WeaponInstance.name_key_at(weapon, int(card["from"]))), _tr(WeaponInstance.name_key_at(weapon, int(card["to"]))),
		])
	match kind:
		LevelUpRules.WEAPON_NEW, LevelUpRules.WEAPON_UP:
			lines.append(_tr(str(GameAuthority.find_weapon(id).get("desc_key", ""))))
		LevelUpRules.PASSIVE_NEW, LevelUpRules.PASSIVE_UP:
			var passive: Dictionary = LevelUpRules.passive_data(id)
			lines.append(_tr(str(passive.get("desc_key", ""))))
			lines.append(stat_change(str(passive.get("stat", "")), float(passive.get("per_level", 0.0))))
		LevelUpRules.STAT:
			lines.append(stat_change(id, float(card["amount"])))
		LevelUpRules.GOLD:
			lines.append(_tr("CARD_GOLD_DESC") % TextFormat.whole(float(card["amount"])))
		LevelUpRules.HEAL:
			lines.append(_tr("CARD_HEAL_DESC") % TextFormat.whole(float(card["amount"]) * 100.0))
	return "\n".join(lines)


## True when picking this card renames a spell to its next tier.
static func is_tier_change(card: Dictionary) -> bool:
	if str(card.get("kind", "")) != LevelUpRules.WEAPON_UP:
		return false
	var weapon: Dictionary = GameAuthority.find_weapon(str(card.get("id", "")))
	return WeaponInstance.name_key_at(weapon, int(card["from"])) != WeaponInstance.name_key_at(weapon, int(card["to"]))


## "Might +5%" or "Armor +1".
static func stat_change(stat: String, amount: float) -> String:
	var name: String = _tr("STAT_" + stat.to_upper())
	if stat == "armor":
		return _tr("CARD_STAT_FLAT") % [name, TextFormat.whole(amount)]
	return _tr("CARD_STAT_PCT") % [name, TextFormat.whole(amount * 100.0)]


static func _tr(key: String) -> String:
	return TranslationServer.translate(key)
