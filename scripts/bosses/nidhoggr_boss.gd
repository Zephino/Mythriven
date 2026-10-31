class_name NidhoggrBoss
extends IkuTursoBoss
## Nidhoggr, 30:00 (docs/PACK_4_PLAN.md: Niflheim). Signature: he burrows down among the roots of the world-tree, where
## nothing can hurt him, and bursts up beneath his target; the broken ground stays as pits that slow and hurt. Works as
## Iku-Turso's dives do (iku_turso_boss.gd), from his own numbers. Source: Grimnismal 32-35 (he gnaws the roots from
## beneath); Voluspa 39.


## The Gnawed Root secret: the final blow is Holy.
var last_element: String = ""


func on_element_hit(element: String) -> void:
	last_element = element


func secret_earned() -> String:
	return "the_gnawed_root" if last_element == "holy" else ""
