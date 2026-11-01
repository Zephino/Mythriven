class_name AeetesBullsBoss
extends BossController
## The Bulls of Aeetes, 10:00 (docs/PACK_9_PLAN.md: Lemnos). Signature, fiery breath: every few seconds they breathe a
## cone of fire in front of them, and the ground there keeps burning for a while (Burn). Source: Apollodorus, Library
## 1.9.23 (the bronze-footed bulls that breathed fire, Hephaestus' gift to Aeetes, which Jason had to yoke).

## Burning ground: {"pos": Vector2, "left": float}.
var flames: Array = []
var breaths: int = 0
## Medea's Ointment secret: their fire never burns the local Hero.
var burned_local: bool = false
var _breath_in: float = 4.0
var _tick: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	for i: int in range(flames.size() - 1, -1, -1):
		flames[i]["left"] = float(flames[i]["left"]) - delta
		if float(flames[i]["left"]) <= 0.0:
			flames.remove_at(i)
	_tick -= delta
	if _tick <= 0.0:
		_tick = 0.5
		var reach: float = float(_sig().get("flame_radius_px", 18.0))
		for player: Player in GameAuthority.players:
			for f: Dictionary in flames:
				if player.alive and player.position.distance_to(f["pos"]) <= reach + player.body_radius:
					GameAuthority.damage_player(player, float(_sig().get("flame_damage", 4.0)), str(data.get("id", "")), f["pos"])
					player.statuses.apply("burn")
					if player.is_local:
						burned_local = true
					break
	if not is_alive():
		return
	_breath_in -= delta
	if _breath_in <= 0.0:
		_breath_in = float(_sig().get("breath_every_s", 6.0))
		breathe()


## A cone of flame toward the nearest Hero.
func breathe() -> void:
	breaths += 1
	var near: Player = GameAuthority.enemies.nearest_player(position_now())
	var dir: Vector2 = (near.position - position_now()).normalized() if near != null else facing
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	var length: float = float(_sig().get("cone_px", 180.0))
	for k: int in 18:
		var t: float = float(k % 6 + 1) / 6.0
		var side: float = (k / 6 - 1) * 0.35 * t
		flames.append({"pos": position_now() + dir.rotated(side) * length * t, "left": float(_sig().get("flame_s", 4.0))})


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the flames move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for f: Dictionary in flames:
		f["pos"] = Vector2(f["pos"]) - shift_px


func _draw() -> void:
	var reach: float = float(_sig().get("flame_radius_px", 18.0))
	for f: Dictionary in flames:
		var at: Vector2 = Vector2(f["pos"]) - global_position
		var fade: float = clampf(float(f["left"]), 0.0, 1.0)
		draw_circle(at, reach, Color(0.95, 0.45, 0.1, 0.3 * fade))
		draw_circle(at + Vector2(0, -3), reach * 0.5, Color(1.0, 0.85, 0.3, 0.4 * fade))
	super._draw()


func secret_earned() -> String:
	return "medeas_ointment" if not burned_local else ""
