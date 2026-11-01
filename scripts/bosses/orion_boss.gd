class_name OrionBoss
extends BossController
## Orion, 30:00 (docs/PACK_10_PLAN.md: the Empyrean; the design's boss). Signature, the blind hunter: he calls his two
## hounds to him, and every so often he is struck blind: for a few seconds he lunges about at random and takes more
## damage, until his sight returns. Sources: Apollodorus 1.4.3-5 (Orion blinded by Oenopion, healed by the rays of the
## rising sun); Aratus, Phaenomena; Hyginus 2.34-35 (Orion and his dogs among the stars).

var blind_s: float = 0.0
var blindings: int = 0
var lunge_dir := Vector2.RIGHT
var _blind_in: float = 10.0
var _hounds_in: float = 3.0
var _lunge_in: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("blind_damage_taken", 1.5)) if blind_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	_hounds_in -= delta
	if _hounds_in <= 0.0:
		_hounds_in = float(_sig().get("hounds_every_s", 12.0))
		var rng: RandomNumberGenerator = GameAuthority.run.rng.combat
		for _k: int in 2:
			GameAuthority.spawn_enemy(str(_sig().get("hound", "star_hound")), position_now() + Vector2.from_angle(rng.randf() * TAU) * 50.0)
	var enemies: EnemyManager = GameAuthority.enemies
	if blind_s > 0.0:
		blind_s -= delta
		_lunge_in -= delta
		if _lunge_in <= 0.0:
			_lunge_in = float(_sig().get("lunge_every_s", 0.8))
			lunge_dir = Vector2.from_angle(GameAuthority.run.rng.combat.randf() * TAU)
		enemies.positions[slot] += lunge_dir * float(_sig().get("lunge_px_s", 160.0)) * delta
		return
	_blind_in -= delta
	if _blind_in <= 0.0:
		_blind_in = float(_sig().get("blind_every_s", 14.0))
		go_blind()


func go_blind() -> void:
	blindings += 1
	blind_s = float(_sig().get("blind_s", 5.0))
	_lunge_in = 0.0
	cast = {}
	if patterns != null:
		patterns.clear()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and blindings == 1:
		banner.show_text(tr("BOSS_ORION_BLIND"))
