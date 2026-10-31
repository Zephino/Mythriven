class_name UiTheme
extends RefCounted
## The look of every menu (owner request 10/31/2026): panels and buttons are framed in dark stone with a bronze
## trim (data/art/ui/frames.json, stretched by their edges), drawn at ui.frame_scale. Set on the default theme,
## so every screen picks it up without its own styling. Button text is cream on the dark stone.

const FRAMES := "ui/frames"
const ICONS := "ui/icons"

static var _style: String = ""


## Styles the default theme in the frame style that goes with this session's menu backdrop (marble and gold, wood
## and iron, sandstone and lapis, mossy stone), or the plain bronze one. Safe to call again (settings changes call it).
static func apply() -> void:
	var art: Dictionary = PixelArt.find(FRAMES)
	if art.is_empty():
		return
	_style = MenuBackdrop.style()
	var theme: Theme = ThemeDB.get_default_theme()
	var panel: StyleBoxTexture = _box(art, "panel", false)
	for type: String in ["PanelContainer", "Panel", "PopupMenu", "PopupPanel", "TooltipPanel"]:
		theme.set_stylebox("panel", type, panel)
	for type: String in ["Button", "OptionButton", "CheckButton", "CheckBox", "MenuButton"]:
		theme.set_stylebox("normal", type, _box(art, "button", false))
		theme.set_stylebox("hover", type, _box(art, "button_hover", false))
		theme.set_stylebox("pressed", type, _box(art, "button_pressed", false))
		theme.set_stylebox("hover_pressed", type, _box(art, "button_pressed", false))
		theme.set_stylebox("disabled", type, _box(art, "button_disabled", false))
		theme.set_stylebox("focus", type, _box(art, "button_focus", true))
		theme.set_color("font_color", type, Color.html(Data.cfg_string("ui.button_text_color")))
		theme.set_color("font_hover_color", type, Color.html(Data.cfg_string("ui.button_hover_text_color")))
		theme.set_color("font_focus_color", type, Color.html(Data.cfg_string("ui.button_hover_text_color")))
		theme.set_color("font_pressed_color", type, Color.html(Data.cfg_string("ui.button_hover_text_color")))
		theme.set_color("font_disabled_color", type, Color.html(Data.cfg_string("ui.button_disabled_text_color")))
		theme.set_constant("icon_max_width", type, Data.cfg_int("ui.icon_px"))
	theme.set_stylebox("normal", "LineEdit", _box(art, "button_pressed", false))
	theme.set_stylebox("focus", "LineEdit", _box(art, "button_focus", true))


## A level-up card's icon: the weapon's picture (a spell's flying picture), the passive's icon, the icon of the
## passive that raises the same stat, a coin for gold, ambrosia for healing. Null when there's none.
static func card_icon(card: Dictionary) -> Texture2D:
	var id: String = str(card.get("id", ""))
	match str(card.get("kind", "")):
		LevelUpRules.WEAPON_NEW, LevelUpRules.WEAPON_UP:
			return weapon_icon(GameAuthority.find_weapon(id))
		LevelUpRules.PASSIVE_NEW, LevelUpRules.PASSIVE_UP:
			return _icon(PixelArt.find(ICONS), id)
		LevelUpRules.STAT:
			for passive: Variant in Data.get_file(LevelUpRules.PASSIVES_FILE):
				if passive is Dictionary and str((passive as Dictionary).get("stat", "")) == id:
					return _icon(PixelArt.find(ICONS), str(passive["id"]))
			return _icon(PixelArt.find(ICONS), id)
		LevelUpRules.GOLD:
			return _icon(PixelArt.find("pickups/gold_coin"), "idle", Color.html(Data.cfg_string("pickups.gold_color")))
		LevelUpRules.HEAL:
			return _icon(PixelArt.find("pickups/ambrosia"), "idle", Color.html(Data.cfg_string("pickups.ambrosia_color")))
	return null


## A weapon's picture, or a spell's flying picture (its own, else its element's).
static func weapon_icon(weapon: Dictionary) -> Texture2D:
	var art: Dictionary = PixelArt.find("weapons/" + str(weapon.get("id", "")))
	if art.is_empty():
		art = PixelArt.find("weapons/" + str(weapon.get("evolved_from", "")))
	if art.is_empty() and weapon.has("art_at_level"):
		art = PixelArt.find("weapons/" + str((weapon["art_at_level"] as Dictionary).get("art", "")))   # Beowulf's sword
	if art.is_empty() and str(weapon.get("projectile_art", "")) != "":
		art = PixelArt.find("projectiles/" + str(weapon["projectile_art"]))
	if art.is_empty():
		art = PixelArt.find("projectiles/element_" + str(weapon.get("element", "physical")))
	return _icon(art, "idle")


## A Hero's or god's standing picture, `scale` times bigger, for a portrait.
static func portrait(art: Dictionary, scale: int) -> Texture2D:
	if art.is_empty():
		return null
	return _scaled(PixelArt.frame(art, false, 0.0).get_image(), scale)


## A god's whole standing picture, for the god buttons (a crop of the top would show a raised weapon, not a face).
static func god_face(god_id: String, scale: int) -> Texture2D:
	return portrait(PixelArt.god(god_id), scale)


static func _icon(art: Dictionary, frame_name: String, tint: Color = Color.WHITE) -> Texture2D:
	if art.is_empty() or not (art["frames"] as Dictionary).has(frame_name):
		return null
	var image: Image = (art["frames"][frame_name][0] as ImageTexture).get_image()
	image = image.duplicate()
	if tint != Color.WHITE:
		for y: int in image.get_height():
			for x: int in image.get_width():
				var c: Color = image.get_pixel(x, y)
				if c.a > 0.0 and not (c.r < 0.2 and c.g < 0.2 and c.b < 0.2):
					image.set_pixel(x, y, Color(c.r * tint.r, c.g * tint.g, c.b * tint.b, c.a))
	# Centred on a square, so long pictures (spears, flames) show as big as round ones.
	var side: int = maxi(image.get_width(), image.get_height())
	var square := Image.create_empty(side, side, false, Image.FORMAT_RGBA8)
	image.convert(Image.FORMAT_RGBA8)
	square.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i((side - image.get_width()) / 2, (side - image.get_height()) / 2))
	return _scaled(square, maxi(int(Data.cfg_float("ui.icon_px") / side), 1))


static func _scaled(image: Image, scale: int) -> ImageTexture:
	var copy: Image = image.duplicate()
	copy.resize(copy.get_width() * scale, copy.get_height() * scale, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(copy)


## One frame as a stretchable box; `hollow` clears its middle (a focus outline drawn over the button).
static func _box(art: Dictionary, frame_name: String, hollow: bool) -> StyleBoxTexture:
	var scale: int = Data.cfg_int("ui.frame_scale")
	var styled: String = _style + "_" + frame_name
	if _style != "" and (art["frames"] as Dictionary).has(styled):
		frame_name = styled
	var image: Image = (art["frames"][frame_name][0] as ImageTexture).get_image().duplicate()
	var edge: int = 4
	if hollow:
		for y: int in range(edge - 1, image.get_height() - edge + 1):
			for x: int in range(edge - 1, image.get_width() - edge + 1):
				image.set_pixel(x, y, Color(0, 0, 0, 0))
	image.resize(image.get_width() * scale, image.get_height() * scale, Image.INTERPOLATE_NEAREST)
	var box := StyleBoxTexture.new()
	box.texture = ImageTexture.create_from_image(image)
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		box.set_texture_margin(side, edge * scale)
		box.set_content_margin(side, edge * scale + Data.cfg_float("ui.frame_padding_px"))
	return box
