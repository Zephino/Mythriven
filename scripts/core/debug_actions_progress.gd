extends Node
## Dev-build only: XP, level-up, and run log test options for the debug menu
## (Phase 6). Created by main.gd; removed with the scene on Retry.

var orbs: XpOrbs
var heals: HealPickups
var level_up_screen: LevelUpScreen


func _ready() -> void:
	DebugMenu.add_info(self, _progress_info)
	DebugMenu.add_button(self, "DEBUG_GAIN_LEVEL", _gain_level)
	DebugMenu.add_button(self, "DEBUG_DROP_ORBS", _drop_orbs)
	DebugMenu.add_button(self, "DEBUG_PULL_ORBS", _pull_orbs)
	DebugMenu.add_button(self, "DEBUG_DROP_AMBROSIA", _drop_ambrosia)
	DebugMenu.add_button(self, "DEBUG_MAX_BUILD", _max_build)
	DebugMenu.add_button(self, "DEBUG_END_RUN", _end_run)


func _progress_info() -> String:
	var run: RunState = GameAuthority.run
	return tr("DEBUG_PROGRESS_INFO") % [
		run.level, roundi(run.xp), roundi(LevelUpRules.xp_to_next(run.level)), run.unspent_level_ups,
		orbs.count(), roundi(run.gold), GameAuthority.auto_collect,
	]


## Gives exactly enough XP for the next level.
func _gain_level() -> void:
	var run: RunState = GameAuthority.run
	var player: Player = GameAuthority.local_player()
	if player != null:
		DebugMenu.toggle()
		GameAuthority.collect_xp(player, LevelUpRules.xp_to_next(run.level) - run.xp)


## Drops many small orbs around the player (tests merging and the pickup sound cap).
func _drop_orbs() -> void:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return
	var rng: RandomNumberGenerator = GameAuthority.run.rng.loot
	var spread: float = Data.cfg_float("xp.merge_far_px") * 2.0
	for _i: int in Data.cfg_int("debug.test_orb_count"):
		orbs.drop(player.position + Vector2(rng.randf_range(-spread, spread), rng.randf_range(-spread, spread)), 1.0)


## Like a Lodestone Shard: every orb flies to you at once.
func _pull_orbs() -> void:
	DebugMenu.toggle()
	orbs.pull_all()


## Drops one Ambrosia a short way from the player (it only flies to you when you're hurt).
func _drop_ambrosia() -> void:
	var player: Player = GameAuthority.local_player()
	if player != null:
		heals.drop(player.position + player.facing * Data.cfg_float("debug.spawn_behind_px") * 2.0)


## Fills every weapon and passive slot at max level, to test Gold/Heal cards and Auto-collect.
func _max_build() -> void:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return
	var guard: int = 0
	while not LevelUpRules.is_maxed(player) and guard < 500:
		guard += 1
		var cards: Array[Dictionary] = LevelUpRules.item_cards(player)
		GameAuthority.apply_card(player, cards[0])
	DebugMenu.show_result(tr("DEBUG_MAX_BUILD_DONE"))


## Ends the run now (writes the run log and shows the death screen).
func _end_run() -> void:
	DebugMenu.toggle()
	var player: Player = GameAuthority.local_player()
	if player != null:
		player.god_mode = false
		GameAuthority.damage_player(player, player.hp + player.armor + 1.0, "debug")
