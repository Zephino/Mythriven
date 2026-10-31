extends HeroKit
## Achilles (unlocked by defeating him on the Aegean Shore). Legend Trait,
## The Heel: nearly invulnerable from the front, vulnerable from behind (hits
## from in front of him are reduced, hits from behind hurt more). Passive,
## Shield of Achilles: +2 Armor (the shield Hephaestus forged, Iliad 18).


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	player.stats.add_bonus("armor", float(passive_data().get("armor", 0.0)))


func incoming_damage_at(amount: float, from: Vector2) -> float:
	var mult: float = heel_mult(player.position, player.facing, from, trait_data())
	# A gold glint where the front turns the blow; a red flash at the heel when struck from behind (owner request
	# 10/31/2026).
	var layer: EffectLayer = effect_layer()
	if layer != null and mult != 1.0:
		var front: bool = mult < 1.0
		var at: Vector2 = player.position + (from - player.position).normalized() * player.body_radius if front else \
				player.position + Vector2(0, player.body_radius)
		layer.spawn_ring(at, 8.0, Color.html(Data.cfg_string("heroes.heel_guard_color" if front else "heroes.heel_hit_color")))
	return amount * mult


## Damage multiplier for a hit from `from` on someone at `at` facing `facing`:
## front_damage_mult inside the front cone, back_damage_mult from behind.
static func heel_mult(at: Vector2, facing: Vector2, from: Vector2, settings: Dictionary) -> float:
	if from == Vector2.INF or from == at or facing == Vector2.ZERO:
		return 1.0
	var dot: float = facing.normalized().dot((from - at).normalized())
	var half_cone: float = deg_to_rad(float(settings.get("front_cone_deg", 120.0)) * 0.5)
	if dot >= cos(half_cone):
		return float(settings.get("front_damage_mult", 1.0))
	if dot <= -cos(half_cone):
		return float(settings.get("back_damage_mult", 1.0))
	return 1.0
