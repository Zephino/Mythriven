extends GutTest
## The HUD's weapon slots (owner request 11/03/2026): Heroes carry at most 5 weapons, and the screen shows each one
## with its level ("MAX" at the top level, "EVO" once evolved), with faint empty slots for the rest.

var _parent: Node2D
var _player: Player


func before_each() -> void:
	GameAuthority.start_run("aegean_shore")
	_parent = add_child_autofree(Node2D.new())
	_player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true)


func after_each() -> void:
	GameAuthority.end_scene()


func test_heroes_carry_five_weapons_and_three_spells() -> void:
	assert_eq(Data.cfg_int("level_up.max_weapons"), 5)
	assert_eq(Data.cfg_int("level_up.max_spells"), 3)


func test_spells_have_their_own_slots() -> void:
	for id: String in ["ember", "frost", "spark"]:
		GameAuthority.give_weapon(_player, id)
	assert_false(LevelUpRules.has_room(_player, true), "three spells fill the spell slots")
	assert_true(LevelUpRules.has_room(_player, false), "but the weapon slots are still free")
	var offered_spell: bool = false
	var offered_weapon: bool = false
	for card: Dictionary in LevelUpRules.item_cards(_player):
		if card.get("kind") == LevelUpRules.WEAPON_NEW:
			var spell: bool = LevelUpRules.is_spell(GameAuthority.find_weapon(str(card["id"])))
			offered_spell = offered_spell or spell
			offered_weapon = offered_weapon or not spell
	assert_false(offered_spell, "no new spell is offered")
	assert_true(offered_weapon, "new weapons still are")


func test_the_slots_show_each_weapon_and_its_level() -> void:
	var hud: HudWeapons = add_child_autofree(HudWeapons.new())
	var spear: WeaponInstance = GameAuthority.give_weapon(_player, "bronze_spear")
	spear.level = 3
	hud._process(0.0)
	await wait_process_frames(1)
	var kinds: Array = []
	for line: Node in hud.get_children():
		if line.has_meta("slot_kind"):
			kinds.append(line.get_meta("slot_kind"))
	assert_eq(kinds.count("weapon"), 5, "five weapon slots")
	assert_eq(kinds.count("spell"), 3, "and three spell slots under them")
	assert_eq(HudWeapons.level_text(spear), tr("UI_HUD_WEAPON_LEVEL") % 3)
	spear.level = spear.max_level()
	assert_eq(HudWeapons.level_text(spear), tr("UI_HUD_WEAPON_MAX"))
	var phalanx: WeaponInstance = GameAuthority.give_weapon(_player, "phalanx")
	assert_eq(HudWeapons.level_text(phalanx), tr("UI_HUD_WEAPON_EVOLVED"))


func test_no_new_weapon_is_offered_once_five_are_carried() -> void:
	for id: String in ["javelin", "longbow", "bronze_sword", "war_hammer", "bronze_spear"]:
		if LevelUpRules.has_room(_player, false):
			GameAuthority.give_weapon(_player, id)
	assert_false(LevelUpRules.has_room(_player, false), "five weapons")
	for card: Dictionary in LevelUpRules.item_cards(_player):
		if card.get("kind") == LevelUpRules.WEAPON_NEW:
			assert_true(LevelUpRules.is_spell(GameAuthority.find_weapon(str(card["id"]))), "only spells are offered now")


func test_the_health_orb_shows_the_heros_health() -> void:
	var bar: HudHealth = add_child_autofree(HudHealth.new())
	_player.hp = _player.max_hp * 0.5
	bar._process(0.016)
	assert_eq(bar._text, tr("UI_HUD_HP") % ceili(_player.hp), "it shows the Hero's health")
	assert_almost_eq(bar._shown_fraction, 0.5, 0.001, "and fills halfway")
	assert_false(bar._low, "half health isn't low")
	_player.hp = _player.max_hp * 0.1
	bar._process(0.016)
	assert_true(bar._low, "a tenth is: the orb pulses")
	assert_gt(bar._trail_fraction, bar._shown_fraction, "and the pale strip shows what the hit took")
