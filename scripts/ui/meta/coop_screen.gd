class_name CoopScreen
extends MenuScreen
## Co-op (GAME_DESIGN.md: Screens / Co-op; Online co-op / Joining flow):
## Host a game (shows a 6-digit code) or Join one (type the code), then a
## lobby with the players and their Heroes. Each player picks a Hero
## (duplicates allowed); the host picks the level and Swift Mode, and the
## host's Omens apply to everyone. When the host leaves, the game ends for
## everyone.

var flow: MenuFlow
var _code_box: LineEdit
var _message: String = ""


static func new_for(menu_flow: MenuFlow) -> CoopScreen:
	var screen := CoopScreen.new()
	screen.flow = menu_flow
	return screen


func _ready() -> void:
	super._ready()
	Net.changed.connect(refresh)
	Net.ended.connect(_on_ended)
	Net.run_starting.connect(_on_run_starting)


func build() -> void:
	set_title(tr_key("UI_COOP"))
	if _message != "":
		add_line(tr_key(_message))
	if OnlineConfig.lobby_url() == "" and Net.service_override == null:
		add_line(tr_key("UI_COOP_NOT_SET_UP"))
		return
	match Net.state:
		Net.State.OFF:
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


func _build_lobby() -> void:
	add_line(tr_key("UI_COOP_CODE") % Net.code)
	if Net.is_host():
		add_line(tr_key("UI_COOP_SHARE_CODE"))
	for id: int in Net.player_ids():
		var hero_id: String = str(Net.roster[id].get("hero", ""))
		var hero_name: String = tr_key(str(HeroRules.find(hero_id).get("name_key", ""))) if hero_id != "" else tr_key("UI_COOP_CHOOSING")
		var who: String = tr_key("UI_COOP_HOST_TAG") if id == LobbyService.HOST_ID else tr_key("UI_COOP_PLAYER_TAG") % id
		add_line(("▶ " if id == Net.my_id else "• ") + who + ": " + hero_name)
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
			add_line(tr_key("UI_COOP_NEED_PLAYERS"))
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
	_message = ""
	Net.host_game(_first_hero())


func _on_join() -> void:
	_message = ""
	if _code_box != null:
		Net.join_game(_code_box.text, _first_hero())


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


func _on_ended(reason: String) -> void:
	_message = reason
	refresh()


func _on_run_starting() -> void:
	flow.start_coop()


## Leaving the screen leaves the lobby too (but not once the run is starting).
func close() -> void:
	if Net.state != Net.State.IN_RUN:
		Net.leave()
	super.close()
