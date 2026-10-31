class_name TiamatBoss
extends BossController
## Tiamat, 30:00 (docs/PACK_2_PLAN.md: the Land Between the Rivers; an original design). Signature, her brood and her
## waters: every few seconds she brings forth more of the monsters she made (the eleven of Enuma Elish), and waves of
## the salt sea roll across the arena, hurting and pushing any Hero they reach. Source: Enuma Elish, Tablets I-IV.

## Rolling waves: {"from": Vector2 (a point on the starting line), "dir": Vector2, "gone": float, "hit": {}}.
var waves: Array = []
var _brood_in: float = 3.0
var _wave_in: float = 4.0

const WAVE_TRAVEL_PX := 720.0
const WAVE_LENGTH_PX := 700.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_brood_in -= delta
	if _brood_in <= 0.0:
		_brood_in = float(_sig().get("brood_every_s", 9.0))
		_bring_forth()
	_wave_in -= delta
	if _wave_in <= 0.0:
		_wave_in = float(_sig().get("wave_every_s", 7.0))
		_raise_wave()
	_roll(delta)


func _bring_forth() -> void:
	var brood: Array = _sig().get("brood", ["river_serpent"])
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var at: Vector2 = position_now()
	for k: int in int(_sig().get("brood_count", 5)):
		GameAuthority.spawn_enemy(str(brood[rng.randi() % brood.size()]), at + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(40.0, 80.0))


func _raise_wave() -> void:
	var center: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
	var dir := Vector2.from_angle(GameAuthority.run.rng.combat.randf() * TAU)
	waves.append({"from": center - dir * WAVE_TRAVEL_PX * 0.5, "dir": dir, "gone": 0.0, "hit": {}})


## A wave's front line right now.
func wave_front(wave: Dictionary) -> Vector2:
	return Vector2(wave["from"]) + Vector2(wave["dir"]) * float(wave["gone"])


func _roll(delta: float) -> void:
	var width: float = float(_sig().get("wave_width_px", 60.0))
	for i: int in range(waves.size() - 1, -1, -1):
		var wave: Dictionary = waves[i]
		wave["gone"] = float(wave["gone"]) + float(_sig().get("wave_speed_px_s", 140.0)) * delta
		if float(wave["gone"]) > WAVE_TRAVEL_PX:
			waves.remove_at(i)
			continue
		var front: Vector2 = wave_front(wave)
		var dir: Vector2 = wave["dir"]
		for player: Player in GameAuthority.players:
			var along: float = (player.position - front).dot(dir)
			var across: float = absf((player.position - front).dot(dir.orthogonal()))
			if along <= 0.0 and along > -width and across <= WAVE_LENGTH_PX * 0.5:
				player.position += dir * float(_sig().get("wave_push_px_s", 120.0)) * delta
				if not (wave["hit"] as Dictionary).has(player.player_id) and player.alive:
					wave["hit"][player.player_id] = true
					GameAuthority.damage_player(player, float(_sig().get("wave_damage", 10.0)), "boss_tiamat", front)


## The waves: a band of dark salt water with a foaming crest.
func _draw() -> void:
	var width: float = float(_sig().get("wave_width_px", 60.0))
	for wave: Dictionary in waves:
		var dir: Vector2 = wave["dir"]
		var front: Vector2 = wave_front(wave) - global_position
		var side: Vector2 = dir.orthogonal() * WAVE_LENGTH_PX * 0.5
		var fade: float = clampf((WAVE_TRAVEL_PX - float(wave["gone"])) / 80.0, 0.0, 1.0)
		draw_colored_polygon(PackedVector2Array([front - side, front + side, front + side - dir * width, front - side - dir * width]),
				Color(0.1, 0.3, 0.35, 0.45 * fade))
		draw_line(front - side, front + side, Color(0.85, 0.95, 0.95, 0.8 * fade), 3.0)
	super._draw()
