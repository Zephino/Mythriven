extends Node
## Dev-build only: Phase 11 test options for the debug menu (shrines, trials,
## binding, meters). Created by RunSystems.

var systems: RunSystems

var _next_god: int = 0


func _ready() -> void:
	DebugMenu.add_info(self, _info)
	DebugMenu.add_button(self, "DEBUG_SHRINE_NEARBY", _shrine_nearby)
	DebugMenu.add_button(self, "DEBUG_BIND_NEXT_GOD", _bind_next)
	DebugMenu.add_button(self, "DEBUG_FILL_GOD_METERS", _fill_meters)


func _info() -> String:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return ""
	var parts := PackedStringArray()
	for slot: Dictionary in systems.gods.gods_of(player):
		parts.append("%s %d%%" % [tr(str(slot["god"].get("name_key", ""))), roundi(float(slot["meter"]) * 100.0)])
	return tr("DEBUG_GODS_INFO") % [", ".join(parts) if not parts.is_empty() else "-", systems.shrines.shrines.size()]


## Places the next god's shrine right next to the player (cycles through all 8, trials included).
func _shrine_nearby() -> void:
	var player: Player = GameAuthority.local_player()
	var all: Array[Dictionary] = GodRules.all()
	if player == null or all.is_empty():
		return
	var god: Dictionary = all[_next_god % all.size()]
	_next_god += 1
	systems.shrines.add(player.position + Vector2(Data.cfg_float("debug.shrine_offset_px"), 0.0), str(god["id"]))
	DebugMenu.show_result(tr("DEBUG_SHRINE_PLACED") % [tr(str(god["name_key"])), str((god.get("shrine", {}) as Dictionary).get("type", ""))])


func _bind_next() -> void:
	var player: Player = GameAuthority.local_player()
	var all: Array[Dictionary] = GodRules.all()
	if player == null or all.is_empty():
		return
	var god: Dictionary = all[_next_god % all.size()]
	_next_god += 1
	var release: int = 0 if systems.gods.is_full(player) else -1
	systems.gods.bind(player, str(god["id"]), release)
	DebugMenu.show_result(tr("DEBUG_GOD_BOUND") % tr(str(god["name_key"])))


func _fill_meters() -> void:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return
	for index: int in systems.gods.gods_of(player).size():
		systems.gods.set_meter(player, index, 1.0)
