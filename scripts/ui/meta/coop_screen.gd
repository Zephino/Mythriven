class_name CoopScreen
extends MenuScreen
## Co-op (GAME_DESIGN.md: Screens / Co-op; Online co-op / Joining flow):
## Host a game (shows a 6-digit code) or Join one (type the code), then a
## lobby with the players and their Heroes. Each player picks a Hero
## (duplicates allowed); the host picks the level and Swift Mode, and the
## host's Omens apply to everyone. When the host leaves, the game ends for
## everyone.
## Public Games (GAME_DESIGN.md: Online co-op / Public games) uses the same
## screen and lobby: a list of open public games to join (even during a run),
## or host one that goes on the list. Friend codes are never listed.

var flow: MenuFlow
## The Public Games screen instead of the friend-code one.
var public_mode: bool = false
var _code_box: LineEdit
var _message: String = ""
var _list: PublicGameList
var _games: Array[Dictionary] = []
var _listing: bool = false
var _list_ok: bool = true


static func new_for(menu_flow: MenuFlow, is_public: bool = false) -> CoopScreen:
	var screen := CoopScreen.new()
	screen.flow = menu_flow
	screen.public_mode = is_public
	return screen


func _ready() -> void:
	super._ready()
	Net.changed.connect(refresh)
	Net.ended.connect(_on_ended)
	Net.run_starting.connect(_on_run_starting)
	if public_mode:
		_list = PublicGameList.new()
		add_child(_list)
		_list.listed.connect(_on_listed)
		if Net.state == Net.State.OFF:
			_refresh_list()


func build() -> void:
	set_title(tr_key("UI_PUBLIC_GAMES" if public_mode else "UI_COOP"))
	if _message != "":
		add_line(tr_key(_message))
	if OnlineConfig.lobby_url() == "" and Net.service_override == null:
		add_line(tr_key("UI_COOP_NOT_SET_UP"))
		return
	match Net.state:
		Net.State.OFF:
			if public_mode:
				_build_public_list()
			else:
				_build_start()
		Net.State.CONNECTING:
			add_line(tr_key("UI_COOP_CONNECTING"))
			add_button(tr_key("UI_COOP_CANCEL"), _on_leave)
		_:
			_build_lobby()


func _build_start() -> void:
	add_line(tr_key("UI_COOP_ABOUT"))
	add_button(tr_key("UI_COOP_HOST"), _on_host)
	add_line(tr_key("UI_COOP_JOIN_HELP"))
	_code_box = add_input(tr_key("UI_COOP_CODE_PLACEHOLDER"), 6, tr_key("UI_COOP_JOIN_HELP"))
	_code_box.text_submitted.connect(_on_join_submitted)
	add_button(tr_key("UI_COOP_JOIN"), _on_join)


## The open public games (same version, a free place), newest first.
func _build_public_list() -> void:
	add_line(tr_key("UI_PUBLIC_ABOUT"))
	add_button(tr_key("UI_PUBLIC_HOST"), _on_host)
	add_button(tr_key("UI_PUBLIC_REFRESH"), _refresh_list, not _listing)
	if _listing:
		add_line(tr_key("UI_PUBLIC_LOOKING"))
	elif not _list_ok:
		add_line(tr_key("UI_PUBLIC_LIST_FAILED"))
	elif _games.is_empty():
		add_line(tr_key("UI_PUBLIC_NONE"))
	for game: Dictionary in _games:
		var level: Dictionary = GameAuthority.find_level(str(game.get("level", "")))
		var level_name: String = tr_key(str(level.get("name_key", ""))) if not level.is_empty() else "?"
		var status: String = tr_key("UI_PUBLIC_IN_RUN" if bool(game.get("in_run", false)) else "UI_PUBLIC_IN_LOBBY")
		add_button(tr_key("UI_PUBLIC_GAME_ROW") % [level_name, int(game.get("players", 0)), status],
			_on_join_public.bind(str(game.get("code", ""))))


func _build_lobby() -> void:
	add_line(tr_key("UI_COOP_CODE") % Net.code)
	if Net.is_host():
		add_line(tr_key("UI_PUBLIC_LISTED" if Net.public_game else "UI_COOP_SHARE_CODE"))
	for id: int in Net.player_ids():
		var hero_id: String = str(Net.roster[id].get("hero", ""))
		var hero_name: String = tr_key(str(HeroRules.find(hero_id).get("name_key", ""))) if hero_id != "" else tr_key("UI_COOP_CHOOSING")
		var who: String = tr_key("UI_COOP_HOST_TAG") if id == LobbyService.HOST_ID else tr_key("UI_COOP_PLAYER_TAG") % id
		var away: String = "" if bool(Net.roster[id].get("here", true)) else " " + tr_key("UI_COOP_STILL_AT_RESULTS")
		add_line(("▶ " if id == Net.my_id else "• ") + who + ": " + hero_name + away)
	add_line(tr_key("UI_COOP_PICK_HERO"))
	for hero: Dictionary in HeroRules.unlocked():
		var id: String = str(hero.get("id", ""))
		var mark: String = tr_key("UI_ON_MARK") if id == Net.my_hero() else tr_key("UI_OFF_MARK")
		add_button(mark + " " + tr_key(str(hero.get("name_key", id))), Net.choose_hero.bind(id))
	var level: Dictionary = GameAuthority.find_level(Net.level_id) if Net.level_id != "" else {}
	var level_name: String = tr_key(str(level.get("name_key", Net.level_id)))
	if Net.is_host():
		add_button(tr_key("UI_COOP_LEVEL") % level_name, _on_next_level)
		if LevelRules.swift_unlocked(Net.level_id):
			add_button(tr_key("UI_SWIFT_ON") if Net.swift else tr_key("UI_SWIFT_OFF"), _on_toggle_swift)
		var omens: PackedStringArray = OmenRules.active()
		if not omens.is_empty():
			add_line(tr_key("UI_COOP_OMENS") % omens.size())
		add_button(tr_key("UI_COOP_START"), Net.start_run, Net.everyone_ready())
		if not Net.everyone_ready():
			add_line(tr_key("UI_PUBLIC_NEED_READY" if Net.public_game else "UI_COOP_NEED_PLAYERS"))
	else:
		add_line(tr_key("UI_COOP_LEVEL") % level_name + (" · " + tr_key("UI_SWIFT_MODE") if Net.swift else ""))
		add_line(tr_key("UI_COOP_WAITING_FOR_HOST"))
	add_button(tr_key("UI_COOP_LEAVE"), _on_leave)


func _first_hero() -> String:
	var heroes: Array[Dictionary] = HeroRules.unlocked()
	var last: String = GameAuthority.selected_hero_id
	if last != "" and not HeroRules.find(last).is_empty():
		return last
	return str(heroes[0].get("id", "")) if not heroes.is_empty() else ""


func _on_host() -> void:
	_claim_then(func() -> void: Net.host_game(_first_hero(), public_mode))


func _on_join_public(game_code: String) -> void:
	_claim_then(func() -> void: Net.join_game(game_code, _first_hero(), true))


## One device at a time (PlayLock): this account can't be in a game on another device.
func _claim_then(go: Callable) -> void:
	_message = ""
	Meta.cloud.play_lock.claim(func(allowed: bool) -> void:
		if allowed:
			go.call()
		else:
			_message = "UI_PLAY_ELSEWHERE"
			refresh())


func _refresh_list() -> void:
	if _list == null:
		return
	_listing = true
	_list.refresh()
	refresh()


func _on_listed(games: Array[Dictionary], ok: bool) -> void:
	_listing = false
	_games = games
	_list_ok = ok
	refresh()


func _on_join() -> void:
	if _code_box != null:
		var typed: String = _code_box.text
		_claim_then(func() -> void: Net.join_game(typed, _first_hero()))


func _on_join_submitted(_text: String) -> void:
	_on_join()


func _on_next_level() -> void:
	var open: Array[String] = []
	for level: Dictionary in LevelRules.all():
		if LevelRules.is_unlocked(level):
			open.append(str(level.get("id", "")))
	if open.is_empty():
		return
	Net.set_level(open[(open.find(Net.level_id) + 1) % open.size()], false)


func _on_toggle_swift() -> void:
	Net.set_level(Net.level_id, not Net.swift)


func _on_leave() -> void:
	Net.leave()
	Meta.cloud.play_lock.release()


func _on_ended(reason: String) -> void:
	_message = reason
	Meta.cloud.play_lock.release()
	if public_mode:
		_refresh_list()
	refresh()


func _on_run_starting() -> void:
	flow.start_coop()


## Leaving the screen leaves the lobby too (but not once the run is starting).
func close() -> void:
	if Net.state != Net.State.IN_RUN:
		Net.leave()
		Meta.cloud.play_lock.release()
	super.close()
