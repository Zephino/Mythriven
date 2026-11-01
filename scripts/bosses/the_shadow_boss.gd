class_name TheShadowBoss
extends BossController
## The Shadow, 30:00 (docs/PACK_12_PLAN.md: the Shadow's Court; the design's boss). Signature, the master's master: every
## so often he tears the shadows off the Heroes; each Hero's shadow rises beside them as a monster that hunts them, and
## while any stolen shadow still stands, he takes only half damage. Source: Andersen, "The Shadow" (1847: the shadow
## that became its master's master).

## The enemy slots of the stolen shadows still standing.
var shadows: Array[int] = []
var torn: int = 0
var _tear_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func standing_shadows() -> int:
	var enemies: EnemyManager = GameAuthority.enemies
	var kind: String = str(_sig().get("shadow_enemy", "living_shadow"))
	for i: int in range(shadows.size() - 1, -1, -1):
		var s: int = shadows[i]
		if enemies.active[s] == 0 or str(enemies.type_of(s)["id"]) != kind:
			shadows.remove_at(i)
	return shadows.size()


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("shielded_damage_taken", 0.5)) if standing_shadows() > 0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	_tear_in -= delta
	if _tear_in <= 0.0:
		_tear_in = float(_sig().get("tear_every_s", 14.0))
		tear_shadows()


## Each Hero's shadow is torn off and rises up beside them.
func tear_shadows() -> void:
	var off: float = float(_sig().get("shadow_offset_px", 30.0))
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		var s: int = GameAuthority.spawn_enemy(str(_sig().get("shadow_enemy", "living_shadow")), player.position + Vector2(off, off * 0.5))
		if s != -1:
			shadows.append(s)
			torn += 1
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and torn > 0 and torn <= GameAuthority.players.size():
		banner.show_text(tr("BOSS_THE_SHADOW_TEARS"))


## A dark thread from him to each stolen shadow while it stands.
func _draw() -> void:
	if is_alive():
		var me: Vector2 = position_now() - global_position
		for s: int in shadows:
			if GameAuthority.enemies.active[s] != 0:
				draw_line(me, GameAuthority.enemies.positions[s] - global_position, Color(0.1, 0.05, 0.15, 0.5), 1.5)
	super._draw()


## Master Again secret: beaten while none of the stolen shadows still stands.
func secret_earned() -> String:
	return "master_again" if torn > 0 and standing_shadows() == 0 else ""
