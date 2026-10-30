class_name LocalLobby
extends LobbyService
## A lobby inside this one program, for the automated tests: several
## LocalLobby nodes with the same code pass messages to each other directly,
## exactly as CloudflareLobby does through the Worker.

static var _rooms: Dictionary = {}
## code -> {"level", "version"} for public games (like the Worker's public list).
static var _public: Dictionary = {}

var my_id: int = 0
var code: String = ""
var _locked: bool = false
var _is_public: bool = false


## The public games, as the Worker lists them.
static func public_games() -> Array:
	var games: Array = []
	for game_code: String in _public:
		var room: Dictionary = _rooms.get(game_code, {})
		if not room.is_empty() and room.size() < 4:
			var host_side: LocalLobby = room[HOST_ID]
			games.append({"code": game_code, "players": room.size(), "level": _public[game_code].get("level", ""),
				"version": _public[game_code].get("version", ""), "in_run": host_side._locked})
	return games


func host(is_public: bool = false) -> void:
	code = "%06d" % (randi() % 1000000)
	my_id = HOST_ID
	_is_public = is_public
	_rooms[code] = {HOST_ID: self}
	if is_public:
		_public[code] = {}
	opened.emit.call_deferred(my_id, code, PackedInt32Array())


func join(join_code: String) -> void:
	var room: Dictionary = _rooms.get(join_code, {})
	var host_side: LocalLobby = room.get(HOST_ID)
	if host_side == null or (host_side._locked and not host_side._is_public) or room.size() >= 4:
		closed.emit.call_deferred("UI_COOP_JOIN_REFUSED")
		return
	code = join_code
	my_id = 2
	while room.has(my_id):
		my_id += 1
	var peers := PackedInt32Array(room.keys())
	for other: LocalLobby in room.values():
		other.peer_joined.emit.call_deferred(my_id)
	room[my_id] = self
	opened.emit.call_deferred(my_id, code, peers)


func send(to: int, data: PackedByteArray) -> void:
	for id: int in _rooms.get(code, {}):
		if id != my_id and (to == EVERYONE or to == id):
			(_rooms[code][id] as LocalLobby).received.emit.call_deferred(my_id, data.duplicate())


func lock() -> void:
	_locked = true


func reopen() -> void:
	_locked = false


func set_info(level_id: String, version: String) -> void:
	if _public.has(code):
		_public[code] = {"level": level_id, "version": version}


func kick(id: int) -> void:
	var target: LocalLobby = _rooms.get(code, {}).get(id)
	if target != null:
		target._drop("UI_COOP_KICKED")


func leave() -> void:
	if not _rooms.has(code):
		return
	var room: Dictionary = _rooms[code]
	room.erase(my_id)
	for other: LocalLobby in room.values():
		if my_id == HOST_ID:
			other._drop("UI_COOP_HOST_LEFT")
		else:
			other.peer_left.emit.call_deferred(my_id)
	if my_id == HOST_ID or room.is_empty():
		_rooms.erase(code)
		_public.erase(code)
	code = ""


func is_open() -> bool:
	return code != "" and _rooms.has(code)


func _drop(reason: String) -> void:
	if _rooms.has(code):
		(_rooms[code] as Dictionary).erase(my_id)
	code = ""
	closed.emit.call_deferred(reason)
