class_name NetLobby
extends RefCounted
## Lobby messages for Net (net_session.gd): the host hears players arrive,
## pick Heroes, and come back after a run; joining players hear the roster and
## the start. In a public game a player may arrive while a run is in progress:
## the host sends them LATE_START and CoopHost adds their Hero to the run
## (GAME_DESIGN.md: Online co-op / Public games).


static func host_message(net: Node, from: int, msg: Array) -> void:
	match int(msg[0]):
		NetMsg.HELLO:
			if msg.size() < 3 or str(msg[1]) != net.version():
				net.send(from, [NetMsg.WRONG_VERSION, net.version()])
				net.lobby.kick(from)
				return
			var in_progress: bool = net.in_run() and GameAuthority.run != null and not GameAuthority.run.ended
			# Someone arriving while the host is on the results screen waits in the lobby.
			net.roster[from] = {"hero": net.valid_hero(str(msg[2])), "here": not in_progress}
			if in_progress and net.public_game and net.roster[from]["hero"] != "":
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
