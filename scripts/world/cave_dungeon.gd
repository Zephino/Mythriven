class_name CaveDungeon
extends RuinsDungeon
## The treasure cave on a mountain's far peak (docs/WORLD_PLAN.md: 5; owner request 10/31/2026): gather at its mouth
## and the party goes down into a cave built from the cave parts (data/art/dungeon/cave.json: dirt floors, rough
## rock, stalagmites, glowing crystals, a still pool), full of the level's monsters until someone reaches the ledge
## at its end. Touching the chest there warps the party back out to the mouth, where a big chest and a pile of gold
## wait. Each cave can be looted once.

const CAVE_PARTS := "dungeon/cave"

var chests: ChestPickups
var gold: GoldPickups


func _parts_id() -> String:
	return CAVE_PARTS


## The mouth is drawn by Mountains; no arch to walk under.
func _draw_front() -> void:
	pass


func _goal(_delta: float) -> void:
	if _opened:
		return
	var reach: float = Data.cfg_float("gods.shrine_radius_px")
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(altar_position()) <= reach + player.body_radius:
			_opened = true
			var key: String = str(shrine.get("key", ""))
			var mouth: Vector2 = shrine["pos"]
			leave()
			if GameAuthority.run != null:
				GameAuthority.run.poi_state[key] = "looted"
			# The treasure comes out with them: a big chest and a pile of gold at the cave's mouth.
			if chests != null:
				chests.drop(mouth + Vector2(0.0, Data.cfg_float("world.cave_treasure_drop_px")), true)
			if gold != null:
				gold.drop_pile(mouth + Vector2(18.0, Data.cfg_float("world.cave_treasure_drop_px")), Data.cfg_float("world.cave_gold"),
						Data.cfg_int("world.cave_gold_coins"))
			return
