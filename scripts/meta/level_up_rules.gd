class_name LevelUpRules
extends RefCounted
## Level-up rules (GAME_DESIGN.md: Core mechanics / Level-up choices; XP).
## - XP curve: level 2 needs 5 XP, each later level ~10% more.
## - 3 cards (4 with high Luck): new weapons/passives, their upgrades, and
##   stat cards. Items already owned are slightly favoured. Maxed items are
##   never offered. No hard stat caps, so stat cards are always useful.
## - When every weapon and passive slot is full and maxed, the item cards are
##   replaced by Gold and Heal (the build is "maxed").
## A card: {"kind": String, "id": String, "from": int, "to": int, "amount": float}.

const WEAPON_NEW := "weapon_new"
const WEAPON_UP := "weapon_up"
const PASSIVE_NEW := "passive_new"
const PASSIVE_UP := "passive_up"
const STAT := "stat"
const GOLD := "gold"
const HEAL := "heal"
const PASSIVES_FILE := "passives.json"


## XP needed to go from `level` to `level + 1`: level 2 needs `level_2_xp`,
## each level after needs `step_per_level` more, and `growth_per_level`
## (0 = off) can make the whole curve grow by a percentage too.
static func xp_to_next(level: int) -> float:
	var steps: int = maxi(level - 1, 0)
	var linear: float = Data.cfg_float("xp.level_2_xp") + Data.cfg_float("xp.step_per_level") * steps
	return roundf(linear * pow(1.0 + Data.cfg_float("xp.growth_per_level"), steps))


static func passive_data(passive_id: String) -> Dictionary:
	var listed: Variant = Data.get_file(PASSIVES_FILE)
	if listed is Array:
		for entry: Variant in listed:
			if entry is Dictionary and (entry as Dictionary).get("id", "") == passive_id:
				return entry
	return {}


## Every weapon/passive card this player could get right now.
static func item_cards(player: Player) -> Array[Dictionary]:
	var cards: Array[Dictionary] = []
	var owned: Dictionary = {}
	for weapon: WeaponInstance in player.weapons:
		owned[weapon.id()] = true
		owned[weapon.base_id] = true
		if weapon.level < weapon.max_level() and not _banished(weapon.id()):
			var up: Dictionary = _card(WEAPON_UP, weapon.id(), weapon.level, weapon.level + 1)
			up["expert"] = weapon.expert
			cards.append(up)
	if player.weapons.size() < Data.cfg_int("level_up.max_weapons"):
		var weapons: Variant = Data.get_file(GameAuthority.WEAPONS_FILE)
		for entry: Variant in (weapons if weapons is Array else []):
			var weapon_id: String = str(entry["id"])
			if bool(entry.get("in_level_up_pool", false)) and not owned.has(weapon_id) and not _banished(weapon_id) \
					and is_unlocked(entry, "weapons_unlocked"):
				var new_card: Dictionary = _card(WEAPON_NEW, weapon_id, 0, 1)
				new_card["expert"] = HeroRules.is_expert(player.hero, entry)
				cards.append(new_card)
	var passives: Variant = Data.get_file(PASSIVES_FILE)
	for entry: Variant in (passives if passives is Array else []):
		var passive_id: String = str(entry["id"])
		if _banished(passive_id) or not is_unlocked(entry, "passives_unlocked"):
			continue
		var level: int = int(player.passives.get(passive_id, 0))
		if level > 0 and level < int(entry["max_level"]):
			cards.append(_card(PASSIVE_UP, passive_id, level, level + 1))
		elif level == 0 and player.passives.size() < Data.cfg_int("level_up.max_passives"):
			cards.append(_card(PASSIVE_NEW, passive_id, 0, 1))
	return cards


## False for weapons and passives that must be unlocked first (with gold, an
## achievement, or a secret) and aren't yet. `section` is the save list.
static func is_unlocked(entry: Dictionary, section: String) -> bool:
	var unlock: Variant = entry.get("unlock", {})
	if not unlock is Dictionary or not ["gold", "achievement", "secret"].has(str(unlock.get("type", ""))):
		return true
	return SaveGame.list(section).has(str(entry.get("id", "")))


static func stat_cards() -> Array[Dictionary]:
	var cards: Array[Dictionary] = []
	var values: Dictionary = Data.cfg("level_up.stat_card_values")
	for stat: String in values:
		var card: Dictionary = _card(STAT, stat, 0, 0)
		card["amount"] = float(values[stat])
		cards.append(card)
	return cards


## True when no weapon or passive card is left (every slot full and maxed).
static func is_maxed(player: Player) -> bool:
	return item_cards(player).is_empty()


static func card_count(player: Player) -> int:
	if player.stats.luck() >= Data.cfg_float("level_up.high_luck_threshold"):
		return Data.cfg_int("level_up.cards_high_luck")
	return Data.cfg_int("level_up.cards")


## Builds the cards for one level-up, using the run's loot generator.
static func build_offer(player: Player, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var count: int = card_count(player)
	var offer: Array[Dictionary] = []
	var pool: Array[Dictionary] = []
	if is_maxed(player):
		offer.append(gold_card())
		offer.append(heal_card())
	else:
		pool = item_cards(player)
	pool.append_array(stat_cards())
	while offer.size() < count and not pool.is_empty():
		var index: int = _pick_weighted(pool, rng)
		offer.append(pool[index])
		pool.remove_at(index)
	return offer


static func gold_card() -> Dictionary:
	var card: Dictionary = _card(GOLD, "gold", 0, 0)
	card["amount"] = Data.cfg_float("level_up.maxed_gold")
	return card


static func heal_card() -> Dictionary:
	var card: Dictionary = _card(HEAL, "heal", 0, 0)
	card["amount"] = Data.cfg_float("level_up.maxed_heal_pct")
	return card


## The Auto-collect choice for a maxed build: "gold", "heal", or "smart"
## (heal below 50% HP, otherwise gold). Returns an empty card when off.
static func auto_collect_card(setting: String, player: Player) -> Dictionary:
	match setting:
		"gold":
			return gold_card()
		"heal":
			return heal_card()
		"smart":
			var low: bool = player.hp < player.max_hp * Data.cfg_float("level_up.smart_heal_below_hp_pct")
			return heal_card() if low else gold_card()
	return {}


## Items banished with the Trader's Banish token never come back this run.
static func _banished(item_id: String) -> bool:
	return GameAuthority.run != null and GameAuthority.run.banished.has(item_id)


static func _card(kind: String, id: String, from_level: int, to_level: int) -> Dictionary:
	return {"kind": kind, "id": id, "from": from_level, "to": to_level, "amount": 0.0}


static func _pick_weighted(pool: Array[Dictionary], rng: RandomNumberGenerator) -> int:
	var weights := PackedFloat32Array()
	var total: float = 0.0
	for card: Dictionary in pool:
		var weight: float = Data.cfg_float("level_up.stat_card_weight")
		if card["kind"] == WEAPON_UP or card["kind"] == PASSIVE_UP:
			weight = Data.cfg_float("level_up.owned_item_weight")
		elif card["kind"] == WEAPON_NEW or card["kind"] == PASSIVE_NEW:
			weight = Data.cfg_float("level_up.new_item_weight")
		weights.append(weight)
		total += weight
	var roll: float = rng.randf() * total
	for i: int in weights.size():
		roll -= weights[i]
		if roll <= 0.0:
			return i
	return weights.size() - 1
