class_name Settings
extends RefCounted
## The player's settings (GAME_DESIGN.md: Accessibility settings; Onboarding),
## saved in the save file's `settings` section the moment they change. Until
## the player changes one, its value comes from config settings.defaults.
## apply() sets the ones that act on the whole game (volume, text size);
## the rest are read where they're used (some on every hit, hence the cache).

static var _cache: Dictionary = {}


static func value(key: String) -> Variant:
	if not _cache.has(key):
		_cache[key] = SaveGame.setting(key, (Data.cfg("settings.defaults") as Dictionary).get(key))
	return _cache[key]


## Forgets cached values (after a change, or when a different save is loaded).
static func clear_cache() -> void:
	_cache.clear()


static func flag(key: String) -> bool:
	return bool(value(key))


static func number(key: String) -> float:
	return float(value(key))


static func text(key: String) -> String:
	return str(value(key))


static func change(key: String, new_value: Variant) -> void:
	SaveGame.set_setting(key, new_value)
	_cache.clear()


## The values an option steps through ([] for on/off settings).
static func choices(key: String) -> Array:
	var listed: Variant = (Data.cfg("settings.choices") as Dictionary).get(key, [])
	return listed if listed is Array else []


## Moves a stepped setting to its next value (wrapping), or flips an on/off one.
static func step(key: String) -> void:
	var options: Array = choices(key)
	if options.is_empty():
		change(key, not flag(key))
		return
	var at: int = -1
	for i: int in options.size():
		var numeric: bool = options[i] is float or options[i] is int
		if (numeric and is_equal_approx(float(options[i]), number(key))) or (not numeric and str(options[i]) == text(key)):
			at = i
	change(key, options[(at + 1) % options.size()])


## Screen shake and hit flash strength: 0 (off), low, or 1 (full).
static func shake_strength() -> float:
	return float((Data.cfg("settings.shake_strength") as Dictionary).get(text("shake"), 1.0))


static func flash_strength() -> float:
	if not _cache.has("_flash_strength"):
		_cache["_flash_strength"] = float((Data.cfg("settings.flash_strength") as Dictionary).get(text("flash"), 1.0))
	return _cache["_flash_strength"]


## Size of the touch controls (joystick, god buttons) as a multiplier.
static func control_scale() -> float:
	return number("control_size_pct") / 100.0


## Group of the layers drawing the players' own attacks and summons, which
## the effect opacity setting fades (enemy attacks always stay fully visible).
const PLAYER_EFFECTS := "player_effects"


## Joins `layer` to the player-effects group and sets its opacity.
static func fade_player_effect(layer: CanvasItem) -> void:
	layer.add_to_group(PLAYER_EFFECTS)
	layer.modulate.a = number("effect_opacity_pct") / 100.0


## Applies the settings that act on the whole game.
static func apply(tree: SceneTree) -> void:
	var volume: float = number("volume_pct") / 100.0
	AudioServer.set_bus_mute(0, volume <= 0.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.0001)))
	# Text size: the default theme's font size, which every screen without its
	# own size uses (screens built after the change pick it up).
	ThemeDB.get_default_theme().default_font_size = roundi(Data.cfg_float("settings.base_font_px") * number("text_size_pct") / 100.0)
	UiTheme.apply()
	for layer: Node in tree.get_nodes_in_group(PLAYER_EFFECTS):
		(layer as CanvasItem).modulate.a = number("effect_opacity_pct") / 100.0
