class_name CloudSaveScreen
extends MenuScreen
## Settings → Account and cloud save (GAME_DESIGN.md: Cloud saves across PC
## and phone). Sign in with Google (the same account on every device), or
## without an account turn cloud saves on to get a private code and type it on
## another device. Shows when it last synced and any notice (such as gold
## taken from the other device's newer save). One device plays at a time.

var _code_box: LineEdit
var _name_box: LineEdit
var _error: String = ""


func _ready() -> void:
	super._ready()
	Meta.cloud.status_changed.connect(refresh)
	Meta.cloud.sign_in.changed.connect(refresh)


func build() -> void:
	set_title(tr_key("UI_CLOUD_SAVE"))
	var cloud: CloudSync = Meta.cloud
	if OnlineConfig.cloud_url() == "":
		add_line(tr_key("UI_CLOUD_NOT_SET_UP"))
		return
	if CloudSync.signed_in():
		_build_username()
		_build_account()
	else:
		add_line(tr_key("UI_CLOUD_ABOUT"))
	if CloudSync.account() == "":
		_build_sign_in()
	if not CloudSync.is_on():
		add_line(tr_key("UI_CLOUD_NO_ACCOUNT"))
		add_button(tr_key("UI_CLOUD_TURN_ON"), _on_turn_on)
		add_line(tr_key("UI_CLOUD_LINK_HELP"))
		_code_box = add_input(tr_key("UI_CLOUD_CODE_PLACEHOLDER"), 16, tr_key("UI_CLOUD_LINK_HELP"))
		add_button(tr_key("UI_CLOUD_LINK"), _on_link)
		if _error != "":
			add_line(_error)
		return
	add_line(tr_key("UI_CLOUD_STATE_" + cloud.state.to_upper()))
	if cloud.last_synced_unix > 0:
		add_line(tr_key("UI_CLOUD_LAST_SYNCED") % Time.get_time_string_from_unix_time(cloud.last_synced_unix + _utc_offset_s()).left(5))
	if cloud.notice != "":
		add_line(cloud.notice)
	add_line(tr_key("UI_CLOUD_ONE_DEVICE"))
	if CloudSync.account() == "":
		add_line(tr_key("UI_CLOUD_YOUR_CODE") % CloudSync.pretty(CloudSync.code()))
		add_line(tr_key("UI_CLOUD_CODE_PRIVATE"))
		add_button(tr_key("UI_CLOUD_COPY"), _on_copy)
	add_button(tr_key("UI_CLOUD_SYNC_NOW"), _on_sync_now, cloud.state != "syncing")
	add_button(tr_key("UI_SIGN_OUT" if CloudSync.account() != "" else "UI_CLOUD_TURN_OFF"), _on_turn_off)


## The Google account signed in, and what this account holds.
func _build_account() -> void:
	var email: String = CloudSync.account_email()
	add_line(tr_key("UI_SIGNED_IN_EMAIL") % email if email != "" else tr_key("UI_SIGNED_IN_GOOGLE"))
	add_line(tr_key("UI_ACCOUNT_PROGRESS") % [SaveGame.gold(), SaveGame.list("heroes_unlocked").size(),
		SaveGame.list("achievements").size()])


## The username other players see (never the real name), only while signed
## in with Google. Saved with progress, so it follows the account.
func _build_username() -> void:
	var current: String = SaveGame.player_name()
	add_line(tr_key("UI_USERNAME") % current if current != "" else tr_key("UI_USERNAME_NONE"))
	_name_box = add_input(tr_key("UI_USERNAME_HINT"), Data.cfg_int("leaderboard.max_name_length"), tr_key("UI_USERNAME_HINT"))
	_name_box.text = current
	_name_box.text_submitted.connect(func(_t: String) -> void: _on_save_name())
	add_button(tr_key("UI_USERNAME_SAVE"), _on_save_name)


func _on_save_name() -> void:
	var cleaned: String = LeaderboardEntry.clean_name(_name_box.text if _name_box != null else "")
	if cleaned == "":
		return
	SaveGame.set_player_name(cleaned)
	refresh()


## Sign in with Google: opens the browser, then waits for the player there.
func _build_sign_in() -> void:
	var sign_in: AccountSignIn = Meta.cloud.sign_in
	if sign_in.state == "starting" or sign_in.state == "waiting":
		add_line(tr_key("UI_SIGNIN_WAITING"))
		add_button(tr_key("UI_COOP_CANCEL"), sign_in.cancel)
	else:
		add_button(tr_key("UI_SIGNIN_GOOGLE"), sign_in.start, AccountSignIn.available())
	if sign_in.error != "":
		add_line(tr_key(sign_in.error))


func _on_turn_on() -> void:
	Meta.cloud.turn_on()
	refresh()


func _on_link() -> void:
	_error = "" if _code_box != null and Meta.cloud.link(_code_box.text) else tr_key("UI_CLOUD_BAD_CODE")
	refresh()


func _on_copy() -> void:
	DisplayServer.clipboard_set(CloudSync.pretty(CloudSync.code()))


func _on_sync_now() -> void:
	Meta.cloud.request_sync(true)


func _on_turn_off() -> void:
	if Net.active() or (GameAuthority.run != null and not GameAuthority.run.ended):
		return
	Meta.cloud.turn_off()
	refresh()


static func _utc_offset_s() -> int:
	return int(Time.get_time_zone_from_system().get("bias", 0)) * 60
