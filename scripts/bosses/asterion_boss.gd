class_name AsterionBoss
extends BossController
## Asterion, the Minotaur, 30:00 (docs/PACK_8_PLAN.md: Knossos; the design's boss). Signature, the bull-man's rush: he
## charges three times in a row, goring whoever he reaches, and then stands winded for a few seconds. Blows struck up
## close hurt him more, as Theseus killed him with his fists. Sources: Apollodorus, Epitome 1.7-9; Plutarch, Theseus 19.

var rushes_left: int = 0
var rush_s: float = 0.0
var winded_s: float = 0.0
var rush_dir := Vector2.RIGHT
var flurries: int = 0
var _rush_in: float = 5.0
var _gored: Dictionary = {}


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if attacker != null and attacker.position.distance_to(position_now()) <= float(_sig().get("close_px", 60.0)):
		amount *= float(_sig().get("close_damage_mult", 1.5))
	return amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	var enemies: EnemyManager = GameAuthority.enemies
	if winded_s > 0.0:
		winded_s -= delta
		enemies.statuses.stun[slot] = maxf(enemies.statuses.stun[slot], minf(winded_s, 0.2))
		return
	if rush_s > 0.0:
		rush_s -= delta
		enemies.positions[slot] += rush_dir * float(_sig().get("rush_px_s", 420.0)) * enemies.statuses.speed_mult(slot) * delta
		for player: Player in GameAuthority.players:
			if player.alive and not _gored.has(player.player_id) and player.position.distance_to(position_now()) <= enemies.radius[slot] + player.body_radius + 6.0:
				_gored[player.player_id] = true
				GameAuthority.damage_player(player, float(_sig().get("gore_damage", 18.0)), str(data.get("id", "")), position_now())
		if rush_s <= 0.0:
			rushes_left -= 1
			if rushes_left > 0:
				_rush_in = float(_sig().get("between_s", 0.4))
			else:
				winded_s = float(_sig().get("winded_s", 3.0))
				_rush_in = float(_sig().get("flurry_every_s", 9.0))
		return
	_rush_in -= delta
	if _rush_in <= 0.0:
		if rushes_left <= 0:
			rushes_left = int(_sig().get("rushes", 3))
			flurries += 1
		start_rush()


func start_rush() -> void:
	var near: Player = GameAuthority.enemies.nearest_player(position_now())
	rush_dir = (near.position - position_now()).normalized() if near != null else Vector2.RIGHT
	if rush_dir == Vector2.ZERO:
		rush_dir = Vector2.RIGHT
	rush_s = float(_sig().get("rush_s", 0.5))
	_gored.clear()
	cast = {}
	if patterns != null:
		patterns.clear()


## Winded: his breath steaming.
func _draw() -> void:
	super._draw()
	if winded_s > 0.0 and is_alive():
		var at: Vector2 = position_now() - global_position + Vector2(0, -GameAuthority.enemies.radius[slot] - 6.0)
		for k: int in 3:
			draw_circle(at + Vector2(k * 6 - 6, -fmod(Time.get_ticks_msec() * 0.02 + k * 4, 12.0)), 2.5, Color(0.9, 0.9, 0.95, 0.5))
