class_name CoopClient
extends Node
## Co-op on a joining player's device (GAME_DESIGN.md: Online co-op / Sync
## rules). This device moves its own Hero and sends where it is ~20 times a
## second, and sends button presses (summons, cards, choices). Everything
## else comes from the host: other players (glided smoothly to where the host
## says), enemies spawning, moving, and dying, shots, damage numbers, the
## run's XP, level, gold, and time, and the state of shrines, chests, bosses…
## While applying the host's messages GameAuthority.replicating is on, so the
## same code as single-player runs (kills drop XP orbs, the Bestiary counts…).

var world: WorldRoot
var enemies: EnemyManager
var gods: GodManager
var numbers: DamageNumbers
var turns: CoopTurns
var effects: EffectLayer
var summons: ResonanceLayer

var _send_in: float = 0.0
## Joined a run in progress: nothing is shown or sent until the
## host's snapshot of the world arrives (CoopLateJoin).
var _waiting_for_world: bool = false
var _last_tick: int = 0
var _mirrors: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Net.run_message.connect(_on_message)
	Net.ended.connect(_on_session_ended)
	enemies.remote = true
	_waiting_for_world = Net.joined_late
	for node: Node in get_tree().get_nodes_in_group(CoopHost.MIRROR_GROUP):
		var mirror: CoopMirror = node.get_meta("coop_mirror")
		_mirrors[mirror.id] = mirror


func _process(delta: float) -> void:
	_glide_others(delta)
	_send_in -= delta
	if _send_in > 0.0 or _waiting_for_world:
		return
	_send_in = 1.0 / Data.cfg_float("coop.sync_rate_hz")
	var me: Player = GameAuthority.local_player()
	if me != null:
		Net.send(LobbyService.HOST_ID, [NetMsg.INPUT, me.position.x, me.position.y, me.velocity.x, me.velocity.y,
			me.facing.x, me.facing.y, _last_tick])


## The host left (or the connection dropped): the run ends here, with a word why.
func _on_session_ended(reason: String) -> void:
	var run: RunState = GameAuthority.run
	if run == null or run.ended:
		return
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and reason != "":
		banner.show_personal(tr(reason))
	get_tree().paused = false
	run.ended = true
	GameAuthority.run_ended.emit(run)


## Other players glide to where the host says they are.
func _glide_others(delta: float) -> void:
	var weight: float = minf(Data.cfg_float("coop.smoothing_per_s") * delta, 1.0)
	for player: Player in GameAuthority.players:
		if player.is_local or not player.has_meta("net_target"):
			continue
		var target: Vector2 = player.get_meta("net_target")
		var before: Vector2 = player.position
		player.position = before.lerp(target, weight)
		player.velocity = (player.position - before) / maxf(delta, 0.001)


func _on_message(from: int, msg: Array) -> void:
	if from != LobbyService.HOST_ID:
		return
	if _waiting_for_world:
		if int(msg[0]) == NetMsg.SNAPSHOT and msg.size() >= 7:
			_apply_snapshot(msg)
		return
	match int(msg[0]):
		NetMsg.TICK:
			if msg.size() >= 7:
				_apply_tick(msg)
		NetMsg.OFFER:
			if msg.size() >= 3:
				CoopChoices.on_offer(str(msg[1]), msg[2])


## Everything already in the world when this player joined, in the host's places.
func _apply_snapshot(msg: Array) -> void:
	_waiting_for_world = false
	world.shift_by(Vector2i(int(msg[1]), int(msg[2])))
	GameAuthority.replicating = true
	for event: Variant in msg[5]:
		if event is Array and not (event as Array).is_empty():
			_apply_event(event)
	GameAuthority.replicating = false
	for place: Variant in msg[6]:
		var player: Player = GameAuthority.player_by_id(int(place[0]))
		if player != null and not player.is_local:
			player.position = Vector2(float(place[1]), float(place[2]))
			player.set_meta("net_target", player.position)
	var me: Player = GameAuthority.local_player()
	if me != null:
		me.position = Vector2(float(msg[3]), float(msg[4]))
		get_tree().call_group(GameCamera.GROUP, "snap_to_target")


func _apply_tick(msg: Array) -> void:
	_last_tick = int(msg[1])
	var run: RunState = GameAuthority.run
	if run == null:
		return
	GameAuthority.replicating = true
	for event: Variant in msg[6]:
		if event is Array and not (event as Array).is_empty():
			_apply_event(event)
	CoopCodec.apply_run_state(run, msg[3])
	for state: Variant in msg[4]:
		var player: Player = GameAuthority.player_by_id(int(state[0]))
		if player != null:
			CoopCodec.apply_player_state(player, state, player.is_local)
			_apply_gods(player, state[14])
	CoopCodec.apply_enemy_batch(enemies, msg[5])
	GameAuthority.replicating = false
	# The host's level-up turns and chest reveals pause everyone; this device's
	# own choice screens keep it paused until they close.
	if bool(msg[2]):
		get_tree().paused = true
	elif get_tree().paused and not CoopChoices.local_modal_open():
		get_tree().paused = false


func _apply_event(event: Array) -> void:
	match int(event[0]):
		CoopCodec.E_SPAWN:
			enemies.spawn_into(int(event[1]), int(event[2]), Vector2(float(event[3]), float(event[4])), float(event[5]))
		CoopCodec.E_KILL:
			GameAuthority.kill_enemy(int(event[1]), GameAuthority.player_by_id(int(event[2])))
		CoopCodec.E_REMOVE:
			enemies.remove_quietly(int(event[1]))
		CoopCodec.E_DAMAGE:
			var slot: int = int(event[1])
			if slot >= 0 and slot < enemies.capacity and enemies.active[slot] != 0:
				enemies.flash_timer[slot] = Data.cfg_float("enemies.hit_flash_s") * Settings.flash_strength()
			if numbers != null:
				numbers.show_number(float(event[4]), Vector2(float(event[2]), float(event[3])), str(event[5]), str(event[6]))
		CoopCodec.E_FLASH:
			var slot: int = int(event[1])
			if slot >= 0 and slot < enemies.capacity and enemies.active[slot] != 0:
				enemies.flash_timer[slot] = Data.cfg_float("enemies.hit_flash_s") * Settings.flash_strength()
		CoopCodec.E_SHOT:
			if GameAuthority.enemy_shots != null:
				GameAuthority.enemy_shots.fire(Vector2(float(event[1]), float(event[2])), Vector2(float(event[3]), float(event[4])),
					float(event[5]), float(event[6]), str(event[7]), str(event[8]), int(event[9]))
		CoopCodec.E_SHOTS:
			_apply_shots(str(event[1]), event[2])
		CoopCodec.E_REACTION:
			GameAuthority.reaction_triggered.emit(str(event[1]), Vector2(float(event[2]), float(event[3])), float(event[4]),
				GameAuthority.player_by_id(int(event[5])))
		CoopCodec.E_SHIFT:
			world.shift_by(Vector2i(int(event[1]), int(event[2])))
		CoopCodec.E_BUILD:
			var data: Array = event[1]
			var player: Player = GameAuthority.player_by_id(int(data[0]))
			if player != null:
				CoopCodec.apply_build(player, data)
		CoopCodec.E_PLACE:
			var player: Player = GameAuthority.player_by_id(int(event[1]))
			if player != null and player.is_local:
				player.position += Vector2(float(event[2]), float(event[3]))
		CoopCodec.E_MIRROR:
			var mirror: CoopMirror = _mirrors.get(str(event[1]))
			if mirror != null:
				mirror.apply(event[2])
		CoopCodec.E_EFFECT:
			if effects != null:
				effects.spawn_from_host(int(event[1]), Vector2(float(event[2]), float(event[3])), float(event[4]), float(event[5]),
					float(event[6]), event[7])
		CoopCodec.E_SUMMON:
			_play_summon(event)
		CoopCodec.E_AGE:
			GameAuthority.age_changed.emit(str(event[1]))
		CoopCodec.E_JOIN:
			if int(event[1]) != Net.my_id:
				CoopLateJoin.add_hero(world, int(event[1]), str(event[2]), Vector2(float(event[3]), float(event[4])))
		CoopCodec.E_RUN_END:
			var run: RunState = GameAuthority.run
			if run != null and not run.ended:
				run.ended = true
				GameAuthority.run_ended.emit(run)
		_:
			CoopChoices.on_event(event)


## A summon or Resonance's visuals (the host dealt the damage).
func _play_summon(event: Array) -> void:
	var player: Player = GameAuthority.player_by_id(int(event[1]))
	if player == null or summons == null:
		return
	if str(event[2]) == "god":
		var god: Dictionary = GodRules.find(str(event[3]))
		if not god.is_empty():
			summons.run(god, player)
	elif gods != null and gods.resonance != null:
		var ids: Array = event[3]
		if ids.size() >= 2:
			var resonance: Dictionary = ResonanceManager.find_pair(str(ids[0]), str(ids[1]))
			if not resonance.is_empty():
				summons.run_resonance(resonance, player)
				if player.is_local:
					Meta.note_resonance_fired(str(resonance.get("id", "")))
	if player.is_local:
		GameCamera.shake_screen(get_tree(), Data.cfg_float("settings.shake_summon_px"))


func _apply_shots(op: String, args: Array) -> void:
	var shots: EnemyProjectiles = GameAuthority.enemy_shots
	if shots == null:
		return
	match op:
		"rewind":
			shots.rewind_boss_shots()
		"clear":
			shots.clear_all(int(args[0]))
		"block":
			shots.block_circle(Vector2(float(args[0]), float(args[1])), float(args[2]))


## Each player's god slots and meters (the buttons and rings show them).
func _apply_gods(player: Player, slots: Array) -> void:
	if gods == null:
		return
	var mine: Array = []
	for row: Variant in slots:
		var god: Dictionary = GodRules.find(str(row[0]))
		if not god.is_empty():
			mine.append({"id": str(row[0]), "god": god, "meter": float(row[1])})
	gods.set_slots(player, mine)
