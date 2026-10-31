class_name CerberusBoss
extends BossController
## Cerberus, 10:00 (docs/PACK_2_PLAN.md: the Underworld; GAME_DESIGN.md Act II bosses). Signature, three heads: each
## head has its own attack, the fire head's fan of flames, the biting head's lunge, the howling head's call to the
## shades. Each phase one head falls (first the howling head, then the fire head) and its attack goes with it, until
## only the biting head is left, lunging faster. His picture loses the head too (cerberus_2, cerberus_1).
## Sources: Hesiod, Theogony 311; Apollodorus, Library 2.5.12 (three dogs' heads, a serpent's tail).


## How many heads he still has: 3, then 2, then 1.
func heads() -> int:
	return clampi(3 - phase_index, 1, 3)


func art_id() -> String:
	return "cerberus" if heads() == 3 else "cerberus_%d" % heads()


func _on_phase_started(index: int) -> void:
	if index <= 0 or slot == -1:
		return
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_CERBERUS_HEAD_FALLS"))
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(position_now(), GameAuthority.enemies.radius[slot] + 20.0, Color(0.9, 0.4, 0.2), true)
