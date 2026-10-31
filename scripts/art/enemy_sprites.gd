class_name EnemySprites
extends RefCounted
## Enemy pixel art drawn hundreds at a time (owner request 10/31/2026; docs/ART_RULES.md: Enemies). Every enemy
## type with art (data/art/enemies/<enemy id>.json) has its standing and walking frames packed into one atlas
## texture, and one MultiMesh draws them all: each instance picks its frame's region of the atlas through its custom
## data, and its colour carries a tint (rgb) and how strongly to apply it (a: hit flash, statuses, wind-ups).
## Types without art keep their circle.

const SHADER := """
shader_type canvas_item;
varying vec4 region;
varying vec4 tint;
void vertex() {
	region = INSTANCE_CUSTOM;
	tint = COLOR;
}
void fragment() {
	vec4 c = texture(TEXTURE, region.xy + UV * region.zw);
	c.rgb = mix(c.rgb, tint.rgb, tint.a);
	COLOR = c;
}
"""

## Per enemy type index: {} when it has no art, else {"anchor": Vector2, "size": Vector2, "idle": Rect2,
## "walk": [Rect2]} (regions in atlas pixels).
var types: Array[Dictionary] = []
var atlas: ImageTexture
var atlas_size := Vector2.ONE


## Packs the art of `type_ids` (in type-index order) into one atlas.
func build(type_ids: Array) -> void:
	var images: Array = []
	for id: Variant in type_ids:
		var art: Dictionary = PixelArt.find("enemies/" + str(id))
		if art.is_empty():
			types.append({})
			images.append([])
			continue
		var frames: Array = [PixelArt.frame(art, false, 0.0)]
		for texture: Variant in (art["frames"] as Dictionary).get("walk", []):
			frames.append(texture)
		types.append({"anchor": art["anchor"], "size": art["size"]})
		images.append(frames)
	# Shelf packing, one row per type.
	var width: int = 8
	var height: int = 0
	for frames: Variant in images:
		var row_w: int = 0
		var row_h: int = 0
		for texture: ImageTexture in frames:
			row_w += texture.get_width() + 1
			row_h = maxi(row_h, texture.get_height())
		width = maxi(width, row_w)
		height += row_h + (1 if row_h > 0 else 0)
	var image := Image.create_empty(width, maxi(height, 1), false, Image.FORMAT_RGBA8)
	var y: int = 0
	for t: int in images.size():
		var frames: Array = images[t]
		if frames.is_empty():
			continue
		var x: int = 0
		var row_h: int = 0
		var rects: Array = []
		for texture: ImageTexture in frames:
			var frame_image: Image = texture.get_image()
			image.blit_rect(frame_image, Rect2i(Vector2i.ZERO, frame_image.get_size()), Vector2i(x, y))
			rects.append(Rect2(x, y, frame_image.get_width(), frame_image.get_height()))
			x += frame_image.get_width() + 1
			row_h = maxi(row_h, frame_image.get_height())
		types[t]["idle"] = rects[0]
		types[t]["walk"] = rects.slice(1) if rects.size() > 1 else [rects[0]]
		y += row_h + 1
	atlas = ImageTexture.create_from_image(image)
	atlas_size = Vector2(image.get_size())


func has_art(type_index: int) -> bool:
	return type_index < types.size() and not types[type_index].is_empty()


## The drawer: a MultiMeshInstance2D over `count` instances using the atlas and shader.
func make_drawer(count: int) -> MultiMeshInstance2D:
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.use_colors = true
	multimesh.use_custom_data = true
	multimesh.mesh = quad
	multimesh.instance_count = count
	# Never cull: instances move all over the world.
	multimesh.custom_aabb = AABB(Vector3(-1e6, -1e6, -1.0), Vector3(2e6, 2e6, 2.0))
	for i: int in count:
		multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))
	var drawer := MultiMeshInstance2D.new()
	drawer.multimesh = multimesh
	drawer.texture = atlas
	var material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = SHADER
	material.shader = shader
	drawer.material = material
	drawer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return drawer


## Places one enemy's picture: feet at the bottom of its body (`at` + radius), facing left or right, standing or
## walking (`stride`: distance walked), tinted by `tint` (rgb, and a = how strongly).
func place(multimesh: MultiMesh, slot: int, type_index: int, at: Vector2, body_radius: float, face_left: bool,
		moving: bool, stride: float, tint: Color) -> void:
	var info: Dictionary = types[type_index]
	var region: Rect2 = info["idle"]
	if moving:
		var walk: Array = info["walk"]
		region = walk[int(stride / Data.cfg_float("enemies.walk_frame_px")) % walk.size()]
	var size: Vector2 = region.size
	var anchor: Vector2 = info["anchor"]
	var offset := Vector2(size.x * 0.5 - anchor.x, size.y * 0.5 - anchor.y)
	if face_left:
		offset.x = -offset.x
	var center: Vector2 = at + Vector2(0.0, body_radius) + offset
	# The quad's texture coordinates run bottom-up, so its height is flipped to draw the picture upright.
	multimesh.set_instance_transform_2d(slot, Transform2D(0.0, Vector2(-size.x if face_left else size.x, -size.y), 0.0, center))
	multimesh.set_instance_custom_data(slot, Color(region.position.x / atlas_size.x, region.position.y / atlas_size.y,
			size.x / atlas_size.x, size.y / atlas_size.y))
	multimesh.set_instance_color(slot, tint)


func hide(multimesh: MultiMesh, slot: int) -> void:
	multimesh.set_instance_transform_2d(slot, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))


## How tall a type's picture stands, in pixels (0 without art).
func height(type_index: int) -> float:
	if type_index < 0 or type_index >= types.size() or types[type_index].is_empty():
		return 0.0
	var region: Rect2 = types[type_index]["idle"]
	return region.size.y
