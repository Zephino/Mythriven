class_name EnemyMovement
extends RefCounted
## How each enemy moves (GAME_DESIGN.md: Enemies / Movement types), as data
## on the pooled slots of EnemyManager:
##   chaser, swarm, brute, encircler: walk at the nearest player
##   flyer:  ignores players and crosses the screen in a sine-wave line, then leaves
##   caster: stops at range and fires a slow projectile after a 0.5 s glow
##   bomber: runs at the player and explodes after a 1 s flashing fuse
##   still:  doesn't move by itself (bosses move through their own scripts)
## Settings for flyers, casters, and bombers are in each enemy's "behavior".

const CHASER := 0
const FLYER := 1
const CASTER := 2
const BOMBER := 3
const STILL := 4
const CODES: Dictionary = {
	"chaser": CHASER, "swarm": CHASER, "brute": CHASER, "encircler": CHASER,
	"flyer": FLYER, "caster": CASTER, "bomber": BOMBER, "still": STILL,
}
## Caster/bomber state: 0 = moving, 1 = winding up (glow or fuse).
const WINDING := 1

## Flyer direction (unit vector) per slot.
var dir := PackedVector2Array()
## Flyer: seconds left before leaving. Caster: seconds to the next shot. Bomber: fuse left.
var timer := PackedFloat32Array()
var state := PackedInt32Array()
## Flyer: seconds flown (drives the sine wave).
var age := PackedFloat32Array()
## A decoy that draws chasers inside `lure_radius` to it (Odysseus' disguise);
## Vector2.INF when there is none.
var lure_pos := Vector2.INF
var lure_radius: float = 0.0


func _init(capacity: int) -> void:
	dir.resize(capacity)
	timer.resize(capacity)
	state.resize(capacity)
	age.resize(capacity)


static func code_of(movement: String) -> int:
	return int(CODES.get(movement, CHASER))


## Sets up a freshly spawned slot. `behavior` is the enemy type's "behavior" data.
func reset(slot: int, code: int, behavior: Dictionary, rng: RandomNumberGenerator) -> void:
	dir[slot] = Vector2.RIGHT
	state[slot] = 0
	age[slot] = 0.0
	match code:
		FLYER:
			timer[slot] = float(behavior.get("lifetime_s", 12.0))
		CASTER:
			timer[slot] = rng.randf_range(0.5, 1.0) * float(behavior.get("cooldown_s", 3.0))
		_:
			timer[slot] = 0.0


## Moves every active enemy by one frame.
func step(m: EnemyManager, delta: float) -> void:
	var decay: float = exp(-Data.cfg_float("enemies.knockback_decay") * delta)
	var flora: Flora = Flora.current
	for i: int in m.capacity:
		if m.active[i] == 0 or m.asleep[i] == 1:
			continue
		var code: int = m.movement_code(i)
		var speed: float = m.speed_of(i)
		var velocity := Vector2.ZERO
		match code:
			FLYER:
				velocity = _flyer(m, i, speed, delta)
				if m.active[i] == 0:
					continue
			CASTER:
				velocity = _caster(m, i, speed, delta)
			BOMBER:
				velocity = _bomber(m, i, speed, delta)
				if m.active[i] == 0:
					continue
			STILL:
				velocity = Vector2.ZERO
			_:
				velocity = _toward_player(m, i) * speed
		var moved: Vector2 = velocity * delta + m.knockback[i] * delta
		m.knockback[i] *= decay
		# Walking monsters slide round trees and boulders and slow on stones; flyers go over (docs/WORLD_PLAN.md: 1).
		if flora != null and code != FLYER and code != STILL and not m.flies(i):
			m.positions[i] = flora.move(m.positions[i], moved, m.radius[i])
		else:
			m.positions[i] += moved


## A winding-up caster glows and a lit bomber flashes; returns the colour to
## draw instead, or a colour with alpha 0 for no change.
func override_color(m: EnemyManager, slot: int) -> Color:
	if state[slot] != WINDING:
		return Color(0, 0, 0, 0)
	if m.movement_code(slot) == BOMBER and int(timer[slot] * 10.0) % 2 == 0:
		return Color.html(Data.cfg_string("enemies.hit_flash_color"))
	if m.movement_code(slot) == CASTER:
		return Color.html(Data.cfg_string("enemies.telegraph_color"))
	return Color(0, 0, 0, 0)


func _toward_player(m: EnemyManager, i: int) -> Vector2:
	# Odysseus' disguise draws nearby enemies to his decoy for a moment.
	if lure_pos != Vector2.INF and m.positions[i].distance_to(lure_pos) <= lure_radius:
		var to_lure: Vector2 = lure_pos - m.positions[i]
		return to_lure.normalized() if to_lure.length_squared() > 1.0 else Vector2.ZERO
	var target: Player = m.nearest_player(m.positions[i])
	if target == null:
		return Vector2.ZERO
	var to_player: Vector2 = target.position - m.positions[i]
	return to_player.normalized() if to_player.length_squared() > 1.0 else Vector2.ZERO


func _flyer(m: EnemyManager, i: int, speed: float, delta: float) -> Vector2:
	var behavior: Dictionary = m.type_of(i).get("behavior", {})
	timer[i] -= delta
	age[i] += delta
	if timer[i] <= 0.0:
		m.remove_quietly(i)
		return Vector2.ZERO
	var hz: float = float(behavior.get("wave_hz", 1.0))
	var sway: float = float(behavior.get("wave_px", 0.0)) * TAU * hz * cos(TAU * hz * age[i])
	return dir[i] * speed + dir[i].orthogonal() * sway


func _caster(m: EnemyManager, i: int, speed: float, delta: float) -> Vector2:
	var behavior: Dictionary = m.type_of(i).get("behavior", {})
	var target: Player = m.nearest_player(m.positions[i])
	if target == null:
		return Vector2.ZERO
	var to_player: Vector2 = target.position - m.positions[i]
	var in_range: bool = to_player.length() <= float(behavior.get("range_px", 120.0))
	if in_range and m.speed_of(i) > 0.0:
		timer[i] -= delta
	var telegraph: float = maxf(float(behavior.get("telegraph_s", 0.5)), Data.cfg_float("enemies.min_attack_telegraph_s"))
	state[i] = WINDING if in_range and timer[i] <= telegraph else 0
	if timer[i] <= 0.0:
		timer[i] = float(behavior.get("cooldown_s", 3.0))
		state[i] = 0
		if GameAuthority.enemy_shots != null:
			GameAuthority.enemy_shots.fire(m.positions[i], to_player.normalized() * float(behavior.get("projectile_speed_px_s", 60.0)),
					float(behavior.get("projectile_radius_px", 4.0)), float(behavior.get("projectile_damage", 5.0)) * m.damage_mult(i),
					str(m.type_of(i)["id"]), str(m.type_of(i).get("element", "")))
	return Vector2.ZERO if in_range else to_player.normalized() * speed


func _bomber(m: EnemyManager, i: int, speed: float, delta: float) -> Vector2:
	var behavior: Dictionary = m.type_of(i).get("behavior", {})
	if state[i] == WINDING:
		timer[i] -= delta
		if timer[i] <= 0.0:
			_explode(m, i, behavior)
		return Vector2.ZERO
	var target: Player = m.nearest_player(m.positions[i])
	if target == null:
		return Vector2.ZERO
	var to_player: Vector2 = target.position - m.positions[i]
	if to_player.length() <= float(behavior.get("trigger_px", 24.0)) + m.radius[i]:
		state[i] = WINDING
		timer[i] = maxf(float(behavior.get("fuse_s", 1.0)), Data.cfg_float("enemies.min_attack_telegraph_s"))
		return Vector2.ZERO
	return to_player.normalized() * speed


## The blast hurts every player inside it, then the bomber is gone (it still drops XP).
func _explode(m: EnemyManager, i: int, behavior: Dictionary) -> void:
	var at: Vector2 = m.positions[i]
	var blast: float = float(behavior.get("blast_radius_px", 40.0))
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(at) <= blast + player.body_radius:
			GameAuthority.damage_player(player, float(behavior.get("blast_damage", 10.0)) * m.damage_mult(i),
					str(m.type_of(i)["id"]), at)
	var effects: EffectLayer = m.get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null:
		effects.spawn_ring(at, blast, Elements.color(str(m.type_of(i).get("element", "fire"))), true)
	GameAuthority.kill_enemy(i, null)
