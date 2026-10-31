class_name ProjectileManager
extends Node2D
## Player projectiles as pooled data drawn with one MultiMesh (GAME_DESIGN.md:
## Object pooling). Three flight styles: "flight" (straight or lobbed with
## gravity, like the Throwing Axe), "boomerang" (flies out, then returns to
## its thrower, like the Bladed Discus), and "orbit" (circles its thrower,
## like Glimmer). When the pool is full the oldest projectile is reused.

const FLIGHT := 0
const BOOMERANG := 1
const ORBIT := 2
## Element pictures that spin as they fly (degrees/s); the rest point along their flight.
const ELEMENT_SPIN_DEG_S := {"wind": 720.0, "holy": 240.0, "dark": 300.0, "earth": 540.0, "fortune": 360.0}

var enemies: EnemyManager
## For the Gáe Bolg's barbs (a thrown spear's kills burst into barbs).
var combat: CombatSystem

var _capacity: int = 0
var _next: int = 0
var _active := PackedByteArray()
var _kind := PackedInt32Array()
var _pos := PackedVector2Array()
var _vel := PackedVector2Array()
var _gravity := PackedFloat32Array()
var _age := PackedFloat32Array()
var _life := PackedFloat32Array()
var _radius := PackedFloat32Array()
var _pierce := PackedInt32Array()
var _return_after := PackedFloat32Array()
var _element := PackedStringArray()
## 1 for a projectile that chains lightning on its first hit (Thor's Blessing).
var _chain := PackedByteArray()
var _orbit_angle := PackedFloat32Array()
var _orbit_radius := PackedFloat32Array()
var _orbit_speed := PackedFloat32Array()
var _weapon: Array[WeaponInstance] = []
var _thrower: Array[Player] = []
## Per projectile: enemy slot -> seconds until it may hit that enemy again.
var _hits: Array[Dictionary] = []
## Per projectile: its picture (weapons.json projectile_art; {} = a coloured dot) and spin (radians/s, 0 = it
## points along its flight). Pictures are drawn in _draw; dots by the MultiMesh.
var _art: Array[Dictionary] = []
var _spin := PackedFloat32Array()
var _pictures: int = 0
var _multimesh: MultiMesh


func setup() -> void:
	add_to_group("player_projectiles")
	Settings.fade_player_effect(self)
	_capacity = Data.cfg_int("projectiles.max_player_projectiles")
	_active.resize(_capacity)
	_kind.resize(_capacity)
	_pos.resize(_capacity)
	_vel.resize(_capacity)
	_gravity.resize(_capacity)
	_age.resize(_capacity)
	_life.resize(_capacity)
	_radius.resize(_capacity)
	_pierce.resize(_capacity)
	_return_after.resize(_capacity)
	_element.resize(_capacity)
	_chain.resize(_capacity)
	_orbit_angle.resize(_capacity)
	_orbit_radius.resize(_capacity)
	_orbit_speed.resize(_capacity)
	_weapon.resize(_capacity)
	_thrower.resize(_capacity)
	_art.resize(_capacity)
	_spin.resize(_capacity)
	for i: int in _capacity:
		_hits.append({})
		_art[i] = {}
	_multimesh = PlaceholderArt.make_multimesh(_capacity)
	var drawer := MultiMeshInstance2D.new()
	drawer.multimesh = _multimesh
	drawer.texture = PlaceholderArt.circle_texture(Data.cfg_int("enemies.placeholder_texture_px"))
	add_child(drawer)


## Launches one projectile. `settings` holds the weapon level's values.
func launch(weapon: WeaponInstance, player: Player, at: Vector2, velocity: Vector2, flight_kind: int, settings: Dictionary) -> void:
	if _capacity <= 0:
		return
	var i: int = _next
	_next = (_next + 1) % _capacity
	_active[i] = 1
	_kind[i] = flight_kind
	_pos[i] = at
	_vel[i] = velocity
	_gravity[i] = float(settings.get("gravity_px_s2", 0.0))
	_age[i] = 0.0
	_life[i] = float(settings.get("lifetime_s", 1.0))
	_radius[i] = float(settings.get("radius_px", 4.0)) * player.stats.area_mult() * float(settings.get("area", 1.0))
	_pierce[i] = int(settings.get("pierce", 0)) + (player.kit.extra_pierce(weapon) if player.kit != null else 0)
	_return_after[i] = float(settings.get("return_after_s", 0.0))
	_weapon[i] = weapon
	_thrower[i] = player
	_hits[i].clear()
	_chain[i] = 1 if Blessings.next_projectile_chains(player) else 0
	# An infusion's element wins over a cycling element (Runo Song).
	_element[i] = weapon.element() if weapon.infusion != "" else str(settings.get("element", weapon.element()))
	var color: Color = Color.html(str(weapon.data.get("placeholder_color", "#ffffff")))
	if settings.has("element") or weapon.infusion != "":
		color = Elements.color(_element[i])
	_multimesh.set_instance_color(i, color)
	if not _art[i].is_empty():
		_pictures -= 1
	# Its own picture (weapons.json projectile_art), else its element's: spells fly as fireballs, ice shards,
	# bolts, gusts, motes of light (owner request 10/31/2026; data/art/projectiles/element_<element>.json).
	var picture: String = str(weapon.data.get("projectile_art", ""))
	var spin: float = float(weapon.data.get("projectile_spin_deg_s", 0.0))
	if picture == "" and _element[i] != "physical":
		picture = "element_" + _element[i]
		spin = float(ELEMENT_SPIN_DEG_S.get(_element[i], 0.0))
	_art[i] = PixelArt.find("projectiles/" + picture) if picture != "" else {}
	if flight_kind == ORBIT and spin == 0.0:
		spin = 240.0
	_spin[i] = deg_to_rad(spin)
	if not _art[i].is_empty():
		_pictures += 1


## Launches a projectile that circles `player`, starting at `start_angle` (radians).
func launch_orbit(weapon: WeaponInstance, player: Player, start_angle: float, settings: Dictionary) -> void:
	launch(weapon, player, player.position, Vector2.ZERO, ORBIT, settings)
	var i: int = (_next - 1 + _capacity) % _capacity
	_orbit_angle[i] = start_angle
	_orbit_radius[i] = float(settings.get("orbit_radius_px", 40.0)) * player.stats.area_mult() * float(settings.get("area", 1.0))
	_orbit_speed[i] = deg_to_rad(float(settings.get("orbit_speed_deg_s", 180.0)))


## Removes player projectiles inside a circle (Medusa's statues block them). Returns how many.
func block_circle(center: Vector2, block_radius: float) -> int:
	var blocked: int = 0
	for i: int in _capacity:
		if _active[i] != 0 and _kind[i] != ORBIT and _pos[i].distance_to(center) <= block_radius + _radius[i]:
			_remove(i)
			blocked += 1
	return blocked


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in _capacity:
		_pos[i] -= shift_px


func _process(delta: float) -> void:
	if _pictures > 0:
		queue_redraw()
	for i: int in _capacity:
		if _active[i] == 0:
			continue
		_age[i] += delta
		if _age[i] >= _life[i] or not is_instance_valid(_thrower[i]):
			_remove(i)
			continue
		if _kind[i] == ORBIT:
			_pos[i] = _thrower[i].position + Vector2.from_angle(_orbit_angle[i] + _age[i] * _orbit_speed[i]) * _orbit_radius[i]
			_tick_hits(i, delta)
			if _active[i] != 0:
				_draw_instance(i)
			continue
		if _kind[i] == BOOMERANG and _age[i] >= _return_after[i]:
			var back: Vector2 = _thrower[i].position - _pos[i]
			if back.length() <= _thrower[i].body_radius + _radius[i]:
				_remove(i)
				continue
			_vel[i] = back.normalized() * _vel[i].length()
		var velocity: Vector2 = _vel[i]
		velocity.y += _gravity[i] * delta
		_vel[i] = velocity
		_pos[i] += velocity * delta
		_tick_hits(i, delta)
		if _active[i] != 0:
			_draw_instance(i)


func _tick_hits(i: int, delta: float) -> void:
	var hits: Dictionary = _hits[i]
	for slot: Variant in hits.keys():
		hits[slot] = float(hits[slot]) - delta
		if float(hits[slot]) <= 0.0:
			hits.erase(slot)
	var weapon: WeaponInstance = _weapon[i]
	var interval: float = weapon.stat("hit_interval")
	for slot: int in enemies.query(_pos[i], _radius[i] + enemies.max_radius()):
		if hits.has(slot) or _pos[i].distance_to(enemies.positions[slot]) > _radius[i] + enemies.radius[slot]:
			continue
		hits[slot] = interval if interval > 0.0 else INF
		var at: Vector2 = enemies.positions[slot]
		GameAuthority.damage_enemy(slot, weapon.damage(), _thrower[i],
				_vel[i].normalized() * weapon.stat("knockback"), _element[i],
				weapon.status_chance(), weapon)
		_barbs(i, slot, at)
		# A spell's hit shows in its element's style (owner request 10/31/2026).
		if combat != null and _element[i] != "physical":
			combat.effects.spawn_burst(at, _element[i], weapon.data.has("evolved_from"))
		if _chain[i] != 0:
			_chain[i] = 0
			Blessings.chain_lightning(_thrower[i], slot, _pos[i], weapon.damage())
		_pierce[i] -= 1
		if _pierce[i] < 0:
			_remove(i)
			return


## Gáe Bolg (on_kill_barbs): the enemy the thrown spear kills bursts into barbs that hit those nearby (Thirty Barbs:
## every enemy it hits).
func _barbs(i: int, slot: int, at: Vector2) -> void:
	var weapon: WeaponInstance = _weapon[i]
	var barbs: Dictionary = weapon.data.get("on_kill_barbs", {})
	if barbs.is_empty() or combat == null:
		return
	if enemies.active[slot] != 0 and not bool(weapon.data.get("barbs_on_every_hit", false)):
		return
	var player: Player = _thrower[i]
	var reach: float = float(barbs.get("radius_px", 0.0)) * player.stats.area_mult() * weapon.stat("area", 1.0)
	combat.hit_circle(at, reach, weapon, player, float(barbs.get("damage_mult", 0.5)))
	combat.effects.spawn_ring(at, reach, combat.effect_color(weapon))


func _draw_instance(i: int) -> void:
	if not _art[i].is_empty():
		_multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2.ZERO, 0.0, _pos[i]))
		return
	var size: float = _radius[i] * 2.0
	_multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2(size, size), 0.0, _pos[i]))


## Thrown weapons and shots with a picture: pointing along their flight (drawn tip up, so turned a quarter more), or
## spinning.
func _draw() -> void:
	if _pictures <= 0:
		return
	for i: int in _capacity:
		if _active[i] == 0 or _art[i].is_empty():
			continue
		var angle: float = _age[i] * _spin[i] if _spin[i] != 0.0 else _vel[i].angle() + PI * 0.5
		var texture: ImageTexture = PixelArt.frame(_art[i], false, 0.0)
		draw_set_transform(_pos[i], angle, Vector2.ONE)
		draw_texture(texture, -texture.get_size() * 0.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _remove(i: int) -> void:
	if _active[i] != 0 and not _art[i].is_empty():
		_pictures -= 1
		_art[i] = {}
	_active[i] = 0
	_weapon[i] = null
	_thrower[i] = null
	_multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))
