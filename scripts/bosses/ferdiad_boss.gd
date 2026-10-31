class_name FerdiadBoss
extends BossController
## Ferdiad, 20:00 (GAME_DESIGN.md: The Misty Isles bosses). Signature, the
## ford: the fight happens across a shallow river strip that slows anyone
## standing in it, and his horn-skin armor blocks hits from the front until
## you Guard Break him. Phases: sword and shield → stone-skin stance (blocks
## from every side) → a desperate all-out assault. Special lines if the player
## is Cú Chulainn, his foster-brother. The Ford secret: as Cú Chulainn, defeat
## him without ever leaving the river strip.

## The river strip's center line (through the arena) and whether the player left it.
var ford_center := Vector2.INF
var left_ford: bool = false


func secret_earned() -> String:
	var player: Player = GameAuthority.local_player()
	var is_cu: bool = player != null and str(player.hero.get("id", "")) == "cu_chulainn"
	return "the_ford" if is_cu and not left_ford else ""


func _sig() -> Dictionary:
	return data.get("signature", {})


func in_ford(at: Vector2) -> bool:
	return ford_center != Vector2.INF and absf(at.y - ford_center.y) <= float(_sig().get("ford_width_px", 70.0)) * 0.5


func _on_phase_started(index: int) -> void:
	if index == 0 and GameAuthority.bosses != null:
		ford_center = GameAuthority.bosses.arena_center


## Horn-skin: hits from the front barely land (from any side in the stone-skin
## stance) until a Guard Break.
func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	if broken_s > 0.0:
		return amount
	if bool(phase().get("stone_skin", false)):
		return amount * float(_sig().get("blocked_mult", 0.15))
	var at: Vector2 = position_now()
	var from := Vector2.INF
	if attacker != null and is_instance_valid(attacker):
		from = attacker.position
	elif push != Vector2.ZERO:
		from = at - push.normalized() * 10.0
	if from == Vector2.INF:
		return amount
	var front: bool = absf(facing.angle_to(from - at)) <= deg_to_rad(float(_sig().get("front_cone_deg", 140.0))) * 0.5
	return amount * (float(_sig().get("blocked_mult", 0.15)) if front else 1.0)


func signature(_delta: float) -> void:
	for player: Player in GameAuthority.players:
		var wading: bool = in_ford(player.position)
		player.slow_zone_mult = float(_sig().get("ford_slow", 0.6)) if wading else 1.0
		if player.is_local and not wading:
			left_ford = true


func _exit_tree() -> void:
	for player: Player in GameAuthority.players:
		player.slow_zone_mult = 1.0


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if ford_center != Vector2.INF:
		ford_center -= shift_px


func _draw() -> void:
	if ford_center != Vector2.INF and is_alive():
		var width: float = float(_sig().get("ford_width_px", 70.0))
		var reach: float = GameAuthority.bosses.arena_radius if GameAuthority.bosses != null else 400.0
		var center: Vector2 = ford_center - global_position
		draw_rect(Rect2(center - Vector2(reach, width * 0.5), Vector2(reach * 2.0, width)), Color.html(str(_sig().get("ford_color", "#4a7aa080"))))
		# The water runs across the ford (owner request 10/31/2026).
		var t: float = GameAuthority.run.elapsed_s if GameAuthority.run != null else 0.0
		for r: int in 18:
			var x: float = center.x - reach + fmod(r * 53.0 + t * 30.0, reach * 2.0)
			var y: float = center.y - width * 0.4 + fmod(r * 23.0, width * 0.8)
			draw_line(Vector2(x, y), Vector2(x + 10.0, y), Color(0.85, 0.95, 1.0, 0.55), 1.0)
	super._draw()
	if is_alive() and broken_s <= 0.0:
		var at: Vector2 = position_now() - global_position
		var half: float = deg_to_rad(float(_sig().get("front_cone_deg", 140.0))) * 0.5
		var color := Color.html(Data.cfg_string("gods.shrine_stone_color"))
		if bool(phase().get("stone_skin", false)):
			draw_arc(at, GameAuthority.enemies.radius[slot] + 4.0, 0.0, TAU, 20, color, 3.0)
		else:
			draw_arc(at, GameAuthority.enemies.radius[slot] + 4.0, facing.angle() - half, facing.angle() + half, 12, color, 3.0)
