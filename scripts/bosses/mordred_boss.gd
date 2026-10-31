class_name MordredBoss
extends BossController
## Mordred, 20:00 (docs/PACK_2_PLAN.md: Avalon's Shadow). Signature, the betrayer's host: at the start and each phase
## his black knights ride out round him, and while any of them live he takes half damage. He has words for King
## Arthur. Source: Malory, Le Morte d'Arthur, books 20-21.

## His knights' slots.
var host: Array = []
var _spoken: bool = false


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(_index: int) -> void:
	_call_host()


func signature(_delta: float) -> void:
	if host.is_empty() and phase_index == 0 and not _spoken:
		_call_host()
	if not _spoken:
		_spoken = true
		for player: Player in GameAuthority.players:
			if str(player.hero.get("id", "")) == "king_arthur":
				var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
				if banner != null:
					banner.show_text(tr("BOSS_MORDRED_ARTHUR"))


## Camlann secret: as King Arthur, defeat him (Malory, book 21).
func secret_earned() -> String:
	var player: Player = GameAuthority.local_player()
	if player == null or str(player.hero.get("id", "")) != "king_arthur":
		return ""
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_MORDRED_CAMLANN"))
	return "camlann"


func _call_host() -> void:
	if slot == -1:
		return
	var at: Vector2 = position_now()
	for k: int in int(_sig().get("knights", 5)):
		var knight: int = GameAuthority.spawn_enemy("black_knight", at + Vector2.from_angle(TAU * k / 5.0) * 50.0)
		if knight != -1:
			host.append(knight)


## True while any of his knights still rides.
func host_alive() -> bool:
	var enemies: EnemyManager = GameAuthority.enemies
	for knight: Variant in host.duplicate():
		if enemies.active[int(knight)] != 0 and str(enemies.type_of(int(knight)).get("id", "")) == "black_knight":
			return true
		host.erase(knight)
	return false


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	var mult: float = float(_sig().get("damage_while_host", 0.5)) if host_alive() else 1.0
	return super.modify_hit(amount * mult, attacker, push)


## While his host lives, a dark ring of their loyalty guards him, and a line to each knight.
func _draw() -> void:
	super._draw()
	if not is_alive() or not host_alive():
		return
	var at: Vector2 = position_now() - global_position
	draw_arc(at, GameAuthority.enemies.radius[slot] + 6.0, 0.0, TAU, 24, Color(0.45, 0.1, 0.12, 0.8), 2.5)
	for knight: Variant in host:
		draw_line(at, GameAuthority.enemies.positions[int(knight)] - global_position, Color(0.45, 0.1, 0.12, 0.35), 1.0)
