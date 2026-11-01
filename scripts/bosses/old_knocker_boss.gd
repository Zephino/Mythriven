class_name OldKnockerBoss
extends BossController
## The Old Knocker, 10:00 (docs/PACK_12_PLAN.md: the Knockers' Deep). Signature, the knocking: every few seconds he knocks
## on a marked spot under each Hero, and the roof comes down there. Crusts of pasty turn up in the arena: a Hero who takes
## one leaves the knocker his share, and he is pleased (he stops knocking and lets his guard down: double damage).
## Source: Robert Hunt, Popular Romances of the West of England (1865: the knockers, and the bit of pasty left for them).

var crusts: Array[Vector2] = []
var fed: int = 0
## Heroes caught in his cave-ins.
var caved: int = 0
var pleased_s: float = 0.0
var marks: Array = []
var _knock_in: float = 2.0
var _crust_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("pleased_damage_taken", 2.0)) if pleased_s > 0.0 else amount


func signature(delta: float) -> void:
	for i: int in range(marks.size() - 1, -1, -1):
		marks[i]["left"] = float(marks[i]["left"]) - delta
		if float(marks[i]["left"]) <= 0.0:
			_cave_in(marks[i]["pos"])
			marks.remove_at(i)
	if not is_alive():
		return
	var reach: float = float(_sig().get("crust_reach_px", 14.0))
	for i: int in range(crusts.size() - 1, -1, -1):
		for player: Player in GameAuthority.players:
			if player.alive and player.position.distance_to(crusts[i]) <= reach + player.body_radius:
				crusts.remove_at(i)
				feed()
				break
	_crust_in -= delta
	if _crust_in <= 0.0:
		_crust_in = float(_sig().get("crust_every_s", 8.0))
		if crusts.size() < int(_sig().get("max_crusts", 2)):
			var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
			var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else position_now()
			crusts.append(centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60.0, 180.0))
	if pleased_s > 0.0:
		pleased_s -= delta
		return
	_knock_in -= delta
	if _knock_in <= 0.0:
		_knock_in = float(_sig().get("knock_every_s", 3.0))
		for player: Player in GameAuthority.players:
			if player.alive:
				marks.append({"pos": player.position, "left": float(_sig().get("telegraph_s", 1.2))})


## His share of the pasty: he is pleased.
func feed() -> void:
	fed += 1
	pleased_s = float(_sig().get("pleased_s", 6.0))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and fed == 1:
		banner.show_text(tr("BOSS_OLD_KNOCKER_FED"))


func _cave_in(at: Vector2) -> void:
	var reach: float = float(_sig().get("cave_radius_px", 32.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach + player.body_radius:
			caved += 1
			GameAuthority.damage_player(player, float(_sig().get("cave_damage", 13.0)), str(data.get("id", "")), at)
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.4, 0.37, 0.34), true)


## The world re-centres under the Heroes (WorldRoot.origin_shifted): the crusts and marks move with it.
func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in crusts.size():
		crusts[i] -= shift_px
	for m: Dictionary in marks:
		m["pos"] = Vector2(m["pos"]) - shift_px


## The marked spots where the roof will fall, and the crusts of pasty (golden half-moons).
func _draw() -> void:
	var area_color := Color.html(Data.cfg_string("bosses.area_telegraph_color"))
	for m: Dictionary in marks:
		draw_arc(Vector2(m["pos"]) - global_position, float(_sig().get("cave_radius_px", 32.0)), 0.0, TAU, 20, area_color, 1.5)
	for at: Vector2 in crusts:
		var p: Vector2 = at - global_position
		draw_arc(p, 6.0, PI, TAU, 12, Color(0.85, 0.65, 0.3), 4.0)
		draw_line(p + Vector2(-6, 0), p + Vector2(6, 0), Color(0.75, 0.55, 0.25), 2.0)
		draw_arc(p, 12.0, 0.0, TAU, 20, Color(1, 1, 1, 0.35), 1.0)
	super._draw()


## The Tinner's Manners secret: the knocker left his share three times, then beaten.
func secret_earned() -> String:
	return "the_tinners_manners" if fed >= 3 else ""
