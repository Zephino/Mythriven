class_name CoopHost
extends Node
## Co-op on the host's device (GAME_DESIGN.md: Online co-op / Sync rules).
## The host's game simulates everything; this node takes each joining
## player's position and button presses (~20/s) and sends everyone an update
## ~20 times a second: the run's numbers, every player's state, a batch of
## enemy positions (each enemy is corrected every few updates, and moves on
## each device in between), and events for everything else ("enemy 214 of
## type X spawned at (x, y)", "enemy 214 died", "a shot was fired"…). Slower
## things (shrines, chests, bosses' visuals) are sent a few times a second by
## the systems themselves (the "coop_mirror" group, see CoopMirror).

## Each update has just gone out (CoopLateJoin sends newcomers their snapshot then).
signal tick_sent

const MIRROR_GROUP := "coop_mirror"
const GROUP := "coop_host"

var world: WorldRoot
var enemies: EnemyManager
var gods: GodManager
var turns: CoopTurns
var effects: EffectLayer
var banner: Banner
var banter: BanterBubble
var gold: GoldPickups
var heals: HealPickups

## Size of the last update sent (for the debug overlay and tests).
var last_tick_bytes: int = 0

var _tick: int = 0
var _send_in: float = 0.0
var _state_in: float = 0.0
var _events: Array = []
var _damage_sent: int = 0
var _cursor: int = 0
## Removals waiting to see whether they were kills: slot -> index in _events.
var _removed_at: Dictionary = {}
## (tick, shift_px) of recent origin shifts, to place positions a client sent before it heard of them.
var _shifts: Array = []
var _builds: Dictionary = {}
var _builds_again_in: float = 0.0
## Game effects that moved a joining player's Hero this update: id -> offset.
var _pushes: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group(GROUP)
	Net.run_message.connect(_on_message)
	enemies.spawned.connect(_on_spawned)
	enemies.removed.connect(_on_removed)
	GameAuthority.enemy_killed.connect(_on_killed)
	GameAuthority.enemy_damaged.connect(_on_damaged)
	GameAuthority.reaction_triggered.connect(_on_reaction)
	GameAuthority.run_ended.connect(_on_run_ended)
	world.origin_shifted.connect(_on_shifted)
	GameAuthority.player_pushed.connect(_on_pushed)
	GameAuthority.age_changed.connect(func(age_id: String) -> void: add_event([CoopCodec.E_AGE, age_id]))
	if GameAuthority.enemy_shots != null:
		GameAuthority.enemy_shots.fired.connect(_on_shot)
		GameAuthority.enemy_shots.bulk.connect(_on_shots_bulk)
	if effects != null:
		effects.shared.connect(_on_shared_effect)
	if banner != null:
		banner.shown.connect(func(text: String) -> void: add_event([CoopCodec.E_BANNER, text]))
	if banter != null:
		banter.said.connect(func(line: Dictionary) -> void: add_event([CoopCodec.E_BANTER, line]))
	if gold != null:
		gold.dropped.connect(func(at: Vector2, value: float) -> void: add_event([CoopCodec.E_DROP, "gold", at.x, at.y, value]))
		gold.pulled.connect(func() -> void: add_event([CoopCodec.E_DROP, "pull", 0.0, 0.0, 0.0]))
	if heals != null:
		heals.dropped.connect(func(at: Vector2) -> void: add_event([CoopCodec.E_DROP, "heal", at.x, at.y, 0.0]))
	if gods != null:
		gods.summoned.connect(_on_summoned)
		if gods.resonance != null:
			gods.resonance.fired.connect(_on_resonance)


## Queues an event for the next update (other co-op systems add theirs here).
func add_event(event: Array) -> void:
	_events.append(event)


func _process(delta: float) -> void:
	_send_in -= delta
	_state_in -= delta
	if _state_in <= 0.0:
		_state_in = 1.0 / Data.cfg_float("coop.state_hz")
		_queue_slow_state()
	if _send_in > 0.0:
		return
	_send_in = 1.0 / Data.cfg_float("coop.sync_rate_hz")
	_send_tick()


func _send_tick() -> void:
	_tick += 1
	var run: RunState = GameAuthority.run
	if run == null:
		return
	for id: int in _pushes:
		var offset: Vector2 = _pushes[id]
		add_event([CoopCodec.E_PLACE, id, offset.x, offset.y])
	_pushes.clear()
	var players: Array = []
	for player: Player in GameAuthority.players:
		players.append(CoopCodec.player_state(player, gods))
	var bytes: PackedByteArray = NetMsg.encode([NetMsg.TICK, _tick, get_tree().paused, CoopCodec.run_state(run), players,
		CoopCodec.enemy_batch(enemies, _next_batch()), _events])
	last_tick_bytes = bytes.size()
	Net.send_bytes(LobbyService.EVERYONE, bytes)
	_events = []
	_removed_at.clear()
	_damage_sent = 0
	tick_sent.emit()


## The next enemies to correct, round-robin, so each is corrected every few updates.
func _next_batch() -> PackedInt32Array:
	var slots := PackedInt32Array()
	var limit: int = Data.cfg_int("coop.enemy_batch")
	var checked: int = 0
	while slots.size() < limit and checked < enemies.capacity:
		_cursor = (_cursor + 1) % enemies.capacity
		checked += 1
		if enemies.active[_cursor] != 0:
			slots.append(_cursor)
	return slots


## Builds that changed (and every build now and then, in case a device's
## own copy drifted), and every system's state for the joining players' screens.
func _queue_slow_state() -> void:
	_builds_again_in -= 1.0 / Data.cfg_float("coop.state_hz")
	if _builds_again_in <= 0.0:
		_builds_again_in = 2.0
		_builds.clear()
	for player: Player in GameAuthority.players:
		var data: Array = CoopCodec.build(player)
		var key: int = hash(data)
		if _builds.get(player.player_id, 0) != key:
			_builds[player.player_id] = key
			add_event([CoopCodec.E_BUILD, data])
	for node: Node in get_tree().get_nodes_in_group(MIRROR_GROUP):
		var mirror: CoopMirror = node.get_meta("coop_mirror")
		if mirror != null:
			add_event([CoopCodec.E_MIRROR, mirror.id, mirror.capture()])


# --- From the joining players -------------------------------------------------------------

func _on_message(from: int, msg: Array) -> void:
	var player: Player = GameAuthority.player_by_id(from)
	if player == null or player.is_local:
		return
	match int(msg[0]):
		NetMsg.INPUT:
			if msg.size() >= 8:
				var at := Vector2(float(msg[1]), float(msg[2]))
				for shift: Array in _shifts:
					# A shift that update hadn't reached them yet when they sent this.
					if int(shift[0]) > int(msg[7]):
						at -= shift[1]
				var moved: Vector2 = at - player.position
				player.position = at
				player.velocity = Vector2(float(msg[3]), float(msg[4]))
				player.facing = Vector2(float(msg[5]), float(msg[6]))
				if moved != Vector2.ZERO:
					player.queue_redraw()
		NetMsg.SUMMON:
			if gods != null and msg.size() >= 2:
				gods.summon(player, int(msg[1]))
		NetMsg.RESONANCE:
			if gods != null and gods.resonance != null:
				gods.resonance.fire(player)
		NetMsg.CARD:
			if turns != null and msg.size() >= 2:
				turns.on_card(player, int(msg[1]))
		NetMsg.CHOICE:
			if msg.size() >= 3:
				CoopChoices.on_choice(player, str(msg[1]), msg[2])
		NetMsg.BYE:
			_on_player_left(player)


## A player who leaves becomes a Shade (their Hero stays for the team's sake).
func _on_player_left(player: Player) -> void:
	if player.alive or player.downed:
		CoopRevives.become_shade(player)
		GameAuthority.check_run_over()


# --- Events ------------------------------------------------------------------------------

func _on_spawned(slot: int) -> void:
	add_event([CoopCodec.E_SPAWN, slot, enemies.kind[slot], enemies.positions[slot].x, enemies.positions[slot].y,
		enemies.max_hp[slot]])


func _on_removed(slot: int) -> void:
	_removed_at[slot] = _events.size()
	add_event([CoopCodec.E_REMOVE, slot])


func _on_killed(slot: int, _type: Dictionary, _at: Vector2, killer: Player) -> void:
	var index: int = int(_removed_at.get(slot, -1))
	var event: Array = [CoopCodec.E_KILL, slot, killer.player_id if killer != null else -1]
	if index >= 0 and index < _events.size():
		_events[index] = event
	else:
		add_event(event)


func _on_damaged(slot: int, amount: float, kind: String, at: Vector2, element: String) -> void:
	if _damage_sent >= Data.cfg_int("coop.damage_numbers_per_tick"):
		add_event([CoopCodec.E_FLASH, slot])
		return
	_damage_sent += 1
	add_event([CoopCodec.E_DAMAGE, slot, at.x, at.y, amount, kind, element])


func _on_reaction(reaction_id: String, at: Vector2, reach: float, by: Player) -> void:
	add_event([CoopCodec.E_REACTION, reaction_id, at.x, at.y, reach, by.player_id if by != null else -1])


func _on_shot(at: Vector2, velocity: Vector2, shot_radius: float, damage: float, source_id: String, element: String, owner_kind: int) -> void:
	add_event([CoopCodec.E_SHOT, at.x, at.y, velocity.x, velocity.y, shot_radius, damage, source_id, element, owner_kind])


func _on_shots_bulk(op: String, args: Array) -> void:
	add_event([CoopCodec.E_SHOTS, op, args])


func _on_shifted(shift_px: Vector2, shift_chunks: Vector2i) -> void:
	# The shift goes out with the next update (number _tick + 1).
	_shifts.append([_tick + 1, shift_px])
	if _shifts.size() > 20:
		_shifts.pop_front()
	add_event([CoopCodec.E_SHIFT, shift_chunks.x, shift_chunks.y])


func _on_pushed(player: Player, offset: Vector2) -> void:
	_pushes[player.player_id] = _pushes.get(player.player_id, Vector2.ZERO) + offset


func _on_shared_effect(effect_kind: int, at: Vector2, angle: float, size: float, spread: float, color: Color) -> void:
	add_event([CoopCodec.E_EFFECT, effect_kind, at.x, at.y, angle, size, spread, color])


## A summon or Resonance: every device plays its visuals (the damage happens here).
func _on_summoned(player: Player, god_id: String) -> void:
	add_event([CoopCodec.E_SUMMON, player.player_id, "god", god_id])


func _on_resonance(player: Player, resonance: Dictionary) -> void:
	add_event([CoopCodec.E_SUMMON, player.player_id, "resonance", gods.bound_ids(player)])


func _on_run_ended(_run: RunState) -> void:
	add_event([CoopCodec.E_RUN_END])
	# Make sure everyone hears it even though the game is about to stop.
	_send_tick()
