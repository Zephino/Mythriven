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


func test_heroes_carry_five_weapons() -> void:
	assert_eq(Data.cfg_int("level_up.max_weapons"), 5)


func test_the_slots_show_each_weapon_and_its_level() -> void:
	var hud: HudWeapons = add_child_autofree(HudWeapons.new())
	var spear: WeaponInstance = GameAuthority.give_weapon(_player, "bronze_spear")
	spear.level = 3
	hud._process(0.0)
	await wait_process_frames(1)
	assert_eq(hud.get_child_count(), 5, "one slot for each weapon a Hero can carry")
	assert_eq(HudWeapons.level_text(spear), tr("UI_HUD_WEAPON_LEVEL") % 3)
	spear.level = spear.max_level()
	assert_eq(HudWeapons.level_text(spear), tr("UI_HUD_WEAPON_MAX"))
	var phalanx: WeaponInstance = GameAuthority.give_weapon(_player, "phalanx")
	assert_eq(HudWeapons.level_text(phalanx), tr("UI_HUD_WEAPON_EVOLVED"))


func test_no_new_weapon_is_offered_once_five_are_carried() -> void:
	for id: String in ["javelin", "longbow", "bronze_sword", "war_hammer", "bronze_spear"]:
		if _player.weapons.size() < 5:
			GameAuthority.give_weapon(_player, id)
	assert_eq(_player.weapons.size(), 5)
	for card: Dictionary in LevelUpRules.item_cards(_player):
		assert_ne(card.get("kind"), LevelUpRules.WEAPON_NEW, "no new weapon cards with all five slots full")
