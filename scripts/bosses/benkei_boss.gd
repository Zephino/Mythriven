class_name BenkeiBoss
extends BossController
## Benkei, 20:00 (docs/PACK_3_PLAN.md: the Land of Legends). Signature, the Gojo Bridge: he holds a bridge across the
## arena, and anyone off it is in the river, slowed. In his last phase comes his "standing death": he takes far less
## harm, as he died on his feet at Koromogawa, still guarding his lord. Defeating him unlocks him as a Hero (bosses.json
## unlocks_hero). Source: the Gikeiki.

var _slowed: Dictionary = {}
var _spoken: bool = false


func _sig() -> Dictionary:
	return data.get("signature", {})


## A Thousand Swords secret: as Yoshitsune, defeat him again, as on the Gojo Bridge.
func secret_earned() -> String:
	var player: Player = GameAuthority.local_player()
	return "a_thousand_swords" if player != null and str(player.hero.get("id", "")) == "yoshitsune" else ""


func standing() -> bool:
	return phase_index >= int(_sig().get("standing_phase", 2))


func _on_phase_started(index: int) -> void:
	if index == int(_sig().get("standing_phase", 2)):
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_BENKEI_STANDING"))


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("standing_damage_mult", 0.4)) if standing() else amount


## True when `at` is on the bridge (a band across the arena through its centre).
func on_bridge(at: Vector2) -> bool:
	var centre: Vector2 = GameAuthority.bosses.arena_center if GameAuthority.bosses != null else global_position
	return absf(at.y - centre.y) <= float(_sig().get("bridge_half_width_px", 46.0))


func signature(_delta: float) -> void:
	for player: Player in GameAuthority.players:
		var in_river: bool = not on_bridge(player.position) and is_alive()
		if in_river:
			player.slow_zone_mult = float(_sig().get("river_slow", 0.55))
			_slowed[player.player_id] = true
		elif _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
			_slowed.erase(player.player_id)


func _exit_tree() -> void:
	for player: Player in GameAuthority.players:
		if is_instance_valid(player) and _slowed.has(player.player_id):
			player.slow_zone_mult = 1.0
	_slowed.clear()


## The river under the bridge and the bridge's planks and rails.
func _draw() -> void:
	if is_alive() and GameAuthority.bosses != null:
		var centre: Vector2 = GameAuthority.bosses.arena_center - global_position
		var half: float = float(_sig().get("bridge_half_width_px", 46.0))
		var span: float = 520.0
		draw_rect(Rect2(centre + Vector2(-span, -260), Vector2(span * 2, 260 - half)), Color(0.2, 0.35, 0.5, 0.35))
		draw_rect(Rect2(centre + Vector2(-span, half), Vector2(span * 2, 260 - half)), Color(0.2, 0.35, 0.5, 0.35))
		draw_rect(Rect2(centre + Vector2(-span, -half), Vector2(span * 2, half * 2)), Color(0.55, 0.4, 0.25, 0.35))
		for x: int in range(int(-span), int(span), 16):
			draw_line(centre + Vector2(x, -half), centre + Vector2(x, half), Color(0.35, 0.25, 0.15, 0.4), 1.0)
		draw_line(centre + Vector2(-span, -half), centre + Vector2(span, -half), Color(0.6, 0.2, 0.15, 0.8), 3.0)
		draw_line(centre + Vector2(-span, half), centre + Vector2(span, half), Color(0.6, 0.2, 0.15, 0.8), 3.0)
	super._draw()
