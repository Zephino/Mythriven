class_name TrialPlayers
extends RefCounted
## Who takes part in a god trial (GodTrial). In co-op every standing player
## must be in the ring before it starts (owner decision 10/30/2026).


## Everyone who could take part: standing players (not downed, not Shades).
static func standing() -> Array[Player]:
	var out: Array[Player] = []
	for player: Player in GameAuthority.players:
		if is_standing(player):
			out.append(player)
	return out


static func is_standing(player: Player) -> bool:
	return is_instance_valid(player) and player.alive and not player.downed and not player.shade


## The nearest standing player among `players` (null when none is).
static func nearest(players: Array[Player], from: Vector2) -> Player:
	var best: Player = null
	for player: Player in players:
		if is_standing(player) and (best == null or player.position.distance_to(from) < best.position.distance_to(from)):
			best = player
	return best


## True while at least one standing player among `players` is inside the ring.
static func any_inside(players: Array[Player], center: Vector2, radius: float) -> bool:
	for player: Player in players:
		if is_standing(player) and player.position.distance_to(center) <= radius:
			return true
	return false
