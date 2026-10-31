extends HeroKit
## Tomoe Gozen. Legend Trait, Cavalry Charge: moving continuously builds
## Momentum every 0.5 s (max 10): +4% attack speed and +2% Move Speed per
## stack. Standing still 1 s loses half. At 10 stacks, every 5 s she charges:
## 1.5 s of trampling enemies she passes through and dodging the next hit.
## Passive: +10% Crit Chance.

var momentum: int = 0

var _moving_for: float = 0.0
var _still_for: float = 0.0
var _charge_ready_in: float = 0.0
var _charge_left: float = 0.0
var _dodge_ready: bool = false
var _move_bonus_applied: float = 0.0
var _trampled: Dictionary = {}


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	player.stats.add_bonus("crit", float(passive_data().get("crit_pct", 0.0)) / 100.0)
	_charge_ready_in = float(trait_data().get("charge_every_s", 5.0))


func is_charging() -> bool:
	return _charge_left > 0.0


func attack_speed_bonus() -> float:
	return float(trait_data().get("attack_speed_pct_per_stack", 0.0)) / 100.0 * momentum


func speed_mult() -> float:
	return float(trait_data().get("charge_speed_mult", 1.0)) if is_charging() else 1.0


## A charge dodges the next hit.
func incoming_damage(amount: float) -> float:
	if _dodge_ready:
		_dodge_ready = false
		return 0.0
	return amount


func hud_text() -> String:
	if is_charging():
		return tr("HUD_CHARGING")
	return tr("HUD_MOMENTUM") % [momentum, int(trait_data().get("max_stacks", 10))]


func _process(delta: float) -> void:
	if not player.alive:
		return
	var max_stacks: int = int(trait_data().get("max_stacks", 10))
	if player.velocity != Vector2.ZERO:
		_still_for = 0.0
		_moving_for += delta
		var every: float = float(trait_data().get("stack_every_s", 0.5))
		while _moving_for >= every:
			_moving_for -= every
			momentum = mini(momentum + 1, max_stacks)
	else:
		_moving_for = 0.0
		_still_for += delta
		if _still_for >= float(trait_data().get("still_s", 1.0)):
			_still_for = 0.0
			momentum = floori(momentum / 2.0)
	_apply_move_bonus()
	queue_redraw()
	if is_charging():
		_charge_left -= delta
		_trample()
	elif momentum >= max_stacks:
		_charge_ready_in -= delta
		if _charge_ready_in <= 0.0:
			_charge_ready_in = float(trait_data().get("charge_every_s", 5.0))
			_charge_left = float(trait_data().get("charge_s", 1.5))
			_dodge_ready = true
			_trampled.clear()


func _apply_move_bonus() -> void:
	var wanted: float = float(trait_data().get("move_speed_pct_per_stack", 0.0)) / 100.0 * momentum
	if is_equal_approx(wanted, _move_bonus_applied):
		return
	player.stats.add_bonus("move_speed", wanted - _move_bonus_applied)
	_move_bonus_applied = wanted
	player.refresh_stats()


## Damages each enemy she runs through once per charge.
func _trample() -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null:
		return
	for slot: int in enemies.query(player.position, player.body_radius + enemies.max_radius()):
		if _trampled.has(slot) or player.position.distance_to(enemies.positions[slot]) > player.body_radius + enemies.radius[slot]:
			continue
		_trampled[slot] = true
		var away: Vector2 = (enemies.positions[slot] - player.position).normalized()
		GameAuthority.damage_enemy(slot, float(trait_data().get("trample_damage", 0.0)), player,
				away * float(trait_data().get("trample_knockback", 0.0)), Elements.PHYSICAL)


## Dust kicked up behind her, more as her momentum builds; while charging, streaks of speed and a cloud of dust
## (owner request 10/31/2026).
func _draw() -> void:
	if not player.alive or player.velocity == Vector2.ZERO:
		return
	var dust := Color.html(Data.cfg_string("heroes.dust_color"))
	var back: Vector2 = -player.velocity.normalized()
	var feet := Vector2(0, player.body_radius)
	var t: float = Time.get_ticks_msec() * 0.001
	var puffs: int = mini(1 + momentum / 3, 4)
	for k: int in puffs:
		var age: float = fmod(t * 3.0 + k * 0.37, 1.0)
		draw_circle(feet + back * (4.0 + age * 12.0) + Vector2(0, -age * 3.0), 1.5 + age * 2.5, Color(dust, dust.a * (1.0 - age)))
	if is_charging():
		var side: Vector2 = back.orthogonal()
		for k: int in 4:
			var off: float = (k - 1.5) * 5.0
			var start: Vector2 = back * 8.0 + side * off + Vector2(0, -6)
			draw_line(start, start + back * (10.0 + fmod(t * 40.0 + k * 7.0, 8.0)), Color(1, 1, 1, 0.6), 1.0)
		draw_circle(feet + back * 10.0, 7.0, Color(dust, dust.a * 0.8))
