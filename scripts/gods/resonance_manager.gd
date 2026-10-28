class_name ResonanceManager
extends Node
## Divine Resonance (GAME_DESIGN.md: Divine Resonance and Patronage):
## 1. Bind a compatible pair: a "Resonance discovered" banner names it the first
##    time (kept for the Compendium).
## 2. Harmony applies while both are bound.
## 3. When both meters are full the god buttons pulse together and a Resonance
##    button appears between them (touch), or R / Q+E (PC) / LB+RB (gamepad).
## 4. Firing it uses both meters. Firing either god alone still works.
## 5. Incompatible pairs have no Resonance.

const FILE := "resonances.json"
const PROFILE_KEY := "resonances"
## Prefix of Harmony switches in player.god_flags.
const HARMONY := "harmony_"

var gods: GodManager
var layer: ResonanceLayer
var banter: BanterBubble


func _ready() -> void:
	gods.god_bound.connect(_on_gods_changed)
	gods.god_released.connect(_on_gods_changed)


static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	return found


## The Resonance two gods form, or {}.
static func find_pair(god_a: String, god_b: String) -> Dictionary:
	for resonance: Dictionary in all():
		var pair: Array = resonance.get("gods", [])
		if pair.has(god_a) and pair.has(god_b) and god_a != god_b:
			return resonance
	return {}


## The Resonance `player`'s two bound gods form right now, or {}.
func active_for(player: Player) -> Dictionary:
	var ids: PackedStringArray = gods.bound_ids(player)
	return find_pair(ids[0], ids[1]) if ids.size() >= 2 else {}


## True when the pair resonates and both meters are full.
func ready_for(player: Player) -> bool:
	return not active_for(player).is_empty() and gods.meter(player, 0) >= 1.0 and gods.meter(player, 1) >= 1.0


## Fires the Resonance (uses both meters). Returns true if it fired.
func fire(player: Player) -> bool:
	if not ready_for(player) or not player.alive:
		return false
	var resonance: Dictionary = active_for(player)
	gods.set_meter(player, 0, 0.0)
	gods.set_meter(player, 1, 0.0)
	if layer != null:
		layer.run_resonance(resonance, player)
	# Väinämöinen: reactions inside an active Resonance count double for Verses.
	player.god_flags["resonance_active_until"] = GameAuthority.run.elapsed_s + float((resonance.get("summon", {}) as Dictionary).get("duration_s", 3.0))
	return true


func _unhandled_input(event: InputEvent) -> void:
	var player: Player = GameAuthority.local_player()
	if player != null and not get_tree().paused and event.is_action_pressed("resonance") and fire(player):
		get_viewport().set_input_as_handled()


func _on_gods_changed(player: Player, _god_id: String) -> void:
	for key: Variant in player.god_flags.keys():
		if str(key).begins_with(HARMONY):
			player.god_flags.erase(key)
	var resonance: Dictionary = active_for(player)
	if resonance.is_empty():
		return
	var harmony: Dictionary = resonance.get("harmony", {})
	for key: String in harmony:
		player.god_flags[HARMONY + key] = harmony[key]
	if Profile.add_to_list(EvolutionRules.CODEX_SECTION, PROFILE_KEY, str(resonance["id"])):
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("RESONANCE_DISCOVERED") % tr(str(resonance.get("name_key", ""))))
		if banter != null:
			banter.say_line(GodRules.line("resonance", str(resonance["id"]), ""))
