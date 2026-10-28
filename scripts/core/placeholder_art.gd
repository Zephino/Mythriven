class_name PlaceholderArt
extends RefCounted
## Simple shapes made in code until real pixel art exists (Phase 19):
## a white circle texture (tinted per enemy or projectile) and a quad mesh
## for drawing many of them at once with a MultiMesh.

static var _circle: ImageTexture = null


## A white anti-aliased circle, `size_px` wide.
static func circle_texture(size_px: int) -> ImageTexture:
	if _circle != null:
		return _circle
	var image := Image.create_empty(size_px, size_px, false, Image.FORMAT_RGBA8)
	var center := Vector2(size_px, size_px) * 0.5
	var radius: float = size_px * 0.5
	for y: int in size_px:
		for x: int in size_px:
			var dist: float = Vector2(x + 0.5, y + 0.5).distance_to(center)
			var alpha: float = clampf(radius - dist, 0.0, 1.0)
			image.set_pixel(x, y, Color(1, 1, 1, alpha))
	_circle = ImageTexture.create_from_image(image)
	return _circle


## A MultiMesh that draws `count` 1×1 quads; each instance is scaled to size.
static func make_multimesh(count: int) -> MultiMesh:
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.use_colors = true
	multimesh.mesh = quad
	multimesh.instance_count = count
	# Never cull: instances move all over the world.
	multimesh.custom_aabb = AABB(Vector3(-1e6, -1e6, -1.0), Vector3(2e6, 2e6, 2.0))
	for i: int in count:
		multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))
	return multimesh
