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


func everyone_ready() -> bool:
	if roster.size() < 2:
		return false
	for id: int in roster:
		if str(roster[id].get("hero", "")) == "" or not bool(roster[id].get("here", true)):
			return false
	return true


# --- Starting and leaving ---------------------------------------------------------------

func host_game(hero_id: String) -> void:
	_open()
	roster = {LobbyService.HOST_ID: {"hero": hero_id, "here": true}}
	level_id = Meta.selected_level()
	lobby.host()


func join_game(join_code: String, hero_id: String) -> void:
	_open()
	roster = {}
	_pending_hero = hero_id
	lobby.join(join_code)


## Leaves the lobby or the run (the host leaving ends it for everyone).
func leave() -> void:
	if lobby != null:
		lobby.leave()
	_close("")


func choose_hero(hero_id: String) -> void:
	if is_host():
		roster[my_id]["hero"] = hero_id
		_broadcast_roster()
	else:
		send(LobbyService.HOST_ID, [NetMsg.HERO, hero_id])
	changed.emit()


## Host only.
func set_level(id: String, swift_mode: bool) -> void:
	level_id = id
	swift = swift_mode
	_broadcast_roster()
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
	_begin_run()


## After a run: back to the same lobby (same code, same players) for another
## run. The host can start again once everyone is back; new friends may join.
func back_to_lobby() -> void:
	if state != State.IN_RUN:
		return
	state = State.LOBBY
	if roster.has(my_id):
		roster[my_id]["here"] = true
	if is_host():
		lobby.reopen()
		_broadcast_roster()
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
	my_id = 0
	code = ""
	changed.emit()


func _close(reason: String) -> void:
	if state == State.OFF:
		return
	state = State.OFF
	roster = {}
	my_id = 0
	code = ""
	if lobby != null:
		lobby.queue_free()
		lobby = null
	ended.emit(reason)
	changed.emit()


func _begin_run() -> void:
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
	if not is_host():
		send(LobbyService.HOST_ID, [NetMsg.HELLO, _version(), _pending_hero])
	changed.emit()


func _on_peer_joined(_id: int) -> void:
	changed.emit()


func _on_peer_left(id: int) -> void:
	roster.erase(id)
	if is_host():
		_broadcast_roster()
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
		_host_lobby_message(from, msg)
	elif from == LobbyService.HOST_ID:
		_client_lobby_message(msg)


func _host_lobby_message(from: int, msg: Array) -> void:
	match int(msg[0]):
		NetMsg.HELLO:
			if msg.size() < 3 or str(msg[1]) != _version():
				send(from, [NetMsg.WRONG_VERSION, _version()])
				lobby.kick(from)
				return
			roster[from] = {"hero": _valid_hero(str(msg[2])), "here": true}
			_broadcast_roster()
		NetMsg.HERO:
			if roster.has(from) and msg.size() >= 2:
				roster[from]["hero"] = _valid_hero(str(msg[1]))
				_broadcast_roster()
		NetMsg.BACK:
			if roster.has(from):
				roster[from]["here"] = true
				_broadcast_roster()
	changed.emit()


func _client_lobby_message(msg: Array) -> void:
	match int(msg[0]):
		NetMsg.ROSTER:
			if msg.size() >= 4 and msg[1] is Dictionary:
				roster = msg[1]
				level_id = str(msg[2])
				swift = bool(msg[3])
		NetMsg.START:
			if msg.size() >= 6:
				run_seed = int(msg[1])
				level_id = str(msg[2])
				swift = bool(msg[3])
				omens = PackedStringArray(msg[4])
				roster = msg[5]
				_begin_run()
		NetMsg.WRONG_VERSION:
			_close("UI_COOP_WRONG_VERSION")
			return
	changed.emit()


func _broadcast_roster() -> void:
	if is_host():
		send(LobbyService.EVERYONE, [NetMsg.ROSTER, roster, level_id, swift])


## A Hero id this player may use ("" for an unknown one).
static func _valid_hero(hero_id: String) -> String:
	return hero_id if not HeroRules.find(hero_id).is_empty() else ""


static func _version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", ""))
