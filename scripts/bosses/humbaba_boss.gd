class_name HumbabaBoss
extends BossController
## Humbaba, 10:00 (docs/PACK_2_PLAN.md: the Land Between the Rivers). Signature, the seven radiances: he is wrapped in
## seven auras of terror, and while any is left, hits strip the outermost radiance instead of harming him. Wind tears
## them away twice as fast (Shamash's thirteen winds held him for Gilgamesh); a Guard Break or Shamash's own summon
## strips one outright. Source: Epic of Gilgamesh, Tablets II-V.

var radiances: int = -1
## What is left of the outermost radiance.
var radiance_left: float = 0.0
var _element: String = ""
var _spoken: bool = false


func _sig() -> Dictionary:
	return data.get("signature", {})


func _ensure() -> void:
	if radiances < 0:
		radiances = int(_sig().get("radiances", 7))
		radiance_left = float(_sig().get("radiance_hp", 120.0))


func on_element_hit(element: String) -> void:
	_element = element


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	_ensure()
	if radiances <= 0:
		return amount
	radiance_left -= amount * (float(_sig().get("wind_mult", 2.0)) if _element == "wind" else 1.0)
	_element = ""
	if radiance_left <= 0.0:
		strip_radiance()
	return 0.0


## The Thirteen Winds secret: as Gilgamesh with Shamash bound, strip all seven radiances and beat him (Tablet V).
func secret_earned() -> String:
	var player: Player = GameAuthority.local_player()
	if player == null or str(player.hero.get("id", "")) != "gilgamesh" or radiances > 0:
		return ""
	return "the_thirteen_winds" if GameAuthority.gods != null and GameAuthority.gods.bound_ids(player).has("shamash") else ""


## Tears away the outermost radiance (a hit, a Guard Break, or Shamash's winds).
func strip_radiance() -> void:
	_ensure()
	if radiances <= 0:
		return
	radiances -= 1
	radiance_left = float(_sig().get("radiance_hp", 120.0))
	var effects: EffectLayer = get_tree().get_first_node_in_group(EffectLayer.GROUP) as EffectLayer
	if effects != null and slot != -1:
		effects.spawn_ring(position_now(), GameAuthority.enemies.radius[slot] + 10.0 + radiances * 5.0, Color(1.0, 0.85, 0.4), true)
	if radiances == 0:
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_HUMBABA_BARE"))


func guard_break() -> void:
	super.guard_break()
	strip_radiance()


func signature(_delta: float) -> void:
	_ensure()
	if _spoken:
		return
	_spoken = true
	for player: Player in GameAuthority.players:
		if str(player.hero.get("id", "")) == "gilgamesh":
			var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
			if banner != null:
				banner.show_text(tr("BOSS_HUMBABA_GILGAMESH"))


## His radiances: a golden ring for each one left.
func _draw() -> void:
	super._draw()
	if not is_alive() or radiances <= 0:
		return
	var at: Vector2 = position_now() - global_position
	var base: float = GameAuthority.enemies.radius[slot] + 8.0
	for k: int in radiances:
		var alpha: float = 0.25 + 0.5 * (radiance_left / maxf(float(_sig().get("radiance_hp", 120.0)), 1.0) if k == radiances - 1 else 1.0)
		draw_arc(at, base + k * 5.0, 0.0, TAU, 32, Color(1.0, 0.85, 0.4, alpha), 1.5)
