extends HeroKit
## Heracles. Legend Trait, Twelve Labors: Labors appear one at a time as HUD
## goals; each completed Labor grants a permanent run bonus, up to 12.
## Passive, Lion's Hide: +2 Armor, and the first hit every 8 s is halved.

var labor_index: int = 0
var progress: float = 0.0
var completed: int = 0

var _hide_ready_in: float = 0.0
var _kill_times := PackedFloat64Array()
var _clock: float = 0.0
var _since_hit: float = 0.0
var _banner_left: float = 0.0
var _banner_key: String = ""


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	player.stats.add_bonus("armor", float(passive_data().get("armor", 0.0)))
	GameAuthority.enemy_killed.connect(_on_enemy_killed)
	GameAuthority.player_damaged.connect(_on_player_damaged)
	GameAuthority.xp_collected.connect(_on_xp_collected)


func labors() -> Array:
	return trait_data().get("labors", [])


func current_labor() -> Dictionary:
	return labors()[labor_index] if labor_index < labors().size() else {}


func _process(delta: float) -> void:
	_clock += delta
	_since_hit += delta
	_hide_ready_in = maxf(_hide_ready_in - delta, 0.0)
	_banner_left = maxf(_banner_left - delta, 0.0)
	var goal: Dictionary = current_labor().get("goal", {})
	match str(goal.get("type", "")):
		"no_damage_for":
			progress = _since_hit
			_check(float(goal.get("seconds", 0.0)))
		"reach_level":
			progress = GameAuthority.run.level if GameAuthority.run != null else 0
			_check(float(goal.get("level", 0)))


## Lion's Hide: the first hit every 8 s is halved.
func incoming_damage(amount: float) -> float:
	if _hide_ready_in > 0.0:
		return amount
	_hide_ready_in = float(passive_data().get("halve_hit_every_s", 8.0))
	return amount * 0.5


func hud_text() -> String:
	if _banner_left > 0.0:
		return tr("LABOR_COMPLETE") % tr(_banner_key)
	var labor: Dictionary = current_labor()
	if labor.is_empty():
		return tr("LABORS_ALL_DONE")
	return tr("LABOR_HUD") % [labor_index + 1, tr(str(labor["name_key"])), goal_text(labor.get("goal", {}))]


## "Defeat enemies 12 / 50" and similar, for the HUD.
func goal_text(goal: Dictionary) -> String:
	var key: String = "LABOR_GOAL_" + str(goal.get("type", "")).to_upper()
	match str(goal.get("type", "")):
		"kills", "collect_xp":
			return tr(key) % [floori(progress), int(goal.get("count", 0))]
		"kills_within":
			return tr(key) % [int(goal.get("count", 0)), int(goal.get("seconds", 0)), floori(progress)]
		"no_damage_for":
			return tr(key) % [floori(progress), int(goal.get("seconds", 0))]
		"reach_level":
			return tr(key) % [floori(progress), int(goal.get("level", 0))]
	return ""


func _on_enemy_killed(_slot: int, _enemy_type: Dictionary, _at: Vector2, killer: Player) -> void:
	if killer != player:
		return
	var goal: Dictionary = current_labor().get("goal", {})
	match str(goal.get("type", "")):
		"kills":
			progress += 1
			_check(float(goal.get("count", 0)))
		"kills_within":
			_kill_times.append(_clock)
			while not _kill_times.is_empty() and _clock - _kill_times[0] > float(goal.get("seconds", 0)):
				_kill_times.remove_at(0)
			progress = _kill_times.size()
			_check(float(goal.get("count", 0)))


func _on_player_damaged(hurt: Player, _amount: float, _source: String) -> void:
	if hurt == player:
		_since_hit = 0.0


func _on_xp_collected(collector: Player, amount: float) -> void:
	var goal: Dictionary = current_labor().get("goal", {})
	if collector == player and str(goal.get("type", "")) == "collect_xp":
		progress += amount
		_check(float(goal.get("count", 0)))


func _check(target: float) -> void:
	if progress < target or labor_index >= labors().size():
		return
	var labor: Dictionary = current_labor()
	var reward: Dictionary = labor.get("reward", {})
	player.stats.add_bonus(str(reward.get("stat", "")), float(reward.get("amount", 0.0)))
	player.refresh_stats()
	completed += 1
	labor_index += 1
	progress = 0.0
	_kill_times.clear()
	_since_hit = 0.0
	_banner_key = str(labor["name_key"])
	_banner_left = Data.cfg_float("heroes.labor_banner_s")
