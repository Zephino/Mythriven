extends HeroKit
## Minamoto no Yoshitsune (docs/PACK_3_PLAN.md: the Land of Legends). Legend Trait, the eight-boat leap: he holds
## `charges` leaps (2); a blow that would land is dodged instead, and he springs leap_px away from it. Each leap comes
## back after recharge_s. As at Dan-no-ura, where he leapt from boat to boat across eight boats (the Tale of the Heike).
## Passive, trained by the tengu of Mount Kurama (the Gikeiki): +15% Move Speed.

var charges: int = 0
var _recharge: float = 0.0
var _flash_s: float = 0.0
var _leap_from := Vector2.ZERO


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	charges = int(trait_data().get("charges", 2))
	player.stats.add_bonus("move_speed", float(passive_data().get("move_speed_pct", 0.0)) / 100.0)


func incoming_damage_at(amount: float, from: Vector2) -> float:
	if charges <= 0 or amount <= 0.0:
		return amount
	charges -= 1
	if _recharge <= 0.0:
		_recharge = float(trait_data().get("recharge_s", 5.0))
	var away: Vector2 = (player.position - from).normalized() if from != Vector2.INF and from != player.position else player.facing.normalized() * -1.0
	_leap_from = player.position
	GameAuthority.push_player(player, away * float(trait_data().get("leap_px", 48.0)))
	_flash_s = 0.3
	return 0.0


func _process(delta: float) -> void:
	_flash_s = maxf(_flash_s - delta, 0.0)
	var most: int = int(trait_data().get("charges", 2))
	if charges < most:
		_recharge -= delta
		if _recharge <= 0.0:
			charges += 1
			_recharge = float(trait_data().get("recharge_s", 5.0)) if charges < most else 0.0
	queue_redraw()


func hud_text() -> String:
	return tr("HUD_EIGHT_BOAT_LEAP") % charges


## The leap: a streak from where he stood.
func _draw() -> void:
	if _flash_s > 0.0:
		draw_line(_leap_from - player.position, Vector2.ZERO, Color(1, 1, 1, _flash_s / 0.3), 3.0)
