class_name SinmaraBoss
extends SurtrBoss
## Sinmara, 30:00 (docs/PACK_4_PLAN.md: Muspelheim). Signature: the fire realm closes in, as Surtr's Ragnarok does
## (the arena's edge burns inward), and in her last phase she takes Laevateinn from its chest of nine locks, and her
## blows land harder. Source: the Poetic Edda, Fjolsvinnsmal 26-30.

func has_blade() -> bool:
	return phase_index >= int((data.get("signature", {}) as Dictionary).get("blade_phase", 2))


func _on_phase_started(index: int) -> void:
	if index == int((data.get("signature", {}) as Dictionary).get("blade_phase", 2)):
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_SINMARA_BLADE"))


func _damage_mult() -> float:
	return super._damage_mult() * (float((data.get("signature", {}) as Dictionary).get("blade_damage_mult", 1.3)) if has_blade() else 1.0)
