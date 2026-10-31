class_name CombatSystem
extends Node
## Runs every player's weapons: picks targets every 0.1 s, fires each weapon
## on its own attack interval through its fire pattern, and turns hits into
## damage through GameAuthority (GAME_DESIGN.md: Weapons, Controls).

var enemies: EnemyManager
var effects: EffectLayer
var projectiles: ProjectileManager
## Fire patterns by the name used in weapons.json "pattern".
var patterns: Dictionary = {}


func _ready() -> void:
	process_priority = 2
	register_pattern("arc", ArcPattern.new())
	register_pattern("thrown_arc", ProjectilePattern.new(ProjectileManager.FLIGHT))
	register_pattern("boomerang", ProjectilePattern.new(ProjectileManager.BOOMERANG))
	register_pattern("forward", ProjectilePattern.new(ProjectileManager.FLIGHT))
	register_pattern("strike", StrikePattern.new())
	register_pattern("orbit", OrbitPattern.new())
	register_pattern("aura", AuraPattern.new())
	register_pattern("thrust", ThrustPattern.new())
	register_pattern("smash", SmashPattern.new())
	register_pattern("switch", SwitchPattern.new())


func register_pattern(pattern_id: String, pattern: FirePattern) -> void:
	patterns[pattern_id] = pattern


func _process(delta: float) -> void:
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		for weapon: WeaponInstance in player.weapons:
			_tick(weapon, player, delta)


func _tick(weapon: WeaponInstance, player: Player, delta: float) -> void:
	weapon.tick_hit_timers(delta)
	weapon.retarget_left -= delta
	var target: int = int(weapon.aim.get("target", -1))
	var target_lost: bool = target != -1 and enemies.active[target] == 0
	if weapon.retarget_left <= 0.0 or weapon.aim.is_empty() or target_lost:
		weapon.retarget_left = Data.cfg_float("performance.retarget_interval_s")
		weapon.aim = Targeting.pick(str(weapon.data.get("targeting", "")), player, _range_of(weapon, player),
				enemies, GameAuthority.run.rng.combat)
	weapon.cooldown_left -= delta
	if weapon.cooldown_left > 0.0 or not bool(weapon.aim.get("fire", false)):
		return
	# Aim at where the target is now, not where it was at the last retarget.
	target = int(weapon.aim.get("target", -1))
	if target != -1:
		weapon.aim["direction"] = Targeting.direction_to(player.position, target, enemies, player.facing)
	weapon.cooldown_left = weapon.attack_interval()
	weapon.attacks_made += 1
	GameAuthority.weapon_fired.emit(player, weapon)
	var pattern: FirePattern = patterns.get(str(weapon.data.get("pattern", "")))
	if pattern == null:
		push_error("CombatSystem: weapon '%s' uses unknown pattern" % weapon.id())
		return
	pattern.fire(weapon, player, weapon.aim, self)


## Targeting range: the weapon's range_px grown by Area for melee weapons.
func _range_of(weapon: WeaponInstance, player: Player) -> float:
	var reach: float = weapon.stat("range_px")
	if str(weapon.data.get("targeting", "")) == Targeting.MELEE:
		reach *= player.stats.area_mult() * weapon.stat("area", 1.0)
	return reach + enemies.max_radius()


## Damages every enemy inside a pie slice. Returns how many were hit.
func hit_sector(center: Vector2, direction: Vector2, reach: float, spread: float, weapon: WeaponInstance,
		player: Player, damage_mult: float) -> int:
	var hits: int = 0
	var half: float = spread * 0.5
	for slot: int in enemies.query(center, reach + enemies.max_radius()):
		var offset: Vector2 = enemies.positions[slot] - center
		if offset.length() > reach + enemies.radius[slot]:
			continue
		if offset.length_squared() > 0.01 and absf(direction.angle_to(offset)) > half:
			continue
		hit_enemy(slot, weapon, player, damage_mult, offset.normalized() if offset != Vector2.ZERO else direction)
		hits += 1
	return hits


## Damages every enemy inside a circle. Returns how many were hit.
func hit_circle(center: Vector2, hit_radius: float, weapon: WeaponInstance, player: Player, damage_mult: float) -> int:
	var hits: int = 0
	for slot: int in enemies.query(center, hit_radius + enemies.max_radius()):
		var offset: Vector2 = enemies.positions[slot] - center
		if offset.length() > hit_radius + enemies.radius[slot]:
			continue
		hit_enemy(slot, weapon, player, damage_mult, offset.normalized() if offset != Vector2.ZERO else player.facing)
		hits += 1
	return hits


## One hit on one enemy (respects the weapon's per-enemy hit interval).
func hit_enemy(slot: int, weapon: WeaponInstance, player: Player, damage_mult: float, push_dir: Vector2) -> void:
	if enemies.active[slot] == 0 or not weapon.try_hit(slot):
		return
	GameAuthority.damage_enemy(slot, weapon.damage() * damage_mult, player,
			push_dir * weapon.stat("knockback"), weapon.element(), weapon.status_chance(), weapon)


func effect_color(weapon: WeaponInstance) -> Color:
	return Color.html(str(weapon.data.get("placeholder_color", Data.cfg_string("effects.default_color"))))
