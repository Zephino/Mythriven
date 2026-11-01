class_name AtlasKingBoss
extends BossController
## Atlas, 30:00 (docs/PACK_11_PLAN.md: Atlantis; the design's boss: Plato's first king, not the Titan). Signature, the
## three walls: he stands behind three walls (brass, tin, orichalcum), and every blow strikes the outermost wall still
## standing until it falls; only then can he be hurt. Some time after the last falls they all rise again. In his last
## phase the island sinks: the ground falls in on marked spots under the Heroes. Sources: Plato, Critias 114a, 116a-c;
## Timaeus 25c-d.

const WALLS := ["brass", "tin", "orichalcum"]
const WALL_COLORS := [Color(0.8, 0.6, 0.25), Color(0.75, 0.78, 0.8), Color(1.0, 0.55, 0.3)]

## Each wall's strength left (0 = fallen).
var walls: Array[float] = [0.0, 0.0, 0.0]
var walls_broken: int = 0
var sinking: bool = false
var marks: Array = []
var _rebuild_in: float = 0.0
var _sink_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index == 0:
		raise_walls()
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_ATLAS_KING_WALLS"))
	elif index >= 2 and not sinking:
		sinking = true
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_ATLAS_KING_SINKING"))


func raise_walls() -> void:
	var strength: float = GameAuthority.enemies.max_hp[slot] * float(_sig().get("wall_hp_fraction", 0.05)) if is_alive() else 100.0
	for i: int in walls.size():
		walls[i] = strength


func walls_up() -> int:
	var n: int = 0
	for w: float in walls:
		if w > 0.0:
			n += 1
	return n


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	for i: int in walls.size():
		if walls[i] > 0.0:
			walls[i] -= amount
			if walls[i] <= 0.0:
				walls[i] = 0.0
				walls_broken += 1
				if walls_up() == 0:
					_rebuild_in = float(_sig().get("rebuild_s", 20.0))
			return 0.0
	return amount


func signature(delta: float) -> void:
	for i: int in range(marks.size() - 1, -1, -1):
		marks[i]["left"] = float(marks[i]["left"]) - delta
		if float(marks[i]["left"]) <= 0.0:
			_fall_in(marks[i]["pos"])
			marks.remove_at(i)
	if not is_alive():
		return
	if walls_up() == 0 and _rebuild_in > 0.0:
		_rebuild_in -= delta
		if _rebuild_in <= 0.0:
			raise_walls()
	if sinking:
		_sink_in -= delta
		if _sink_in <= 0.0:
			_sink_in = float(_sig().get("sink_every_s", 1.5))
			for player: Player in GameAuthority.players:
				if player.alive:
					marks.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 1.2))})


func _fall_in(at: Vector2) -> void:
	var reach: float = float(_sig().get("sink_radius_px", 30.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			GameAuthority.damage_player(player, float(_sig().get("sink_damage", 14.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.2, 0.4, 0.7), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for m: Dictionary in marks:
		m["pos"] = Vector2(m["pos"]) - shift_px


## The walls still standing, as rings round him (brass outside, orichalcum inside), and the marked spots that will fall.
func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	for m: Dictionary in marks:
		draw_arc(Vector2(m["pos"]) - global_position, float(_sig().get("sink_radius_px", 30.0)), 0.0, TAU, 20, area_color, 1.5)
	super._draw()
	if is_alive():
		var me: Vector2 = position_now() - global_position
		var r: float = float(data.get("radius", 20.0))
		for i: int in walls.size():
			if walls[i] > 0.0:
				draw_arc(me, r + 18.0 - i * 6.0, 0.0, TAU, 32, WALL_COLORS[i], 3.0)
