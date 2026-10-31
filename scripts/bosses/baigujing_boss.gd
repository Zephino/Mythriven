class_name BaigujingBoss
extends BossController
## Baigujing, the White Bone Demon, 20:00 (docs/BONUS_LEVELS_PLAN.md: the Realm of the Ten Suns). Signature, three
## disguises: in turn she takes the shape of a village girl, an old woman and an old man, and while disguised every
## blow heals her instead; between disguises her true shape of white bones shows for a few seconds, and only then can
## she be hurt. Source: Journey to the West, chapter 27.

const FORMS := ["girl", "old_woman", "old_man"]

var disguise: int = 0
var disguised: bool = true
var _left: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "baigujing_" + str(FORMS[disguise]) if disguised else "baigujing"


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if not disguised or broken_s > 0.0:
		return amount
	# The wrong target: the blow heals her.
	var enemies: EnemyManager = GameAuthority.enemies
	enemies.hp[slot] = minf(enemies.hp[slot] + amount * float(_sig().get("heal_fraction", 0.5)), enemies.max_hp[slot])
	return 0.0


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _left < 0.0:
		_left = float(_sig().get("disguised_s", 5.0))
	_left -= delta
	if _left > 0.0:
		return
	disguised = not disguised
	if disguised:
		disguise = (disguise + 1) % FORMS.size()
		_left = float(_sig().get("disguised_s", 5.0))
	else:
		_left = float(_sig().get("true_s", 3.5))
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_BAIGUJING_TRUE"))


func _draw() -> void:
	super._draw()
	if is_alive() and not disguised:
		draw_arc(position_now() - global_position, GameAuthority.enemies.radius[slot] + 8.0, 0.0, TAU, 24, Color(1, 1, 1, 0.7), 2.0)
