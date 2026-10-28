class_name EvolutionRules
extends RefCounted
## Standard evolutions (GAME_DESIGN.md: Weapons / Standard evolutions): a
## weapon at its top level plus its paired passive owned → the next chest
## evolves it into the weapon named in its "evolution" data. The evolved
## weapon replaces it in the same slot (expertise is kept). Each recipe found
## goes into the Codex.

const CODEX_SECTION := "codex"
const CODEX_KEY := "evolutions"


## True when `weapon` can evolve now for `player`.
static func can_evolve(weapon: WeaponInstance, player: Player) -> bool:
	if weapon.evolved or weapon.level < weapon.max_level():
		return false
	var evolution: Variant = weapon.data.get("evolution")
	if not evolution is Dictionary:
		return false
	return int(player.passives.get(str((evolution as Dictionary).get("passive", "")), 0)) > 0


## Weapons of `player` that the next chest would evolve.
static func candidates(player: Player) -> Array[WeaponInstance]:
	var found: Array[WeaponInstance] = []
	for weapon: WeaponInstance in player.weapons:
		if can_evolve(weapon, player):
			found.append(weapon)
	return found


## Every recipe in weapons.json: [{"weapon", "passive", "into"}].
static func all_recipes() -> Array[Dictionary]:
	var recipes: Array[Dictionary] = []
	var listed: Variant = Data.get_file(GameAuthority.WEAPONS_FILE)
	for entry: Variant in (listed if listed is Array else []):
		var evolution: Variant = (entry as Dictionary).get("evolution")
		if evolution is Dictionary:
			recipes.append({"weapon": str(entry["id"]), "passive": str(evolution.get("passive", "")),
					"into": str(evolution.get("into", ""))})
	return recipes


## Evolves `weapon` in place. Returns the recipe {"weapon", "passive", "into"}, or {} if it can't.
static func evolve(weapon: WeaponInstance) -> Dictionary:
	var evolution: Variant = weapon.data.get("evolution")
	if not evolution is Dictionary:
		return {}
	var into: Dictionary = GameAuthority.find_weapon(str((evolution as Dictionary).get("into", "")))
	if into.is_empty():
		return {}
	var recipe: Dictionary = {"weapon": weapon.id(), "passive": str(evolution.get("passive", "")), "into": str(into["id"])}
	weapon.base_id = weapon.id()
	weapon.data = into
	weapon.level = 1
	weapon.evolved = true
	weapon.hit_wait.clear()
	return recipe


## Records a recipe in the Codex. Returns true the first time it's found.
static func discover(recipe: Dictionary) -> bool:
	return Profile.add_to_list(CODEX_SECTION, CODEX_KEY, str(recipe.get("into", "")))


static func is_discovered(into_id: String) -> bool:
	return Profile.get_list(CODEX_SECTION, CODEX_KEY).has(into_id)
