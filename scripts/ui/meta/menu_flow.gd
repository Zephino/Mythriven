class_name MenuFlow
extends Node
## The menus outside a run (GAME_DESIGN.md: Screens): Title → Play → level
## select → Hero select → the run, and the Hall of Legends with its pages.
## The main scene adds this when there's no run to start and listens for
## `start`. Which screen opens first comes from Meta.next_screen.

signal start(hero_id: String)


func _ready() -> void:
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
	Meta.next_screen = "title"


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
	start.emit(hero_id)
	queue_free()


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
