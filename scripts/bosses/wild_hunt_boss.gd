class_name WildHuntBoss
extends MorvarchBoss
## The Wild Hunt, 30:00 (docs/PACK_5_PLAN.md: Erebus; the design's boss). Signature, the ride: again and again the
## black huntsmen gallop straight across the arena at a Hero, trampling whoever is in the way and leaving a trail of
## grave-cold mist that slows, and each time they ride they loose their hounds. Sources: the Anglo-Saxon Chronicle for 1127 (black huntsmen on black
## horses and black goats, with black hounds with wide eyes); Orderic Vitalis 8.17 (Hellequin's household).
## Baubo (the Brocken, 20:00) uses this script too: she charges on her sow and calls witches after her ("hound").

var rides: int = 0


func signature(delta: float) -> void:
	var waiting: float = _gallop_in
	super.signature(delta)
	# A new ride began this frame (the wait to the next one was reset).
	if is_alive() and _gallop_in > waiting:
		loose_hounds()


func loose_hounds() -> void:
	rides += 1
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var at: Vector2 = position_now()
	for _k: int in int(_sig().get("hounds", 3)):
		GameAuthority.spawn_enemy(str(_sig().get("hound", "hunt_hound")), at + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(30.0, 60.0))
