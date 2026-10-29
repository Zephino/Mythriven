class_name Banking
extends RefCounted
## How much of a run's gold is kept (GAME_DESIGN.md: Death, permanent
## progression, and saving / Persistence rule). Dying keeps 100%. Quitting
## before 5:00 keeps none; quitting at 5:00 or later keeps 10%, rounded down.
## A crash or force-close counts as quitting. Swift Mode uses the scaled time
## (keeps 10% from 3:30). Omens and Swift Mode add their gold bonuses.


## Gold banked for a run. `arc_seconds` is time on the run arc's clock
## (RunState.arc_s()), so Swift Mode's 3:30 counts as 5:00.
static func banked(run_gold: float, arc_seconds: float, quit: bool, omens: PackedStringArray, swift: bool) -> int:
	var kept: float = run_gold
	if quit:
		if arc_seconds < Data.cfg_float("economy.quit_min_seconds"):
			return 0
		kept *= Data.cfg_float("economy.quit_gold_pct")
	return floori(kept * bonus_mult(omens, swift))


## Gold multiplier from active Omens (their bonuses add up) and Swift Mode.
static func bonus_mult(omens: PackedStringArray, swift: bool) -> float:
	var bonus: float = 0.0
	for omen: Dictionary in OmenRules.all():
		if omens.has(str(omen.get("id", ""))):
			bonus += float(omen.get("gold_bonus_pct", 0.0)) / 100.0
	return (1.0 + bonus) * (Data.cfg_float("swift.gold_mult") if swift else 1.0)


## For the run state saved while playing: gold that a force-close would keep.
static func banked_from_checkpoint(checkpoint: Dictionary) -> int:
	if checkpoint.is_empty():
		return 0
	return banked(float(checkpoint.get("gold", 0.0)), float(checkpoint.get("arc_s", 0.0)), true,
			PackedStringArray(checkpoint.get("omens", [])), bool(checkpoint.get("swift", false)))
