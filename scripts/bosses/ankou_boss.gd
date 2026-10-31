class_name AnkouBoss
extends ThanatosBoss
## The Ankou, 20:00 (docs/PACK_4_PLAN.md: Ys). Signature, the axle creaks: whoever hears his cart's axle in the night is
## marked, and the mark lands unless he is struck hard enough first; it works as Thanatos' mark of death does
## (thanatos_boss.gd), without Heracles' wrestling bonus. Source: Anatole Le Braz, La Legende de la mort (1893).

func cancel_needed(_player: Player) -> float:
	return float(_sig().get("cancel_hp_fraction", 0.06)) * GameAuthority.enemies.max_hp[slot]
