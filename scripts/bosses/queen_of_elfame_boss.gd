class_name QueenOfElfameBoss
extends BossController
## The Queen of Elfame, 30:00 (docs/PACK_7_PLAN.md: Elfame; the design's boss). Signature, the fruit of Elfland: fruit
## appears in the arena. Eating it heals a Hero, but binds their tongue: both their god meters empty, as the queen warned
## Thomas that the fruit of her garden would bind him. Sources: the ballad Thomas the Rhymer (Child 37); the romance of
## Thomas of Erceldoune (15th c.).

## Fruit on the ground.
var fruit: Array[Vector2] = []
var eaten: int = 0
var _grow_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_grow_in -= delta
	if _grow_in <= 0.0:
		_grow_in = float(_sig().get("fruit_every_s", 8.0))
		grow_fruit()
	var reach: float = float(_sig().get("fruit_reach_px", 14.0))
	for i: int in range(fruit.size() - 1, -1, -1):
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(fruit[i]) <= reach + player.body_radius:
				fruit.remove_at(i)
				eat(player)
				break


func grow_fruit() -> void:
	if fruit.size() >= int(_sig().get("max_fruit", 3)):
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	fruit.append(centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 200.0))


## Healed, but the tongue is bound: both god meters empty.
func eat(player: Player) -> void:
	eaten += 1
	GameAuthority.heal_player(player, player.max_hp * float(_sig().get("heal_fraction", 0.3)))
	if GameAuthority.gods != null:
		for k: int in 2:
			GameAuthority.gods.set_meter(player, k, 0.0)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and eaten == 1:
		banner.show_text(tr("BOSS_QUEEN_OF_ELFAME_FRUIT"))


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the fruit moves with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in fruit.size():
		fruit[i] -= shift_px


func _draw() -> void:
	for at: Vector2 in fruit:
		var p: Vector2 = at - global_position
		draw_circle(p, 5.0, Color(0.85, 0.15, 0.25))
		draw_circle(p + Vector2(-1.5, -1.5), 2.0, Color(1.0, 0.6, 0.65))
		draw_line(p + Vector2(0, -5), p + Vector2(2, -8), Color(0.3, 0.6, 0.25), 1.5)
	super._draw()


## True Thomas secret: beaten without anyone eating the fruit of Elfland.
func secret_earned() -> String:
	return "true_thomas" if eaten == 0 else ""
