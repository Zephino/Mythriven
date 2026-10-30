class_name CoopLateJoin
extends Node
## Joining a public game's run in progress (GAME_DESIGN.md: Online co-op /
## Public games), on the host. A player who arrives gets their Hero beside the
## host's Hero with its signature weapon (sharing the team's XP and level),
## the other players hear about it (E_JOIN), and right after the next update
## the newcomer gets a snapshot of everything already in the world: how far
## the world has moved (origin shifts), the Age, every enemy, every build, and
## every shrine, chest, and boss. Their device (CoopClient) waits for it
## before showing anything else.

var host: CoopHost
## Newcomers whose snapshot goes out after the next update.
var _waiting: PackedInt32Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Net.late_joined.connect(_on_late_joined)
	host.tick_sent.connect(_send_snapshots)


func _on_late_joined(id: int) -> void:
	var hero_id: String = str(Net.roster.get(id, {}).get("hero", ""))
	if hero_id == "":
		return
	var beside: Player = GameAuthority.local_player()
	# Each id has its own side of the host's Hero, so newcomers never land on someone.
	var offset := Vector2(Data.cfg_float("coop.spawn_spread_px"), 0.0).rotated(PI * 0.5 * (id - 1))
	var at: Vector2 = (beside.position if beside != null else Vector2.ZERO) + offset
	add_hero(host.world, id, hero_id, at)
	host.add_event([CoopCodec.E_JOIN, id, hero_id, at.x, at.y])
	if not _waiting.has(id):
		_waiting.append(id)


## Adds another player's Hero to this device's run. Ids are used again after
## a player leaves, so a Shade left behind with the same id makes way.
static func add_hero(world: Node, id: int, hero_id: String, at: Vector2) -> Player:
	var old: Player = GameAuthority.player_by_id(id)
	if old != null and not old.is_local:
		GameAuthority.remove_player(old)
	var player: Player = GameAuthority.spawn_player(world, at, null, false, hero_id, id)
	GameAuthority.give_weapon(player, str(player.hero.get("signature_weapon", Data.cfg_string("player.starting_weapon"))))
	return player


## Sent right after an update, so nothing waiting in the next one is already in the snapshot.
func _send_snapshots() -> void:
	for id: int in _waiting:
		if GameAuthority.player_by_id(id) != null:
			Net.send(id, snapshot(id))
	_waiting.clear()


func snapshot(id: int) -> Array:
	var events: Array = []
	var run: RunState = GameAuthority.run
	if run != null:
		events.append([CoopCodec.E_AGE, RunArc.age_at(run.arc_s())])
	var enemies: EnemyManager = host.enemies
	for slot: int in enemies.capacity:
		if enemies.active[slot] != 0:
			events.append([CoopCodec.E_SPAWN, slot, enemies.kind[slot], enemies.positions[slot].x, enemies.positions[slot].y,
				enemies.max_hp[slot]])
	var places: Array = []
	for player: Player in GameAuthority.players:
		events.append([CoopCodec.E_BUILD, CoopCodec.build(player)])
		places.append([player.player_id, player.position.x, player.position.y])
	for node: Node in get_tree().get_nodes_in_group(CoopHost.MIRROR_GROUP):
		var mirror: CoopMirror = node.get_meta("coop_mirror")
		if mirror != null:
			events.append([CoopCodec.E_MIRROR, mirror.id, mirror.capture()])
	var shift: Vector2i = host.world.total_shift
	var newcomer: Player = GameAuthority.player_by_id(id)
	var at: Vector2 = newcomer.position if newcomer != null else Vector2.ZERO
	return [NetMsg.SNAPSHOT, shift.x, shift.y, at.x, at.y, events, places]
