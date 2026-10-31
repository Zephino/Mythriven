class_name LevelArt
extends RefCounted
## Builds a level's ground from levels.json: a TileSet with one 16 px tile per
## ground type, two variants each (the pixel-art tiles in data/art/ground/,
## or plain coloured tiles for a level without them), and the decoration list.

const SOURCE_ID := 0
const VARIANTS := 2


## A TileSet whose atlas column (ground_index * 2 + variant) is that ground type.
static func build_tileset(tileset_data: Dictionary, tile_px: int) -> TileSet:
	var grounds: Array = tileset_data.get("ground", [])
	var shade: float = float(tileset_data.get("variant_shade", 0.0))
	var image := Image.create_empty(tile_px * VARIANTS * maxi(grounds.size(), 1), tile_px, false, Image.FORMAT_RGBA8)
	# The level's ground tiles (data/art/ground/<tileset id>.json; owner request 10/31/2026), where drawn at this size.
	var art: Dictionary = PixelArt.find("ground/" + str(tileset_data.get("id", "")))
	for i: int in grounds.size():
		var ground: Dictionary = grounds[i]
		var base := Color.html(str(ground.get("placeholder_color", "#ff00ff")))
		var dots: String = str(ground.get("placeholder_dots", ""))
		var pictures: Array = (art.get("frames", {}) as Dictionary).get(str(ground.get("id", "")), [])
		for variant: int in VARIANTS:
			var origin := Vector2i((i * VARIANTS + variant) * tile_px, 0)
			if variant < pictures.size():
				var picture: Image = (pictures[variant] as ImageTexture).get_image()
				if picture.get_size() == Vector2i(tile_px, tile_px):
					picture.convert(Image.FORMAT_RGBA8)
					image.blit_rect(picture, Rect2i(Vector2i.ZERO, picture.get_size()), origin)
					continue
			image.fill_rect(Rect2i(origin, Vector2i(tile_px, tile_px)), base.darkened(shade * variant))
			if dots != "":
				_draw_dots(image, origin, tile_px, Color.html(dots), variant)
	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(tile_px, tile_px)
	for column: int in grounds.size() * VARIANTS:
		source.create_tile(Vector2i(column, 0))
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(tile_px, tile_px)
	tileset.add_source(source, SOURCE_ID)
	return tileset


## A few single pixels (for example flowers in the grass).
static func _draw_dots(image: Image, origin: Vector2i, tile_px: int, color: Color, variant: int) -> void:
	var step: int = maxi(floori(tile_px / 4.0), 1)
	for y: int in range(floori(step / 2.0) + variant, tile_px, step * 2):
		for x: int in range(floori(step / 2.0) + variant * 2, tile_px, step * 2):
			image.set_pixel(origin.x + x, origin.y + y, color)
