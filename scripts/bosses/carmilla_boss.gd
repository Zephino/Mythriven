class_name CarmillaBoss
extends BossController
## Carmilla, 30:00 (docs/PACK_5_PLAN.md: Karnstein; the design's boss). Signature, the mist and the bite: every few
## seconds she fades into mist and appears beside a Hero, and bites whoever is close (Poison: the slow wasting of her
## victims). In her last phase she takes the shape of the "monstrous cat", sooty black, and runs faster. Source:
## J. Sheridan Le Fanu, Carmilla (1872), chapter 6 and on.

var as_cat: bool = false
var visits: int = 0
var _mist_in: float = 5.0
var _mist_s: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "carmilla_cat" if as_cat else "carmilla"


func _on_phase_started(index: int) -> void:
	if index >= 2 and not as_cat:
		as_cat = true
		data = data.duplicate(true)
		data["move_speed"] = float(data.get("move_speed", 40.0)) * float(_sig().get("cat_speed_mult", 1.6))
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_CARMILLA_CAT"))


func signature(delta: float) -> void:
	if not is_alive():
		return
	_mist_s = maxf(_mist_s - delta, 0.0)
	_mist_in -= delta
	if _mist_in <= 0.0 and target != null and is_instance_valid(target):
		_mist_in = float(_sig().get("mist_every_s", 6.0))
		appear_beside(target)


## She vanishes and comes out of the mist beside `player`, biting whoever is close.
func appear_beside(player: Player) -> void:
	visits += 1
	_mist_s = 0.6
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(position_now(), 30.0, Color(0.85, 0.85, 0.9), true)
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var at: Vector2 = player.position + Vector2.from_angle(rng.randf() * TAU) * float(_sig().get("appear_px", 40.0))
	GameAuthority.enemies.positions[slot] = at
	for other: Player in GameAuthority.players:
		if other.alive and other.position.distance_to(at) <= float(_sig().get("bite_radius_px", 50.0)) + other.body_radius:
			GameAuthority.damage_player(other, float(_sig().get("bite_damage", 10.0)), str(data.get("id", "")), at)
			other.statuses.apply("poison")
	if effects != null:
		effects.spawn_ring(at, float(_sig().get("bite_radius_px", 50.0)), Color(0.6, 0.1, 0.2), true)


func _draw() -> void:
	super._draw()
	if _mist_s > 0.0 and is_alive():
		draw_circle(position_now() - global_position, 30.0, Color(0.9, 0.9, 0.95, 0.35 * _mist_s / 0.6))
