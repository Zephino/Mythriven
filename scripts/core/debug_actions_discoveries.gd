extends Node
## Dev-build only: Phase 14 test options for the debug menu (points of
## interest, the Trader, world events). Created by RunSystems.

var systems: RunSystems

var _next_poi: int = 0


func _ready() -> void:
	DebugMenu.add_info(self, _info)
	DebugMenu.add_button(self, "DEBUG_PLACE_POI", _place_poi)
	DebugMenu.add_button(self, "DEBUG_GIVE_GOLD", _give_gold)
	DebugMenu.add_button(self, "DEBUG_CHAOS_SURGE", systems.director.start_event.bind("chaos_surge"))
	DebugMenu.add_button(self, "DEBUG_DIVINE_STORM", systems.director.start_event.bind("divine_storm"))


func _info() -> String:
	var run: RunState = GameAuthority.run
	if run == null:
		return ""
	var event: String = systems.director.event_id()
	return tr("DEBUG_DISCOVERIES_INFO") % [systems.pois.nearby.size(), run.poi_state.size(), run.reroll_tokens, run.banish_tokens,
			tr("EVENT_" + event.to_upper() + "_NAME") if event != "" else "-"]


## Places the next kind of point of interest a short walk from the player.
func _place_poi() -> void:
	var player: Player = GameAuthority.local_player()
	var all: Array[Dictionary] = PoiRules.all()
	if player == null or all.is_empty():
		return
	var poi: Dictionary = all[_next_poi % all.size()]
	_next_poi += 1
	systems.pois.place(str(poi["id"]), player.position + Vector2(Data.cfg_float("debug.poi_offset_px"), 0.0))
	DebugMenu.show_result(tr("DEBUG_POI_PLACED") % tr(str(poi["name_key"])))


func _give_gold() -> void:
	var player: Player = GameAuthority.local_player()
	if player != null:
		GameAuthority.collect_gold(player, Data.cfg_float("debug.gold_amount"))
