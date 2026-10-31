class_name PlayLock
extends Node
## One device at a time (owner decision 10/31/2026): a cloud save (a Google
## account, or a typed sync code) can only be played on one device at once,
## and never twice in the same co-op game. Before a run or a co-op game starts
## this device claims the save from the Worker (leaderboard-api/src/cloud.js,
## /cloud/play); while it plays it renews the claim every BEAT_S; back on the
## title screen it lets go. A game that closes without letting go loses its
## claim after the Worker's 90 s.
##
## Without cloud saves (or offline) there's nothing to check and play is
## always allowed. If another device takes over while this one was offline,
## this device's run ends with a message (`lost`).

## The claim was taken by another device during play.
signal lost

const BEAT_S := 30.0

## True while this device holds the claim.
var held: bool = false

var _beat_in: float = 0.0
var _claimer: HTTPRequest
var _beater: HTTPRequest
var _waiting: Callable = Callable()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_claimer = _make_request(_on_claimed)
	_beater = _make_request(_on_beat)
	lost.connect(_end_play)


## Claims the save to play here, then calls `on_done(allowed: bool)`.
## Allowed at once when cloud saves are off; allowed when offline.
func claim(on_done: Callable) -> void:
	if not CloudSync.is_on() or OnlineConfig.play_url() == "":
		on_done.call(true)
		return
	_waiting = on_done
	_claimer.cancel_request()
	if _claimer.request(OnlineConfig.play_url(), _headers(), HTTPClient.METHOD_POST, _body("claim")) != OK:
		_answer(true)


## Lets another device play (back on the title screen, or quitting).
func release() -> void:
	if not held:
		return
	held = false
	if not CloudSync.is_on() or OnlineConfig.play_url() == "":
		return
	var once: HTTPRequest = _make_request(func(_a: int, _b: int, _c: PackedStringArray, _d: PackedByteArray) -> void: pass)
	if once.request(OnlineConfig.play_url(), _headers(), HTTPClient.METHOD_POST, _body("release")) != OK:
		once.queue_free()
	else:
		once.request_completed.connect(func(_a: int, _b: int, _c: PackedStringArray, _d: PackedByteArray) -> void: once.queue_free())


func _process(delta: float) -> void:
	if not held:
		return
	_beat_in -= delta
	if _beat_in <= 0.0:
		_beat_in = BEAT_S
		if CloudSync.is_on():
			_beater.cancel_request()
			_beater.request(OnlineConfig.play_url(), _headers(), HTTPClient.METHOD_POST, _body("beat"))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		release()


func _on_claimed(result: int, status: int, _headers_in: PackedStringArray, _body_in: PackedByteArray) -> void:
	# Only a clear "another device is playing" stops play; offline is allowed.
	_answer(not (result == HTTPRequest.RESULT_SUCCESS and status == 409))


func _answer(allowed: bool) -> void:
	if allowed:
		held = true
		_beat_in = BEAT_S
	var on_done: Callable = _waiting
	_waiting = Callable()
	if on_done.is_valid():
		on_done.call(allowed)


func _on_beat(result: int, status: int, _headers_in: PackedStringArray, _body_in: PackedByteArray) -> void:
	if held and result == HTTPRequest.RESULT_SUCCESS and status == 409:
		held = false
		lost.emit()


## Another device has the save now: this device's run or co-op game ends.
func _end_play() -> void:
	if Net.active():
		Net.leave("UI_PLAY_TAKEN_ELSEWHERE")
	var run: RunState = GameAuthority.run
	if run == null or run.ended:
		return
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_personal(tr("UI_PLAY_TAKEN_ELSEWHERE"))
	get_tree().paused = false
	run.ended = true
	GameAuthority.run_ended.emit(run)


func _headers() -> PackedStringArray:
	return PackedStringArray(["Authorization: Bearer " + CloudSync.code(), "Content-Type: application/json"])


func _body(action: String) -> String:
	return JSON.stringify({"device": CloudSync.device_id(), "action": action})


func _make_request(on_done: Callable) -> HTTPRequest:
	var request := HTTPRequest.new()
	request.timeout = 10.0
	request.request_completed.connect(on_done)
	add_child(request)
	return request
