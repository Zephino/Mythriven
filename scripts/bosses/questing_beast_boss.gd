class_name QuestingBeastBoss
extends BossController
## The Questing Beast, 10:00 (docs/PACK_8_PLAN.md: Logres). Signature, the questing: from its belly comes a noise like
## thirty couple of hounds questing; every so often it bays, and the noise drives every Hero near it back. Source:
## Thomas Malory, Le Morte d'Arthur (1485), 1.19-20 (the beast King Pellinore hunted all his life).

var bays: int = 0
var push_left: float = 0.0
var _bay_in: float = 4.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	if push_left > 0.0:
		push_left -= delta
		var reach: float = float(_sig().get("bay_radius_px", 140.0))
		for player: Player in GameAuthority.players:
			var away: Vector2 = player.position - position_now()
			if player.alive and away.length() <= reach and not (player.kit != null and player.kit.controls_movement()):
				player.position += (away.normalized() if away.length() > 0.1 else Vector2.RIGHT) * float(_sig().get("push_px_s", 260.0)) * delta
	_bay_in -= delta
	if _bay_in <= 0.0:
		_bay_in = float(_sig().get("bay_every_s", 7.0))
		bay()


func bay() -> void:
	bays += 1
	push_left = float(_sig().get("push_s", 0.4))
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(position_now(), float(_sig().get("bay_radius_px", 140.0)), Color(0.9, 0.85, 0.6), true)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and bays == 1:
		banner.show_text(tr("BOSS_QUESTING_BEAST_BAYS"))
