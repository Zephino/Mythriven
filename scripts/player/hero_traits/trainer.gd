extends HeroKit
## Scáthach (unlocked by defeating her on the Misty Isles). Legend Trait,
## Trainer of Heroes (from the design's Hero list: "each weapon level-up also
## boosts another weapon"): whenever she takes a weapon card, another of her
## weapons below its top level also gains a level.
## Passive, Fortress of Shadows (her stronghold Dún Scáith): +1 Armor, +5%
## Crit Chance. Numbers are placeholders that need owner approval.

## Times the trait has trained a second weapon this run.
var lessons: int = 0


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	player.stats.add_bonus("armor", float(passive_data().get("armor", 0.0)))
	player.stats.add_bonus("crit", float(passive_data().get("crit_pct", 0.0)) / 100.0)
	GameAuthority.card_applied.connect(_on_card_applied)


func _on_card_applied(who: Player, card: Dictionary) -> void:
	if who != player or not [LevelUpRules.WEAPON_UP, LevelUpRules.WEAPON_NEW].has(str(card.get("kind", ""))):
		return
	var others: Array[WeaponInstance] = []
	for weapon: WeaponInstance in player.weapons:
		if weapon.id() != str(card.get("id", "")) and weapon.level < weapon.max_level():
			others.append(weapon)
	if others.is_empty() or GameAuthority.run == null:
		return
	others[GameAuthority.run.rng.loot.randi_range(0, others.size() - 1)].level += 1
	lessons += 1


func hud_text() -> String:
	return tr("HUD_LESSONS") % lessons if lessons > 0 else ""
