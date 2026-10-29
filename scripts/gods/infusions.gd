class_name Infusions
extends RefCounted
## Divine infusions (GAME_DESIGN.md: Weapons / Divine infusions): a weapon at
## its top level (evolved or not) plus a bound god of a different element →
## the next chest infuses it with that god's element, using one of 8
## templates (elements.json "infusions"): hits apply the element's status and
## kills (or hits) add the template's effect. One infusion per weapon. A god of
## the weapon's own element makes it Empowered instead (+50% status chance and
## duration). Names build automatically: prefix + weapon name ("Thunder Gáe
## Bolg"), with optional overrides ("Winter Barbs").

const CODEX_KEY := "infusions"


static func template(god_id: String) -> Dictionary:
	return (Elements.data().get("infusions", {}) as Dictionary).get(god_id, {})


static func empowered_data() -> Dictionary:
	return (Elements.data().get("infusions", {}) as Dictionary).get("empowered", {})


## Infusion offers for `player`'s chest: [{"weapon": id, "gods": [god ids]}], one per weapon.
static func candidates(player: Player) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	if GameAuthority.gods == null:
		return found
	var gods: PackedStringArray = GameAuthority.gods.bound_ids(player)
	for weapon: WeaponInstance in player.weapons:
		if weapon.infusion != "" or weapon.level < weapon.max_level():
			continue
		var eligible := PackedStringArray()
		for god_id: String in gods:
			if not template(god_id).is_empty():
				eligible.append(god_id)
		if not eligible.is_empty():
			found.append({"weapon": weapon.id(), "gods": eligible})
	return found


## Infuses (or Empowers) `weapon` with `god_id`. Returns the recipe {"weapon", "god", "empowered"}.
static func infuse(weapon: WeaponInstance, god_id: String) -> Dictionary:
	var element: String = str(template(god_id).get("element", ""))
	weapon.infusion = god_id
	weapon.empowered = element == str(weapon.data.get("element", ""))
	return {"weapon": weapon.id(), "god": god_id, "empowered": weapon.empowered}


## The weapon's shown name, with the infusion prefix or override.
static func display_name(weapon: WeaponInstance) -> String:
	var base: String = TranslationServer.translate(weapon.name_key())
	if weapon.infusion == "":
		return base
	if weapon.empowered:
		return TranslationServer.translate("INFUSION_EMPOWERED_NAME") % base
	var overrides: Dictionary = (Elements.data().get("infusions", {}) as Dictionary).get("name_overrides", {})
	var key: String = "%s+%s" % [weapon.id(), weapon.infusion]
	if overrides.has(key):
		return TranslationServer.translate(str(overrides[key]))
	return TranslationServer.translate("INFUSION_NAME") % [TranslationServer.translate(str(template(weapon.infusion).get("prefix_key", ""))), base]


## Records a discovered infusion in the Codex. True the first time.
static func discover(recipe: Dictionary) -> bool:
	return Profile.add_to_list(EvolutionRules.CODEX_SECTION, CODEX_KEY, "%s+%s" % [recipe.get("weapon", ""), recipe.get("god", "")])


## Extra crit damage for an infused weapon (Fortune's).
static func crit_bonus(weapon: WeaponInstance) -> float:
	if weapon == null or weapon.infusion == "" or weapon.empowered:
		return 0.0
	return float(template(weapon.infusion).get("crit_damage_bonus", 0.0))


## After an infused weapon hits: Thunder chains, Tidal splashes.
static func on_hit(weapon: WeaponInstance, player: Player, slot: int) -> void:
	if weapon.infusion == "" or weapon.empowered:
		return
	var t: Dictionary = template(weapon.infusion)
	var enemies: EnemyManager = GameAuthority.enemies
	var at: Vector2 = enemies.positions[slot]
	if t.has("chain_chance") and GameAuthority.run.rng.combat.randf() < float(t["chain_chance"]):
		var left: int = int(t.get("chain_targets", 2))
		for other: int in enemies.query(at, float(t.get("chain_radius_px", 80.0))):
			if left <= 0:
				break
			if other != slot:
				GameAuthority.damage_enemy(other, weapon.damage() * float(t.get("chain_damage_mult", 0.5)), player, Vector2.ZERO, "lightning", 0.3)
				left -= 1
	if t.has("splash_radius_px"):
		for other: int in enemies.query(at, float(t["splash_radius_px"])):
			var away: Vector2 = (enemies.positions[other] - at).normalized()
			enemies.knockback[other] += away * float(t.get("splash_push", 120.0)) * (1.0 - float(enemies.type_of(other).get("knockback_resist", 0.0)))


## When an infused weapon kills: Sunfire explodes, Winter splits into shards,
## Greenwood leaves thorns, Fortune's may drop gold, Solar flashes, Raven sends a crow.
static func on_kill(weapon: WeaponInstance, player: Player, slot: int, at: Vector2, ground: GroundEffects,
		gold: GoldPickups) -> void:
	if weapon.infusion == "" or weapon.empowered:
		return
	var t: Dictionary = template(weapon.infusion)
	var enemies: EnemyManager = GameAuthority.enemies
	var element: String = str(t.get("element", ""))
	match str(t.get("on_kill", "")):
		"explode", "flash":
			var reach: float = float(t.get("explode_radius_px", t.get("flash_radius_px", 26.0)))
			var mult: float = float(t.get("explode_damage_mult", t.get("flash_damage_mult", 0.5)))
			for other: int in enemies.query(at, reach):
				if other != slot:
					GameAuthority.damage_enemy(other, weapon.damage() * mult, player, Vector2.ZERO, element, 0.5)
			_ring(enemies, at, reach, element)
		"shards", "crow":
			var count: int = int(t.get("shards", 1))
			var reach: float = float(t.get("shard_range_px", t.get("crow_range_px", 100.0)))
			for other: int in enemies.query(at, reach):
				if count <= 0:
					break
				if other != slot:
					GameAuthority.damage_enemy(other, weapon.damage() * float(t.get("shard_damage_mult", t.get("crow_damage_mult", 0.5))),
							player, Vector2.ZERO, element, 0.5)
					count -= 1
		"thorns":
			if ground != null:
				ground.add(at, float(t.get("thorn_radius_px", 16.0)), float(t.get("thorn_s", 3.0)), float(t.get("thorn_dps", 6.0)),
						element, player)
		"gold":
			if gold != null and GameAuthority.run.rng.loot.randf() < float(t.get("gold_chance", 0.1)):
				gold.drop(at, Data.cfg_float("pickups.gold_coin_value"))


static func _ring(enemies: EnemyManager, at: Vector2, reach: float, element: String) -> void:
	var effects: EffectLayer = enemies.get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Elements.color(element), true)
