class_name BossManager
extends Node2D
## Boss fights (GAME_DESIGN.md: Bosses; Boss timing; Run arc).
## - Each Age's boss spawns on time (10:00, 20:00, 30:00) even if the last is
##   still alive; then both fight at once and the arena grows to hold them.
## - Clean slate: every regular enemy on screen bursts into XP orbs.
## - Arena: a ring (radius ~1.2 screens) keeps the players in; only weak
##   fodder spawns, at 25%; hazards and elites pause.
## - Rewards: a big chest (evolution/infusion eligible), a Boon (choose 1 of
##   3), and a gold bonus (+50 / +100 / +200). Defeating Achilles unlocks him
##   as a Hero and saves at once. The 30:00 boss's fall starts the Unraveling.
## - Entrance banter.

signal boss_spawned(controller: BossController)
signal boss_defeated(boss_id: String)

const FILE := "bosses.json"
const SCRIPTS: Dictionary = {
	"medusa": "res://scripts/bosses/medusa_boss.gd",
	"achilles": "res://scripts/bosses/achilles_boss.gd",
	"kronos": "res://scripts/bosses/kronos_boss.gd",
	"fenrir": "res://scripts/bosses/fenrir_boss.gd",
	"loki": "res://scripts/bosses/loki_boss.gd",
	"surtr": "res://scripts/bosses/surtr_boss.gd",
}

var world: WorldRoot
var spawner: EnemySpawner
var chests: ChestPickups
var gold: GoldPickups
var boons: BoonScreen
var banter: BanterBubble
var unraveling: Unraveling

var controllers: Array[BossController] = []
var arena_center := Vector2.ZERO
var arena_radius: float = 0.0
var _schedule: Array[Dictionary] = []
var _defeated: int = 0


func _ready() -> void:
	z_index = 2
	GameAuthority.bosses = self
	var level: Dictionary = GameAuthority.run.level_data if GameAuthority.run != null else {}
	var times: Array = Data.cfg("run_arc.boss_times_s")
	var bosses: Dictionary = level.get("bosses", {})
	var keys: Array = bosses.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool: return int(a) < int(b))
	for i: int in keys.size():
		_schedule.append({"time_s": float(times[mini(i, times.size() - 1)]), "id": str(bosses[keys[i]]), "index": i})


static func find(boss_id: String) -> Dictionary:
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary and str(entry.get("id", "")) == boss_id:
			return entry
	return {}


func active_count() -> int:
	var count: int = 0
	for controller: BossController in controllers:
		if controller.is_alive():
			count += 1
	return count


## Spawns a boss now, at the edge of the arena. Returns its controller (or null).
func spawn_boss(boss_id: String, index: int = -1) -> BossController:
	var player: Player = GameAuthority.local_player()
	var boss: Dictionary = find(boss_id)
	if player == null or boss.is_empty():
		return null
	var controller: BossController = load(str(SCRIPTS.get(boss_id, "res://scripts/bosses/boss_controller.gd"))).new()
	controller.set_meta("index", index)
	controller.patterns = PatternRunner.new()
	world.add_child(controller.patterns)
	world.origin_shifted.connect(controller.patterns.on_origin_shifted)
	world.add_child(controller)
	if controller.has_method("on_origin_shifted"):
		world.origin_shifted.connect(Callable(controller, "on_origin_shifted"))
	var view: Vector2 = _view_size()
	if active_count() == 0:
		arena_center = player.position
		arena_radius = view.x * 0.5 * Data.cfg_float("bosses.arena_radius_screens")
		_clean_slate(view)
	else:
		arena_radius *= Data.cfg_float("bosses.second_boss_arena_mult")
	var at: Vector2 = player.position + Vector2.from_angle(GameAuthority.run.rng.spawns.randf() * TAU) * view.y * 0.4
	if not controller.spawn(boss, at):
		controller.queue_free()
		return null
	controller.defeated.connect(_on_defeated)
	controllers.append(controller)
	_set_arena(true)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_APPEARS") % tr(str(boss.get("name_key", ""))))
	if banter != null:
		banter.say_line(GodRules.line("boss_entrance", boss_id, str(player.hero.get("id", ""))))
		if GameAuthority.gods != null:
			banter.say_line(GodRules.boss_god_line(boss_id, GameAuthority.gods.bound_ids(player)))
	boss_spawned.emit(controller)
	return controller


## Routes a hit on a boss's body to its controller.
func on_boss_hit(slot: int, amount: float, element_mult: float, attacker: Player, push: Vector2) -> float:
	for controller: BossController in controllers:
		if controller.slot == slot and controller.is_alive():
			return controller.on_hit(amount, element_mult, attacker, push)
	return amount


func _process(_delta: float) -> void:
	var run: RunState = GameAuthority.run
	if run == null or run.ended:
		return
	while not _schedule.is_empty() and run.arc_s() >= float(_schedule[0]["time_s"]):
		var next: Dictionary = _schedule.pop_front()
		spawn_boss(str(next["id"]), int(next["index"]))
	if run.boss_arena_active:
		_keep_players_in()
	queue_redraw()


func _keep_players_in() -> void:
	for player: Player in GameAuthority.players:
		var offset: Vector2 = player.position - arena_center
		if offset.length() > arena_radius - player.body_radius:
			player.position = arena_center + offset.normalized() * (arena_radius - player.body_radius)


## Every regular enemy on screen bursts into XP orbs.
func _clean_slate(view: Vector2) -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	var reach: float = view.length() * 0.5
	for slot: int in enemies.capacity:
		if enemies.active[slot] != 0 and enemies.positions[slot].distance_to(arena_center) <= reach \
				and not bool(enemies.type_of(slot).get("boss", false)):
			GameAuthority.kill_enemy(slot, null)


func _set_arena(on: bool) -> void:
	GameAuthority.run.boss_arena_active = on
	if spawner == null:
		return
	if on:
		var table: Dictionary = RunArc.wave_table(GameAuthority.run.level_data)
		spawner.fodder_only = PackedStringArray(table.get("boss_fodder", []))
		spawner.rate_mult = Data.cfg_float("bosses.fodder_spawn_rate")
	else:
		spawner.fodder_only = PackedStringArray()
		spawner.rate_mult = 1.0


func _on_defeated(controller: BossController) -> void:
	var boss_id: String = str(controller.data.get("id", ""))
	var at: Vector2 = controller.position_now()
	if GameAuthority.enemies != null and controller.slot != -1:
		at = GameAuthority.enemies.positions[controller.slot]
	var index: int = int(controller.get_meta("index", _defeated))
	_defeated += 1
	if active_count() == 0:
		_set_arena(false)
		if GameAuthority.enemy_shots != null:
			GameAuthority.enemy_shots.clear_all(EnemyProjectiles.BOSS)
	if chests != null:
		chests.drop(at, true)
	var milestone: Array = Data.cfg("run_arc.milestone_gold")
	if gold != null and index >= 0:
		gold.drop_pile(at, float(milestone[mini(index, milestone.size() - 1)]), Data.cfg_int("pickups.pile_coins") * 2)
	var hero_id: String = str(controller.data.get("unlocks_hero", ""))
	if hero_id != "" and HeroRules.unlock(hero_id):
		Meta.note_unlock(tr("HERO_UNLOCKED") % tr(str(HeroRules.find(hero_id).get("name_key", ""))))
	Meta.note_boss_defeated(str(controller.data.get("enemy", boss_id)), index,
			str(controller.call("secret_earned")) if controller.has_method("secret_earned") else "")
	if index == 2 and unraveling != null:
		unraveling.begin()
	boss_defeated.emit(boss_id)
	if boons != null:
		boons.offer()
	controller.patterns.queue_free()
	controller.queue_free()
	controllers.erase(controller)


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	arena_center -= shift_px


func _view_size() -> Vector2:
	return get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)


func _draw() -> void:
	if GameAuthority.run != null and GameAuthority.run.boss_arena_active:
		draw_arc(arena_center, arena_radius, 0.0, TAU, 96, Color.html(Data.cfg_string("bosses.arena_color")), 3.0)
	_draw_markers()


## A bold, slowly pulsing ring around each living boss so it stands out from
## the horde and the ground (placeholder art can blend in).
func _draw_markers() -> void:
	var marker: Dictionary = Data.cfg("bosses.marker")
	var seconds: float = GameAuthority.run.elapsed_s if GameAuthority.run != null else 0.0
	var pulse: float = 0.5 + 0.5 * sin(seconds * TAU * float(marker.get("pulse_hz", 1.0)))
	var width: float = float(marker.get("width_px", 2.0))
	for controller: BossController in controllers:
		if not controller.is_alive():
			continue
		var at: Vector2 = controller.position_now()
		var ring: float = GameAuthority.enemies.radius[controller.slot] + float(marker.get("gap_px", 4.0)) + pulse * float(marker.get("pulse_px", 3.0))
		draw_arc(at, ring, 0.0, TAU, 48, Color.html(str(marker.get("outline_color", "#000000"))), width + 3.0)
		draw_arc(at, ring, 0.0, TAU, 48, Color.html(str(marker.get("color", "#ff3050"))), width)
