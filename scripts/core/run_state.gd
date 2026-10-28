class_name RunState
extends RefCounted
## Everything about the current run (one Last Stand) that is lost when it
## ends. Owned by GameAuthority. Nothing here persists (persists: false).

var seed_value: int = 0
## The level's entry from levels.json.
var level_data: Dictionary = {}
var rng: RunRng
## Run time in seconds. Stops while the game is paused (level-ups, menus).
var elapsed_s: float = 0.0
var kills: int = 0
var ended: bool = false
## Shared XP (co-op shares one bar). Level starts at 1.
var xp: float = 0.0
var level: int = 1
## Level-ups earned but not yet chosen (banked with the level badge).
var unspent_level_ups: int = 0
## Cards currently offered; kept when the choice is banked.
var current_offer: Array[Dictionary] = []
## Gold collected this run (banking rules come in Phase 15).
var gold: float = 0.0
## True once any F1 debug option touched this run; such runs never go on the leaderboard.
var debug_used: bool = false
## True while a boss arena is up (hazards pause, only fodder spawns).
var boss_arena_active: bool = false
## God meter charge multiplier from events (the Divine Storm doubles it).
var god_charge_mult: float = 1.0
## Until this run time, kills drop more XP and gold (Tyche's Wheel of Fortune).
var double_drops_until_s: float = -1.0
var drop_mult_bonus: float = 2.0
## XP multiplier from events (the Chaos Surge doubles it).
var xp_mult: float = 1.0


func _init(run_seed: int, level_entry: Dictionary) -> void:
	seed_value = run_seed
	level_data = level_entry
	rng = RunRng.new(run_seed)


## Multiplier on what a kill drops right now (XP and gold).
func drop_mult() -> float:
	return drop_mult_bonus if elapsed_s < double_drops_until_s else 1.0
