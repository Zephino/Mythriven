class_name ScathachBoss
extends BossController
## Scáthach, 10:00 (GAME_DESIGN.md: The Misty Isles bosses). Signature, the
## lesson: she announces each technique by name before using it (its name on
## the cast bar), and every time she repeats one it comes faster. Learn the
## pattern, beat the teacher. Phases: spear forms → leaping strikes → all the
## forms in sequence. Her techniques are the hero-feats she taught in the
## Irish tales. Defeating her unlocks her as a Hero (BossManager).

## How many times each technique has been used: name key -> count.
var _taught: Dictionary = {}


func _next_attack() -> void:
	_attacks += 1
	var list: Array = phase().get("techniques", [])
	if list.is_empty():
		super._next_attack()
		return
	var technique: Dictionary = list[_attacks % list.size()]
	var key: String = str(technique.get("name_key", ""))
	var times: int = int(_taught.get(key, 0))
	_taught[key] = times + 1
	var sig: Dictionary = data.get("signature", {})
	var faster: float = pow(float(sig.get("repeat_cast_mult", 0.85)), times)
	cast = {"name_key": key, "cast_s": maxf(float(technique.get("cast_s", 1.4)) * faster, float(sig.get("min_cast_s", 0.5))),
		"pattern": technique.get("pattern", {})}
	cast_left = float(cast["cast_s"])
