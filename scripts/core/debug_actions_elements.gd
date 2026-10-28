extends Node
## Dev-build only: element and status test options for the debug menu
## (Phase 8). Created by main.gd; removed with the scene on Retry.

const TEST_STATUSES: PackedStringArray = ["burn", "chill", "shock", "soaked", "poison", "hex"]
const SPELLS: PackedStringArray = ["ember", "frost", "spark", "breeze", "glimmer", "shade"]

var enemies: EnemyManager


func _ready() -> void:
	DebugMenu.add_info(self, _status_info)
	DebugMenu.add_button(self, "DEBUG_GIVE_SPELLS", _give_spells)
	for status_id: String in TEST_STATUSES:
		DebugMenu.add_button(self, "DEBUG_APPLY_" + status_id.to_upper(), _apply_nearby.bind(status_id))
	DebugMenu.add_button(self, "DEBUG_FREEZE_NEARBY", _freeze_nearby)
	DebugMenu.add_button(self, "DEBUG_JUMP_TO_UNRAVELING", _jump_time)


func _status_info() -> String:
	var counts: Dictionary = {}
	for status_id: String in TEST_STATUSES + PackedStringArray(["frozen"]):
		counts[status_id] = 0
	for i: int in enemies.capacity:
		if enemies.active[i] == 0:
			continue
		for status_id: String in counts:
			if enemies.statuses.has(i, status_id):
				counts[status_id] = int(counts[status_id]) + 1
	var player: Player = GameAuthority.local_player()
	var on_player: String = ", ".join(PackedStringArray(player.statuses.timers.keys())) if player != null else ""
	return tr("DEBUG_STATUS_INFO") % [
		counts["burn"], counts["chill"], counts["frozen"], counts["shock"], counts["soaked"], counts["poison"],
		counts["hex"], on_player,
	]


## Gives the local player every elemental spell (as many as there are free weapon slots).
func _give_spells() -> void:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return
	for spell_id: String in SPELLS:
		var owned: bool = false
		for weapon: WeaponInstance in player.weapons:
			owned = owned or weapon.id() == spell_id
		if not owned and player.weapons.size() < Data.cfg_int("level_up.max_weapons"):
			GameAuthority.give_weapon(player, spell_id)


func _apply_nearby(status_id: String) -> void:
	for slot: int in _nearby():
		enemies.statuses.apply(slot, status_id)


## Three Chill stacks: every nearby enemy becomes Frozen.
func _freeze_nearby() -> void:
	for slot: int in _nearby():
		for _i: int in 3:
			enemies.statuses.apply(slot, "chill")


## Sets the run timer to 30:00, when enemies start passing statuses to players.
func _jump_time() -> void:
	GameAuthority.run.elapsed_s = maxf(GameAuthority.run.elapsed_s, Data.cfg_float("debug.jump_to_time_s"))


func _nearby() -> PackedInt32Array:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return PackedInt32Array()
	return enemies.query(player.position, Data.cfg_float("debug.status_test_radius_px"))
