class_name GodRules
extends RefCounted
## Helpers for gods.json (GAME_DESIGN.md: Gods (summons); Finding gods;
## Divine Resonance and Patronage).
## - Which god a shrine offers: 50% one of the level's local gods, otherwise
##   any god, picked by rarity; never one already bound or on offer; rare gods
##   never before 8:00.
## - How fast a god's meter fills for a player: Votive Bell (god_charge),
##   Patronage (+15% for gods of the Hero's own pantheon; +8% with every god
##   for Heroes whose pantheon has no launch god), and Tomoe's Divine Link.

const FILE := "gods.json"


static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	return found


static func find(god_id: String) -> Dictionary:
	for god: Dictionary in all():
		if str(god.get("id", "")) == god_id:
			return god
	return {}


## True when no launch god shares the Hero's pantheon (they get the flat bonus instead).
static func has_launch_pantheon(pantheon: String) -> bool:
	for god: Dictionary in all():
		if str(god.get("pantheon", "")) == pantheon:
			return true
	return false


static func is_patron(player: Player, god: Dictionary) -> bool:
	return str(player.hero.get("patron_pantheon", "")) != "" and str(player.hero.get("patron_pantheon", "")) == str(god.get("pantheon", ""))


## Meter charge multiplier for `god` and `player`.
static func charge_mult(player: Player, god: Dictionary) -> float:
	var mult: float = 1.0 + float(player.stats.bonus.get("god_charge", 0.0))
	var pantheon: String = str(player.hero.get("patron_pantheon", ""))
	if is_patron(player, god):
		mult += Data.cfg_float("gods.patronage_charge_bonus")
	elif pantheon != "" and not has_launch_pantheon(pantheon):
		mult += Data.cfg_float("gods.no_patron_charge_bonus")
	# Tomoe Gozen's Divine Link: at full Momentum, god meters fill 25% faster.
	if str((player.hero.get("divine_link", {}) as Dictionary).get("id", "")) == "momentum_charges_gods" and player.kit != null:
		var stacks: Variant = player.kit.get("momentum")
		if stacks != null and int(stacks) >= int(player.kit.trait_data().get("max_stacks", 10)):
			mult += Data.cfg_float("gods.momentum_charge_bonus")
	return mult


## Picks the god for a new shrine. `taken` are gods bound or on offer.
## `favor_rare` (hidden shrines) weights uncommon and rare gods up. Returns "" if none fits.
static func pick_for_shrine(level: Dictionary, taken: PackedStringArray, seconds: float, rng: RandomNumberGenerator,
		favor_rare: bool = false) -> String:
	var weights: Dictionary = Data.cfg("gods.rarity_weights")
	if favor_rare:
		weights = Data.cfg("gods.hidden_rarity_weights")
	var pool: Dictionary = {}
	var local_pool: Dictionary = {}
	var locals: Array = level.get("local_gods", [])
	for god: Dictionary in all():
		var god_id: String = str(god["id"])
		var rarity: String = str(god.get("rarity", "common"))
		if taken.has(god_id) or (rarity == "rare" and seconds < Data.cfg_float("gods.rare_god_min_time_s")):
			continue
		pool[god_id] = float(weights.get(rarity, 1.0))
		if locals.has(god_id):
			local_pool[god_id] = pool[god_id]
	if not local_pool.is_empty() and rng.randf() < float(level.get("local_shrine_chance", 0.5)):
		return RunArc.pick_weighted(local_pool, rng)
	return RunArc.pick_weighted(pool, rng)


## The banter line for a trigger, or {} (lines with a Hero set win for that Hero).
static func line(trigger: String, god_id: String, hero_id: String) -> Dictionary:
	var general: Dictionary = {}
	var listed: Variant = Data.get_file("banter.json")
	for entry: Variant in (listed if listed is Array else []):
		if not entry is Dictionary or str(entry.get("trigger", "")) != trigger:
			continue
		var line_god: String = str(entry.get("god", ""))
		var line_hero: String = str(entry.get("hero", ""))
		if line_god != god_id and not (line_god == "" and line_hero == hero_id):
			continue
		if line_hero == hero_id and line_hero != "":
			return entry
		if line_hero == "":
			general = entry
	return general
