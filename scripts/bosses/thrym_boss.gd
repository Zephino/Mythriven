class_name ThrymBoss
extends BossController
## Thrym, 20:00 (docs/PACK_2_PLAN.md: Jotunheim). Signature, the stolen weapon: as he stole Thor's hammer, every so
## often he takes one of a Hero's weapons for stolen_s and drops it in his golden hoard nearby; reach the hoard to
## take it back early. Everything stolen comes back when he falls. Source: Thrymskvida (Poetic Edda).

## Each {"player": id, "weapon": WeaponInstance, "left": seconds, "at": Vector2 (the hoard)}.
var stolen: Array = []
var _steal_in: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if _steal_in < 0.0:
		_steal_in = float(_sig().get("first_s", 8.0))
	_steal_in -= delta
	if _steal_in <= 0.0 and target != null and target.alive and target.weapons.size() > 0:
		_steal_in = float(_sig().get("every_s", 24.0))
		_steal(target)
	for entry: Dictionary in stolen.duplicate():
		entry["left"] = float(entry["left"]) - delta
		var player: Player = GameAuthority.player_by_id(int(entry["player"]))
		var reached: bool = player != null and player.position.distance_to(entry["at"]) <= float(_sig().get("hoard_radius_px", 18.0)) + player.body_radius
		if float(entry["left"]) <= 0.0 or reached:
			_give_back(entry)


func _steal(player: Player) -> void:
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
	var weapon: WeaponInstance = player.weapons[rng.randi_range(0, player.weapons.size() - 1)]
	player.weapons.erase(weapon)
	var at: Vector2 = player.position + Vector2.from_angle(rng.randf() * TAU) * float(_sig().get("hoard_distance_px", 170.0))
	stolen.append({"player": player.player_id, "weapon": weapon, "left": float(_sig().get("stolen_s", 20.0)), "at": at})
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_THRYM_STEALS") % tr(weapon.name_key()))


func _give_back(entry: Dictionary) -> void:
	stolen.erase(entry)
	var player: Player = GameAuthority.player_by_id(int(entry["player"]))
	if player != null and is_instance_valid(player):
		player.weapons.append(entry["weapon"])


## Everything stolen comes back when he falls (or the fight ends).
func _exit_tree() -> void:
	for entry: Dictionary in stolen.duplicate():
		_give_back(entry)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for entry: Dictionary in stolen:
		entry["at"] = Vector2(entry["at"]) - shift_px


## His hoard: a heap of gold with the stolen weapon's picture on top, glinting.
func _draw() -> void:
	super._draw()
	var t: float = Time.get_ticks_msec() * 0.004
	for entry: Dictionary in stolen:
		var at: Vector2 = Vector2(entry["at"]) - global_position
		draw_set_transform(at, 0.0, Vector2(1.0, 0.55))
		draw_circle(Vector2.ZERO, 14.0, Color(0.85, 0.65, 0.2))
		draw_circle(Vector2(0, -3), 9.0, Color(0.95, 0.8, 0.35))
		draw_set_transform(Vector2.ZERO)
		var art: Dictionary = PixelArt.weapon_art(entry["weapon"])
		if not art.is_empty():
			var texture: ImageTexture = PixelArt.frame(art, false, 0.0)
			draw_texture(texture, at - texture.get_size() * 0.5 + Vector2(0, -10))
		draw_circle(at + Vector2(sin(t) * 8.0, -6.0), 1.5, Color(1, 1, 0.8, 0.5 + 0.5 * sin(t * 3.0)))
		draw_arc(at, 20.0, 0.0, TAU * clampf(float(entry["left"]) / float(_sig().get("stolen_s", 20.0)), 0.0, 1.0), 24,
				Color(1.0, 0.85, 0.3, 0.8), 2.0)
