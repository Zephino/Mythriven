class_name ApepBoss
extends BossController
## Apep, 30:00 (GAME_DESIGN.md: The Two Lands bosses). Signature, swallowing
## the light: in phase 2 Apep swallows one of the player's bound gods and turns
## its power against them (attacks in the god's element). A glowing orb pulses
## inside Apep; hit Apep while it glows 10 times to free the god. Phases: coils
## sweep the arena and dark-orb spirals → the swallow → everything together;
## the Unraveling begins after. The Sun's Return secret: let Apep swallow Ra,
## then free him.

## The swallowed god's id ("" = none) and orb hits so far.
var swallowed: String = ""
var orb_hits: int = 0

var _orb_t: float = 0.0
var _turned_left: float = 0.0
var _freed_ra: bool = false
var _swallowed_once: bool = false


func secret_earned() -> String:
	return "the_suns_return" if _freed_ra else ""


func _sig() -> Dictionary:
	return data.get("signature", {})


func _on_phase_started(index: int) -> void:
	if index >= 1 and not _swallowed_once:
		_swallow()


## True while the orb glows (hits count toward freeing the god).
func orb_glowing() -> bool:
	return swallowed != "" and fmod(_orb_t, float(_sig().get("orb_cycle_s", 3.0))) < float(_sig().get("orb_glow_s", 1.5))


func _swallow() -> void:
	var player: Player = GameAuthority.local_player()
	var gods: GodManager = GameAuthority.gods
	if player == null or gods == null or gods.gods_of(player).is_empty():
		return
	_swallowed_once = true
	var bound: PackedStringArray = gods.bound_ids(player)
	var index: int = bound.find("ra") if bound.has("ra") else GameAuthority.run.rng.combat.randi_range(0, bound.size() - 1)
	swallowed = bound[index]
	gods.release(player, index)
	orb_hits = 0
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_APEP_SWALLOWS") % tr(str(GodRules.find(swallowed).get("name_key", ""))))


func modify_hit(amount: float, _attacker: Player, _push: Vector2) -> float:
	if orb_glowing():
		orb_hits += 1
		if orb_hits >= int(_sig().get("orb_hits", 10)):
			_free_god()
	return amount


func _free_god() -> void:
	var freed: String = swallowed
	swallowed = ""
	_freed_ra = _freed_ra or freed == "ra"
	var player: Player = GameAuthority.local_player()
	if player != null and GameAuthority.gods != null:
		GameAuthority.gods.bind(player, freed)
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_APEP_FREED") % tr(str(GodRules.find(freed).get("name_key", ""))))


func signature(delta: float) -> void:
	if swallowed == "":
		return
	_orb_t += delta
	_turned_left -= delta
	if _turned_left <= 0.0 and target != null and patterns != null:
		_turned_left = float(_sig().get("turned_every_s", 7.0))
		var turned: Dictionary = (_sig().get("turned_summon", {}) as Dictionary).duplicate()
		patterns.run(turned, position_now(), target.position, str(GodRules.find(swallowed).get("element", "dark")), str(data.get("id", "")), _damage_mult())


func _draw() -> void:
	super._draw()
	if swallowed == "" or not is_alive():
		return
	var at: Vector2 = position_now() - global_position
	var color := Color.html(str(GodRules.find(swallowed).get("placeholder_color", "#ffffff")))
	draw_circle(at, 6.0 if orb_glowing() else 3.0, Color(color, 1.0 if orb_glowing() else 0.4))
	draw_arc(at, 9.0, -PI * 0.5, -PI * 0.5 + TAU * orb_hits / maxf(float(_sig().get("orb_hits", 10)), 1.0), 16, color, 2.0)
