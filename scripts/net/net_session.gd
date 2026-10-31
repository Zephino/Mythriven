extends Node
## Autoload "Net": the co-op session (GAME_DESIGN.md: Online co-op (6-digit
## codes)). Holds the lobby connection from the Co-op screen through the run,
## the players and their Heroes, and the host's choices (level, Swift Mode;
## the host's Omens apply to everyone). The host's game is the authority in a
## run; run messages are passed on to CoopHost / CoopClient through
## `run_message`.

signal changed
## The session ended; `reason` is a translation key ("" when this player left).
signal ended(reason: String)
signal run_message(from: int, msg: Array)
## Host → everyone: the run is starting (main.gd builds it).
signal run_starting
## Host: a player joined the run in progress (CoopHost adds their Hero).
signal late_joined(id: int)

enum State { OFF, CONNECTING, LOBBY, IN_RUN }

var state: State = State.OFF
var lobby: LobbyService
var my_id: int = 0
var code: String = ""
## id -> {"hero": hero id ("" = not chosen yet), "here": false while that
## player is still on the results screen after a run}
var roster: Dictionary = {}
var level_id: String = ""
var swift: bool = false
var omens: PackedStringArray = []
var run_seed: int = 0
## A public game: on the public list for anyone to join
## (GAME_DESIGN.md: Online co-op / Public games).
var public_game: bool = false
## On a player who joined a run already in progress: their game waits for the
## host's snapshot of the world (CoopClient).
var joined_late: bool = false
## Set before connecting to use another service (the tests use LocalLobby).
var service_override: LobbyService = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


# --- State --------------------------------------------------------------------------------

func active() -> bool:
	return state != State.OFF


func in_run() -> bool:
	return state == State.IN_RUN


func is_host() -> bool:
	return active() and my_id == LobbyService.HOST_ID


## True on a joining player's device during a co-op run: the host decides
## everything that happens, and this device shows it.
func is_client() -> bool:
	return state == State.IN_RUN and my_id != LobbyService.HOST_ID


## Player ids in turn order (the host first).
func player_ids() -> PackedInt32Array:
	var ids := PackedInt32Array(roster.keys())
	ids.sort()
	return ids


## Ready to start: everyone has a Hero and is back in the lobby. A friend
## game needs a second player; a public game can start alone (others join later).
func everyone_ready() -> bool:
	if roster.size() < (1 if public_game else 2):
		return false
	for id: int in roster:
		if str(roster[id].get("hero", "")) == "" or not bool(roster[id].get("here", true)):
			return false
	return true


# --- Starting and leaving ---------------------------------------------------------------

func host_game(hero_id: String, is_public: bool = false) -> void:
	_open()
	public_game = is_public
	roster = {LobbyService.HOST_ID: {"hero": hero_id, "here": true}}
	level_id = Meta.selected_level()
	lobby.host(is_public)


func join_game(join_code: String, hero_id: String, is_public: bool = false) -> void:
	_open()
	public_game = is_public
	roster = {}
	_pending_hero = hero_id
	lobby.join(join_code)


## Leaves the lobby or the run (the host leaving ends it for everyone).
## `reason`: a translation key shown on the Co-op screen ("" when the player chose to leave).
func leave(reason: String = "") -> void:
	if lobby != null:
		lobby.leave()
	_close(reason)


func choose_hero(hero_id: String) -> void:
	if is_host():
		roster[my_id]["hero"] = hero_id
		broadcast_roster()
	else:
		send(LobbyService.HOST_ID, [NetMsg.HERO, hero_id])
	changed.emit()


## Host only.
func set_level(id: String, swift_mode: bool) -> void:
	level_id = id
	swift = swift_mode
	broadcast_roster()
	changed.emit()


## Host only: starts the run for everyone.
func start_run() -> void:
	if not is_host() or not everyone_ready():
		return
	var seeder := RandomNumberGenerator.new()
	seeder.randomize()
	run_seed = seeder.randi()
	omens = OmenRules.active()
	lobby.lock()
	send(LobbyService.EVERYONE, [NetMsg.START, run_seed, level_id, swift, Array(omens), roster])
	begin_run()


## After a run: back to the same lobby (same code, same players) for another
## run. The host can start again once everyone is back; new friends may join.
func back_to_lobby() -> void:
	if state != State.IN_RUN:
		return
	state = State.LOBBY
	joined_late = false
	if roster.has(my_id):
		roster[my_id]["here"] = true
	if is_host():
		lobby.reopen()
		broadcast_roster()
	else:
		send(LobbyService.HOST_ID, [NetMsg.BACK])
	changed.emit()


func send(to: int, msg: Array) -> void:
	send_bytes(to, NetMsg.encode(msg))


func send_bytes(to: int, data: PackedByteArray) -> void:
	if lobby != null:
		lobby.send(to, data)


func my_hero() -> String:
	return str(roster.get(my_id, {}).get("hero", ""))


var _pending_hero: String = ""


func _open() -> void:
	if lobby != null:
		lobby.leave()
		lobby.queue_free()
	lobby = service_override if service_override != null else CloudflareLobby.new()
	add_child(lobby)
	lobby.opened.connect(_on_opened)
	lobby.peer_joined.connect(_on_peer_joined)
	lobby.peer_left.connect(_on_peer_left)
	lobby.received.connect(_on_received)
	lobby.closed.connect(_close)
	state = State.CONNECTING
	joined_late = false
	my_id = 0
	code = ""
	changed.emit()


func _close(reason: String) -> void:
	if state == State.OFF:
		return
	state = State.OFF
	roster = {}
	public_game = false
	joined_late = false
	my_id = 0
	code = ""
	if lobby != null:
		lobby.queue_free()
		lobby = null
	ended.emit(reason)
	changed.emit()


## Starts this device's run (from the host's START, or LATE_START for a run in progress).
func begin_run() -> void:
	state = State.IN_RUN
	# Everyone comes back to the lobby on their own after the run.
	for id: int in roster:
		roster[id]["here"] = false
	GameAuthority.selected_hero_id = my_hero()
	Meta.level_id = level_id
	Meta.swift = swift
	run_starting.emit()
	changed.emit()


# --- Lobby messages ---------------------------------------------------------------------

func _on_opened(id: int, lobby_code: String, _peers: PackedInt32Array) -> void:
	my_id = id
	code = lobby_code
	state = State.LOBBY
	if is_host():
		_tell_public_list()
	else:
		send(LobbyService.HOST_ID, [NetMsg.HELLO, version(), _pending_hero])
	changed.emit()


func _on_peer_joined(_id: int) -> void:
	changed.emit()


func _on_peer_left(id: int) -> void:
	roster.erase(id)
	if is_host():
		broadcast_roster()
	run_message.emit(id, [NetMsg.BYE])
	changed.emit()


func _on_received(from: int, data: PackedByteArray) -> void:
	var msg: Array = NetMsg.decode(data)
	if msg.is_empty():
		return
	var kind: int = msg[0]
	if kind >= NetMsg.INPUT:
		if state == State.IN_RUN:
			run_message.emit(from, msg)
		return
	if is_host():
		NetLobby.host_message(self, from, msg)
	elif from == LobbyService.HOST_ID:
		NetLobby.client_message(self, msg)
	changed.emit()


func broadcast_roster() -> void:
	if is_host():
		send(LobbyService.EVERYONE, [NetMsg.ROSTER, roster, level_id, swift])
		_tell_public_list()


## Public games: what the public list shows about this game.
func _tell_public_list() -> void:
	if public_game and lobby != null:
		lobby.set_info(level_id, version())


## A Hero id this player may use ("" for an unknown one).
static func valid_hero(hero_id: String) -> String:
	return hero_id if not HeroRules.find(hero_id).is_empty() else ""


static func version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", ""))
