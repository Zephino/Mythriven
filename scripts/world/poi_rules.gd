class_name PoiRules
extends RefCounted
## Where points of interest go (GAME_DESIGN.md: Regions and POIs). A region is
## 4×4 chunks (2,048 px). For each region, a generator seeded from the run seed
## and the region's position decides: a 35% chance of one POI, its type
## (weighted by the Age and by distance from the start), and its position
## (away from the region's edges). The same seed always places the same POIs.
## The starting region always has Ancient Ruins within 1 screen.
## Positions here are in "absolute" world pixels (before origin shifts).

const FILE := "pois.json"


static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	return found


static func find(poi_id: String) -> Dictionary:
	for poi: Dictionary in all():
		if str(poi.get("id", "")) == poi_id:
			return poi
	return {}


static func region_px() -> float:
	return Data.cfg_float("world.region_chunks") * Data.cfg_float("world.chunk_tiles") * Data.cfg_float("world.tile_px")


static func region_of(absolute_px: Vector2) -> Vector2i:
	var size: float = region_px()
	return Vector2i(floori(absolute_px.x / size), floori(absolute_px.y / size))


static func key_of(region: Vector2i) -> String:
	return "%d,%d" % [region.x, region.y]


## The region's POI {"id", "key", "pos"} (pos in absolute px), or {} for none.
static func for_region(run_seed: int, region: Vector2i, age: String) -> Dictionary:
	if region == Vector2i.ZERO:
		var offset: Array = Data.cfg("world.start_ruins_offset_px")
		return {"id": "ancient_ruins", "key": key_of(region), "pos": Vector2(float(offset[0]), float(offset[1]))}
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([run_seed, region.x, region.y, "poi"])
	if rng.randf() >= Data.cfg_float("world.poi_chance"):
		return {}
	var distance: int = maxi(absi(region.x), absi(region.y))
	var weights: Dictionary = {}
	for poi: Dictionary in all():
		if distance >= int(poi.get("min_regions", 0)):
			weights[str(poi["id"])] = float((poi.get("weights", {}) as Dictionary).get(age, 0.0))
	var poi_id: String = RunArc.pick_weighted(weights, rng)
	if poi_id == "":
		return {}
	var size: float = region_px()
	var margin: float = Data.cfg_float("world.poi_edge_margin")
	var pos := Vector2(region.x + rng.randf_range(margin, 1.0 - margin), region.y + rng.randf_range(margin, 1.0 - margin)) * size
	return {"id": poi_id, "key": key_of(region), "pos": pos}
