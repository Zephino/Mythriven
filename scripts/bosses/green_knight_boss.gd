class_name GreenKnightBoss
extends BossController
## The Green Knight, 10:00 (docs/PACK_2_PLAN.md: Avalon's Shadow). Signature, the beheading game: the first time he
## is "slain" he picks up his own head by the hair and fights on, back to half health, headless and faster.
## Source: Sir Gawain and the Green Knight.

var headless: bool = false
## Hits the local Hero took after he picked up his head (the Green Girdle secret: at most 1; Gawain was only nicked).
var hits_after: int = 0


func _ready() -> void:
	super._ready()
	GameAuthority.player_damaged.connect(_on_player_damaged)


func _on_player_damaged(player: Player, _amount: float, _source_id: String) -> void:
	if headless and player.is_local and is_alive():
		hits_after += 1


func secret_earned() -> String:
	return "the_green_girdle" if headless and hits_after <= int(_sig().get("girdle_hits", 1)) else ""


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "green_knight_headless" if headless else "green_knight"


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	var enemies: EnemyManager = GameAuthority.enemies
	if not headless and slot != -1 and enemies.hp[slot] - amount <= 0.0:
		headless = true
		# He takes the blow, then stands again: the hit lands on half his health.
		enemies.hp[slot] = enemies.max_hp[slot] * float(_sig().get("return_hp_fraction", 0.5)) + amount * 2.0
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_GREEN_KNIGHT_RISES"))
	return amount


func phase() -> Dictionary:
	var current: Dictionary = super.phase()
	if headless:
		current = current.duplicate()
		current["attack_every_s"] = float(_sig().get("after_attack_every_s", 1.6))
	return current
