class_name UnweaverBoss
extends BossController
## The Unweaver, 30:00 (GAME_DESIGN.md: the Crossroads finale; an original being, the game's own). Signature: it fights
## with what it has stolen. Each of its phases uses the attacks of a different boss, taken from bosses the Heroes have
## beaten (any boss before that); and every so often it unweaves the gods, as Apep swallows Ra but both at once: every
## Hero's two god meters unravel to nothing.

## The bosses whose attacks it uses, one per phase.
var stolen: Array = []
var unweavings: int = 0
var _unweave_in: float = 8.0
var _thread_s: float = 0.0


func _sig() -> Dictionary:
	return data.get("signature", {})


## Takes its phases' attacks from other bosses (beaten ones first).
func steal() -> void:
	data = data.duplicate(true)
	var pool: Array = []
	for level: Dictionary in LevelRules.all():
		for boss_id: String in LevelRules.bosses_defeated(str(level.get("id", ""))):
			var found: Dictionary = BossManager.find(boss_id)
			if not found.is_empty() and boss_id != str(data.get("id", "")):
				pool.append(found)
	if pool.size() < 3:
		for entry: Variant in Data.get_file(BossManager.FILE):
			if entry is Dictionary and str(entry.get("id", "")) != str(data.get("id", "")) and (entry.get("phases", []) as Array).size() > 0:
				pool.append(entry)
	var rng: RandomNumberGenerator = GameAuthority.run.rng.combat if GameAuthority.run != null else RandomNumberGenerator.new()
	var phases: Array = data.get("phases", [])
	for i: int in phases.size():
		if pool.is_empty():
			break
		var source: Dictionary = pool[rng.randi() % pool.size()]
		var theirs: Array = source.get("phases", [])
		stolen.append(str(source.get("id", "")))
		(phases[i] as Dictionary)["patterns"] = ((theirs[mini(i, theirs.size() - 1)] as Dictionary).get("patterns", []) as Array).duplicate(true)


func signature(delta: float) -> void:
	if stolen.is_empty():
		steal()
	_thread_s = maxf(_thread_s - delta, 0.0)
	if not is_alive():
		return
	_unweave_in -= delta
	if _unweave_in <= 0.0:
		_unweave_in = float(_sig().get("unweave_every_s", 15.0))
		unweave()


## Every Hero's two god meters unravel to nothing.
func unweave() -> void:
	unweavings += 1
	_thread_s = 1.2
	if GameAuthority.gods != null:
		for player: Player in GameAuthority.players:
			for k: int in 2:
				GameAuthority.gods.set_meter(player, k, 0.0)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_UNWEAVER_UNWEAVES"))


## Threads pulled from every Hero into the Unweaver as it unweaves.
func _draw() -> void:
	super._draw()
	if _thread_s <= 0.0 or not is_alive():
		return
	var at: Vector2 = position_now() - global_position
	var colours := [Color(0.8, 0.25, 0.25), Color(0.9, 0.7, 0.25), Color(0.25, 0.6, 0.35), Color(0.25, 0.4, 0.8), Color(0.55, 0.3, 0.8)]
	for player: Player in GameAuthority.players:
		var from: Vector2 = player.position - global_position
		for k: int in colours.size():
			var bend: Vector2 = (at - from).orthogonal().normalized() * (k - 2) * 8.0
			draw_polyline(PackedVector2Array([from, from.lerp(at, 0.5) + bend, at]), Color(colours[k], _thread_s / 1.2), 1.5)
