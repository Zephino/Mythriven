class_name PixelArt
extends RefCounted
## Pixel-art sprites drawn from text (data/art/<id>.json; the rules are in
## docs/ART_RULES.md): each frame is rows of letters, one letter per pixel,
## and the palette says which colour each letter is ('.' is see-through).
## Made into textures once and kept. Drawn with nearest-neighbour filtering at
## 1 art pixel = 1 game pixel, so they stay crisp at the camera's zoom.
## Heroes hold the weapon they use most (owner request 10/31/2026): weapons are
## separate pictures (data/art/weapons/<weapon id>.json) with a grip point,
## drawn at the Hero's hand.

const ART_DIR := "res://data/art/"

## id (plus "|" and the mastery colour, when recoloured) -> {"anchor": Vector2,
## "size": Vector2, "frames": {name: [ImageTexture]}}, or {} when there's no art.
static var _cache: Dictionary = {}


## The art for `id` (a Hero id), or {} if it has none yet (the placeholder is
## drawn instead). With a `colour` (a mastery palette, Hero select: Color), the
## letters the file lists under "recolor" (the Hero's clothes) take that colour.
static func find(id: String, colour: Color = Color(0, 0, 0, 0)) -> Dictionary:
	var key: String = id if colour.a <= 0.0 else id + "|" + colour.to_html(false)
	if _cache.has(key):
		return _cache[key]
	var art: Dictionary = {}
	var path: String = ART_DIR + id + ".json"
	if id != "" and FileAccess.file_exists(path):
		art = build(JSON.parse_string(FileAccess.get_file_as_string(path)), colour)
	_cache[key] = art
	return art


## Textures from an art file's contents ({} if it's malformed), its clothes in
## `colour` when one is given.
static func build(data: Variant, colour: Color = Color(0, 0, 0, 0)) -> Dictionary:
	if not data is Dictionary or not (data as Dictionary).get("frames") is Dictionary:
		return {}
	var palette: Dictionary = {}
	for key: String in (data["palette"] as Dictionary):
		palette[key] = Color.html(str(data["palette"][key]))
	if colour.a > 0.0 and data.get("recolor") is Array:
		for key: Variant in data["recolor"]:
			if palette.has(str(key)):
				palette[str(key)] = recolour(palette[str(key)], colour)
	var frames: Dictionary = {}
	for name: String in (data["frames"] as Dictionary):
		var list: Array[ImageTexture] = []
		for rows: Variant in data["frames"][name]:
			list.append(_texture(rows, palette))
		frames[name] = list
	var size: Array = data.get("size", [16, 16])
	var anchor: Array = data.get("anchor", [size[0] / 2, size[1] - 1])
	var art: Dictionary = {"size": Vector2(size[0], size[1]), "anchor": Vector2(anchor[0], anchor[1]), "frames": frames}
	for point: String in ["hand", "grip"]:
		if data.get(point) is Array:
			art[point] = Vector2(data[point][0], data[point][1])
	return art


## A boss's art (data/art/bosses/<enemy id>.json), or {} while it has none
## (its pooled circle is drawn instead).
static func boss(enemy_id: String) -> Dictionary:
	return find("bosses/" + enemy_id) if enemy_id != "" else {}


## A god's art (data/art/gods/<god id>.json), or {} while it has none (its
## coloured dot or circle is drawn instead).
static func god(god_id: String) -> Dictionary:
	return find("gods/" + god_id) if god_id != "" else {}


## Draws `art`'s standing frame on `canvas` with the middle of its feet at
## `feet` (in the canvas's own coordinates), mirrored when `face_left`.
## `stride` (distance walked) picks a walking frame when `walking`; `pose` names
## another frame to draw instead (a god's "seated" frame on their throne).
static func draw_standing(canvas: CanvasItem, art: Dictionary, feet: Vector2, face_left: bool, tint: Color = Color.WHITE,
		walking: bool = false, stride: float = 0.0, pose: String = "") -> void:
	var anchor: Vector2 = art["anchor"]
	var frames: Dictionary = art["frames"]
	var texture: ImageTexture = frame(art, walking, stride)
	if pose != "" and frames.has(pose) and not (frames[pose] as Array).is_empty():
		texture = frames[pose][0]
	canvas.draw_set_transform(feet, 0.0, Vector2(-1.0 if face_left else 1.0, 1.0))
	canvas.draw_texture(texture, -anchor, tint)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## The picture of the weapon the Hero uses most, to draw in their hand: the
## highest level among their weapons that have one (on a tie, the one they got
## first, so a Hero starts with their signature weapon). Spells have no
## picture; an evolved weapon uses its base weapon's until it has its own.
## {} when none has a picture.
static func held_weapon(weapons: Array) -> Dictionary:
	var best: Dictionary = {}
	var best_level: int = -1
	for weapon: WeaponInstance in weapons:
		var art: Dictionary = find("weapons/" + weapon.id())
		if art.is_empty():
			art = find("weapons/" + str(weapon.data.get("evolved_from", "")))
		if not art.is_empty() and weapon.level > best_level:
			best = art
			best_level = weapon.level
	return best


## A clothing colour in a mastery colour: that colour's hue and saturation,
## keeping the original's brightness, so light cloth and its shadow stay apart.
static func recolour(original: Color, colour: Color) -> Color:
	return Color.from_hsv(colour.h, colour.s, original.v)


static func _texture(rows: Array, palette: Dictionary) -> ImageTexture:
	var height: int = rows.size()
	var width: int = str(rows[0]).length() if height > 0 else 1
	var image := Image.create(width, maxi(height, 1), false, Image.FORMAT_RGBA8)
	for y: int in height:
		var row: String = str(rows[y])
		for x: int in mini(row.length(), width):
			var key: String = row[x]
			if key != "." and palette.has(key):
				image.set_pixel(x, y, palette[key])
	return ImageTexture.create_from_image(image)


## The frame to show: walking frames in turn while moving (`stride` is the
## distance walked), else the first idle frame.
static func frame(art: Dictionary, moving: bool, stride: float) -> ImageTexture:
	var frames: Dictionary = art["frames"]
	if moving and frames.has("walk") and not (frames["walk"] as Array).is_empty():
		var walk: Array = frames["walk"]
		return walk[int(stride / Data.cfg_float("player.walk_frame_px")) % walk.size()]
	return (frames.get("idle", frames.values()[0]) as Array)[0]
