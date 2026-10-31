class_name HitResolver
extends RefCounted
## Resolves one hit on one enemy (GAME_DESIGN.md: Core mechanics / Damage
## formula; Elements, statuses, and reactions). Owned by GameAuthority.
##   Counterplay: Fire on a Soaked enemy only removes Soaked; Ice on a
##   Burning enemy only removes Burn.
##   Reactions (at most 30 per second, the effect budget):
##     Conduct      Lightning on Soaked: chains to every Soaked enemy within 4 tiles
##     Steam Burst  Fire on Chilled/Frozen: removes the ice, small explosion
##     Shatter      Physical on Frozen: +100% damage, Freeze ends
##     Spread       Wind on Burn/Poison/Soaked: copies them to up to 4 nearby enemies
##   Weakness ×1.5 / resistance ×0.5, Shock (+20%) and Shatter join the
##   element step of the damage formula; Hex lowers Armor.
##   Elites: Armored adds Armor; a Warded shield takes damage first (Holy
##   breaks it at once). `attacker` is null for hazards (no Might or crits).

const SPREADABLE: PackedStringArray = ["burn", "poison", "soaked"]

var _reaction_times := PackedFloat64Array()


## Returns the damage dealt.
func hit(slot: int, base: float, attacker: Player, push: Vector2, element: String, status_chance: float,
		allow_reactions: bool = true, weapon: WeaponInstance = null) -> float:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null or enemies.active[slot] == 0:
		return 0.0
	var st: EnemyStatuses = enemies.statuses
	var data: Dictionary = enemies.type_of(slot)
	var at: Vector2 = enemies.positions[slot]
	var status_id: String = Elements.status_of(element)
	var element_mult: float = Elements.multiplier(data, element)
	# The Flood and the Sun Harmony (Enki + Shamash): Holy burns hotter on the Soaked.
	if attacker != null and element == "holy" and st.has(slot, "soaked"):
		element_mult *= float(attacker.god_flags.get(ResonanceManager.HARMONY + "holy_vs_soaked_mult", 1.0))
	var bonus: float = 1.0
	if allow_reactions:
		if attacker != null and not attacker.god_flags.is_empty():
			Blessings.harmony_before_hit(attacker, slot, element, base, at)
		if element == "fire" and st.has(slot, "soaked"):
			st.remove(slot, "soaked")
			status_id = ""
		elif element == "ice" and st.has(slot, "burn"):
			st.remove(slot, "burn")
			status_id = ""
		bonus = _react(slot, base, attacker, element, status_chance, at)
	var shock_mult: float = st.consume_shock(slot)
	var armor: float = (float(data.get("armor", 0.0)) + enemies.elites.bonus_armor[slot]) * st.armor_mult(slot)
	var might: float = 0.0
	var crit_chance: float = 0.0
	if attacker != null:
		base *= attacker.statuses.outgoing_damage_mult() * attacker.element_damage_mult(element)
		might = attacker.stats.might()
		crit_chance = attacker.stats.crit_chance()
		if str(attacker.god_flags.get("always_burn_element", "")) == element:
			status_chance = 1.0
	var result: Dictionary = Damage.hit(base, 0.0, might, crit_chance,
			Data.cfg_float("combat.crit_mult") + Infusions.crit_bonus(weapon), _rng().randf(), element_mult * bonus * shock_mult, armor,
			Data.cfg_float("combat.min_damage"))
	var amount: float = float(result["amount"]) * st.damage_taken_mult(slot)
	# Bosses: the Guard gauge, Guard Breaks, and signature rules (Achilles' heel).
	if bool(data.get("boss", false)) and GameAuthority.bosses != null:
		amount = GameAuthority.bosses.on_boss_hit(slot, amount, element_mult, attacker, push, element)
	var to_hp: float = enemies.elites.absorb(slot, amount, element == "holy")
	enemies.hp[slot] -= to_hp
	enemies.flash_timer[slot] = Data.cfg_float("enemies.hit_flash_s") * Settings.flash_strength()
	enemies.knockback[slot] += push * (1.0 - float(data.get("knockback_resist", 0.0)))
	if status_id != "" and _rng().randf() < status_chance:
		_apply_status(slot, status_id, push, data, _status_duration(attacker, weapon, status_id))
	var kind: String = _number_kind(bool(result["crit"]), element_mult) if to_hp > 0.0 else "resist"
	GameAuthority.enemy_damaged.emit(slot, amount, kind, at, element)
	if attacker != null and attacker.is_local:
		Meta.note_damage_dealt(weapon, amount)
	if attacker != null and not attacker.god_flags.is_empty() and enemies.active[slot] != 0:
		Blessings.after_hit(attacker, weapon, slot, element)
	if weapon != null and weapon.infusion != "" and attacker != null:
		Infusions.on_hit(weapon, attacker, slot)
	if enemies.hp[slot] <= 0.0:
		if weapon != null and weapon.infusion != "" and attacker != null and GameAuthority.gods != null:
			Infusions.on_kill(weapon, attacker, slot, at, GameAuthority.gods.ground, GameAuthority.gods.gold)
		GameAuthority.kill_enemy(slot, attacker)
	return amount


## Damage over time (Burn, Poison): skips Armor and reactions.
func damage_over_time(slot: int, amount: float) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null or enemies.active[slot] == 0:
		return
	enemies.hp[slot] -= amount
	GameAuthority.enemy_damaged.emit(slot, amount, "dot", enemies.positions[slot], "")
	if enemies.hp[slot] <= 0.0:
		GameAuthority.kill_enemy(slot, null)


## True (and counted) if the reaction budget for this second isn't used up.
func take_reaction_budget() -> bool:
	var now: float = Time.get_ticks_msec() / 1000.0
	while not _reaction_times.is_empty() and now - _reaction_times[0] >= 1.0:
		_reaction_times.remove_at(0)
	if _reaction_times.size() >= Data.cfg_int("effect_budgets.max_reactions_per_s"):
		return false
	_reaction_times.append(now)
	return true


func _react(slot: int, base: float, attacker: Player, element: String, status_chance: float, at: Vector2) -> float:
	var st: EnemyStatuses = GameAuthority.enemies.statuses
	var tile: float = Data.cfg_float("world.tile_px")
	if element == Elements.PHYSICAL and st.has(slot, "frozen") and take_reaction_budget():
		st.remove(slot, "frozen")
		_announce("shatter", at, 0.0, attacker)
		return 1.0 + float(Elements.reaction("shatter").get("damage_bonus", 1.0)) * _reaction_mult(attacker)
	if element == "fire" and (st.has(slot, "frozen") or st.has(slot, "chill")) and take_reaction_budget():
		st.remove(slot, "frozen")
		st.remove(slot, "chill")
		var steam: Dictionary = Elements.reaction("steam_burst")
		var steam_radius: float = float(steam.get("radius_tiles", 2)) * tile
		for other: int in _others_near(slot, at, steam_radius):
			hit(other, base * float(steam.get("damage_mult", 0.75)) * _reaction_mult(attacker), attacker, Vector2.ZERO, "fire", 0.0, false)
		_announce("steam_burst", at, steam_radius, attacker)
	elif element == "lightning" and st.has(slot, "soaked") and take_reaction_budget():
		var conduct: Dictionary = Elements.reaction("conduct")
		var conduct_radius: float = float(conduct.get("radius_tiles", 4)) * tile
		for other: int in _others_near(slot, at, conduct_radius):
			if st.has(other, "soaked"):
				hit(other, base * float(conduct.get("damage_mult", 0.5)) * _reaction_mult(attacker), attacker, Vector2.ZERO, "lightning",
						status_chance, false)
		_announce("conduct", at, conduct_radius, attacker)
	elif element == "wind" and take_reaction_budget():
		var spreading: PackedStringArray = []
		for status_id: String in SPREADABLE:
			if st.has(slot, status_id):
				spreading.append(status_id)
		if spreading.is_empty():
			_reaction_times.remove_at(_reaction_times.size() - 1)
			return 1.0
		var spread: Dictionary = Elements.reaction("spread")
		var targets: PackedInt32Array = _others_near(slot, at, float(spread.get("radius_tiles", 3)) * tile)
		for i: int in mini(targets.size(), int(spread.get("max_targets", 4))):
			for status_id: String in spreading:
				st.apply(targets[i], status_id)
		_announce("spread", at, float(spread.get("radius_tiles", 3)) * tile, attacker)
	return 1.0


## Status length: the attacker's status duration, Frozen Deluge's longer Chill, Empowered weapons.
func _status_duration(attacker: Player, weapon: WeaponInstance, status_id: String) -> float:
	var mult: float = attacker.stats.status_duration_mult() if attacker != null else 1.0
	if attacker != null and status_id == "chill":
		mult *= float(attacker.god_flags.get(ResonanceManager.HARMONY + "chill_duration_mult", 1.0))
	if weapon != null and weapon.empowered:
		mult *= float(Infusions.empowered_data().get("status_duration_mult", 1.5))
	return mult


## Väinämöinen's Divine Link: his reactions deal more damage.
func _reaction_mult(attacker: Player) -> float:
	return attacker.reaction_damage_mult if attacker != null else 1.0


func _apply_status(slot: int, status_id: String, push: Vector2, data: Dictionary, duration_mult: float) -> void:
	if status_id == "gust":
		var strength: float = float(Elements.status("gust").get("knockback", 0.0))
		var direction: Vector2 = push.normalized() if push != Vector2.ZERO else Vector2.RIGHT
		GameAuthority.enemies.knockback[slot] += direction * strength * (1.0 - float(data.get("knockback_resist", 0.0)))
		return
	GameAuthority.enemies.statuses.apply(slot, status_id, duration_mult, not bool(data.get("boss", false)))


func _others_near(slot: int, at: Vector2, reach: float) -> PackedInt32Array:
	var found := PackedInt32Array()
	for other: int in GameAuthority.enemies.query(at, reach):
		if other != slot:
			found.append(other)
	return found


func _announce(reaction_id: String, at: Vector2, reach: float, by: Player) -> void:
	GameAuthority.reaction_triggered.emit(reaction_id, at, reach, by)


## How the damage number looks: weakness hits are big and yellow with "!",
## resisted hits small and grey (GAME_DESIGN.md: Weakness and resistance).
func _number_kind(crit: bool, element_mult: float) -> String:
	if element_mult > 1.0:
		return "weak"
	if element_mult < 1.0:
		return "resist"
	return "crit" if crit else "normal"


func _rng() -> RandomNumberGenerator:
	return GameAuthority.run.rng.combat
