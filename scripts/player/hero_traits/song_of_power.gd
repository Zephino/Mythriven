extends HeroKit
## Väinämöinen. Legend Trait, Song of Power: every elemental reaction he
## causes adds a Verse stack (+3% spell damage, max 10, each lasts 6 s).
## Passive, Eternal Sage: statuses he applies last 30% longer. Reactions
## during an active Resonance count double for Verses.

var _verses := PackedFloat32Array()


func setup(owner_player: Player, hero_data: Dictionary) -> void:
	super.setup(owner_player, hero_data)
	player.stats.add_bonus("status_duration", float(passive_data().get("status_duration_pct", 0.0)) / 100.0)
	GameAuthority.reaction_triggered.connect(_on_reaction)


func verses() -> int:
	return _verses.size()


## Spells deal +3% per Verse.
func damage_mult(weapon: WeaponInstance) -> float:
	if not (weapon.data.get("categories", []) as Array).has("spell"):
		return 1.0
	return 1.0 + float(trait_data().get("spell_damage_pct_per_verse", 0.0)) / 100.0 * verses()


func hud_text() -> String:
	return tr("HUD_VERSES") % [verses(), int(trait_data().get("max_verses", 10))]


func _process(delta: float) -> void:
	for i: int in range(_verses.size() - 1, -1, -1):
		_verses[i] -= delta
		if _verses[i] <= 0.0:
			_verses.remove_at(i)


func _on_reaction(_reaction_id: String, _at: Vector2, _reach: float, by: Player) -> void:
	if by != player:
		return
	# Reactions inside an active Resonance count double.
	var count: int = 2 if float(player.god_flags.get("resonance_active_until", -1.0)) > GameAuthority.run.elapsed_s else 1
	for _k: int in count:
		if _verses.size() >= int(trait_data().get("max_verses", 10)):
			_verses.remove_at(0)
		_verses.append(float(trait_data().get("verse_s", 6.0)))
