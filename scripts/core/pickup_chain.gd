class_name PickupChain
extends RefCounted
## Rising-pitch pickup chain (GAME_DESIGN.md: Rising-pitch pickups). Each
## pickup within the chain window plays the next note up; after the top step
## it holds that note; after the reset time without a pickup it starts again
## at the bottom. At most `per_second` sounds play each second.

var window_s: float = 0.4
var reset_s: float = 0.6
var max_steps: int = 12
var per_second: int = 20

var step: int = -1
var _last_time: float = -INF
var _played: PackedFloat64Array = PackedFloat64Array()


static func from_config() -> PickupChain:
	var chain := PickupChain.new()
	chain.window_s = Data.cfg_float("pickups.pickup_chain_window_s")
	chain.reset_s = Data.cfg_float("pickups.pickup_chain_reset_s")
	chain.max_steps = Data.cfg_int("pickups.pickup_chain_max_steps")
	chain.per_second = Data.cfg_int("pickups.pickup_sounds_per_s")
	return chain


## Registers a pickup at time `now` (seconds). Returns the note step to play
## (0 = bottom), or -1 when the sound is skipped by the rate limit.
func on_pickup(now: float) -> int:
	var gap: float = now - _last_time
	if step < 0 or gap > reset_s:
		step = 0
	elif gap <= window_s:
		step = mini(step + 1, max_steps - 1)
	_last_time = now
	while not _played.is_empty() and now - _played[0] >= 1.0:
		_played.remove_at(0)
	if _played.size() >= per_second:
		return -1
	_played.append(now)
	return step
