class_name CoopCodec
extends RefCounted
## Packs and unpacks the parts of the host's co-op updates (CoopHost /
## CoopClient): the run's numbers, each player's state and build, and a batch
## of enemy positions. Only plain values (no objects) go over the network.

## Event codes in a TICK's event list.
const E_SPAWN := 1
const E_KILL := 2
const E_REMOVE := 3
const E_DAMAGE := 4
const E_SHOT := 5
const E_SHOTS := 6
const E_REACTION := 7
const E_SHIFT := 8
const E_BUILD := 9
const E_BANNER := 10
const E_BANTER := 11
const E_RUN_END := 12
const E_PLACE := 13
const E_TURN := 14
const E_MIRROR := 15
const E_SUMMON := 16
const E_FLASH := 17
const E_DROP := 18
const E_EFFECT := 19
const E_AGE := 20
## [E_OFFER, player id, kind, data]: a choice for that player (sent in order with everything else).
const E_OFFER := 21
## [E_JOIN, player id, hero id, x, y]: a player joined the run in progress.
const E_JOIN := 22

# Player flag bits.
const ALIVE := 1
const DOWNED := 2
const SHADE := 4


static func run_state(run: RunState) -> Array:
	return [run.elapsed_s, run.xp, run.level, run.kills, run.gold, run.unspent_level_ups, run.boss_arena_active,
		run.double_drops_until_s, run.god_charge_mult]


static func apply_run_state(run: RunState, state: Array) -> void:
	if state.size() < 9:
		return
	run.elapsed_s = float(state[0])
	run.xp = float(state[1])
	run.level = int(state[2])
	run.kills = int(state[3])
	run.gold = float(state[4])
	run.unspent_level_ups = int(state[5])
	run.boss_arena_active = bool(state[6])
	run.double_drops_until_s = float(state[7])
	run.god_charge_mult = float(state[8])


static func player_state(player: Player, gods: GodManager) -> Array:
	var flags: int = (ALIVE if player.alive else 0) | (DOWNED if player.downed else 0) | (SHADE if player.shade else 0)
	var slots: Array = []
	if gods != null:
		for slot: Dictionary in gods.gods_of(player):
			slots.append([str(slot["id"]), float(slot["meter"])])
	var speed: float = player.statuses.speed_mult() * player.slow_zone_mult * player.ground_speed_mult
	return [player.player_id, player.position.x, player.position.y, player.facing.x, player.facing.y, player.hp, player.max_hp,
		flags, player.bleed_s, player.revive_progress_s, speed, player.ground_grip_per_s, player.rooted_s, player.invulnerable_s,
		slots, player.revives_used, player.gold_spent]


## Applies a player's state; `mine` keeps this device's own position (it moves its own Hero).
static func apply_player_state(player: Player, state: Array, mine: bool) -> void:
	if state.size() < 17:
		return
	if not mine:
		player.set_meta("net_target", Vector2(float(state[1]), float(state[2])))
		player.facing = Vector2(float(state[3]), float(state[4]))
	player.hp = float(state[5])
	player.max_hp = float(state[6])
	var flags: int = int(state[7])
	player.alive = flags & ALIVE != 0
	player.downed = flags & DOWNED != 0
	player.shade = flags & SHADE != 0
	player.bleed_s = float(state[8])
	player.revive_progress_s = float(state[9])
	player.net_speed_mult = float(state[10])
	player.ground_grip_per_s = float(state[11])
	player.rooted_s = float(state[12])
	player.invulnerable_s = float(state[13])
	player.revives_used = int(state[15])
	player.gold_spent = float(state[16])
	player.queue_redraw()


## Everything about a player's build that their device needs to show it.
static func build(player: Player) -> Array:
	var weapons: Array = []
	for weapon: WeaponInstance in player.weapons:
		weapons.append([weapon.id(), weapon.level, weapon.evolved, weapon.base_id, weapon.infusion, weapon.empowered, weapon.expert])
	return [player.player_id, weapons, player.passives.duplicate(), player.stats.bonus.duplicate()]


static func apply_build(player: Player, data: Array) -> void:
	if data.size() < 4:
		return
	var kept: Dictionary = {}
	for weapon: WeaponInstance in player.weapons:
		kept[weapon.id()] = weapon
	var weapons: Array[WeaponInstance] = []
	for entry: Variant in data[1]:
		var row: Array = entry
		var weapon: WeaponInstance = kept.get(str(row[0]))
		if weapon == null:
			var weapon_data: Dictionary = GameAuthority.find_weapon(str(row[0]))
			if weapon_data.is_empty():
				continue
			weapon = WeaponInstance.new(weapon_data, player)
		weapon.level = int(row[1])
		weapon.evolved = bool(row[2])
		weapon.base_id = str(row[3])
		weapon.infusion = str(row[4])
		weapon.empowered = bool(row[5])
		weapon.expert = bool(row[6])
		weapons.append(weapon)
	player.weapons = weapons
	player.passives = (data[2] as Dictionary).duplicate()
	for stat: Variant in data[3]:
		player.stats.bonus[stat] = float(data[3][stat])
	player.refresh_stats()


## A batch of enemy positions: slot (2 bytes), x, y (4 bytes each), HP (1 byte, 0–255).
static func enemy_batch(enemies: EnemyManager, slots: PackedInt32Array) -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	for slot: int in slots:
		buffer.put_u16(slot)
		buffer.put_float(enemies.positions[slot].x)
		buffer.put_float(enemies.positions[slot].y)
		buffer.put_u8(clampi(roundi(enemies.hp[slot] / maxf(enemies.max_hp[slot], 0.001) * 255.0), 0, 255))
	return buffer.data_array


static func apply_enemy_batch(enemies: EnemyManager, data: PackedByteArray) -> void:
	var buffer := StreamPeerBuffer.new()
	buffer.data_array = data
	while buffer.get_available_bytes() >= 11:
		var slot: int = buffer.get_u16()
		var at := Vector2(buffer.get_float(), buffer.get_float())
		var hp_fraction: float = buffer.get_u8() / 255.0
		if slot < enemies.capacity:
			enemies.correct(slot, at, hp_fraction)
