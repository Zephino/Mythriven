class_name CoopMirror
extends RefCounted
## Lets a world system show the host's state on the joining players' screens
## (shrines, chests, points of interest, bosses' visuals, hazards…). The
## system has `net_capture() -> Variant` (the data its drawing uses) and
## `net_apply(state)`. On the host, CoopHost sends net_capture() a few times a
## second; on a joining player's device the system stops deciding things
## (its _process is switched off) and only applies what the host sent.

var id: String = ""
var node: Node = null


## Call from the system's _ready. Does nothing outside co-op.
static func attach(system: Node, mirror_id: String) -> void:
	if not Net.in_run():
		return
	var mirror := CoopMirror.new()
	mirror.id = mirror_id
	mirror.node = system
	system.set_meta("coop_mirror", mirror)
	system.add_to_group(CoopHost.MIRROR_GROUP)
	if Net.is_client():
		system.process_mode = Node.PROCESS_MODE_DISABLED


func capture() -> Variant:
	return node.call("net_capture") if is_instance_valid(node) else null


func apply(state: Variant) -> void:
	if is_instance_valid(node) and state != null:
		node.call("net_apply", state)
		if node is CanvasItem:
			(node as CanvasItem).queue_redraw()


## Positions in a capture as plain numbers: [x0, y0, x1, y1, …].
static func pack_points(points: PackedVector2Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(points.size() * 2)
	for i: int in points.size():
		out[i * 2] = points[i].x
		out[i * 2 + 1] = points[i].y
	return out


static func unpack_points(data: PackedFloat32Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(data.size() / 2)
	for i: int in out.size():
		out[i] = Vector2(data[i * 2], data[i * 2 + 1])
	return out


## Array-of-dictionary state (Vector2 values survive var_to_bytes as they are).
static func copy_dicts(items: Array) -> Array:
	var out: Array = []
	for item: Variant in items:
		if item is Dictionary:
			out.append((item as Dictionary).duplicate(true))
	return out
