class_name CloudSync
extends Node
## Cloud saves (GAME_DESIGN.md: Cloud saves across PC and phone), through the
## owner's Cloudflare Worker (leaderboard-api/src/cloud.js) instead of Epic
## Online Services (owner decision, 00.01.25). The player turns it on in
## Settings → Cloud save and gets a private sync code; typing the same code on
## another device links the two. The code is kept only on this device, in its
## own file, never inside the save.
##
## When it syncs: on launch, soon after anything is saved between runs (a
## purchase, the end of a run), and during a run at most once every
## save.cloud_sync_min_interval_s when something lasting was earned. Each sync
## downloads the cloud copy, merges it with this device's save
## (SaveGame.merge: unlocks combine, the higher level wins, gold comes from
## the device played last), saves the result here, and uploads it. The game
## always works offline; a failed sync is simply tried again later.
## Signing in with Google (AccountSignIn, owner request 10/31/2026) fills in
## the account's code automatically; PlayLock keeps a save to one device at a time.

signal status_changed

const ALPHABET := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
const CODE_LENGTH := 12
## Seconds to wait after a between-runs save before syncing (several saves
## in a row become one upload).
const SOON_S := 2.0

## What the Cloud save screen shows: "off", "syncing", "synced", or "error".
var state: String = "off"
## A one-line notice for the player (for example when gold came from the other device).
var notice: String = ""
var last_synced_unix: int = 0
var sign_in: AccountSignIn
var play_lock: PlayLock

var _http: HTTPRequest
var _busy: bool = false
var _phase: String = ""
var _wait_s: float = -1.0
var _since_sync_s: float = 0.0
## True from linking until the first sync: the cloud copy's gold wins, so a
## fresh device never wipes the gold saved from the other one.
var _linking: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_http = HTTPRequest.new()
	_http.timeout = 20.0
	_http.request_completed.connect(_on_reply)
	add_child(_http)
	sign_in = AccountSignIn.new()
	add_child(sign_in)
	play_lock = PlayLock.new()
	add_child(play_lock)
	state = "synced" if is_on() else "off"
	# Version 00.01.42 kept the Google name here; the owner chose usernames instead.
	_set_value("name", "")
	if is_on():
		request_sync(true)


# --- The sync code (this device only) ------------------------------------------------

static func code() -> String:
	return normalize(_value("code"))


## How this device signed in ("google"), or "" when it uses a typed code.
static func account() -> String:
	return _value("account")


## This device's own random id (for the one-device-at-a-time rule).
static func device_id() -> String:
	var id: String = _value("device")
	if id == "":
		id = Crypto.new().generate_random_bytes(12).hex_encode()
		_set_value("device", id)
	return id


static func _value(key: String) -> String:
	var file := ConfigFile.new()
	if file.load(file_path()) != OK:
		return ""
	return str(file.get_value("cloud", key, ""))


## Changes one value in this device's cloud file ("" removes it), keeping the others.
static func _set_value(key: String, value: String) -> void:
	var file := ConfigFile.new()
	file.load(file_path())
	if value != "":
		file.set_value("cloud", key, value)
	elif file.has_section_key("cloud", key):
		file.erase_section_key("cloud", key)
	file.save(file_path())


## This device's code file (a scratch one while the tests run or use a test save).
static func file_path() -> String:
	if SaveGame.path() == Data.cfg_string("save.file"):
		return Data.cfg_string("save.cloud_file")
	return SaveGame.path() + ".cloud.cfg"


static func is_on() -> bool:
	return code() != "" and OnlineConfig.cloud_url() != ""


static func set_code(new_code: String) -> void:
	_set_value("code", new_code)


## `email`: which Google account is signed in, shown in Settings (kept only on this device).
static func set_account(provider: String, email: String = "") -> void:
	_set_value("account", provider)
	_set_value("email", email.left(120) if provider != "" else "")


## The signed-in Google account's email ("" if unknown).
static func account_email() -> String:
	return _value("email")


## A new random code (60 bits), from letters and digits that can't be mixed up.
static func new_code() -> String:
	var bytes: PackedByteArray = Crypto.new().generate_random_bytes(CODE_LENGTH)
	var out: String = ""
	for b: int in bytes:
		out += ALPHABET[b % ALPHABET.length()]
	return out


## Upper-case, no dashes or spaces; "" if it isn't a valid code.
static func normalize(raw: String) -> String:
	var tidy: String = raw.replace("-", "").replace(" ", "").strip_edges().to_upper()
	if tidy.length() != CODE_LENGTH:
		return ""
	for ch: String in tidy:
		if not ALPHABET.contains(ch):
			return ""
	return tidy


## "ABCD-EFGH-JK23", easier to read and type.
static func pretty(raw: String) -> String:
	var tidy: String = normalize(raw)
	return "%s-%s-%s" % [tidy.substr(0, 4), tidy.substr(4, 4), tidy.substr(8, 4)] if tidy != "" else ""


# --- Turning it on and off ---------------------------------------------------------------

## Starts cloud saves with a new code and uploads this device's save.
func turn_on() -> void:
	set_code(new_code())
	notice = ""
	request_sync(true)


## Links this device to the code from another device. Returns false if the code isn't valid.
func link(typed: String) -> bool:
	var tidy: String = normalize(typed)
	if tidy == "":
		return false
	set_code(tidy)
	notice = ""
	_linking = true
	request_sync(true)
	return true


## Stops syncing on this device (its save stays; the cloud copy stays too).
func turn_off() -> void:
	play_lock.release()
	set_code("")
	set_account("")
	_http.cancel_request()
	_busy = false
	state = "off"
	status_changed.emit()


## Asks for a sync: `now` soon (launch, a purchase, the end of a run), else
## batched to at most once every save.cloud_sync_min_interval_s.
func request_sync(now: bool = false) -> void:
	if not is_on():
		return
	var wait: float = SOON_S if now else maxf(Data.cfg_float("save.cloud_sync_min_interval_s") - _since_sync_s, SOON_S)
	_wait_s = wait if _wait_s < 0.0 else minf(_wait_s, wait)


func _process(delta: float) -> void:
	_since_sync_s += delta
	if SaveGame.take_cloud_change():
		var in_run: bool = GameAuthority.run != null and not GameAuthority.run.ended
		request_sync(not in_run)
	if _wait_s < 0.0 or _busy:
		return
	_wait_s -= delta
	if _wait_s <= 0.0:
		_wait_s = -1.0
		_start()


# --- One sync: download, merge, upload ------------------------------------------------------

func _start() -> void:
	if not is_on():
		return
	_busy = true
	_since_sync_s = 0.0
	state = "syncing"
	status_changed.emit()
	_phase = "get"
	if _http.request(OnlineConfig.cloud_url(), _headers(), HTTPClient.METHOD_GET) != OK:
		_fail()


func _headers() -> PackedStringArray:
	return PackedStringArray(["Authorization: Bearer " + code(), "Accept: application/json", "Content-Type: application/json"])


func _on_reply(result: int, status: int, _headers_in: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or status == 0:
		_fail()
		return
	if _phase == "get":
		if status != 200:
			_fail()
			return
		var reply: Variant = _parse(body.get_string_from_utf8())
		var cloud: Variant = reply.get("save") if reply is Dictionary else null
		apply_cloud(cloud if cloud is Dictionary else {}, _linking)
		_linking = false
		_phase = "put"
		if _http.request(OnlineConfig.cloud_url(), _headers(), HTTPClient.METHOD_PUT, JSON.stringify(SaveGame.data())) != OK:
			_fail()
		return
	_busy = false
	if status == 429:
		# Another device just wrote; try again shortly.
		request_sync(true)
		_wait_s = 6.0
		return
	if status != 200:
		_fail()
		return
	last_synced_unix = int(Time.get_unix_time_from_system())
	state = "synced"
	status_changed.emit()


## Merges the downloaded cloud save into this device's save and saves it here.
## `linking`: this device was just linked, so the cloud's gold (and settings)
## win. Sets a notice when the gold came from the other device.
func apply_cloud(cloud: Dictionary, linking: bool = false) -> void:
	if cloud.is_empty():
		return
	var local: Dictionary = SaveGame.data()
	var gold_before: int = SaveGame.gold()
	var merged: Dictionary = SaveGame.merge(local, cloud)
	if linking:
		merged["gold"] = int(cloud.get("gold", merged["gold"]))
	SaveGame.replace(merged)
	# Settings may have come from the other device: use them now.
	Settings.clear_cache()
	if is_inside_tree():
		Settings.apply(get_tree())
	if SaveGame.gold() != gold_before:
		notice = TranslationServer.translate("UI_CLOUD_GOLD_NOTICE") % SaveGame.gold()


func _fail() -> void:
	_busy = false
	state = "error"
	status_changed.emit()
	# Offline or the server is busy: try again later.
	request_sync(false)
	_wait_s = maxf(_wait_s, Data.cfg_float("save.cloud_sync_min_interval_s"))


static func _parse(text: String) -> Variant:
	var json := JSON.new()
	return json.data if json.parse(text) == OK else null
