class_name Blessings
extends RefCounted
## A bound god's passive Blessing (GAME_DESIGN.md: Gods / Blessing, trigger,
## and summon). Stat Blessings change the player's stats while the god is
## bound; the others are switches in player.god_flags that combat checks:
##   Tyche      +30% gold, +Luck, −10% Max HP
##   Cernunnos  regenerate 1% HP/s; melee hits Poison
##   Thor       +15% Lightning damage; every 10th projectile chains lightning
##   Skadi      +20% Max HP; enemies that touch you are Chilled
##   Sekhmet    +15% Might; Fire weapons always Burn
##   Poseidon   +25% Area, −10% Move Speed; hits Soak
##   Ra         +15% Holy damage; Holy hits break shields
##   Morrígan   +10% Crit Chance; kills on Hexed enemies heal 1 HP

## Blessing keys that are percentages of a stat: key -> stat.
const PERCENT_STATS: Dictionary = {
	"max_hp_pct": "max_hp", "might_pct": "might", "area_pct": "area", "move_speed_pct": "move_speed", "crit_pct": "crit",
}


## Adds (direction 1) or removes (direction -1) a god's Blessing from a player.
static func apply(player: Player, god: Dictionary, direction: float) -> void:
	var blessing: Dictionary = god.get("blessing", {})
	for key: String in blessing:
		var value: Variant = blessing[key]
		if PERCENT_STATS.has(key):
			player.stats.add_bonus(PERCENT_STATS[key], float(value) / 100.0 * direction)
		elif key == "luck":
			player.stats.add_bonus("luck", float(value) * direction)
		elif key == "gold_pct":
			player.gold_mult += float(value) / 100.0 * direction
		elif key == "element_damage":
			for element: String in (value as Dictionary):
				player.element_damage[element] = float(player.element_damage.get(element, 0.0)) + float(value[element]) / 100.0 * direction
		elif direction > 0.0:
			player.god_flags[key] = value
		else:
			player.god_flags.erase(key)
	player.refresh_stats()


## After a player's hit lands: melee Poison (Cernunnos), Soak (Poseidon), and
## the Eye of Ra Harmony.
static func after_hit(player: Player, weapon: WeaponInstance, slot: int, element: String) -> void:
	var statuses: EnemyStatuses = GameAuthority.enemies.statuses
	var melee_status: String = str(player.god_flags.get("melee_status", ""))
	if melee_status != "" and weapon != null and is_melee(weapon):
		statuses.apply(slot, melee_status, player.stats.status_duration_mult())
	var hit_status: String = str(player.god_flags.get("hit_status", ""))
	if hit_status != "":
		statuses.apply(slot, hit_status, player.stats.status_duration_mult())
	# Eye of Ra Harmony: Holy and Fire hits each apply the other's status.
	if element == "holy" and player.god_flags.has(ResonanceManager.HARMONY + "holy_burns"):
		statuses.apply(slot, "burn", player.stats.status_duration_mult())
	elif element == "fire" and player.god_flags.has(ResonanceManager.HARMONY + "fire_smites"):
		statuses.apply(slot, "smite", player.stats.status_duration_mult())


## Sun and Snow Harmony: a Fire hit on a Chilled or Frozen enemy also sets off a
## mini Steam Burst (outside the reaction budget).
static func harmony_before_hit(player: Player, slot: int, element: String, base: float, at: Vector2) -> void:
	var key: String = ResonanceManager.HARMONY + "mini_steam_on_chilled"
	if element != "fire" or not player.god_flags.has(key):
		return
	var statuses: EnemyStatuses = GameAuthority.enemies.statuses
	if not (statuses.has(slot, "chill") or statuses.has(slot, "frozen")):
		return
	var reach: float = float(player.god_flags.get(ResonanceManager.HARMONY + "mini_steam_radius_px", 20.0))
	var mult: float = float(player.god_flags.get(ResonanceManager.HARMONY + "mini_steam_damage_mult", 0.4))
	for other: int in GameAuthority.enemies.query(at, reach):
		if other != slot:
			GameAuthority.hits.hit(other, base * mult, player, Vector2.ZERO, "fire", 0.0, false)


static func is_melee(weapon: WeaponInstance) -> bool:
	var targeting: String = str(weapon.data.get("targeting", ""))
	return targeting == Targeting.MELEE or str(weapon.data.get("pattern", "")) == "thrust"


## Thor: true when this launch is a chaining projectile (every 10th).
static func next_projectile_chains(player: Player) -> bool:
	var every: int = int(player.god_flags.get("chain_every_n_projectiles", 0))
	if every <= 0:
		return false
	player.projectiles_launched += 1
	return player.projectiles_launched % every == 0


## Thor's chain: lightning jumps from `at` to the nearest few enemies.
static func chain_lightning(player: Player, from_slot: int, at: Vector2, damage: float) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	var thor: Dictionary = player.god_flags
	var reach: float = float(thor.get("chain_radius_px", 80.0))
	var left: int = int(thor.get("chain_targets", 2)) + int(thor.get(ResonanceManager.HARMONY + "chain_bonus_targets", 0))
	var effects: EffectLayer = enemies.get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	for slot: int in enemies.query(at, reach):
		if left <= 0:
			break
		if slot == from_slot:
			continue
		var target_at: Vector2 = enemies.positions[slot]
		GameAuthority.damage_enemy(slot, damage * float(thor.get("chain_damage_mult", 0.5)), player, Vector2.ZERO, "lightning", 0.3)
		if effects != null:
			effects.spawn_ring(target_at, 8.0, Elements.color("lightning"))
		left -= 1


## Morrígan: a kill on a Hexed enemy heals its killer.
static func on_kill(player: Player, slot: int) -> void:
	var heal: float = float(player.god_flags.get("heal_on_hexed_kill", 0.0))
	if heal > 0.0 and GameAuthority.enemies != null and GameAuthority.enemies.statuses.hex[slot] > 0.0:
		GameAuthority.heal_player(player, heal)
