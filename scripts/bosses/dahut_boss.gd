class_name DahutBoss
extends TiamatBoss
## Dahut, 30:00 (docs/PACK_4_PLAN.md: Ys). Signature, the sea gates: she has opened the gates, and waves of the sea roll
## in across the arena while the sea's creatures come with them (as Tiamat's waves and brood do, tiamat_boss.gd, from
## her own numbers); in her last phase she becomes a mari-morgan. Source: Albert Le Grand (1636); the Barzaz Breiz.

func art_id() -> String:
	return "dahut_morgan" if phase_index >= int((data.get("signature", {}) as Dictionary).get("morgan_phase", 2)) else "dahut"


func _on_phase_started(index: int) -> void:
	if index == int((data.get("signature", {}) as Dictionary).get("morgan_phase", 2)):
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_DAHUT_MORGAN"))


## The Golden Key secret: the final blow is Lightning.
var last_element: String = ""


func on_element_hit(element: String) -> void:
	last_element = element


func secret_earned() -> String:
	return "the_golden_key" if last_element == "lightning" else ""
