extends Node
## Main scene. Builds the run: the endless ground (Phase 3), pooled enemies
## and their spawner (Phase 4), weapons, projectiles, attack effects, and
## damage numbers (Phase 5–6), XP orbs, the HUD, and the level-up screen
## (Phase 6), one local player that moves with keyboard,
## gamepad, or the touch joystick (Phase 2), a camera that follows it, and the
## death screen. Also shows the Phase 1 translation test label,
## the build version in the corner, and any data errors found at startup.

var _test_label: Label
var _version_label: Label
var _error_label: Label
var _death_screen: DeathScreen
var _enemies: EnemyManager
var _orbs: XpOrbs
var _level_up: LevelUpScreen


func _ready() -> void:
	var hero_id: String = GameAuthority.selected_hero_id
	if hero_id != "" and not HeroRules.find(hero_id).is_empty():
		_start()
		return
	var select := HeroSelect.new()
	select.hero_chosen.connect(_on_hero_chosen)
	add_child(select)


func _on_hero_chosen(hero_id: String) -> void:
	GameAuthority.selected_hero_id = hero_id
	_start()


func _start() -> void:
	var joystick := TouchJoystick.new()
	_build_world(joystick)
	_build_ui(joystick)


func _build_world(joystick: TouchJoystick) -> void:
	var run: RunState = GameAuthority.start_run(Data.cfg_string("run.default_level"))
	var world := WorldRoot.new()
	world.name = "World"
	add_child(world)
	var chunks := ChunkManager.new()
	world.add_child(chunks)
	chunks.setup(run.level_data, run.seed_value)
	world.origin_shifted.connect(chunks.on_origin_shifted)

	_enemies = EnemyManager.new()
	world.add_child(_enemies)
	_enemies.setup()
	GameAuthority.enemies = _enemies
	world.origin_shifted.connect(_enemies.on_origin_shifted)
	_orbs = XpOrbs.new()
	world.add_child(_orbs)
	_orbs.setup()
	world.origin_shifted.connect(_orbs.on_origin_shifted)
	GameAuthority.enemy_killed.connect(_orbs.on_enemy_killed)
	var heals := HealPickups.new()
	world.add_child(heals)
	heals.setup()
	world.origin_shifted.connect(heals.on_origin_shifted)
	GameAuthority.enemy_killed.connect(heals.on_enemy_killed)
	var pickup_audio := PickupAudio.new()
	add_child(pickup_audio)
	_orbs.pickup_audio = pickup_audio

	var spawner := EnemySpawner.new()
	spawner.enemies = _enemies
	world.add_child(spawner)

	var input := PlayerInput.new()
	input.joystick = joystick
	var player: Player = GameAuthority.spawn_player(world, Vector2.ZERO, input, true, GameAuthority.selected_hero_id)
	var start_weapon: String = str(player.hero.get("signature_weapon", Data.cfg_string("player.starting_weapon")))
	GameAuthority.give_weapon(player, start_weapon)

	var effects := EffectLayer.new()
	world.add_child(effects)
	effects.setup()
	world.origin_shifted.connect(effects.on_origin_shifted)
	var numbers := DamageNumbers.new()
	world.add_child(numbers)
	numbers.setup()
	world.origin_shifted.connect(numbers.on_origin_shifted)
	GameAuthority.enemy_damaged.connect(numbers.on_enemy_damaged)
	GameAuthority.reaction_triggered.connect(numbers.on_reaction)
	GameAuthority.reaction_triggered.connect(effects.on_reaction)
	var projectiles := ProjectileManager.new()
	projectiles.enemies = _enemies
	world.add_child(projectiles)
	projectiles.setup()
	world.origin_shifted.connect(projectiles.on_origin_shifted)
	var combat := CombatSystem.new()
	combat.enemies = _enemies
	combat.effects = effects
	combat.projectiles = projectiles
	world.add_child(combat)
	chunks.update_chunks()
	chunks.build_all_now()

	var camera := GameCamera.new()
	camera.target = player
	world.add_child(camera)

	if OS.is_debug_build():
		var grid: Node2D = preload("res://scripts/world/debug_grid.gd").new()
		world.add_child(grid)
		var actions: Node = preload("res://scripts/core/debug_actions.gd").new()
		actions.set("world", world)
		actions.set("chunks", chunks)
		actions.set("grid", grid)
		actions.set("camera", camera)
		add_child(actions)
		var combat_actions: Node = preload("res://scripts/core/debug_actions_combat.gd").new()
		combat_actions.set("enemies", _enemies)
		combat_actions.set("spawner", spawner)
		add_child(combat_actions)
		var element_actions: Node = preload("res://scripts/core/debug_actions_elements.gd").new()
		element_actions.set("enemies", _enemies)
		add_child(element_actions)

	_level_up = LevelUpScreen.new()
	add_child(_level_up)
	var hud := Hud.new()
	hud.level_up_screen = _level_up
	add_child(hud)
	if OS.is_debug_build():
		var progress_actions: Node = preload("res://scripts/core/debug_actions_progress.gd").new()
		progress_actions.set("orbs", _orbs)
		progress_actions.set("heals", heals)
		progress_actions.set("level_up_screen", _level_up)
		add_child(progress_actions)

	_death_screen = DeathScreen.new()
	add_child(_death_screen)
	GameAuthority.run_ended.connect(_on_run_ended)


## Drop references to this scene's objects (for example on Retry).
func _exit_tree() -> void:
	GameAuthority.end_scene()


func _on_run_ended(run: RunState) -> void:
	_level_up.close()
	var log_path: String = RunLog.write(run, GameAuthority.players)
	var lines: PackedStringArray = [tr("UI_SURVIVED") % TextFormat.run_time(run.elapsed_s)]
	lines.append(tr("UI_RESULTS_LINE") % [run.level, run.kills])
	var player: Player = GameAuthority.local_player()
	if player != null and _enemies.type_index.has(player.cause_of_death):
		var killer: Dictionary = _enemies.types[_enemies.type_index[player.cause_of_death]]
		lines.append(tr("UI_FELLED_BY") % tr(str(killer["name_key"])))
	if log_path != "":
		lines.append(tr("UI_RUN_LOG_SAVED"))
	var entry: Dictionary = LeaderboardEntry.build(run, player, "") if player != null else {}
	_death_screen.show_summary(lines, entry, LeaderboardEntry.can_submit(run))


func _build_ui(joystick: TouchJoystick) -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	root.add_child(joystick)
	var margin_px: float = Data.cfg_float("ui.screen_margin_px")

	# Text set to a key is translated automatically and follows pseudo-localization.
	# Bottom-centre, so it doesn't cover the player in the middle of the screen.
	_test_label = Label.new()
	_test_label.text = "UI_TEST_LABEL"
	_test_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, int(margin_px))
	_test_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_test_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_test_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_test_label)

	_version_label = Label.new()
	_version_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_version_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, int(margin_px))
	_version_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_version_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(_version_label)

	_error_label = Label.new()
	_error_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_error_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_error_label.offset_left = margin_px
	_error_label.offset_top = margin_px
	_error_label.offset_right = -margin_px
	_error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	root.add_child(_error_label)

	Localization.changed.connect(_refresh)
	Data.reloaded.connect(_refresh)
	_refresh()


func _refresh() -> void:
	_version_label.text = tr("UI_VERSION_LABEL") % ProjectSettings.get_setting("application/config/version", "")
	var lines: PackedStringArray = []
	for err: Dictionary in Data.errors:
		lines.append(JsonValidator.describe(err))
	if not lines.is_empty():
		lines.insert(0, tr("UI_DATA_ERRORS_TITLE"))
	_error_label.text = "\n".join(lines)
