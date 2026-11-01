class_name GoblinMerchantsBoss
extends BossController
## The Goblin Merchant-Men, 30:00 (docs/PACK_9_PLAN.md: the Goblin Market; the design's boss). Signature, "Come buy!":
## every so often a ring of goblins springs up round a Hero, crying their wares, and closes in on them, as they crowded
## round Lizzie trying to make her eat. Break out of the ring. Source: Christina Rossetti, Goblin Market (1862).

var rings: int = 0
var _ring_in: float = 5.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_ring_in -= delta
	if _ring_in <= 0.0:
		_ring_in = float(_sig().get("ring_every_s", 10.0))
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		if near != null:
			surround(near)


## A ring of goblins round `player`.
func surround(player: Player) -> int:
	rings += 1
	var made: int = 0
	var count: int = int(_sig().get("ring_goblins", 10))
	for k: int in count:
		if GameAuthority.spawn_enemy(str(_sig().get("goblin", "goblin_man")),
				player.position + Vector2.from_angle(TAU * k / float(count)) * float(_sig().get("ring_px", 90.0))) >= 0:
			made += 1
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and rings == 1:
		banner.show_text(tr("BOSS_GOBLIN_MERCHANTS_COME_BUY"))
	return made


## Come Buy, No Thanks secret: three of their rings survived before they fall.
func secret_earned() -> String:
	return "no_thanks" if rings >= 3 else ""
