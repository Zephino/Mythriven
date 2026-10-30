class_name PublicGameList
extends Node
## Reads the list of public co-op games from the Worker (GAME_DESIGN.md:
## Online co-op / Public games). Only games with the same version of the game
## and a free place are offered. The tests use LocalLobby's list instead.

## `ok` is false when the list couldn't be reached.
signal listed(games: Array[Dictionary], ok: bool)

var _request: HTTPRequest


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_request = HTTPRequest.new()
	_request.timeout = 10.0
	add_child(_request)
	_request.request_completed.connect(_on_done)


func refresh() -> void:
	if Net.service_override is LocalLobby:
		listed.emit.call_deferred(offered(LocalLobby.public_games()), true)
		return
	var url: String = OnlineConfig.public_games_url()
	_request.cancel_request()
	if url == "" or _request.request(url, PackedStringArray(["Accept: application/json"])) != OK:
		listed.emit.call_deferred([] as Array[Dictionary], false)


## The games this player can join, from the list's rows.
static func offered(rows: Array) -> Array[Dictionary]:
	var games: Array[Dictionary] = []
	var version: String = str(ProjectSettings.get_setting("application/config/version", ""))
	for row: Variant in rows:
		if row is Dictionary and str(row.get("version", "")) == version and int(row.get("players", 0)) < 4 \
				and str(row.get("code", "")).length() == 6:
			games.append(row)
	return games


func _on_done(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		listed.emit([] as Array[Dictionary], false)
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	var rows: Array = parsed.get("games", []) if parsed is Dictionary and parsed.get("games") is Array else []
	listed.emit(offered(rows), true)
