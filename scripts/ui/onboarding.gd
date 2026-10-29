class_name Onboarding
extends Node
## First-run tips (GAME_DESIGN.md: Onboarding): a short line in the banner the
## first time the player levels up, sees a shrine, lands a weakness hit, fills
## a god's meter, and has a Resonance ready. Each shows once ever (remembered
## in the save) and all of them can be switched off in Settings, which can
## also show them again. The list is config settings.onboarding_tips.

var banner: Banner
var gods: GodManager
var resonance: ResonanceManager
var shrines: Shrines

var _check_in: float = 0.0


static func seen() -> Array:
	var listed: Variant = SaveGame.setting("tips_seen", [])
	return listed if listed is Array else []


## Shows every tip again from the next run.
static func reset() -> void:
	SaveGame.set_setting("tips_seen", [])


func _ready() -> void:
	GameAuthority.level_up_ready.connect(_on_level_up_ready)
	GameAuthority.enemy_damaged.connect(_on_enemy_damaged)


## Shows tip `id` if tips are on and it hasn't been shown before. Returns true if shown.
func show_tip(id: String) -> bool:
	if not Settings.flag("tips") or seen().has(id) or not (Data.cfg("settings.onboarding_tips") as Array).has(id):
		return false
	var shown: Array = seen().duplicate()
	shown.append(id)
	SaveGame.set_setting("tips_seen", shown)
	if banner != null:
		banner.show_text(tr("TIP_FIRST_" + id.to_upper()))
	return true


func _on_level_up_ready(_run: RunState) -> void:
	show_tip("level_up")


func _on_enemy_damaged(_slot: int, _amount: float, kind: String, _at: Vector2, _element: String) -> void:
	if kind == "weak":
		show_tip("weakness")


# The rest are checked a few times a second.
func _process(delta: float) -> void:
	_check_in -= delta
	if _check_in > 0.0:
		return
	_check_in = 0.25
	var player: Player = GameAuthority.local_player()
	if player == null:
		return
	if shrines != null:
		for shrine: Dictionary in shrines.shrines:
			if bool(shrine.get("seen", false)):
				show_tip("shrine")
				break
	if gods != null:
		for index: int in gods.gods_of(player).size():
			if gods.meter(player, index) >= 1.0:
				show_tip("meter_full")
	if resonance != null and resonance.ready_for(player):
		show_tip("resonance")
