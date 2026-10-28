extends Node
## Dev-build only: enemy and combat test options for the debug menu
## (Phase 4 onward). Created by main.gd; removed with the scene on Retry.

var enemies: EnemyManager
var spawner: EnemySpawner


func _ready() -> void:
	DebugMenu.add_info(self, _enemy_info)
	DebugMenu.add_button(self, "DEBUG_SPAWN_CHASERS", _spawn_chasers)
	DebugMenu.add_button(self, "DEBUG_SPAWN_SWARM", _spawn_swarm)
	DebugMenu.add_button(self, "DEBUG_FILL_TO_CAP", _fill_to_cap)
	DebugMenu.add_button(self, "DEBUG_KILL_ALL", _kill_all)
	DebugMenu.add_check(self, "DEBUG_AUTO_SPAWN", spawner.auto_spawn, _on_auto_spawn_toggled)
	DebugMenu.add_check(self, "DEBUG_GOD_MODE", false, _on_god_mode_toggled)
	DebugMenu.add_button(self, "DEBUG_HEAL", _heal)


func _enemy_info() -> String:
	var player: Player = GameAuthority.local_player()
	var player_hp: int = roundi(player.hp) if player != null else 0
	return tr("DEBUG_ENEMY_INFO") % [
		enemies.active_count(), enemies.capacity, player_hp, TextFormat.run_time(GameAuthority.run.elapsed_s),
	]


func _spawn_chasers() -> void:
	spawner.spawn_ring(Data.cfg_string("enemies.auto_chaser_type"), Data.cfg_int("debug.spawn_count"))


func _spawn_swarm() -> void:
	var sizes: Array = Data.cfg("enemies.swarm_pack_size")
	spawner.spawn_pack(Data.cfg_string("enemies.auto_swarm_type"), int(sizes[1]))


## Heaviest stress test: spawn until the enemy cap (500) is reached.
func _fill_to_cap() -> void:
	spawner.spawn_ring(Data.cfg_string("enemies.auto_chaser_type"), enemies.free_slots())


## Removes every enemy without rewards (test only).
func _kill_all() -> void:
	for i: int in enemies.capacity:
		if enemies.active[i] != 0:
			enemies.despawn(i)


func _on_auto_spawn_toggled(on: bool) -> void:
	spawner.auto_spawn = on


func _on_god_mode_toggled(on: bool) -> void:
	for player: Player in GameAuthority.players:
		player.god_mode = on


func _heal() -> void:
	for player: Player in GameAuthority.players:
		GameAuthority.heal_player(player, player.max_hp)
