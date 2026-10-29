class_name SurtrBoss
extends BossController
## Surtr, 30:00 (GAME_DESIGN.md: Midgard's Edge bosses). Signature, Ragnarök:
## the arena's edge burns inward over the fight; standing in the fire hurts.
## Phases: flaming-sword slams → charges that leave fire trails and the cast
## "Flames of Muspelheim" → burning-sword sweeps with safe gaps.

var _fight_s: float = 0.0
var _burn_tick: float = 0.0


## How far from the arena's center the fire has reached.
func burn_radius() -> float:
	var bosses: BossManager = GameAuthority.bosses
	if bosses == null:
		return INF
	var sig: Dictionary = data.get("signature", {})
	var progress: float = clampf(_fight_s / maxf(float(sig.get("burn_s", 150.0)), 1.0), 0.0, 1.0)
	return bosses.arena_radius * lerpf(1.0, float(sig.get("min_fraction", 0.45)), progress)


func signature(delta: float) -> void:
	_fight_s += delta
	_burn_tick -= delta
	if _burn_tick > 0.0:
		return
	_burn_tick = 0.5
	var bosses: BossManager = GameAuthority.bosses
	var sig: Dictionary = data.get("signature", {})
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(bosses.arena_center) > burn_radius():
			GameAuthority.damage_player(player, float(sig.get("burn_damage", 6.0)) * _damage_mult(), str(data.get("id", "")))


func _draw() -> void:
	super._draw()
	var bosses: BossManager = GameAuthority.bosses
	if not is_alive() or bosses == null:
		return
	var center: Vector2 = bosses.arena_center - global_position
	var radius: float = burn_radius()
	var color := Color.html(Data.cfg_string("bosses.fire_telegraph_color"))
	draw_arc(center, radius, 0.0, TAU, 96, color, 4.0)
	draw_arc(center, (radius + bosses.arena_radius) * 0.5, 0.0, TAU, 96, Color(color, 0.35), maxf(bosses.arena_radius - radius, 1.0))
