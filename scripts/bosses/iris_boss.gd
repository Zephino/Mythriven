class_name IrisBoss
extends MorvarchBoss
## Iris, 20:00 (docs/PACK_4_PLAN.md: Cloud-Cuckoo-Land). Signature: the messenger of the gods darts across the sky in
## straight flights, leaving a trail of rainbow that slows whoever stands in it (Morvarc'h's gallop and wake,
## morvarch_boss.gd, from her own numbers). Source: Aristophanes, The Birds (Iris flies into the birds' sky).


var age: float = 0.0


func signature(delta: float) -> void:
	age += delta
	super.signature(delta)


## Iris at the Walls secret: catch her within 60 s, as the birds caught her at their walls.
func secret_earned() -> String:
	return "iris_at_the_walls" if age <= 60.0 else ""
