class_name LobbyService
extends Node
## What co-op needs from an online service (GAME_DESIGN.md: Online co-op /
## Online service): host a game and get a 6-digit code, join with a code, and
## pass messages between up to 4 players. CloudflareLobby is the one used
## (owner decision, 00.01.25); another service (Epic Online Services, Steam)
## can be added as another subclass without changing the game.
##
## Player ids: the host is 1, others 2–4. `to` = 0 means everyone else.

## Connected: this device's id, the game's code, and the players already there.
signal opened(my_id: int, code: String, peers: PackedInt32Array)
signal peer_joined(id: int)
signal peer_left(id: int)
signal received(from: int, data: PackedByteArray)
## The connection ended (the host left, the code was wrong, no internet…):
## `reason` is a translation key.
signal closed(reason: String)

const HOST_ID := 1
const EVERYONE := 0


## `is_public`: the game goes on the public list, and players may join during a run.
func host(_is_public: bool = false) -> void:
	pass


func join(_code: String) -> void:
	pass


func send(_to: int, _data: PackedByteArray) -> void:
	pass


## Host only: the run is starting (the public list shows "in a run";
## players can still join, and CoopLateJoin adds them to the run).
func lock() -> void:
	pass


## Host only: back in the lobby after a run.
func reopen() -> void:
	pass


## Host of a public game: what the public list shows (the level, and the
## game's version so only matching games are offered).
func set_info(_level_id: String, _version: String) -> void:
	pass


## Host only: put the game on the public list, or take it off (friends with the code can still join).
func set_public(_on: bool) -> void:
	pass


## Host only: removes a player from the lobby.
func kick(_id: int) -> void:
	pass


func leave() -> void:
	pass


func is_open() -> bool:
	return false
