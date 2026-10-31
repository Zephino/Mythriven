class_name RuinsDungeon
extends ShrineDungeon
## The Ancient Ruins as a dungeon (owner request 10/31/2026): in the world the ruins are a crumbling stairway going
## down; the party gathers at it (in co-op, every standing player together) and goes in, and the run outside pauses
## as for a shrine. Inside, a maze built at random from the ruins' own parts (data/art/dungeon/ruins.json: cracked
## flagstones, broken walls, snapped pillars, torches, rubble and bones) fills with the level's monsters until someone
## reaches the treasure vault at the far end. Touching the chest on its dais opens it: the party is warped back out
## and the ruins' gift is chosen (a weapon or passive level, a heal, or gold), as before.

const PARTS := "dungeon/ruins"

var pois: PoiManager
var _opened: bool = false


## True when the ruins can be a dungeon (their parts have art).
static func has_art() -> bool:
	return not PixelArt.find(PARTS).is_empty()


## Each frame while the party is near unexplored ruins (PoiManager calls it).
## Only the ruin someone stands at counts, so another ruin on screen doesn't reset the gathering.
func tick_entrance(poi: Dictionary, at: Vector2, delta: float) -> void:
	if not GameAuthority.decides():
		return
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= Data.cfg_float("gods.shrine_radius_px") * 2.0 + player.body_radius:
			gather(_site(poi, at), delta)
			return


## The site a ruin's dungeon is built for: the same maze for everyone, from the ruin's place in the world.
func _site(poi: Dictionary, at: Vector2) -> Dictionary:
	return {"pos": at, "seed": hash(str(poi["key"])), "key": str(poi["key"]), "god": {}}


func enter(site: Dictionary) -> void:
	_opened = false
	super.enter(site)


func _parts_id() -> String:
	return PARTS


## The treasure: touching the chest opens it, warps the party out, and offers the ruins' gift.
func _goal(_delta: float) -> void:
	if _opened:
		return
	var reach: float = Data.cfg_float("gods.shrine_radius_px")
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(altar_position()) <= reach + player.body_radius:
			_opened = true
			var key: String = str(shrine.get("key", ""))
			leave()
			if pois != null:
				pois.finish_ruins(key, player)
			return


## The gold-bound chest on its dais.
func _draw_goal() -> void:
	var chest: Dictionary = PixelArt.find("pickups/chest_big")
	if not _opened and not chest.is_empty():
		PixelArt.draw_standing(self, chest, altar_position() + Vector2(0.0, -2.0), false)


## The ruins in the world: the stairway down. No ring round it (owner request 10/31/2026); one shows only while the
## party gathers at it, filling up.
func draw_entrance(canvas: CanvasItem, at: Vector2, done: bool, _color: Color) -> void:
	var frames: Dictionary = PixelArt.find(PARTS)["frames"]
	var texture: ImageTexture = (frames["entrance"] as Array)[0]
	var shade := Color(1, 1, 1, 0.45) if done else Color.WHITE
	canvas.draw_texture(texture, at - Vector2(texture.get_width() * 0.5, texture.get_height() * 0.75), shade)
	if not done and not active and gather_progress(at) > 0.0:
		canvas.draw_arc(at, Data.cfg_float("gods.shrine_radius_px"), -PI * 0.5, -PI * 0.5 + TAU * gather_progress(at), 40,
				Color.WHITE, 3.0)


# --- Co-op: joining players go in and out with the host (carried by PoiManager's mirror) --------------------------

func net_state() -> Array:
	return [shrine.get("key", ""), int(shrine.get("seed", 0)), shrine["pos"]] if active else []


func net_follow(state: Variant) -> void:
	var inside: Array = state if state is Array else []
	if not inside.is_empty() and not active:
		enter({"pos": inside[2], "seed": int(inside[1]), "key": str(inside[0]), "god": {}})
	elif inside.is_empty() and active:
		leave()
