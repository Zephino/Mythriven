class_name PitChampionBoss
extends BossController
## The Pit Champion, 20:00 (docs/PACK_8_PLAN.md: Ghorvast, the game's own invented realm). Signature, rage: every blow
## he takes fills his rage. When it is full he goes berserk for a few seconds (faster, hitting twice as hard), and then
## he is spent: he can't act and takes double damage.

var rage: float = 0.0
var berserk_s: float = 0.0
var spent_s: float = 0.0
var rampages: int = 0
var _base_speed: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	if spent_s > 0.0:
		return amount * float(_sig().get("spent_damage_taken", 2.0))
	if berserk_s <= 0.0 and is_alive():
		rage += amount / maxf(GameAuthority.enemies.max_hp[slot] * float(_sig().get("rage_fraction", 0.08)), 1.0)
		if rage >= 1.0:
			go_berserk()
	return amount


func _damage_mult() -> float:
	return super._damage_mult() * (float(_sig().get("berserk_damage_mult", 2.0)) if berserk_s > 0.0 else 1.0)


func go_berserk() -> void:
	rampages += 1
	rage = 0.0
	berserk_s = float(_sig().get("berserk_s", 5.0))
	if _base_speed < 0.0:
		data = data.duplicate(true)
		_base_speed = float(data.get("move_speed", 40.0))
	data["move_speed"] = _base_speed * float(_sig().get("berserk_speed_mult", 1.8))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null and rampages == 1:
		banner.show_text(tr("BOSS_PIT_CHAMPION_BERSERK"))


func signature(delta: float) -> void:
	if not is_alive():
		return
	if berserk_s > 0.0:
		berserk_s -= delta
		if berserk_s <= 0.0:
			data["move_speed"] = _base_speed
			spent_s = float(_sig().get("spent_s", 3.0))
		return
	if spent_s > 0.0:
		spent_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(spent_s, 0.2))


## A rage bar over his head, red when he is berserk.
func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	var at: Vector2 = position_now() - global_position + Vector2(-16, -GameAuthority.enemies.radius[slot] - 26.0)
	draw_rect(Rect2(at, Vector2(32, 3)), Color(0, 0, 0, 0.5))
	var fill: float = 1.0 if berserk_s > 0.0 else clampf(rage, 0.0, 1.0)
	draw_rect(Rect2(at, Vector2(32 * fill, 3)), Color(0.9, 0.2, 0.15) if berserk_s > 0.0 else Color(0.9, 0.6, 0.2))
