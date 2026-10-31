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
	"ammit": "res://scripts/bosses/ammit_boss.gd",
	"set": "res://scripts/bosses/set_boss.gd",
	"apep": "res://scripts/bosses/apep_boss.gd",
	"scathach": "res://scripts/bosses/scathach_boss.gd",
	"ferdiad": "res://scripts/bosses/ferdiad_boss.gd",
	"balor": "res://scripts/bosses/balor_boss.gd",
	"cerberus": "res://scripts/bosses/cerberus_boss.gd",
	"hrungnir": "res://scripts/bosses/hrungnir_boss.gd",
	"green_knight": "res://scripts/bosses/green_knight_boss.gd",
	"mordred": "res://scripts/bosses/mordred_boss.gd",
	"twrch_trwyth": "res://scripts/bosses/twrch_trwyth_boss.gd",
	"humbaba": "res://scripts/bosses/humbaba_boss.gd",
	"bull_of_heaven": "res://scripts/bosses/bull_of_heaven_boss.gd",
	"tiamat": "res://scripts/bosses/tiamat_boss.gd",
	"elk_of_hiisi": "res://scripts/bosses/elk_of_hiisi_boss.gd",
	"iku_turso": "res://scripts/bosses/iku_turso_boss.gd",
	"louhi": "res://scripts/bosses/louhi_boss.gd",
	"dragon_third_labour": "res://scripts/bosses/dragon_third_labour_boss.gd",
	"witch_fourth_labour": "res://scripts/bosses/witch_fourth_labour_boss.gd",
	"white_div": "res://scripts/bosses/white_div_boss.gd",
	"zmey_gorynych": "res://scripts/bosses/zmey_gorynych_boss.gd",
	"baba_yaga": "res://scripts/bosses/baba_yaga_boss.gd",
	"koschei": "res://scripts/bosses/koschei_boss.gd",
	"thrym": "res://scripts/bosses/thrym_boss.gd",
	"ymir": "res://scripts/bosses/ymir_boss.gd",
	"thanatos": "res://scripts/bosses/thanatos_boss.gd",
	"typhon": "res://scripts/bosses/typhon_boss.gd",
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
## Which of the run's bosses (by index) were beaten, so a run taken over on another device skips them (RunSnapshot).
var defeated_indices: Array[int] = []


func _ready() -> void:
	z_index = 2
	GameAuthority.bosses = self
	CoopMirror.attach(self, "bosses")
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
func on_boss_hit(slot: int, amount: float, element_mult: float, attacker: Player, push: Vector2, element: String = "") -> float:
	for controller: BossController in controllers:
		if controller.slot == slot and controller.is_alive():
			controller.on_element_hit(element)
			return controller.on_hit(amount, element_mult, attacker, push)
	return amount


## Damage over time (Burn, Poison) on a boss, after its rules (Koschei can't die while his egg is whole).
func cap_boss_dot(slot: int, amount: float) -> float:
	for controller: BossController in controllers:
		if controller.slot == slot and controller.is_alive():
			return controller.cap_lethal(amount)
	return amount


## A run taken over from another device (RunSnapshot): the bosses already beaten don't come again. One that was
## being fought comes back at once and the fight starts fresh.
func skip_beaten(beaten: Array) -> void:
	for value: Variant in beaten:
		var index: int = int(value)
		if not defeated_indices.has(index):
			defeated_indices.append(index)
			_defeated += 1
	_schedule.assign(_schedule.filter(func(entry: Dictionary) -> bool: return not defeated_indices.has(int(entry["index"]))))


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
			GameAuthority.place_player(player, arena_center + offset.normalized() * (arena_radius - player.body_radius))


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
	defeated_indices.append(index)
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
	SecretPassives.on_boss_defeated()
	Meta.note_boss_defeated(str(controller.data.get("enemy", boss_id)), index,
			str(controller.call("secret_earned")) if controller.has_method("secret_earned") else "")
	if index == 2 and unraveling != null:
		unraveling.begin()
	boss_defeated.emit(boss_id)
	if boons != null:
		boons.offer()
		# Co-op: every player picks their own Boon on their own device.
		for player: Player in GameAuthority.players:
			if CoopChoices.is_remote(player) and player.alive:
				CoopChoices.offer(player, "boon", null)
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
## the horde and the ground (placeholder art can blend in). The boss is drawn
## again here, above the other enemies, so the horde never hides it.
func _draw_markers() -> void:
	var marker: Dictionary = Data.cfg("bosses.marker")
	var seconds: float = GameAuthority.run.elapsed_s if GameAuthority.run != null else 0.0
	var pulse: float = 0.5 + 0.5 * sin(seconds * TAU * float(marker.get("pulse_hz", 1.0)))
	var width: float = float(marker.get("width_px", 2.0))
	for controller: BossController in controllers:
		if not controller.is_alive() or controller.slot < 0:
			continue
		var at: Vector2 = controller.position_now()
		var body: float = GameAuthority.enemies.radius[controller.slot]
		# A boss with art stands out by itself (drawn above the horde by its controller): no ring (owner request 10/31/2026).
		if not PixelArt.boss(str(controller.data.get("enemy", ""))).is_empty():
			continue
		draw_circle(at, body + float(marker.get("body_outline_px", 2.0)), Color.html(str(marker.get("outline_color", "#000000"))))
		draw_circle(at, body, GameAuthority.enemies.base_color(controller.slot))
		var ring: float = body + float(marker.get("gap_px", 4.0)) + pulse * float(marker.get("pulse_px", 3.0))
		draw_arc(at, ring, 0.0, TAU, 48, Color.html(str(marker.get("outline_color", "#000000"))), width + 3.0)
		draw_arc(at, ring, 0.0, TAU, 48, Color.html(str(marker.get("color", "#ff3050"))), width)


# --- Co-op (CoopMirror) ------------------------------------------------------------------

func net_capture() -> Variant:
	var bosses: Array = []
	for controller: BossController in controllers:
		bosses.append([str(controller.data.get("id", "")), int(controller.get_meta("index", -1)), controller.net_capture()])
	return [arena_center, arena_radius, bosses]


## Joining player: stand-in controllers (the boss's own script, never acting)
## so the boss bar, cast bar, and signature visuals show.
func net_apply(state: Variant) -> void:
	arena_center = state[0]
	arena_radius = float(state[1])
	var wanted: Array = state[2]
	for i: int in range(controllers.size() - 1, -1, -1):
		var keep: bool = false
		for row: Variant in wanted:
			if str(row[0]) == str(controllers[i].data.get("id", "")) and int(row[1]) == int(controllers[i].get_meta("index", -1)):
				keep = true
		if not keep:
			controllers[i].queue_free()
			controllers.remove_at(i)
	for row: Variant in wanted:
		var controller: BossController = null
		for existing: BossController in controllers:
			if str(existing.data.get("id", "")) == str(row[0]) and int(existing.get_meta("index", -1)) == int(row[1]):
				controller = existing
		if controller == null:
			controller = load(str(SCRIPTS.get(str(row[0]), "res://scripts/bosses/boss_controller.gd"))).new()
			controller.puppet = true
			controller.data = find(str(row[0]))
			controller.set_meta("index", int(row[1]))
			add_child(controller)
			controllers.append(controller)
		controller.net_apply(row[2])
