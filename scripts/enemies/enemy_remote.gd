class_name EnemyRemote
extends RefCounted
## Enemies on a joining player's device in co-op (for EnemyManager in remote
## mode): each is put into the same slot number as on the host, glides toward
## the position the host last sent, and keeps drifting the way it was going
## until the next correction, so the horde moves smoothly between updates.

var target := PackedVector2Array()
var drift := PackedVector2Array()
var corrected_at := PackedFloat32Array()
var clock: float = 0.0
var _rebuild_in: float = 0.0


func _init(capacity: int) -> void:
	target.resize(capacity)
	drift.resize(capacity)
	corrected_at.resize(capacity)


func spawn_into(m: EnemyManager, slot: int, kind_id: int, at: Vector2, hp_max: float) -> void:
	if slot < 0 or slot >= m.capacity or kind_id < 0 or kind_id >= m.types.size():
		return
	if m.active[slot] != 0:
		m.despawn(slot)
	if m.take_slot(slot) == -1:
		return
	m.kind[slot] = kind_id
	m.positions[slot] = at
	m.knockback[slot] = Vector2.ZERO
	m.max_hp[slot] = hp_max
	m.hp[slot] = hp_max
	m.radius[slot] = float(m.types[kind_id]["radius_px"])
	m.flash_timer[slot] = 0.0
	m.tint_override[slot] = Color(0, 0, 0, 0)
	m.statuses.clear(slot)
	m.elites.clear(slot)
	target[slot] = at
	drift[slot] = Vector2.ZERO
	corrected_at[slot] = clock


func correct(m: EnemyManager, slot: int, at: Vector2, hp_fraction: float) -> void:
	if m.active[slot] == 0:
		return
	var since: float = clock - corrected_at[slot]
	drift[slot] = (at - target[slot]) / since if since > 0.02 and since < 1.0 else Vector2.ZERO
	target[slot] = at
	corrected_at[slot] = clock
	m.hp[slot] = m.max_hp[slot] * hp_fraction


func follow(m: EnemyManager, delta: float) -> void:
	clock += delta
	var weight: float = minf(Data.cfg_float("coop.smoothing_per_s") * delta, 1.0)
	for i: int in m.capacity:
		if m.active[i] == 0:
			continue
		target[i] += drift[i] * delta
		m.positions[i] = m.positions[i].lerp(target[i], weight)
	# Weapons still pick targets on this device, so the spatial hash stays current.
	_rebuild_in -= delta
	if _rebuild_in <= 0.0:
		_rebuild_in = 1.0 / Data.cfg_float("performance.separation_hz")
		m.hash_grid.rebuild(m.positions, m.active)


func on_origin_shifted(shift_px: Vector2) -> void:
	for i: int in target.size():
		target[i] -= shift_px
