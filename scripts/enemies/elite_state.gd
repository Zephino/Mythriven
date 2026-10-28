class_name EliteState
extends RefCounted
## Elite modifiers stored as data on EnemyManager's pooled slots
## (GAME_DESIGN.md: Elites). Each elite has 1 modifier (2 in Deep Night):
##   Hasted          +50% speed
##   Armored         high Armor
##   Splitting       splits into 3 smaller copies on death (Hydra-style)
##   Warded          a shield blocks the first 30% of its HP; Holy breaks it instantly
##   Elemental Aura  damages nearby players with its element
##   Summoner        spawns minions every 5 s
## Modifier settings are in elite_modifiers.json.

const FILE := "elite_modifiers.json"

## Modifier ids per slot (empty for normal enemies and split copies).
var mods: Array[PackedStringArray] = []
var shield := PackedFloat32Array()
var bonus_armor := PackedFloat32Array()
## Seconds to the next aura pulse / summon.
var aura_timer := PackedFloat32Array()
var summon_timer := PackedFloat32Array()
## 1 for a split copy: it doesn't split again or drop a chest.
var is_copy := PackedByteArray()


func _init(capacity: int) -> void:
	mods.resize(capacity)
	for i: int in capacity:
		mods[i] = PackedStringArray()
	shield.resize(capacity)
	bonus_armor.resize(capacity)
	aura_timer.resize(capacity)
	summon_timer.resize(capacity)
	is_copy.resize(capacity)


static func modifier(modifier_id: String) -> Dictionary:
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary and str(entry.get("id", "")) == modifier_id:
			return entry
	return {}


static func all_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			ids.append(str(entry.get("id", "")))
	return ids


## `count` different modifiers picked at random.
static func roll(count: int, rng: RandomNumberGenerator) -> PackedStringArray:
	var pool: PackedStringArray = all_ids()
	var picked := PackedStringArray()
	while picked.size() < count and not pool.is_empty():
		var index: int = rng.randi_range(0, pool.size() - 1)
		picked.append(pool[index])
		pool.remove_at(index)
	return picked


func clear(slot: int) -> void:
	mods[slot] = PackedStringArray()
	shield[slot] = 0.0
	bonus_armor[slot] = 0.0
	aura_timer[slot] = 0.0
	summon_timer[slot] = 0.0
	is_copy[slot] = 0


## Gives a slot its modifiers. `max_hp` sizes the Warded shield.
func setup(slot: int, modifier_ids: PackedStringArray, max_hp: float) -> void:
	mods[slot] = modifier_ids
	for modifier_id: String in modifier_ids:
		var data: Dictionary = modifier(modifier_id)
		match modifier_id:
			"armored":
				bonus_armor[slot] += float(data.get("armor_bonus", 0.0))
			"warded":
				shield[slot] = max_hp * float(data.get("shield_frac", 0.3))
			"elemental_aura":
				aura_timer[slot] = float(data.get("interval_s", 1.0))
			"summoner":
				summon_timer[slot] = float(data.get("every_s", 5.0))


func has(slot: int, modifier_id: String) -> bool:
	return mods[slot].has(modifier_id)


func speed_mult(slot: int) -> float:
	return float(modifier("hasted").get("speed_mult", 1.0)) if has(slot, "hasted") else 1.0


## Takes damage on the Warded shield first. Holy (or a shield-breaking hit)
## breaks it at once. Returns the damage left over for HP.
func absorb(slot: int, amount: float, breaks_shield: bool) -> float:
	if shield[slot] <= 0.0:
		return amount
	if breaks_shield:
		shield[slot] = 0.0
		return amount
	var blocked: float = minf(shield[slot], amount)
	shield[slot] -= blocked
	return amount - blocked


## Auras and summons, once per frame.
func tick(m: EnemyManager, delta: float) -> void:
	for i: int in m.capacity:
		if m.active[i] == 0 or mods[i].is_empty():
			continue
		if has(i, "elemental_aura"):
			aura_timer[i] -= delta
			if aura_timer[i] <= 0.0:
				var aura: Dictionary = modifier("elemental_aura")
				aura_timer[i] = float(aura.get("interval_s", 1.0))
				_pulse_aura(m, i, aura)
		if has(i, "summoner") and m.speed_of(i) > 0.0:
			summon_timer[i] -= delta
			if summon_timer[i] <= 0.0:
				var summon: Dictionary = modifier("summoner")
				summon_timer[i] = float(summon.get("every_s", 5.0))
				for k: int in int(summon.get("count", 3)):
					var offset := Vector2.from_angle(TAU * k / maxf(float(summon.get("count", 3)), 1.0)) * m.radius[i] * 2.0
					GameAuthority.spawn_enemy(str(summon.get("minion", "")), m.positions[i] + offset)


## Called just before an elite dies: a Splitting elite leaves smaller copies.
func on_killed(m: EnemyManager, slot: int) -> void:
	if is_copy[slot] != 0 or not has(slot, "splitting"):
		return
	var split: Dictionary = modifier("splitting")
	var type_id: String = str(m.type_of(slot)["id"])
	var copies: int = int(split.get("copies", 3))
	for k: int in copies:
		var at: Vector2 = m.positions[slot] + Vector2.from_angle(TAU * k / copies) * m.radius[slot]
		var copy: int = GameAuthority.spawn_enemy(type_id, at)
		if copy == -1:
			continue
		is_copy[copy] = 1
		m.max_hp[copy] *= float(split.get("copy_hp_frac", 0.25))
		m.hp[copy] = m.max_hp[copy]
		m.radius[copy] *= float(split.get("copy_size_mult", 0.6))


func _pulse_aura(m: EnemyManager, i: int, aura: Dictionary) -> void:
	var reach: float = float(aura.get("radius_px", 50.0)) + m.radius[i]
	var element: String = str(m.type_of(i).get("element", ""))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(m.positions[i]) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(aura.get("damage", 4.0)) * m.damage_mult(i), str(m.type_of(i)["id"]),
					m.positions[i])
	var effects: EffectLayer = m.get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(m.positions[i], reach, Elements.color(element) if element != "" else Color.WHITE)
