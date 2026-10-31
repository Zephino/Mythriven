class_name AccountSignIn
extends Node
## Sign in with Google (owner request 10/31/2026; leaderboard-api/src/accounts.js).
## The same on the web, PC, and phones: the game asks the Worker for a sign-in
## page, opens it in the browser, and asks every few seconds until the player
## has signed in there. The Worker then hands over the account's cloud-save
## code, and this device links to it (CloudSync.link: unlocks combine, and the
## account's gold wins). A device that already had cloud saves brings its save
## to a brand-new account. Google's email is kept only on this device, to show
## which account is signed in; the real name is never asked for (players
## choose a username instead, SaveGame.player_name).

signal changed

## Seconds between asking the Worker whether the player has signed in.
const POLL_S := 2.0

## "idle", "starting", "waiting" (the browser page is open), "asking" (signed in; waiting for the player to say
## whether to bring this device's progress, the first time only), or "done".
var state: String = "idle"
## A translation key when something went wrong ("" otherwise).
var error: String = ""

var _http: HTTPRequest
var _login: String = ""
var _poll_in: float = -1.0
var _left_s: float = 0.0
## While "asking": the account's code and email, to finish with once the player answers.
var _pending: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_http = HTTPRequest.new()
	_http.timeout = 15.0
	_http.request_completed.connect(_on_reply)
	add_child(_http)


static func available() -> bool:
	return OnlineConfig.auth_url("start") != ""


func start() -> void:
	if not available() or state == "starting" or state == "waiting":
		return
	error = ""
	_http.cancel_request()
	state = "starting"
	changed.emit()
	var body: String = JSON.stringify({"code": CloudSync.code()})
	if _http.request(OnlineConfig.auth_url("start"), ["Content-Type: application/json"], HTTPClient.METHOD_POST, body) != OK:
		_stop("UI_SIGNIN_NO_CONNECTION")


func cancel() -> void:
	_stop("")


func _process(delta: float) -> void:
	if state != "waiting":
		return
	_left_s -= delta
	if _left_s <= 0.0:
		_stop("UI_SIGNIN_EXPIRED")
		return
	if _poll_in < 0.0:
		return
	_poll_in -= delta
	if _poll_in <= 0.0:
		_poll_in = -1.0
		if _http.request(OnlineConfig.auth_url("poll") + "?login=" + _login) != OK:
			_poll_in = POLL_S


func _on_reply(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var reply: Variant = JSON.parse_string(body.get_string_from_utf8()) if result == HTTPRequest.RESULT_SUCCESS else null
	if state == "starting":
		if status == 503:
			_stop("UI_SIGNIN_NOT_SET_UP")
		elif status != 200 or not reply is Dictionary or str(reply.get("login", "")) == "":
			_stop("UI_SIGNIN_NO_CONNECTION")
		else:
			_login = str(reply["login"])
			state = "waiting"
			_left_s = 600.0
			_poll_in = POLL_S
			changed.emit()
			_open(str(reply.get("url", "")))
		return
	if state != "waiting":
		return
	# Still waiting (or a dropped reply): ask again shortly.
	_poll_in = POLL_S
	if status != 200 or not reply is Dictionary:
		return
	match str(reply.get("state", "")):
		"done":
			finish(str(reply.get("code", "")), str(reply.get("email", "")))
		"cancelled":
			_stop("UI_SIGNIN_CANCELLED")
		"expired":
			_stop("UI_SIGNIN_EXPIRED")


## The Worker handed over the account's save code: link this device to it. The first time this device signs in,
## if it has progress, the player is asked first whether to bring it (owner request 10/31/2026; see answer()).
func finish(account_code: String, account_email: String = "", keep_local: Variant = null) -> void:
	var cloud: CloudSync = get_parent() as CloudSync
	if CloudSync.normalize(account_code) == "":
		_stop("UI_SIGNIN_NO_CONNECTION")
		return
	if keep_local == null and CloudSync.should_ask_import(account_code):
		_pending = [account_code, account_email]
		state = "asking"
		changed.emit()
		return
	if CloudSync.normalize(account_code) == CloudSync.code():
		if cloud != null:
			cloud.request_sync(true)
	elif cloud != null:
		cloud.link(account_code, keep_local != false)
	else:
		CloudSync.set_code(CloudSync.normalize(account_code))
	CloudSync.set_account("google", account_email)
	state = "done"
	error = ""
	changed.emit()
	if cloud != null:
		cloud.status_changed.emit()


## The player's answer to "bring this device's progress?": true combines it with the account's; false switches
## this device to the account's progress (its own is put aside).
func answer(keep_local: bool) -> void:
	if state != "asking" or _pending.size() < 2:
		return
	var pending: Array = _pending
	_pending = []
	finish(str(pending[0]), str(pending[1]), keep_local)


func _stop(reason: String) -> void:
	_http.cancel_request()
	state = "idle"
	error = reason
	_login = ""
	_poll_in = -1.0
	changed.emit()


## Opens the sign-in page in the browser (a new tab on the web).
func _open(url: String) -> void:
	if url == "":
		return
	if OS.has_feature("web"):
		var opened: Variant = JavaScriptBridge.eval("!!window.open(%s, '_blank')" % JSON.stringify(url), true)
		if not bool(opened):
			error = "UI_SIGNIN_POPUP_BLOCKED"
			changed.emit()
		return
	OS.shell_open(url)
