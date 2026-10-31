class_name MenuBackdrop
extends Control
## The scene behind every menu (owner decisions 10/31/2026, docs/DECISIONS.md "Menus"): one of the painted backdrops
## in data/art/menu/, chosen at random when the game loads and never the same as last time, kept for the whole
## session so every menu shows the same one. Each brings its matching frame style (UiTheme). The scene is scaled to
## cover the screen (cropped, never stretched). On the title screen the unlocked Heroes walk the road to the shrine
## (or gather round the campfire), and the Hero played last stands on the right.

const SCENES_KEY := "ui.menu_backdrops"
const SAVE_FILE := "user://menu.cfg"

static var _scene: String = ""
static var _meta: Dictionary = {}

## True on the title screen: draw the Heroes.
var show_heroes: bool = false
var _time: float = 0.0
var _walkers: Array[String] = []
var _last_hero: String = ""


## The backdrop of this session (chosen the first time it's asked for).
static func scene() -> String:
	if _scene == "":
		_choose()
	return _scene


## The frame style that goes with this session's backdrop.
static func style() -> String:
	scene()
	return str(_meta.get("style", ""))


static func _choose() -> void:
	var names: Array = Data.cfg(SCENES_KEY)
	var config := ConfigFile.new()
	config.load(SAVE_FILE)
	var last: String = str(config.get_value("menu", "last_backdrop", ""))
	var choices: Array = names.filter(func(name: String) -> bool: return name != last)
	if choices.is_empty():
		choices = names
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_scene = str(choices[rng.randi_range(0, choices.size() - 1)]) if not choices.is_empty() else ""
	config.set_value("menu", "last_backdrop", _scene)
	config.save(SAVE_FILE)
	var path: String = PixelArt.ART_DIR + "menu/" + _scene + ".json"
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
	_meta = (raw as Dictionary).get("scene", {}) if raw is Dictionary else {}


## Remembers the Hero chosen, to stand on the title screen next time.
static func remember_hero(hero_id: String) -> void:
	var config := ConfigFile.new()
	config.load(SAVE_FILE)
	config.set_value("menu", "last_hero", hero_id)
	config.save(SAVE_FILE)


## Forgets the Hero played last (after starting over), so the title shows the first Hero again.
static func forget_hero() -> void:
	var config := ConfigFile.new()
	config.load(SAVE_FILE)
	if config.has_section_key("menu", "last_hero"):
		config.erase_section_key("menu", "last_hero")
	config.save(SAVE_FILE)


static func last_hero() -> String:
	var config := ConfigFile.new()
	config.load(SAVE_FILE)
	return str(config.get_value("menu", "last_hero", "heracles"))


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if show_heroes:
		_last_hero = last_hero()
		for hero: Dictionary in HeroRules.all():
			var id: String = str(hero["id"])
			if HeroRules.is_unlocked(hero) and id != _last_hero and not PixelArt.find(id).is_empty():
				_walkers.append(id)
		_walkers = _walkers.slice(0, Data.cfg_int("ui.menu_walkers"))


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


## Where backdrop pixel `p` lands on screen, and how big a backdrop pixel is.
func _fit() -> Array:
	var art: Dictionary = PixelArt.find("menu/" + scene())
	var art_size: Vector2 = art["size"] if not art.is_empty() else Vector2(480, 270)
	var zoom: float = maxf(size.x / art_size.x, size.y / art_size.y)
	var offset: Vector2 = (size - art_size * zoom) * 0.5
	return [offset, zoom]


func _draw() -> void:
	var art: Dictionary = PixelArt.find("menu/" + scene())
	if art.is_empty():
		draw_rect(Rect2(Vector2.ZERO, size), Color.html(Data.cfg_string("heroes.menu_background")))
		return
	var fit: Array = _fit()
	var offset: Vector2 = fit[0]
	var zoom: float = fit[1]
	var texture: ImageTexture = PixelArt.frame(art, false, 0.0)
	draw_texture_rect(texture, Rect2(offset, texture.get_size() * zoom), false)
	if str(_meta.get("mode", "")) == "camp":
		_draw_fire(offset, zoom)
	if show_heroes:
		_draw_heroes(offset, zoom)


## The campfire: flames flickering over the logs drawn in the scene.
func _draw_fire(offset: Vector2, zoom: float) -> void:
	var at: Vector2 = offset + Vector2(_meta.get("fire", [0, 0])[0], _meta.get("fire", [0, 0])[1]) * zoom
	for k: int in 5:
		var sway: float = sin(_time * 7.0 + k * 1.7) * 1.2
		var tall: float = (7.0 + 3.0 * sin(_time * 9.0 + k * 2.3)) * (1.0 - absf(k - 2) * 0.18)
		var base: Vector2 = at + Vector2((k - 2) * 2.2, 0.0) * zoom
		var tip: Vector2 = base + Vector2(sway, -tall) * zoom
		var colour := Color(1.0, 0.45 + 0.1 * k, 0.15) if k % 2 == 0 else Color(1.0, 0.8, 0.3)
		draw_colored_polygon(PackedVector2Array([base - Vector2(1.6, 0) * zoom, base + Vector2(1.6, 0) * zoom, tip]), colour)
	for k: int in 3:
		var rise: float = fmod(_time * 0.8 + k * 0.33, 1.0)
		draw_rect(Rect2(at + Vector2(sin(_time + k * 2.0) * 3.0, -10.0 - rise * 26.0) * zoom, Vector2.ONE * zoom),
				Color(1.0, 0.75, 0.3, 1.0 - rise))


## The Heroes walking the road to the shrine (or standing round the fire), and the Hero played last on the right.
func _draw_heroes(offset: Vector2, zoom: float) -> void:
	var ground: float = float(_meta.get("ground_y", 200))
	var camp: bool = str(_meta.get("mode", "")) == "camp"
	var count: int = _walkers.size()
	for k: int in count:
		var art: Dictionary = PixelArt.find(_walkers[k])
		if camp:
			var fire: Array = _meta.get("fire", [150, 222])
			# Round the fire, alternating sides, each a little further round the circle.
			var side: float = -1.0 if k % 2 == 0 else 1.0
			var angle: float = (0.15 + 0.35 * floorf(k / 2.0)) * PI
			var spot := Vector2(fire[0], fire[1]) + Vector2(side * cos(angle) * 34.0, -sin(angle) * 10.0 + 6.0)
			_draw_figure(art, offset + spot * zoom, zoom, spot.x > float(fire[0]), false, 0.0, 1.0)
			continue
		# Walking toward the shrine on the left, one behind another; each fades into the shrine and starts again.
		var from_x: float = float(_meta.get("walk_from_x", 200))
		var to_x: float = float(_meta.get("shrine_x", 70)) + 16.0
		var span: float = from_x - to_x
		var speed: float = Data.cfg_float("ui.menu_walk_speed")
		var along: float = fmod(_time * speed + k * span / maxf(count, 1), span)
		var x: float = from_x - along
		var fade: float = clampf(along / 12.0, 0.0, 1.0) * clampf((span - along) / 16.0, 0.0, 1.0)
		var y: float = ground - (along / span) * float(_meta.get("rise", 0.0))
		_draw_figure(art, offset + Vector2(x, y) * zoom, zoom, true, true, _time * speed + k * 7.0, fade)
	var last: Dictionary = PixelArt.find(_last_hero)
	if not last.is_empty():
		var spot := Vector2(float(_meta.get("last_hero_x", 410)), ground + 6.0)
		var scale: float = zoom * Data.cfg_float("ui.menu_last_hero_scale")
		var feet: Vector2 = offset + spot * zoom
		# On narrow screens the backdrop is cropped at the sides: keep the Hero wholly on screen, and leave them out
		# when there's no room for them beside the menu buttons (owner report 10/31/2026: half a Hero at the edge).
		var half: float = (last["size"] as Vector2).x * 0.5 * scale
		var margin: float = Data.cfg_float("ui.screen_margin_px")
		feet.x = minf(feet.x, size.x - margin - half)
		if feet.x - half >= size.x * 0.5 + Data.cfg_float("ui.menu_column_px") * 0.5:
			_draw_figure(last, feet, scale, true, false, 0.0, 1.0)


func _draw_figure(art: Dictionary, feet: Vector2, zoom: float, face_left: bool, walking: bool, stride: float, alpha: float) -> void:
	if art.is_empty():
		return
	var texture: ImageTexture = PixelArt.frame(art, walking, stride)
	var anchor: Vector2 = art["anchor"]
	draw_set_transform(feet, 0.0, Vector2(-zoom if face_left else zoom, zoom))
	draw_texture(texture, -anchor, Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
