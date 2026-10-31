class_name MenuFlow
extends Node
## The menus outside a run (GAME_DESIGN.md: Screens): Title → Play → level
## select → Hero select → the run, and the Hall of Legends with its pages.
## Before a run starts, PlayLock checks this account isn't playing on another
## device; back in the menus (outside co-op), this device lets go of it.
## The main scene adds this when there's no run to start and listens for
## `start`. Which screen opens first comes from Meta.next_screen.

signal start(hero_id: String)

## Runs this device already said "Not now" to (by their seed), so it doesn't ask again this session.
static var _declined: Array[int] = []


func _ready() -> void:
	if not Net.active():
		Meta.cloud.play_lock.release()
	match Meta.next_screen:
		"hero_select":
			show_hero_select()
		"coop":
			# Back in the co-op lobby after a run, over the title.
			var title_screen := TitleScreen.new_for(self)
			add_child(title_screen)
			title_screen.open_child(CoopScreen.new_for(self, Net.public_game))
		"hall":
			# The Hall opens over the title, so Back returns to the title.
			var title := TitleScreen.new_for(self)
			add_child(title)
			title.open_child(HallScreen.new_for(self))
		_:
			add_child(TitleScreen.new_for(self))
			if Meta.notice.is_empty():  # not straight after this device's run was taken over
				_offer_takeover()
	Meta.next_screen = "title"
	if not Meta.notice.is_empty():
		add_child(NoticeScreen.make(str(Meta.notice[0]), str(Meta.notice[1])))
		Meta.notice = []


## Taking over a run (owner decisions 10/31/2026): if this account is playing a solo run on another device right now,
## ask whether to carry on with it here. Yes: the whole build carries over and the other device steps aside.
func _offer_takeover() -> void:
	if Net.active():
		return
	Meta.cloud.play_lock.peek(func(snap: Dictionary) -> void:
		if snap.is_empty() or not is_inside_tree() or _declined.has(int(snap.get("seed", 0))):
			return
		var text: String = tr("UI_TAKEOVER_ASK") % RunSnapshot.summary(snap)
		add_child(NoticeScreen.ask("UI_TAKEOVER_TITLE", text, [
			["UI_TAKEOVER_YES", func() -> void: _take_over()],
			["UI_TAKEOVER_NO", func() -> void: _declined.append(int(snap.get("seed", 0)))],
		])))


func _take_over() -> void:
	var checking := NoticeScreen.make("UI_TAKEOVER_TITLE", "UI_TAKEOVER_CHECKING", false)
	add_child(checking)
	Meta.cloud.play_lock.take_over(func(snap: Dictionary) -> void:
		checking.queue_free()
		if snap.is_empty():
			add_child(NoticeScreen.make("UI_TAKEOVER_TITLE", "UI_TAKEOVER_GONE"))
			return
		RunSnapshot.prepare(snap)
		start.emit(GameAuthority.selected_hero_id)
		queue_free())


## Play: choose a level, then a Hero.
func play(from: MenuScreen) -> void:
	from.open_child(LevelSelectScreen.new_for(self))


func choose_level(level_id: String, swift: bool) -> void:
	Meta.level_id = level_id
	Meta.swift = swift
	show_hero_select()


func show_hero_select() -> void:
	var select := HeroSelect.new()
	select.hero_chosen.connect(_on_hero_chosen)
	select.back.connect(_on_hero_back)
	add_child(select)


func _on_hero_chosen(hero_id: String) -> void:
	GameAuthority.selected_hero_id = hero_id
	MenuBackdrop.remember_hero(hero_id)
	var checking := NoticeScreen.make("UI_PLAY", "UI_PLAY_CHECKING", false)
	add_child(checking)
	Meta.cloud.play_lock.claim(func(allowed: bool) -> void:
		checking.queue_free()
		if allowed:
			start.emit(hero_id)
			queue_free()
			return
		show_hero_select()
		add_child(NoticeScreen.make("UI_PLAY_ELSEWHERE_TITLE", "UI_PLAY_ELSEWHERE")))


## A co-op run is starting (Net chose the level and this player's Hero).
func start_coop() -> void:
	start.emit(GameAuthority.selected_hero_id)
	queue_free()


## Back from Hero select returns to the menus, or to the title if none is open.
func _on_hero_back() -> void:
	for child: Node in get_children():
		if child is MenuScreen:
			return
	add_child(TitleScreen.new_for(self))
