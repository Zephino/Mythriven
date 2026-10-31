class_name GarmrBoss
extends BossController
## Garmr, 20:00 (docs/PACK_4_PLAN.md: Niflheim). Signature, baying: every few seconds he bays, hurting anyone close,
## and the restless dead come at the sound. Source: Voluspa 44 (Garm bays loudly before Gnipahellir).

var _howl_in: float = 4.0
var howls: int = 0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	_howl_in -= delta
	if _howl_in <= 0.0:
		_howl_in = float(_sig().get("howl_every_s", 8.0))
		howl()


func howl() -> void:
	howls += 1
	var at: Vector2 = position_now()
	var reach: float = float(_sig().get("howl_radius_px", 110.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= reach:
			GameAuthority.damage_player(player, float(_sig().get("howl_damage", 8.0)), "garmr", at)
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	for _k: int in int(_sig().get("howl_adds", 5)):
		GameAuthority.spawn_enemy(str(_sig().get("add", "draugr")), at + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(120.0, 200.0))
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, reach, Color(0.7, 0.75, 0.85), true)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and howls == 1:
		banner.show_text(tr("BOSS_GARMR_BAYS"))
