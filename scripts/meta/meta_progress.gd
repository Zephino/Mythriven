extends Node
## Autoload "Meta": everything between runs (Phase 15; GAME_DESIGN.md: Death,
## permanent progression, and saving; Discovery and feel). It keeps the menu
## choices for the next run (level, Swift Mode), watches each run for the
## Bestiary, achievements, secrets, and the death recap, and banks gold when
## the run ends:
##   - dying keeps 100% of the run's gold; quitting keeps 10% from 5:00, none before;
##   - while playing, the run's gold and time are saved every few seconds, so a
##     crash or force-close is settled as a quit the next time the game starts;
##   - anything used outside a level (unlocks, discoveries) is saved the moment
##     it's earned.
## Game systems report feats with the note_*() functions.

## Something was earned during a run (shown as a banner).
signal earned(text: String)

## Chosen on the menus for the next run.
var level_id: String = ""
var swift: bool = false
## Which menu opens when the main scene loads without a run to start:
## "title", "hero_select", or "hall".
var next_screen: String = "title"
## A run being taken over from another device (RunSnapshot), until Main has rebuilt it.
var takeover: Dictionary = {}
## A message to show when the menus open next: [title key, text key] (e.g. this run went on on another device).
var notice: Array = []
var tracker: RunTracker = RunTracker.new()
## The last finished run's recap: {"lines", "tip"} (DeathRecap.build).
var last_recap: Dictionary = {}
## Cloud saves (Phase 20).
var cloud: CloudSync

var _finished: bool = true
var _checkpoint_left: float = 0.0
var _check_left: float = 0.0


func _ready() -> void:
	SaveGame.data()
	Settings.apply(get_tree())
	cloud = CloudSync.new()
	add_child(cloud)
	settle_unfinished_run()
	GameAuthority.run_started.connect(_on_run_started)
	GameAuthority.player_spawned.connect(_on_player_spawned)
	GameAuthority.player_damaged.connect(_on_player_damaged)
	GameAuthority.enemy_killed.connect(_on_enemy_killed)
	GameAuthority.elite_killed.connect(_on_elite_killed)
	GameAuthority.gold_collected.connect(_on_gold_collected)
	GameAuthority.run_ended.connect(_on_run_ended)


## The level the next run is on: the one chosen if it's unlocked, else the first.
func selected_level() -> String:
	for level: Dictionary in LevelRules.all():
		if str(level.get("id", "")) == level_id and LevelRules.is_unlocked(level):
			return level_id
	return Data.cfg_string("run.default_level")


## A run that was still going when the game closed is settled as a quit.
func settle_unfinished_run() -> int:
	var checkpoint: Dictionary = SaveGame.data()["run_in_progress"]
	if checkpoint.is_empty():
		return 0
	var kept: int = Banking.banked_from_checkpoint(checkpoint)
	SaveGame.data()["gold"] = SaveGame.gold() + kept
	SaveGame.data()["run_in_progress"] = {}
	SaveGame.commit("gold")
	return kept


func _on_run_started(run: RunState) -> void:
	tracker = RunTracker.new()
	last_recap = {}
	_finished = false
	_checkpoint_left = Data.cfg_float("meta.checkpoint_s")
	var level: String = str(run.level_data.get("id", ""))
	if Net.in_run():
		# Co-op: the host's Omens and Swift Mode apply to everyone, and enemies scale with the players.
		OmenRules.apply_to_run(run, Net.omens, Net.swift)
		_apply_coop_scaling(run, Net.roster.size())
	elif not takeover.is_empty():
		# Taken over from another device: that run's Omens and Swift Mode, whatever this device has chosen.
		OmenRules.apply_to_run(run, PackedStringArray(takeover.get("omens", [])), bool(takeover.get("swift", false)))
	else:
		OmenRules.apply_to_run(run, OmenRules.active(), swift and LevelRules.swift_unlocked(level))
	# Later packs are harder (enemies.pack_difficulty); HP and damage are applied by LevelScaling.
	run.spawn_mult *= LevelScaling.pack("spawn_mult", run.level_data)


## Co-op scaling (GAME_DESIGN.md: Fairness rules / Scaling): +60% enemy HP and
## +50% spawns per extra player; boss HP ×(1 + 0.75 per extra player).
static func _apply_coop_scaling(run: RunState, players: int) -> void:
	var extra: int = maxi(players - 1, 0)
	run.coop_players = players
	run.coop_hp_mult = 1.0 + Data.cfg_float("coop.enemy_hp_per_extra_player") * extra
	run.coop_boss_hp_mult = 1.0 + Data.cfg_float("coop.boss_hp_per_extra_player") * extra
	run.spawn_mult *= 1.0 + Data.cfg_float("coop.spawns_per_extra_player") * extra


func _on_player_spawned(player: Player) -> void:
	if GameAuthority.run == null:
		return
	OmenRules.apply_to_player(player, GameAuthority.run)
	if player.is_local and not player.hero.is_empty():
		player.palette_color = Rewards.palette(str(player.hero.get("id", "")))
		player.aura_color = Rewards.equipped_aura()


func _process(delta: float) -> void:
	var run: RunState = GameAuthority.run
	if run == null or run.ended or _finished:
		return
	_checkpoint_left -= delta
	if _checkpoint_left <= 0.0:
		_checkpoint_left = Data.cfg_float("meta.checkpoint_s")
		_checkpoint(run)
	_check_left -= delta
	if _check_left <= 0.0:
		_check_left = 1.0
		_check_during_run(run)


func _checkpoint(run: RunState) -> void:
	SaveGame.data()["run_in_progress"] = {"gold": TraderScreen.bankable(GameAuthority.local_player()), "arc_s": run.arc_s(), "omens": Array(run.omens), "swift": run.swift,
		"level": str(run.level_data.get("id", ""))}
	SaveGame.commit("run_in_progress")


## Achievements and secrets that can happen at any moment of a run.
func _check_during_run(run: RunState) -> void:
	_announce(AchievementRules.check(_context(run)))
	if run.arc_s() >= Data.cfg_float("secrets.beggar_king_s") and tracker.gold_pickups == 0:
		note_secret("the_beggar_king")


func _context(run: RunState) -> Dictionary:
	return {"arc_s": run.arc_s(), "kills": run.kills, "level": run.level, "swift": run.swift, "omens": run.omens.size()}


# --- Events from the run -------------------------------------------------------------

func _on_player_damaged(player: Player, amount: float, source_id: String) -> void:
	if player.is_local and GameAuthority.run != null:
		tracker.note_damage(GameAuthority.run.elapsed_s, source_id, amount)


func _on_enemy_killed(_slot: int, enemy_type: Dictionary, _at: Vector2, _killer: Player) -> void:
	Bestiary.count_kill(str(enemy_type.get("id", "")))
	SaveGame.add_stat("kills_total", 1.0)


func _on_elite_killed(_at: Vector2, _enemy_type: Dictionary, _is_copy: bool) -> void:
	tracker.elites_killed += 1
	SaveGame.add_stat("elites_total", 1.0)


func _on_gold_collected(_player: Player, _amount: float) -> void:
	tracker.gold_pickups += 1


func note_damage_dealt(weapon: WeaponInstance, amount: float) -> void:
	tracker.note_dealt(weapon.base_id if weapon != null else "", amount)


func note_god_bound(god_id: String) -> void:
	if not tracker.gods_bound.has(god_id):
		tracker.gods_bound.append(god_id)
	GodLevels.mark_bound(god_id)


func note_resonance_fired(resonance_id: String) -> void:
	if not tracker.resonances_fired.has(resonance_id):
		tracker.resonances_fired.append(resonance_id)
	Profile.add_to_list("codex", "resonances_fired", resonance_id)


func note_evolution() -> void:
	tracker.evolutions += 1


func note_labor_done(total_done: int, all_done: bool) -> void:
	tracker.labors_done = total_done
	if all_done:
		note_secret("the_twelve_labors")


## A boss fell: `index` 0/1/2 is the 10/20/30-minute boss. `secret` is a
## secret the fight earned (e.g. Medusa beaten without being petrified).
func note_boss_defeated(boss_id: String, index: int, secret: String = "") -> void:
	tracker.bosses_defeated.append(boss_id)
	SaveGame.add_stat("bosses_total", 1.0)
	if GameAuthority.run != null and index >= 0:
		_announce(LevelRules.note_boss(str(GameAuthority.run.level_data.get("id", "")), boss_id, index))
	if secret != "":
		note_secret(secret)


func note_secret(secret_id: String) -> void:
	_announce(SecretRules.reveal(secret_id))


## Something new outside the achievement and secret lists (e.g. a Hero unlocked by a boss).
func note_unlock(text: String) -> void:
	_announce(PackedStringArray([text]))


## A banter line was heard: it joins the Words of Legend.
func note_banter(line_id: String) -> void:
	if line_id != "":
		SaveGame.add_to("words", line_id)


func _announce(lines: PackedStringArray) -> void:
	for line: String in lines:
		tracker.new_unlocks.append(line)
		earned.emit(line)


# --- The end of a run ---------------------------------------------------------------

func _on_run_ended(run: RunState) -> void:
	_finish(run, false)


## Quits the run from the pause menu: banks 10% of its gold from 5:00, none before.
func quit_run() -> void:
	var run: RunState = GameAuthority.run
	if run == null or _finished:
		return
	run.ended = true
	_finish(run, true)


## This run went on on another device (RunSnapshot): it ends here with nothing banked or counted (the other device
## banks it when it ends), and the game goes back to the title with a message.
func hand_over() -> void:
	var run: RunState = GameAuthority.run
	if run == null or _finished:
		return
	_finished = true
	run.ended = true
	SaveGame.data()["run_in_progress"] = {}
	SaveGame.commit("run_in_progress")
	notice = ["UI_RUN_TAKEN_OVER_TITLE", "UI_RUN_TAKEN_OVER"]
	GameAuthority.selected_hero_id = ""
	next_screen = "title"
	get_tree().paused = false
	get_tree().reload_current_scene()


func _finish(run: RunState, quit: bool) -> void:
	if _finished:
		return
	_finished = true
	# F1 debug gold is never banked (TraderScreen.bankable).
	var banked: int = Banking.banked(TraderScreen.bankable(GameAuthority.local_player()), run.arc_s(), quit, run.omens, run.swift)
	var save: Dictionary = SaveGame.data()
	save["gold"] = SaveGame.gold() + banked
	save["run_in_progress"] = {}
	SaveGame.add_stat("runs", 1.0)
	SaveGame.add_stat("gold_banked_total", banked)
	var player: Player = GameAuthority.local_player()
	var hero_id: String = str(player.hero.get("id", "")) if player != null else ""
	if hero_id != "":
		save["mastery"][hero_id] = float((save["mastery"] as Dictionary).get(hero_id, 0.0)) + run.elapsed_s
	var best_before: float = Records.best(hero_id, str(run.level_data.get("id", "")), run.swift)
	Records.note(run, hero_id)
	if GameAuthority.gods != null and player != null and GameAuthority.gods.bound_ids(player).has("tyche") \
			and banked == Data.cfg_int("secrets.fortune_gold"):
		note_secret("fortunes_favor")
	var hint: String = SecretRules.count_run()
	if hint != "":
		tracker.new_unlocks.append(TranslationServer.translate("ORACLE_NEW_HINT"))
	_announce(AchievementRules.check(_context(run)))
	SaveGame.commit("run")
	if not quit:
		last_recap = DeathRecap.build(run, player, tracker, banked, best_before)
