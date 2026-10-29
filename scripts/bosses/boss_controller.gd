class_name BossController
extends Node2D
## One boss in a fight (GAME_DESIGN.md: Bosses). Its body is a pooled enemy
## slot (so weapons, statuses, and targeting work as usual); this node moves
## it, picks attacks from the shared pattern library, and runs:
## - Phases at HP thresholds (bosses.json "phases"; 3 per boss).
## - Named casts with a cast bar ("Serpent Hair — 1.5 s").
## - The Guard gauge: damage fills it, weakness hits fill it ×2. When full:
##   Guard Break, stunned 4 s, +50% damage taken, the current cast is
##   cancelled; then the gauge refills more slowly.
## - Chill slows it; only a Guard Break stuns it.
## Each boss's signature mechanic is in a script that extends this one.

signal defeated(controller: BossController)

const GROUP := "bosses"

var data: Dictionary = {}
var slot: int = -1
var patterns: PatternRunner
var phase_index: int = 0
var guard: float = 0.0
var guard_max: float = 1.0
var broken_s: float = 0.0
## The named cast in progress: {"name_key", "cast_s", "pattern"} and seconds left.
var cast: Dictionary = {}
var cast_left: float = 0.0
var facing := Vector2.LEFT
var target: Player

var _attack_timer: float = 1.5
var _attacks: int = 0
var _charge_to := Vector2.ZERO
var _charge_delay: float = 0.0
var _charge_left: float = 0.0
var _charge_speed: float = 0.0
var _was_alive: bool = false


func _ready() -> void:
	add_to_group(GROUP)
	z_index = 4


## Puts the boss into the world at `at`. Returns false if no slot was free.
func spawn(boss_data: Dictionary, at: Vector2) -> bool:
	data = boss_data
	slot = GameAuthority.spawn_enemy(str(data.get("enemy", data.get("id", ""))), at)
	if slot == -1:
		return false
	guard_max = float((data.get("guard_gauge", {}) as Dictionary).get("max", 1000.0))
	_was_alive = true
	_on_phase_started(0)
	return true


func is_alive() -> bool:
	var enemies: EnemyManager = GameAuthority.enemies
	return slot != -1 and enemies != null and enemies.active[slot] != 0 and str(enemies.type_of(slot)["id"]) == str(data.get("enemy", ""))


func position_now() -> Vector2:
	return GameAuthority.enemies.positions[slot] if is_alive() else global_position


func hp_fraction() -> float:
	var enemies: EnemyManager = GameAuthority.enemies
	return clampf(enemies.hp[slot] / maxf(enemies.max_hp[slot], 1.0), 0.0, 1.0) if is_alive() else 0.0


func phase() -> Dictionary:
	var phases: Array = data.get("phases", [])
	return phases[clampi(phase_index, 0, phases.size() - 1)] if not phases.is_empty() else {}


## A hit on this boss: signature rules, Guard Break damage, and the Guard gauge.
func on_hit(amount: float, element_mult: float, attacker: Player, push: Vector2) -> float:
	amount = modify_hit(amount, attacker, push)
	var gauge: Dictionary = data.get("guard_gauge", {})
	if broken_s > 0.0:
		return amount * float(gauge.get("damage_taken_mult", 1.5))
	guard += amount * (Data.cfg_float("bosses.guard_weakness_fill_mult") if element_mult > 1.0 else 1.0)
	if guard >= guard_max:
		guard_break()
	return amount


## Hook for signature mechanics that change damage taken (Achilles' heel).
func modify_hit(amount: float, _attacker: Player, _push: Vector2) -> float:
	return amount


## Fills the Guard gauge by a fraction of its size (the Eye of Ra Resonance).
func add_guard_fraction(fraction: float) -> void:
	if broken_s <= 0.0 and is_alive():
		guard += guard_max * fraction
		if guard >= guard_max:
			guard_break()


func guard_break() -> void:
	var gauge: Dictionary = data.get("guard_gauge", {})
	broken_s = float(gauge.get("break_s", Data.cfg_float("bosses.guard_break_s")))
	guard = 0.0
	guard_max *= float(gauge.get("refill_growth", 1.25))
	cast = {}
	cast_left = 0.0
	_charge_left = 0.0
	if patterns != null:
		patterns.clear()
	if is_alive():
		GameAuthority.enemies.statuses.stun[slot] = broken_s
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_GUARD_BREAK"))
	GameCamera.shake_screen(get_tree(), Data.cfg_float("settings.shake_guard_break_px"))


func _process(delta: float) -> void:
	if not is_alive():
		if _was_alive:
			_was_alive = false
			defeated.emit(self)
		return
	var enemies: EnemyManager = GameAuthority.enemies
	target = enemies.nearest_player(enemies.positions[slot])
	_update_phase()
	if broken_s > 0.0:
		broken_s -= delta
		queue_redraw()
		return
	_move(delta)
	if patterns != null:
		patterns.set_origin(enemies.positions[slot])
	if not cast.is_empty():
		cast_left -= delta
		if cast_left <= 0.0:
			_fire(cast.get("pattern", {}))
			cast = {}
	else:
		_attack_timer -= delta
		if _attack_timer <= 0.0 and target != null:
			_attack_timer = float(phase().get("attack_every_s", data.get("attack_every_s", 2.5)))
			_next_attack()
	signature(delta)
	queue_redraw()


## Each boss's signature mechanic, every frame (override).
func signature(_delta: float) -> void:
	pass


## Called when a new phase begins (override to set things up).
func _on_phase_started(_index: int) -> void:
	pass


func _update_phase() -> void:
	var phases: Array = data.get("phases", [])
	var frac: float = hp_fraction()
	var index: int = phases.size() - 1
	for i: int in phases.size():
		if frac > float((phases[i] as Dictionary).get("hp_above", 0.0)):
			index = i
			break
	if index != phase_index:
		phase_index = index
		_on_phase_started(index)


func _next_attack() -> void:
	_attacks += 1
	var casts: Array = phase().get("casts", [])
	if not casts.is_empty() and _attacks % 3 == 0:
		cast = casts[int(_attacks / 3.0) % casts.size()]
		cast_left = float(cast.get("cast_s", 1.5))
		return
	var list: Array = phase().get("patterns", [])
	if not list.is_empty():
		_fire(list[_attacks % list.size()])


func _fire(pattern: Dictionary) -> void:
	if patterns == null or target == null or pattern.is_empty():
		return
	var origin: Vector2 = position_now()
	var aim: Vector2 = target.position
	var is_charge: bool = str(pattern.get("pattern", "")) == "charge_trail"
	if is_charge:
		aim = origin + (target.position - origin).normalized() * (origin.distance_to(target.position) + 60.0)
	var total: float = patterns.run(pattern, origin, aim, str(GameAuthority.enemies.type_of(slot).get("element", "")),
			str(data.get("id", "")), _damage_mult())
	if is_charge:
		var charge_s: float = float(pattern.get("charge_s", Data.cfg_float("patterns.charge_trail.charge_s")))
		_charge_to = aim
		_charge_delay = maxf(total - charge_s, 0.0)
		_charge_left = charge_s
		_charge_speed = origin.distance_to(aim) / maxf(charge_s, 0.05)


## Boss attacks grow a little with the run's level scaling.
func _damage_mult() -> float:
	return LevelScaling.damage_mult(LevelScaling.current_level())


## Charges when one is running; otherwise keeps its preferred distance from the player.
func _move(delta: float) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	var at: Vector2 = enemies.positions[slot]
	var slow: float = enemies.statuses.speed_mult(slot)
	if _charge_left > 0.0:
		if _charge_delay > 0.0:
			_charge_delay -= delta
			return
		_charge_left -= delta
		var to_target: Vector2 = _charge_to - at
		facing = to_target.normalized() if to_target.length() > 1.0 else facing
		enemies.positions[slot] = at + to_target.limit_length(_charge_speed * slow * delta)
		return
	if target == null:
		return
	var offset: Vector2 = target.position - at
	facing = offset.normalized() if offset.length() > 1.0 else facing
	var keep: float = float(data.get("keep_distance_px", 100.0))
	var speed: float = float(data.get("move_speed", 40.0)) * slow
	if offset.length() > keep * 1.2:
		enemies.positions[slot] = at + offset.normalized() * speed * delta
	elif offset.length() < keep * 0.7:
		enemies.positions[slot] = at - offset.normalized() * speed * 0.6 * delta


func _draw() -> void:
	if not is_alive():
		return
	var at: Vector2 = position_now() - global_position
	if broken_s > 0.0:
		draw_arc(at, GameAuthority.enemies.radius[slot] + 6.0, 0.0, TAU, 24, Color.html(Data.cfg_string("bosses.guard_break_color")), 3.0)
	draw_line(at, at + facing * (GameAuthority.enemies.radius[slot] + 6.0), Color.WHITE, 2.0)
