class_name CoopRevives
extends Node
## Co-op revives and the Wandering Shade (GAME_DESIGN.md: Online co-op /
## Fairness rules). At 0 HP a player is downed and bleeds out over 20 s; an
## ally standing beside them for 3 s (then 5 s) revives them at 30% HP. Each
## player has 2 revives a run. A player who bleeds out, or goes down with no
## revives left, becomes a Wandering Shade: a ghost that still moves, collects
## XP and gold for the team, and gives allies nearby +10% god charge, but
## can't die or deal damage. The run ends when no one is left fighting.
## Runs on the host (the host's game decides everything in co-op).


static func go_down(player: Player) -> void:
	if player.revives_used >= Data.cfg_int("coop.revives_per_player"):
		become_shade(player)
		return
	player.downed = true
	player.bleed_s = Data.cfg_float("coop.bleed_out_s")
	player.revive_progress_s = 0.0
	player.queue_redraw()


## Seconds an ally must stand beside this player to revive them (3 s, then 5 s).
static func revive_time(player: Player) -> float:
	var times: Array = Data.cfg("coop.revive_stand_s")
	return float(times[clampi(player.revives_used, 0, times.size() - 1)])


static func revive(player: Player) -> void:
	player.downed = false
	player.alive = true
	player.revives_used += 1
	player.revive_progress_s = 0.0
	player.hp = player.max_hp * Data.cfg_float("coop.revive_hp_pct")
	player.cause_of_death = ""
	player.queue_redraw()


static func become_shade(player: Player) -> void:
	player.downed = false
	player.shade = true
	player.alive = false
	player.hp = 0.0
	player.revive_progress_s = 0.0
	player.queue_redraw()


## +10% god charge for a fighting player with a Shade nearby (1.0 otherwise).
static func shade_charge_mult(player: Player) -> float:
	if not player.alive:
		return 1.0
	var reach: float = Data.cfg_float("coop.shade_aura_px")
	for other: Player in GameAuthority.players:
		if other.shade and other.position.distance_to(player.position) <= reach:
			return 1.0 + Data.cfg_float("coop.shade_god_charge_bonus")
	return 1.0


func _process(delta: float) -> void:
	if GameAuthority.run == null or GameAuthority.run.ended or not GameAuthority.decides():
		return
	var reach: float = Data.cfg_float("coop.revive_reach_px")
	for player: Player in GameAuthority.players:
		if not player.downed:
			continue
		player.bleed_s -= delta
		var helped: bool = false
		for ally: Player in GameAuthority.players:
			if ally != player and ally.alive and ally.position.distance_to(player.position) <= reach + ally.body_radius:
				helped = true
				break
		player.revive_progress_s = player.revive_progress_s + delta if helped else 0.0
		player.queue_redraw()
		if player.revive_progress_s >= revive_time(player):
			revive(player)
		elif player.bleed_s <= 0.0:
			become_shade(player)
			GameAuthority.check_run_over()
