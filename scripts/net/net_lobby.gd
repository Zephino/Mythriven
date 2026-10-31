class_name NetLobby
extends RefCounted
## Lobby messages for Net (net_session.gd): the host hears players arrive,
## pick Heroes, and come back after a run; joining players hear the roster and
## the start. A player may arrive while a run is in progress (public and
## friend games alike): the host sends them LATE_START and CoopLateJoin adds
## their Hero to the run (GAME_DESIGN.md: Online co-op / Joining in progress).
## A solo run can also go online from the pause menu (Invite friends), and the
## host can put the game on the public list or take it off at any time.


## Invite friends mid-run (owner request 10/31/2026): this solo run becomes a
## co-op game hosted here. Friends join with the code (or from the public list
## when `is_public`) straight into the run, the same as joining in progress.
## Returns true when the lobby is opening (now_online follows).
static func go_online(net: Node, is_public: bool) -> bool:
	var run: RunState = GameAuthority.run
	if net.active() or run == null or run.ended:
		return false
	net.host_game(GameAuthority.selected_hero_id, is_public)
	net.level_id = str(run.level_data.get("id", net.level_id))
	net.swift = Meta.swift
	net.omens = OmenRules.active()
	net.run_seed = run.seed_value
	return true


## The lobby for a solo run is open: the run is now this host's co-op run.
static func now_online(net: Node) -> void:
	net.state = net.State.IN_RUN
	net.roster[net.my_id]["here"] = false
	net.lobby.lock()
	net.went_online.emit()


## Host: list the game publicly, or make it friends-only (code) again.
static func set_public(net: Node, on: bool) -> void:
	if not net.is_host():
		return
	net.public_game = on
	net.lobby.set_public(on)
	net.tell_public_list()
	net.changed.emit()


static func host_message(net: Node, from: int, msg: Array) -> void:
	match int(msg[0]):
		NetMsg.HELLO:
			if msg.size() < 3 or str(msg[1]) != net.version():
				net.send(from, [NetMsg.WRONG_VERSION, net.version()])
				net.lobby.kick(from)
				return
			var in_progress: bool = net.in_run() and GameAuthority.run != null and not GameAuthority.run.ended
			# Someone arriving while the host is on the results screen waits in the lobby.
			var name: String = LeaderboardEntry.clean_name(str(msg[3])) if msg.size() >= 4 else ""
			net.roster[from] = {"hero": net.valid_hero(str(msg[2])), "here": not in_progress, "name": name}
			if in_progress and net.roster[from]["hero"] != "":
				net.send(from, [NetMsg.LATE_START, net.run_seed, net.level_id, net.swift, Array(net.omens), net.roster])
				net.late_joined.emit(from)
			net.broadcast_roster()
		NetMsg.HERO:
			if net.roster.has(from) and msg.size() >= 2:
				net.roster[from]["hero"] = net.valid_hero(str(msg[1]))
				net.broadcast_roster()
		NetMsg.BACK:
			if net.roster.has(from):
				net.roster[from]["here"] = true
				net.broadcast_roster()


static func client_message(net: Node, msg: Array) -> void:
	match int(msg[0]):
		NetMsg.ROSTER:
			if msg.size() >= 4 and msg[1] is Dictionary:
				net.roster = msg[1]
				net.level_id = str(msg[2])
				net.swift = bool(msg[3])
		NetMsg.START, NetMsg.LATE_START:
			if msg.size() >= 6 and msg[5] is Dictionary and not net.in_run():
				net.run_seed = int(msg[1])
				net.level_id = str(msg[2])
				net.swift = bool(msg[3])
				net.omens = PackedStringArray(msg[4])
				net.roster = msg[5]
				net.joined_late = int(msg[0]) == NetMsg.LATE_START
				net.begin_run()
		NetMsg.WRONG_VERSION:
			net._close("UI_COOP_WRONG_VERSION")
