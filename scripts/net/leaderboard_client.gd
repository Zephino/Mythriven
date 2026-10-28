class_name LeaderboardClient
extends Node
## Talks to the shared leaderboard: reads the board (from the Worker, or from
## GitHub's `data` branch before the Worker is set up) and sends one score to
## the Worker. Never holds a GitHub key (see leaderboard-api/README.md).
## Keeps working while the game is paused (death and level-up screens pause it).

signal board_loaded(entries: Array[Dictionary], error: String)
signal score_sent(accepted: bool, error: String)

var _reader: HTTPRequest
var _sender: HTTPRequest


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_reader = _make_request(_on_read_done)
	_sender = _make_request(_on_send_done)


func fetch() -> void:
	_reader.cancel_request()
	var err: Error = _reader.request(OnlineConfig.read_url(), PackedStringArray(["Accept: application/json"]))
	if err != OK:
		var none: Array[Dictionary] = []
		board_loaded.emit(none, error_string(err))


func send(entry: Dictionary) -> void:
	if not OnlineConfig.can_post():
		score_sent.emit(false, TranslationServer.translate("UI_LB_OFFLINE"))
		return
	_sender.cancel_request()
	var headers := PackedStringArray(["Content-Type: application/json", "Accept: application/json"])
	var err: Error = _sender.request(OnlineConfig.post_url(), headers, HTTPClient.METHOD_POST, JSON.stringify(entry))
	if err != OK:
		score_sent.emit(false, error_string(err))


## The board's rows from a reply body ({"entries": [...]}); empty if unreadable.
static func parse_entries(body: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var parsed: Variant = _parse(body)
	if parsed is Dictionary and (parsed as Dictionary).get("entries") is Array:
		for row: Variant in parsed["entries"]:
			if row is Dictionary:
				rows.append(row)
	return rows


func _make_request(on_done: Callable) -> HTTPRequest:
	var request := HTTPRequest.new()
	request.timeout = Data.cfg_float("leaderboard.request_timeout_s")
	request.request_completed.connect(on_done)
	add_child(request)
	return request


func _on_read_done(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	# 404: the board file doesn't exist yet, so nobody has a score.
	var problem: String = "" if code == 404 else _problem(result, code)
	board_loaded.emit(parse_entries(body.get_string_from_utf8()), problem)


func _on_send_done(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var problem: String = _problem(result, code)
	var parsed: Variant = _parse(body.get_string_from_utf8())
	var reply: Dictionary = parsed if parsed is Dictionary else {}
	if problem != "":
		score_sent.emit(false, str(reply.get("error", problem)))
		return
	score_sent.emit(bool(reply.get("accepted", false)), "")


## "" when the request worked; otherwise a short reason to show the player.
func _problem(result: int, code: int) -> String:
	if result != HTTPRequest.RESULT_SUCCESS:
		return TranslationServer.translate("UI_LB_NO_CONNECTION")
	if code < 200 or code >= 300:
		return "HTTP %d" % code
	return ""


## Parsed JSON, or null. (JSON.parse_string would also print an error for an empty reply.)
static func _parse(text: String) -> Variant:
	var json := JSON.new()
	return json.data if json.parse(text) == OK else null
