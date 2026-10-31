extends HeroKit
## King Arthur. Legend Trait, Shield Wall: stand still for 0.4 s and he raises
## his shield toward the nearest threat; it blocks enemy shots in a 120° arc
## and halves contact damage. Moving drops it.
## Passive, The Scabbard (in legend, its wearer lost no blood): immune to
## burning and poison; regenerates 1% HP per second while the shield is raised.
## Divine Link: each summon grants a shield worth 20% Max HP for 5 s.

var raised: bool = false
## Divine Link shield: HP left and seconds left.
var shield_hp: float = 0.0

var _still_for: float = 0.0
var _shield_left: float = 0.0
var _toward := Vector2.RIGHT


func _process(delta: float) -> void:
	if not player.alive:
		raised = false
		return
	if player.velocity == Vector2.ZERO:
		_still_for += delta
	else:
		_still_for = 0.0
	raised = _still_for >= float(trait_data().get("still_s", 0.4))
	if raised:
		var target: Vector2 = _nearest_threat()
		if target != Vector2.INF:
			_toward = (target - player.position).normalized()
		GameAuthority.heal_player(player, player.max_hp * float(passive_data().get("regen_pct_per_s", 0.0)) / 100.0 * delta)
	_shield_left = maxf(_shield_left - delta, 0.0)
	if _shield_left <= 0.0:
		shield_hp = 0.0
	queue_redraw()


func blocks_shot(at: Vector2) -> bool:
	return raised and _in_arc(at)


func immune_to_dot() -> bool:
	return true


## Raised: contact damage from the front is halved. The summon shield soaks hits first.
func incoming_damage_at(amount: float, from: Vector2) -> float:
	if raised and from != Vector2.INF and _in_arc(from):
		amount *= float(trait_data().get("contact_mult", 0.5))
	if shield_hp > 0.0:
		var soaked: float = minf(shield_hp, amount)
		shield_hp -= soaked
		amount -= soaked
	return amount


func on_summon() -> void:
	var link: Dictionary = hero.get("divine_link", {})
	shield_hp = player.max_hp * float(link.get("shield_pct", 0.0)) / 100.0
	_shield_left = float(link.get("shield_s", 0.0))


func hud_text() -> String:
	return tr("HUD_SHIELD_RAISED") if raised else ""


func _in_arc(at: Vector2) -> bool:
	var to: Vector2 = at - player.position
	if to.length_squared() < 0.01:
		return true
	return absf(_toward.angle_to(to)) <= deg_to_rad(float(trait_data().get("block_arc_deg", 120.0))) * 0.5


func _nearest_threat() -> Vector2:
	var enemies: EnemyManager = GameAuthority.enemies
	if enemies == null:
		return Vector2.INF
	var best := Vector2.INF
	for slot: int in enemies.query(player.position, Data.cfg_float("heroes.shield_scan_px")):
		if best == Vector2.INF or enemies.positions[slot].distance_squared_to(player.position) < best.distance_squared_to(player.position):
			best = enemies.positions[slot]
	return best


## Raised, a curved wall of shield faces the danger (owner request 10/31/2026): a band with a dark rim and a boss
## in its middle.
func _draw() -> void:
	var color := Color.html(Data.cfg_string("heroes.shield_color"))
	if raised:
		var half: float = deg_to_rad(float(trait_data().get("block_arc_deg", 120.0))) * 0.5
		var r: float = Data.cfg_float("player.placeholder_size_px")
		var a: float = _toward.angle()
		var band := PackedVector2Array()
		for k: int in 13:
			band.append(Vector2.from_angle(a - half + half * 2.0 * k / 12.0) * (r + 2.0))
		for k: int in 13:
			band.append(Vector2.from_angle(a + half - half * 2.0 * k / 12.0) * (r - 2.0))
		draw_colored_polygon(band, Color(color, 0.55))
		draw_arc(Vector2.ZERO, r + 2.0, a - half, a + half, 16, Color(0.14, 0.09, 0.05, 0.9), 1.5)
		draw_arc(Vector2.ZERO, r - 2.0, a - half, a + half, 16, Color(0.14, 0.09, 0.05, 0.6), 1.0)
		draw_circle(Vector2.from_angle(a) * r, 2.5, Color.html(Data.cfg_string("heroes.race_color")))
	if shield_hp > 0.0:
		draw_arc(Vector2.ZERO, Data.cfg_float("player.placeholder_size_px") * 1.3, 0.0, TAU, 24, color, 1.5)
