class_name PoiManager
extends Node2D
## Points of interest in the world (GAME_DESIGN.md: Regions and POIs):
##   Hidden Shrine     an extra shrine, often an uncommon or rare god
##   Ancient Ruins     a stairway down into a dungeon (RuinsDungeon); the chest at its end
##                     gives the choice of a weapon/passive level, a heal, or gold
##                     (without the dungeon's art: stand in the circle 10 s while spawns spike ×3)
##   Dragon's Hoard    kill 50 enemies inside its circle to break the seal: chest + gold
##   Monster's Lair    3 elites with guards inside a ring of walls: big chest + gold
##   Wandering Trader  sells items for run gold
## At most one POI per region and about 3 nearby at once. A POI's state is
## stored only when it changes (run.poi_state: region key → "cleared" or "looted").

signal poi_entered(poi: Dictionary)

var shrines: Shrines
var spawner: EnemySpawner
var chests: ChestPickups
var gold: GoldPickups
var trader: TraderScreen
var ruins_choice: RuinsChoiceScreen
var ruins_dungeon: RuinsDungeon

## How far the world origin has moved, in chunks (absolute = local + this × chunk size).
var origin_chunk: Vector2i = Vector2i.ZERO
## Generated POIs by region key (cached so a region never changes during a run).
var regions: Dictionary = {}
## The few POIs near the players right now.
var nearby: Array[Dictionary] = []
## POIs placed by hand (debug menu), always considered.
var extra: Array[Dictionary] = []

var _scan_left: float = 0.0
## Per player id: the Trader they're at, so walking away and back reopens it.
var _trader_open_key: Dictionary = {}


func _ready() -> void:
	z_index = -2
	GameAuthority.enemy_killed.connect(_on_enemy_killed)
	CoopMirror.attach(self, "pois")


func chunk_px() -> float:
	return Data.cfg_float("world.chunk_tiles") * Data.cfg_float("world.tile_px")


func to_local_px(absolute_px: Vector2) -> Vector2:
	return absolute_px - Vector2(origin_chunk) * chunk_px()


func to_absolute_px(local_px: Vector2) -> Vector2:
	return local_px + Vector2(origin_chunk) * chunk_px()


func state_of(poi: Dictionary) -> String:
	return str(GameAuthority.run.poi_state.get(str(poi["key"]), ""))


func set_state(poi: Dictionary, state: String) -> void:
	GameAuthority.run.poi_state[str(poi["key"])] = state


## The POI generated for a region (generates and caches it the first time).
func poi_for(region: Vector2i) -> Dictionary:
	var key: String = PoiRules.key_of(region)
	if not regions.has(key):
		var run: RunState = GameAuthority.run
		regions[key] = PoiRules.for_region(run.seed_value, region, RunArc.age_at(run.arc_s()))
	return regions[key]


## Places a POI of `poi_id` at `local_px` now (debug menu).
func place(poi_id: String, local_px: Vector2) -> Dictionary:
	var poi: Dictionary = {"id": poi_id, "key": "placed_%d" % extra.size(), "pos": to_absolute_px(local_px)}
	extra.append(poi)
	_scan_left = 0.0
	return poi


func on_origin_shifted(_shift_px: Vector2, shift_chunks: Vector2i) -> void:
	origin_chunk += shift_chunks


func _process(delta: float) -> void:
	var run: RunState = GameAuthority.run
	var player: Player = GameAuthority.local_player()
	if run == null or run.ended or player == null:
		return
	_scan_left -= delta
	if _scan_left <= 0.0:
		_scan_left = 0.5
		_scan(player)
	var in_ruins: bool = false
	for poi: Dictionary in nearby:
		if state_of(poi) != "":
			continue
		var at: Vector2 = to_local_px(poi["pos"])
		var data: Dictionary = PoiRules.find(str(poi["id"]))
		# In co-op every player can use a point of interest; the nearest one counts.
		var closest: Player = _closest_player(at)
		if closest == null:
			continue
		var dist: float = closest.position.distance_to(at)
		var reach: float = float(data.get("radius_px", 40.0))
		match str(poi["id"]):
			"hidden_shrine":
				if dist <= _view().x * 0.5 and shrines != null:
					shrines.add(at, "", true)
					set_state(poi, "looted")
			"ancient_ruins":
				if ruins_dungeon != null and RuinsDungeon.has_art():
					ruins_dungeon.tick_entrance(poi, at, delta)
				elif dist <= reach:
					in_ruins = true
					poi["progress"] = float(poi.get("progress", 0.0)) + delta
					if float(poi["progress"]) >= float(data.get("hold_s", 10.0)):
						set_state(poi, "cleared")
						if ruins_choice != null:
							ruins_choice.offer(closest, float(data.get("gold", 40.0)))
			"monsters_lair":
				_tick_lair(poi, data, at, dist)
			"wandering_trader":
				for visitor: Player in GameAuthority.players:
					_check_trader(poi, visitor, visitor.position.distance_to(at), reach)
	if spawner != null:
		spawner.poi_mult = float(PoiRules.find("ancient_ruins").get("spawn_mult", 3.0)) if in_ruins else 1.0
	queue_redraw()


## The ruins' chest was opened (RuinsDungeon): they're explored, and the opener chooses their gift.
func finish_ruins(key: String, player: Player) -> void:
	GameAuthority.run.poi_state[key] = "cleared"
	if ruins_choice != null:
		ruins_choice.offer(player, float(PoiRules.find("ancient_ruins").get("gold", 40.0)))


func _check_trader(poi: Dictionary, player: Player, dist: float, reach: float) -> void:
	var key: String = str(poi["key"])
	if not player.alive:
		return
	if dist <= reach and str(_trader_open_key.get(player.player_id, "")) != key and trader != null:
		_trader_open_key[player.player_id] = key
		trader.open_for(player)
	elif dist > reach * 2.0 and str(_trader_open_key.get(player.player_id, "")) == key:
		_trader_open_key.erase(player.player_id)


func _closest_player(at: Vector2) -> Player:
	var best: Player = null
	for player: Player in GameAuthority.players:
		if player.alive and (best == null or player.position.distance_to(at) < best.position.distance_to(at)):
			best = player
	return best


# --- Co-op (CoopMirror) ------------------------------------------------------------------

func net_capture() -> Variant:
	return [CoopMirror.copy_dicts(nearby), GameAuthority.run.poi_state.duplicate() if GameAuthority.run != null else {},
			ruins_dungeon.net_state() if ruins_dungeon != null else []]


func net_apply(state: Variant) -> void:
	nearby.assign(state[0])
	if GameAuthority.run != null:
		GameAuthority.run.poi_state = state[1]
	if ruins_dungeon != null and (state as Array).size() > 2:
		ruins_dungeon.net_follow(state[2])


## Finds the POIs in the regions around the player and keeps the nearest few.
func _scan(player: Player) -> void:
	var here: Vector2i = PoiRules.region_of(to_absolute_px(player.position))
	var found: Array[Dictionary] = []
	for dx: int in range(-1, 2):
		for dy: int in range(-1, 2):
			var poi: Dictionary = poi_for(here + Vector2i(dx, dy))
			if not poi.is_empty():
				found.append(poi)
	found.append_array(extra)
	var limit: float = _view().x * Data.cfg_float("world.compass_range_screens")
	found.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return to_local_px(a["pos"]).distance_to(player.position) < to_local_px(b["pos"]).distance_to(player.position))
	nearby.clear()
	for poi: Dictionary in found:
		if nearby.size() < Data.cfg_int("world.max_pois_loaded") and to_local_px(poi["pos"]).distance_to(player.position) <= limit:
			nearby.append(poi)


func _tick_lair(poi: Dictionary, data: Dictionary, at: Vector2, dist: float) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if not poi.has("elites"):
		if dist > _view().x * float(data.get("wake_screens", 1.2)):
			return
		var slots := PackedInt32Array()
		var types: Array = (RunArc.wave_table(GameAuthority.run.level_data).get("elites", {}) as Dictionary).get("types", ["minotaur"])
		var rng: RandomNumberGenerator = GameAuthority.run.rng.spawns
		for k: int in int(data.get("elites", 3)):
			var slot: int = GameAuthority.spawn_enemy(str(types[k % types.size()]), at + Vector2.from_angle(TAU * k / 3.0) * 30.0)
			if slot != -1:
				enemies.elites.setup(slot, EliteState.roll(RunArc.elite_modifier_count(GameAuthority.run.arc_s()), rng), enemies.max_hp[slot])
				slots.append(slot)
		for k: int in int(data.get("guards", 10)):
			GameAuthority.spawn_enemy(str(data.get("guard_type", "satyr_skirmisher")), at + Vector2.from_angle(TAU * k / 10.0) * 60.0)
		poi["elites"] = slots
		poi["elite_types"] = types
		return
	for slot: int in (poi["elites"] as PackedInt32Array):
		if enemies.active[slot] != 0 and enemies.is_elite(slot):
			return
	set_state(poi, "cleared")
	if chests != null:
		chests.drop(at, true)
	if gold != null:
		gold.drop_pile(at, float(data.get("gold", 100.0)), Data.cfg_int("pickups.pile_coins"))


## Dragon's Hoard: kills inside its circle break the seal.
func _on_enemy_killed(_slot: int, _enemy_type: Dictionary, at: Vector2, _killer: Player) -> void:
	if Net.is_client():
		return
	for poi: Dictionary in nearby:
		if str(poi["id"]) != "dragons_hoard" or state_of(poi) != "":
			continue
		var data: Dictionary = PoiRules.find("dragons_hoard")
		var center: Vector2 = to_local_px(poi["pos"])
		if at.distance_to(center) > float(data.get("radius_px", 140.0)):
			continue
		poi["kills"] = int(poi.get("kills", 0)) + 1
		if int(poi["kills"]) >= int(data.get("kills", 50)):
			set_state(poi, "looted")
			if chests != null:
				chests.drop(center)
			if gold != null:
				gold.drop_pile(center, float(data.get("gold", 60.0)), Data.cfg_int("pickups.pile_coins"))


func _view() -> Vector2:
	return get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)


## The ruin each region's Ancient Ruins are built from (its own scenery picture).
const RUINS := {"greek": "broken_column", "norse": "runestone", "egyptian": "obelisk", "irish": "standing_stone",
		"welsh": "standing_stone", "mesopotamian": "boundary_stone", "finnish": "log_hut_ruin", "persian": "div_palace_ruin", "slavic": "log_hut_ruin", "japanese": "castle_wall_ruin"}


func _region() -> String:
	return str(GameAuthority.run.level_data.get("region", "")) if GameAuthority.run != null else ""


func _draw() -> void:
	for poi: Dictionary in nearby:
		var at: Vector2 = to_local_px(poi["pos"])
		var data: Dictionary = PoiRules.find(str(poi["id"]))
		var color := Color.html(str(data.get("icon_color", "#ffffff")))
		var done: bool = state_of(poi) != ""
		if done:
			color = Color(color, 0.35)
		var reach: float = float(data.get("radius_px", 40.0))
		match str(poi["id"]):
			"ancient_ruins":
				if ruins_dungeon != null and RuinsDungeon.has_art():
					ruins_dungeon.draw_entrance(self, at, done, color)
					continue
				draw_arc(at, reach, 0.0, TAU, 40, color, 2.0)
				var k: float = float(poi.get("progress", 0.0)) / float(data.get("hold_s", 10.0))
				if k > 0.0 and not done:
					draw_arc(at, reach - 4.0, -PI * 0.5, -PI * 0.5 + TAU * minf(k, 1.0), 40, Color.WHITE, 4.0)
				# A ring of the level's own standing ruins (owner request 10/31/2026): columns, runestones, obelisks or
				# standing stones.
				var ruin: Dictionary = PixelArt.find("scenery/" + str(RUINS.get(_region(), "broken_column")))
				for c: int in 6:
					var spot: Vector2 = at + Vector2.from_angle(TAU * c / 6.0 - PI * 0.5) * reach * 0.6
					if ruin.is_empty():
						draw_rect(Rect2(spot - Vector2(3, 8), Vector2(6, 16)), color)
					else:
						PixelArt.draw_standing(self, ruin, spot + Vector2(0, 8), false, Color(1, 1, 1, color.a))
			"dragons_hoard":
				draw_arc(at, reach, 0.0, TAU, 48, Color(color, 0.5), 1.5)
				var k: float = float(poi.get("kills", 0)) / float(data.get("kills", 50))
				draw_arc(at, 22.0, -PI * 0.5, -PI * 0.5 + TAU * minf(k, 1.0), 24, color, 4.0)
				# A heap of gold round a gold-bound chest.
				var coin: Dictionary = PixelArt.find("pickups/gold_coin")
				var chest: Dictionary = PixelArt.find("pickups/chest_big")
				if coin.is_empty() or chest.is_empty():
					draw_rect(Rect2(at - Vector2(9, 6), Vector2(18, 12)), color)
				else:
					var coin_tint := Color(Color.html(Data.cfg_string("pickups.gold_color")), color.a)
					for c: int in 14:
						var spot: Vector2 = at + Vector2(((c * 7) % 13 - 6) * 1.8, 6.0 - float(c % 4) * 2.5 + absf(float((c * 7) % 13 - 6)) * 0.4)
						draw_texture(PixelArt.frame(coin, false, 0.0), spot - Vector2(4, 4), coin_tint)
					PixelArt.draw_standing(self, chest, at + Vector2(0, 2), false, Color(1, 1, 1, color.a))
			"monsters_lair":
				for c: int in 12:
					if c % 4 != 0:
						var a: float = TAU * c / 12.0
						draw_line(at + Vector2.from_angle(a) * reach, at + Vector2.from_angle(a + TAU / 14.0) * reach, color, 4.0)
				# A dark den mouth with bones strewn before it.
				draw_set_transform(at, 0.0, Vector2(1.0, 0.6))
				draw_circle(Vector2.ZERO, 16.0, Color(0.25, 0.2, 0.16, color.a))
				draw_circle(Vector2(0, 2), 11.0, Color(0.05, 0.03, 0.02, color.a))
				draw_set_transform(Vector2.ZERO)
				var bone := Color(0.92, 0.88, 0.78, color.a)
				for c: int in 5:
					var spot: Vector2 = at + Vector2(-20.0 + c * 10.0, 16.0 + (c % 2) * 5.0)
					var dir: Vector2 = Vector2.from_angle(c * 1.3)
					draw_line(spot - dir * 3.0, spot + dir * 3.0, bone, 1.5)
					draw_circle(spot - dir * 3.0, 1.2, bone)
					draw_circle(spot + dir * 3.0, 1.2, bone)
			"wandering_trader":
				# A market stall: a counter with goods, under a striped awning on two posts.
				var awning := Color.html(Data.cfg_string("world.trader_awning_color"))
				var wood := Color(0.42, 0.29, 0.17, color.a)
				draw_line(at + Vector2(-13, -12), at + Vector2(-13, 8), wood, 2.0)
				draw_line(at + Vector2(13, -12), at + Vector2(13, 8), wood, 2.0)
				draw_rect(Rect2(at - Vector2(12, 2), Vector2(24, 10)), color)
				draw_rect(Rect2(at - Vector2(12, 2), Vector2(24, 2)), wood)
				for s: int in 4:
					draw_rect(Rect2(at + Vector2(-15 + s * 7.5, -16), Vector2(7.5, 5)), Color(awning if s % 2 == 0 else Color.WHITE, color.a))
				draw_circle(at + Vector2(-6, -4), 2.5, Color(0.85, 0.3, 0.2, color.a))
				draw_circle(at + Vector2(0, -4), 2.5, Color(0.95, 0.8, 0.3, color.a))
				draw_rect(Rect2(at + Vector2(4, -7), Vector2(5, 5)), Color(0.5, 0.65, 0.85, color.a))
			_:
				draw_arc(at, 12.0, 0.0, TAU, 20, color, 2.0)
