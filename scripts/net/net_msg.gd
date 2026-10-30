class_name NetMsg
extends RefCounted
## Co-op message types. Every message is an Array whose first item is one of
## these, sent as bytes with var_to_bytes (no objects, so nothing can run code).

# Lobby
## Client → host: [HELLO, version, hero_id]
const HELLO := 1
## Host → all: [ROSTER, {id: {"hero": id}}, level_id, swift]
const ROSTER := 2
## Client → host: [HERO, hero_id]
const HERO := 3
## Host → all: [START, seed, level_id, swift, omens, roster]
const START := 4
## Host → one client: [WRONG_VERSION, host_version]
const WRONG_VERSION := 5
## Client → host: [BACK] back in the lobby after a run
const BACK := 6
## Host → one client joining a public game's run in progress: like START
## (then a SNAPSHOT of the world follows)
const LATE_START := 7

# In a run (host-authoritative; see CoopHost / CoopClient)
## Client → host, ~20/s: [INPUT, epoch, x, y, vx, vy, facing_x, facing_y]
const INPUT := 20
## Host → all, ~20/s: [TICK, epoch, elapsed_s, players, enemy batch, events]
const TICK := 21
## Client → host: [CARD, index] (a level-up card chosen on that player's turn)
const CARD := 22
## Client → host: [SUMMON, god slot] / [RESONANCE]
const SUMMON := 23
const RESONANCE := 24
## Client → host: [CHOICE, kind, value] (shrine bind / release, Boon, Trader…)
const CHOICE := 25
## Host → one client: [OFFER, kind, data] (level-up cards, god choice, Boons…)
const OFFER := 26
## Client → host: [BANKED] a quit or a leave (handled as leaving the run)
const BYE := 27
## Host → one client who joined late: [SNAPSHOT, shift_x, shift_y, spawn_x,
## spawn_y, events, player positions] (everything already in the world)
const SNAPSHOT := 28


static func encode(msg: Array) -> PackedByteArray:
	return var_to_bytes(msg)


## The message, or [] if the bytes aren't a valid message.
static func decode(data: PackedByteArray) -> Array:
	var value: Variant = bytes_to_var(data)
	if value is Array and not (value as Array).is_empty() and (value as Array)[0] is int:
		return value
	return []
