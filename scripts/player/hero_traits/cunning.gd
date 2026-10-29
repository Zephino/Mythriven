extends HeroKit
## Odysseus (secret Hero). Legend Trait, Cunning (from the design's Hero
## list: "standing still lays traps; disguises draw enemies away"):
##   - standing still for 1 s lays a trap (up to 3); an enemy stepping on one
##     takes damage and is rooted;
##   - every 20 s he slips into a disguise for 4 s: a decoy stays where he was
##     and draws nearby enemies to it.
## Passive, Of Many Wiles (Homer's epithet polymētis): +10% Luck.
## All numbers are placeholders that need owner approval.

## World positions of laid traps.
var traps: PackedVector2Array = []
## The decoy's position while disguised (Vector2.INF = none).
var decoy := Vector2.INF

var _still_for: float = 0.0
var _disguise_in: float = 0.0
var _disguise_left: float = 0.0


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	player.stats.add_bonus("luck", float(passive_data().get("luck", 0.0)))
	_disguise_in = float(trait_data().get("disguise_every_s", 20.0))
	var world: WorldRoot = player.get_parent() as WorldRoot
	if world != null:
		world.origin_shifted.connect(on_origin_shifted)


func hud_text() -> String:
	return tr("HUD_DISGUISED") if decoy != Vector2.INF else tr("HUD_TRAPS") % [traps.size(), int(trait_data().get("max_traps", 3))]


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	for i: int in traps.size():
		traps[i] -= shift_px
	if decoy != Vector2.INF:
		decoy -= shift_px
		_set_lure(decoy)


func _process(delta: float) -> void:
	if not player.alive or GameAuthority.enemies == null:
		_end_disguise()
		return
	var data: Dictionary = trait_data()
	_still_for = _still_for + delta if player.velocity == Vector2.ZERO else 0.0
	if _still_for >= float(data.get("still_s", 1.0)) and traps.size() < int(data.get("max_traps", 3)):
		_still_for = 0.0
		traps.append(player.position)
	_spring_traps(data)
	if decoy != Vector2.INF:
		_disguise_left -= delta
		if _disguise_left <= 0.0:
			_end_disguise()
	else:
		_disguise_in -= delta
		if _disguise_in <= 0.0:
			_disguise_in = float(data.get("disguise_every_s", 20.0))
			_disguise_left = float(data.get("disguise_s", 4.0))
			decoy = player.position
			_set_lure(decoy)
	queue_redraw()


func _spring_traps(data: Dictionary) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	var reach: float = float(data.get("trap_radius_px", 22.0))
	for i: int in range(traps.size() - 1, -1, -1):
		var hit: Array[int] = []
		for slot: int in enemies.query(traps[i], reach):
			hit.append(slot)
		if hit.is_empty():
			continue
		for slot: int in hit:
			GameAuthority.damage_enemy(slot, float(data.get("trap_damage", 30.0)), player, Vector2.ZERO, Elements.PHYSICAL)
			if enemies.active[slot] != 0 and not bool(enemies.type_of(slot).get("boss", false)):
				enemies.statuses.apply_stun(slot, float(data.get("trap_root_s", 2.0)))
		var effects: EffectLayer = effect_layer()
		if effects != null:
			effects.spawn_ring(traps[i], reach, Color.html(Data.cfg_string("heroes.trap_color")))
		traps.remove_at(i)


func _set_lure(at: Vector2) -> void:
	GameAuthority.enemies.movement.lure_pos = at
	GameAuthority.enemies.movement.lure_radius = float(trait_data().get("lure_radius_px", 160.0))


func _end_disguise() -> void:
	if decoy == Vector2.INF:
		return
	decoy = Vector2.INF
	if GameAuthority.enemies != null:
		GameAuthority.enemies.movement.lure_pos = Vector2.INF


func _exit_tree() -> void:
	_end_disguise()


func _draw() -> void:
	var color := Color.html(Data.cfg_string("heroes.trap_color"))
	for at: Vector2 in traps:
		var local: Vector2 = at - player.position
		draw_line(local + Vector2(-5, -5), local + Vector2(5, 5), color, 2.0)
		draw_line(local + Vector2(-5, 5), local + Vector2(5, -5), color, 2.0)
	if decoy != Vector2.INF:
		var size_px: float = Data.cfg_float("player.placeholder_size_px")
		draw_rect(Rect2(decoy - player.position - Vector2.ONE * size_px * 0.5, Vector2.ONE * size_px), Color(color, 0.6))
