class_name HedalTrollsBoss
extends BossController
## The Hedal Trolls, 10:00 (docs/PACK_13_PLAN.md: Dovrefjell). Signature, one eye between three: every few seconds they
## pass the eye from one to another, and for a moment none of them can see: they stumble (stunned) and take double
## damage. Source: Asbjørnsen and Moe, "The Boys Who Met the Trolls in the Hedal Woods".

var passes: int = 0
var blind_s: float = 0.0
## Which of the three holds the eye (0-2).
var holder: int = 0
var _pass_in: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("blind_damage_taken", 2.0)) if blind_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _pass_in < 0.0:
		_pass_in = float(_sig().get("pass_every_s", 5.0))
	if blind_s > 0.0:
		blind_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(blind_s, 0.2))
		if blind_s <= 0.0:
			holder = (holder + 1) % 3
		return
	_pass_in -= delta
	if _pass_in <= 0.0:
		_pass_in = float(_sig().get("pass_every_s", 5.0))
		pass_eye()


## The eye goes from hand to hand: for a moment nobody can see.
func pass_eye() -> void:
	passes += 1
	blind_s = float(_sig().get("blind_s", 1.5))
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and passes == 1:
		banner.show_text(tr("BOSS_HEDAL_TROLLS_PASS"))


## The single eye, shown over whichever head holds it, or in the air between them while it is passed.
func _draw() -> void:
	super._draw()
	if is_alive():
		var me: Vector2 = position_now() - global_position
		var at: Vector2 = me + Vector2(-18.0 + holder * 18.0, -58.0)
		if blind_s > 0.0:
			at = me + Vector2(-18.0 + (holder + 0.5) * 18.0, -66.0)
		draw_circle(at, 4.0, Color(0.95, 0.95, 0.9))
		draw_circle(at, 2.0, Color(0.15, 0.3, 0.2))
