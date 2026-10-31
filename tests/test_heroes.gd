extends GutTest
## Phase 9: Heroes, Legend Traits, passives, expertise, and the new weapons.

const CHASER := "placeholder_chaser"

var _parent: Node2D
var _enemies: EnemyManager
var _combat: CombatSystem


func before_each() -> void:
	GameAuthority.start_run("aegean_shore")
	_parent = add_child_autofree(Node2D.new())
	_enemies = EnemyManager.new()
	_parent.add_child(_enemies)
	_enemies.setup()
	_enemies.set_process(false)
	GameAuthority.enemies = _enemies
	var effects := EffectLayer.new()
	_parent.add_child(effects)
	effects.setup()
	_combat = CombatSystem.new()
	_combat.enemies = _enemies
	_combat.effects = effects
	_parent.add_child(_combat)
	_combat.set_process(false)


func after_each() -> void:
	GameAuthority.end_scene()


func _hero(hero_id: String) -> Player:
	var player: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, hero_id)
	player.kit.set_process(false)
	player.stats.base["crit"] = 0.0
	return player


func _spawn(at: Vector2, hp: float = 10000.0) -> int:
	var slot: int = _enemies.spawn(CHASER, at)
	_enemies.hp[slot] = hp
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	return slot


func test_four_starting_heroes_with_design_stats() -> void:
	var expected: Dictionary = {"heracles": [150, 90, 2], "cu_chulainn": [110, 105, 1], "vainamoinen": [100, 95, 0], "tomoe_gozen": [95, 115, 1]}
	for hero_id: String in expected:
		var stats: Dictionary = HeroRules.find(hero_id)["stats"]
		assert_eq([int(stats["max_hp"]), int(stats["move_speed"]), int(stats["armor"])], expected[hero_id], hero_id)
		assert_eq(HeroRules.find(hero_id)["care_tier"], "A")


func test_heroes_play_differently() -> void:
	var heracles: Player = _hero("heracles")
	var cu: Player = _hero("cu_chulainn")
	assert_eq(heracles.max_hp, 150.0)
	assert_eq(heracles.armor, 4.0, "Lion's Hide adds +2 Armor")
	assert_eq(cu.move_speed, 105.0)
	assert_eq(heracles.kit.get_script().resource_path.get_file(), "twelve_labors.gd")
	assert_eq(cu.kit.get_script().resource_path.get_file(), "salmon_leap.gd")


func test_expertise_only_for_expert_categories_not_the_start_weapon() -> void:
	var heracles: Dictionary = HeroRules.find("heracles")
	assert_true(HeroRules.is_expert(heracles, GameAuthority.find_weapon("longbow")), "Bow")
	assert_true(HeroRules.is_expert(heracles, GameAuthority.find_weapon("throwing_axe")), "Thrown")
	assert_false(HeroRules.is_expert(heracles, GameAuthority.find_weapon("great_club")))
	assert_false(HeroRules.is_expert(heracles, GameAuthority.find_weapon("javelin")))
	var vaino: Dictionary = HeroRules.find("vainamoinen")
	assert_true(HeroRules.is_expert(vaino, GameAuthority.find_weapon("ember")), "all spells")
	assert_false(HeroRules.is_expert(vaino, GameAuthority.find_weapon("runo_song")), "not his own starting spell")


func test_expert_weapons_attack_faster_hit_harder_and_get_a_level_8_bonus() -> void:
	var player: Player = _hero("heracles")
	var expert: WeaponInstance = GameAuthority.give_weapon(player, "longbow")
	var plain: WeaponInstance = WeaponInstance.new(GameAuthority.find_weapon("longbow"), player)
	assert_true(expert.expert)
	assert_almost_eq(expert.attack_interval(), plain.attack_interval() / 1.25, 0.001)
	assert_almost_eq(expert.damage(), plain.damage() * 1.15, 0.001)
	expert.level = 8
	plain.level = 8
	assert_eq(int(expert.stats()["count"]), int(plain.stats()["count"]) + 1)


func test_expert_badge_on_level_up_cards() -> void:
	var player: Player = _hero("heracles")
	var badges: Dictionary = {}
	for card: Dictionary in LevelUpRules.item_cards(player):
		if card["kind"] == LevelUpRules.WEAPON_NEW:
			badges[card["id"]] = bool(card.get("expert", false))
	assert_true(badges["longbow"])
	assert_false(badges["javelin"])
	assert_string_contains(CardText.full({"kind": LevelUpRules.WEAPON_NEW, "id": "longbow", "from": 0, "to": 1, "expert": true}),
			str(TranslationServer.translate("CARD_EXPERT")))


func test_lions_hide_halves_the_first_hit_every_8_seconds() -> void:
	var player: Player = _hero("heracles")
	var start: float = player.hp
	GameAuthority.damage_player(player, 24.0, "test")
	assert_almost_eq(start - player.hp, (24.0 - 4.0) * 0.5, 0.001)
	var second: float = player.hp
	GameAuthority.damage_player(player, 24.0, "test")
	assert_almost_eq(second - player.hp, 20.0, 0.001, "only the first hit is halved")


func test_labors_progress_and_reward() -> void:
	var player: Player = _hero("heracles")
	var kit: HeroKit = player.kit
	var labor: Dictionary = kit.call("current_labor")
	assert_eq(labor["name_key"], "LABOR_NEMEAN_LION")
	var armor_before: float = player.armor
	for _i: int in int(labor["goal"]["count"]):
		GameAuthority.enemy_killed.emit(0, {}, Vector2.ZERO, player)
	assert_eq(int(kit.get("labor_index")), 1)
	assert_eq(player.armor, armor_before + 1.0, "the Nemean Lion's reward")
	assert_ne(kit.hud_text(), "")


func test_all_labors_done_message_shows_briefly_then_clears() -> void:
	var player: Player = _hero("heracles")
	var kit: HeroKit = player.kit
	kit.set_process(false)
	for _i: int in (kit.call("labors") as Array).size():
		kit.set("progress", 1.0e9)
		kit.call("_check", 1.0)
	assert_true(kit.call("current_labor").is_empty())
	kit._process(Data.cfg_float("heroes.labor_banner_s") + 0.1)
	assert_eq(kit.hud_text(), str(tr("LABORS_ALL_DONE")), "the all-done line shows after the last Labor's banner")
	kit._process(Data.cfg_float("heroes.labors_all_done_s") + 0.1)
	assert_eq(kit.hud_text(), "", "then the HUD line clears")


func test_salmon_leap_moves_makes_untargetable_and_lands_with_a_shockwave() -> void:
	var player: Player = _hero("cu_chulainn")
	var target: int = _spawn(Vector2(48 + 10, 0))
	var target_hp: float = _enemies.hp[target]
	player.velocity = Vector2.RIGHT * 100.0
	player.kit._process(8.01)
	assert_true(player.kit.is_untargetable())
	var hp_before: float = player.hp
	GameAuthority.damage_player(player, 50.0, "test")
	assert_eq(player.hp, hp_before, "untargetable mid-leap")
	player.kit._process(0.81)
	assert_almost_eq(player.position.x, 48.0, 0.5, "3 tiles")
	assert_false(player.kit.is_untargetable())
	assert_lt(_enemies.hp[target], target_hp, "the landing shockwave hits")


func test_battle_frenzy_below_30_percent() -> void:
	var player: Player = _hero("cu_chulainn")
	var area_before: float = player.stats.area_mult()
	player.hp = player.max_hp * 0.2
	player.kit._process(0.01)
	assert_almost_eq(player.kit.attack_speed_bonus(), 0.3, 0.001)
	assert_gt(player.stats.area_mult(), area_before)


func test_song_of_power_verses_raise_spell_damage() -> void:
	var player: Player = _hero("vainamoinen")
	var spell: WeaponInstance = GameAuthority.give_weapon(player, "ember")
	var club := WeaponInstance.new(GameAuthority.find_weapon("great_club"), player)
	GameAuthority.reaction_triggered.emit("conduct", Vector2.ZERO, 10.0, player)
	GameAuthority.reaction_triggered.emit("conduct", Vector2.ZERO, 10.0, player)
	assert_eq(int(player.kit.call("verses")), 2)
	assert_almost_eq(player.kit.damage_mult(spell), 1.06, 0.0001)
	assert_eq(player.kit.damage_mult(club), 1.0, "only spells")
	assert_almost_eq(player.stats.status_duration_mult(), 1.3, 0.001, "Eternal Sage")


func test_cavalry_charge_momentum_charge_and_dodge() -> void:
	var player: Player = _hero("tomoe_gozen")
	player.velocity = Vector2.RIGHT * 100.0
	player.kit._process(4.75)
	assert_eq(int(player.kit.get("momentum")), 9)
	assert_false(player.kit.call("is_charging"))
	player.kit._process(0.3)
	assert_eq(int(player.kit.get("momentum")), 10)
	assert_almost_eq(player.kit.attack_speed_bonus(), 0.4, 0.001)
	player.kit._process(5.0)
	assert_true(player.kit.call("is_charging"), "a charge every 5 s at full Momentum")
	var hp_before: float = player.hp
	GameAuthority.damage_player(player, 50.0, "test")
	assert_eq(player.hp, hp_before, "the charge dodges the next hit")
	player.velocity = Vector2.ZERO
	player.kit._process(1.0)
	assert_eq(int(player.kit.get("momentum")), 5, "standing still 1 s loses half")


func test_gae_bolg_thrust_hits_a_line_and_kills_burst_into_barbs() -> void:
	# Spears jab; javelins are thrown (owner decision 10/31/2026).
	var player: Player = _hero("cu_chulainn")
	var spear: WeaponInstance = player.weapons[0] if not player.weapons.is_empty() else GameAuthority.give_weapon(player, "gae_bolg")
	assert_eq(str(spear.data["pattern"]), "thrust", "spears jab")
	assert_eq(str(GameAuthority.find_weapon("javelin")["pattern"]), "forward", "javelins are thrown")
	var in_line: int = _spawn(Vector2(60, 0))
	var off_line: int = _spawn(Vector2(30, 40))
	var dies: int = _spawn(Vector2(20, 0), 1.0)
	var bystander: int = _spawn(Vector2(20, 22))
	var hp: Dictionary = {in_line: _enemies.hp[in_line], off_line: _enemies.hp[off_line], bystander: _enemies.hp[bystander]}
	ThrustPattern.new().fire(spear, player, {"direction": Vector2.RIGHT}, _combat)
	assert_lt(_enemies.hp[in_line], hp[in_line])
	assert_eq(_enemies.hp[off_line], hp[off_line])
	assert_eq(_enemies.active[dies], 0)
	assert_lt(_enemies.hp[bystander], hp[bystander], "barbs from the kill")


func test_hammers_smash_the_ground_in_front() -> void:
	# Hammers smash the ground (owner rule 10/31/2026): everything round the spot it lands is hit.
	var player: Player = _hero("heracles")
	var hammer: WeaponInstance = GameAuthority.give_weapon(player, "war_hammer")
	assert_eq(str(hammer.data["pattern"]), "smash")
	var reach: float = hammer.stat("range_px") * player.stats.area_mult() * hammer.stat("area", 1.0)
	var on_spot: int = _spawn(Vector2(reach, 0))
	var beside_spot: int = _spawn(Vector2(reach, 18))
	var behind: int = _spawn(Vector2(-40, 0))
	var hp: Dictionary = {on_spot: _enemies.hp[on_spot], beside_spot: _enemies.hp[beside_spot], behind: _enemies.hp[behind]}
	SmashPattern.new().fire(hammer, player, {"direction": Vector2.RIGHT}, _combat)
	assert_lt(_enemies.hp[on_spot], hp[on_spot], "the spot it lands on")
	assert_lt(_enemies.hp[beside_spot], hp[beside_spot], "and all round it")
	assert_eq(_enemies.hp[behind], hp[behind], "not behind the Hero")


func test_shrines_are_built_at_random_and_the_god_stays_inside() -> void:
	# Owner request 10/31/2026: shrines built from parts round the altar; the god sits or walks, confined inside.
	for pantheon: String in ["greek", "norse", "egyptian", "celtic"]:
		assert_false(PixelArt.find("shrines/" + pantheon).is_empty(), pantheon + " shrine parts")
	var a: Dictionary = ShrineLayout.make(1234, "greek")
	assert_eq(ShrineLayout.make(1234, "greek"), a, "the same seed builds the same shrine (co-op)")
	var sizes := {}
	var sits := {}
	for seed_value: int in 40:
		var layout: Dictionary = ShrineLayout.make(seed_value, "norse")
		sizes[layout["size"]] = true
		sits[bool(layout["sits"])] = true
		var half: Vector2 = Vector2(layout["size"]) * ShrineLayout.TILE * 0.5
		for k: int in 60:
			var feet: Vector2 = ShrineLayout.walker(layout, k * 0.7, 16.0)["feet"]
			assert_true(absf(feet.x) < half.x + ShrineLayout.TILE and absf(feet.y) < half.y * 2.0 + ShrineLayout.TILE,
					"the walking god stays inside the shrine")
		var altars: int = 0
		for item: Dictionary in layout["objects"]:
			if str(item["part"]) == "altar":
				altars += 1
				assert_eq(Vector2(item["at"]).x, 0.0, "the altar is at the shrine's position")
		assert_eq(altars, 1)
	assert_gt(sizes.size(), 3, "shrines come in different sizes")
	assert_eq(sits.size(), 2, "some gods sit, some walk")


func test_shrine_dungeons_lead_from_the_entrance_to_the_god() -> void:
	# Owner decisions 10/31/2026: a random dungeon (sometimes a maze) leads to the god's throne room.
	var kinds := {}
	for seed_value: int in 30:
		var plan: Dictionary = ShrineDungeon.plan(seed_value, "celtic")
		assert_eq(ShrineDungeon.plan(seed_value, "celtic")["floor"].size(), plan["floor"].size(), "the same seed, the same dungeon")
		var walk: Dictionary = plan["walk"]
		var altar_tile := Vector2i(floori(Vector2(plan["room_origin"]).x), floori(Vector2(plan["room_origin"]).y))
		var seen := {plan["start"]: true}
		var queue: Array = [plan["start"]]
		while not queue.is_empty():
			var t: Vector2i = queue.pop_front()
			for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if walk.has(t + d) and not seen.has(t + d):
					seen[t + d] = true
					queue.append(t + d)
		assert_true(seen.has(altar_tile), "seed %d: the way through reaches the god's altar" % seed_value)
		kinds[walk.size() / 10] = true
	assert_gt(kinds.size(), 3, "dungeons come in different sizes")


func test_thrown_weapons_and_shots_fly_as_pictures() -> void:
	var player: Player = _hero("atalanta")
	var projectiles := ProjectileManager.new()
	projectiles.enemies = _enemies
	projectiles.combat = _combat
	_parent.add_child(projectiles)
	projectiles.setup()
	projectiles.set_process(false)
	_combat.projectiles = projectiles
	var javelin: WeaponInstance = GameAuthority.give_weapon(player, "javelin")
	ProjectilePattern.new(ProjectileManager.FLIGHT).fire(javelin, player, {"direction": Vector2.RIGHT}, _combat)
	assert_false(projectiles._art[0].is_empty(), "the javelin flies as its picture")
	# Spells fly as their element's picture (owner request 10/31/2026).
	var elements: Dictionary = (Data.get_file("elements.json") as Dictionary)["elements"]
	for element: String in elements:
		if element != "physical":
			assert_false(PixelArt.find("projectiles/element_" + element).is_empty(), element + " has a spell picture")
	var ember: WeaponInstance = GameAuthority.give_weapon(player, "ember")
	ProjectilePattern.new(ProjectileManager.FLIGHT).fire(ember, player, {"direction": Vector2.RIGHT}, _combat)
	assert_eq(projectiles._art[1], PixelArt.find("projectiles/element_fire"), "Ember flies as a fireball")
	for weapon: Dictionary in Data.get_file("weapons.json"):
		var picture: String = str(weapon.get("projectile_art", ""))
		if picture != "":
			assert_false(PixelArt.find("projectiles/" + picture).is_empty(), "%s flies as projectiles/%s" % [weapon["id"], picture])


func test_runo_song_cycles_fire_ice_lightning() -> void:
	var player: Player = _hero("vainamoinen")
	var song: WeaponInstance = GameAuthority.give_weapon(player, "runo_song")
	var projectiles := ProjectileManager.new()
	projectiles.enemies = _enemies
	_parent.add_child(projectiles)
	projectiles.setup()
	_combat.projectiles = projectiles
	var elements: Array[String] = []
	for attack: int in 3:
		song.attacks_made = attack + 1
		ProjectilePattern.new(ProjectileManager.FLIGHT).fire(song, player, {"direction": Vector2.RIGHT}, _combat)
		elements.append(projectiles._element[attack])
	assert_eq(elements, ["fire", "ice", "lightning"] as Array[String])


func test_hero_pixel_art_files_are_well_formed() -> void:
	var checked: int = 0
	for file: String in DirAccess.get_files_at(PixelArt.ART_DIR) + DirAccess.get_files_at(PixelArt.ART_DIR + "weapons").duplicate():
		if not file.ends_with(".json"):
			continue
		var is_weapon: bool = not FileAccess.file_exists(PixelArt.ART_DIR + file)
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PixelArt.ART_DIR + ("weapons/" if is_weapon else "") + file))
		assert_true(data is Dictionary, file + " is JSON")
		var size: Array = data["size"]
		for frame_name: String in (data["frames"] as Dictionary):
			for rows: Variant in data["frames"][frame_name]:
				assert_eq((rows as Array).size(), int(size[1]), "%s %s: every frame is %d rows" % [file, frame_name, size[1]])
				for row: Variant in rows:
					assert_eq(str(row).length(), int(size[0]), "%s %s: every row is %d pixels" % [file, frame_name, size[0]])
					for letter: String in str(row):
						assert_true(letter == "." or (data["palette"] as Dictionary).has(letter), "%s: '%s' is in the palette" % [file, letter])
		if is_weapon:
			assert_true(data.get("grip") is Array, file + " marks its grip")
			assert_false(GameAuthority.find_weapon(file.get_basename()).is_empty(), file + " is named after a weapon")
		else:
			assert_false(HeroRules.find(file.get_basename()).is_empty(), file + " is named after a Hero")
		checked += 1
	assert_gt(checked, 0)
	var enemy_ids: Array = []
	for enemy: Dictionary in Data.get_file(EnemyManager.ENEMIES_FILE):
		enemy_ids.append(str(enemy["id"]))
	for file: String in DirAccess.get_files_at(PixelArt.ART_DIR + "enemies"):
		if file.ends_with(".json"):
			var enemy_art: Dictionary = PixelArt.find("enemies/" + file.get_basename())
			assert_false(enemy_art.is_empty(), "enemies/" + file + " loads")
			assert_eq((enemy_art["frames"]["walk"] as Array).size(), 4, "enemies/" + file + " has 4 moving frames")
			assert_true(enemy_ids.has(file.get_basename()), "enemies/" + file + " is named after an enemy")
	for file: String in DirAccess.get_files_at(PixelArt.ART_DIR + "gods"):
		if file.ends_with(".json"):
			var god_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PixelArt.ART_DIR + "gods/" + file))
			assert_true(god_data is Dictionary and (god_data as Dictionary).has("anchor"), "gods/" + file + " is art")
			assert_false(PixelArt.god(file.get_basename()).is_empty(), "gods/" + file + " loads")
			assert_false(GodRules.find(file.get_basename()).is_empty(), "gods/" + file + " is named after a god")
			assert_true(((god_data as Dictionary)["frames"] as Dictionary).has("seated"), "gods/" + file + " sits on a throne")
	for file: String in DirAccess.get_files_at(PixelArt.ART_DIR + "bosses"):
		if not file.ends_with(".json"):
			continue
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PixelArt.ART_DIR + "bosses/" + file))
		assert_true(data is Dictionary, "bosses/" + file + " is JSON")
		var size: Array = data["size"]
		for frame_name: String in (data["frames"] as Dictionary):
			for rows: Variant in data["frames"][frame_name]:
				assert_eq((rows as Array).size(), int(size[1]), "bosses/%s %s: every frame is %d rows" % [file, frame_name, size[1]])
				for row: Variant in rows:
					assert_eq(str(row).length(), int(size[0]), "bosses/%s: every row is %d pixels" % [file, size[0]])
					for letter: String in str(row):
						assert_true(letter == "." or (data["palette"] as Dictionary).has(letter), "bosses/%s: '%s' is in the palette" % [file, letter])
		assert_false(PixelArt.boss(file.get_basename()).is_empty(), "bosses/" + file + " loads")
		var named_after_boss: bool = false
		for enemy: Variant in Data.get_file(EnemyManager.ENEMIES_FILE):
			# A boss's other looks are named after it too: cerberus_2, cerberus_1 (Cerberus as his heads fall).
			var id: String = str(enemy.get("id", ""))
			if bool(enemy.get("boss", false)) and (id == file.get_basename() or file.get_basename().begins_with(id + "_")):
				named_after_boss = true
		assert_true(named_after_boss, "bosses/" + file + " is named after a boss")
	var art: Dictionary = PixelArt.find("heracles")
	assert_false(art.is_empty(), "Heracles has art")
	assert_eq((art["frames"]["walk"] as Array).size(), 4, "a four-frame walk")
	assert_true(PixelArt.find("no_such_hero").is_empty(), "Heroes without art keep the placeholder")


func test_mastery_colours_recolour_a_heros_clothes() -> void:
	var colour := Color.html(str((Data.cfg("heroes.mastery_palettes") as Array)[2]))
	var plain: Dictionary = PixelArt.find("heracles")
	var tinted: Dictionary = PixelArt.find("heracles", colour)
	assert_ne(plain, tinted, "a mastery colour gives different textures")
	assert_eq(PixelArt.find("heracles", colour), tinted, "and keeps them")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PixelArt.ART_DIR + "heracles.json"))
	assert_true((data["recolor"] as Array).has("r"), "his chiton is listed as his clothes")
	var cloth := Color.html(str(data["palette"]["r"]))
	var recoloured: Color = PixelArt.recolour(cloth, colour)
	assert_almost_eq(recoloured.h, colour.h, 0.01, "clothes take the colour's hue")
	assert_almost_eq(recoloured.v, cloth.v, 0.01, "and keep their brightness")
	var image: Image = (tinted["frames"]["idle"][0] as ImageTexture).get_image()
	var skin := Color.html(str(data["palette"]["s"]))
	var found_skin: bool = false
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).is_equal_approx(skin):
				found_skin = true
	assert_true(found_skin, "skin keeps its colour")


func test_a_hero_holds_the_weapon_they_use_most() -> void:
	var player: Player = _hero("heracles")
	var club: WeaponInstance = player.weapons[0] if not player.weapons.is_empty() else GameAuthority.give_weapon(player, "great_club")
	assert_eq(PixelArt.held_weapon(player.weapons), PixelArt.find("weapons/great_club"), "starts with his club")
	var sword: WeaponInstance = GameAuthority.give_weapon(player, "bronze_sword")
	assert_eq(PixelArt.held_weapon(player.weapons), PixelArt.find("weapons/great_club"), "a tie keeps the first weapon")
	sword.level = club.level + 1
	assert_eq(PixelArt.held_weapon(player.weapons), PixelArt.find("weapons/bronze_sword"), "the higher-level weapon is held")
	var ember: WeaponInstance = GameAuthority.give_weapon(player, "ember")
	ember.level = 8
	assert_eq(PixelArt.held_weapon(player.weapons), PixelArt.find("weapons/bronze_sword"), "spells aren't held")


func test_spell_hits_and_reactions_have_their_own_bursts() -> void:
	var effects: EffectLayer = _combat.effects
	effects.spawn_burst(Vector2(10, 10), "fire")
	var found: int = -1
	for i: int in effects._capacity:
		if effects._active[i] == 1 and effects._kind[i] == EffectLayer.KIND_BURST:
			found = i
	assert_ne(found, -1, "a spell hit shows a burst")
	assert_eq(effects._tag[found], "fire", "in its element's style")
	effects.on_reaction("shatter", Vector2(20, 20), 30.0, null)
	var reaction: bool = false
	for i: int in effects._capacity:
		if effects._active[i] == 1 and effects._kind[i] == EffectLayer.KIND_REACTION and effects._tag[i] == "shatter":
			reaction = true
	assert_true(reaction, "a reaction shows its own burst")
	# Evolved spells look distinct: their own pictures, a forked bolt (Tempest), a darker aura (Oblivion).
	var evolved: Array = ["inferno", "absolute_zero", "cyclone", "judgment"]
	for weapon: Dictionary in Data.get_file("weapons.json"):
		if str(weapon["id"]) in evolved:
			assert_eq(str(weapon.get("projectile_art", "")), str(weapon["id"]), str(weapon["id"]) + " has its own picture")


func test_pickup_and_summon_pictures_load() -> void:
	for name: String in ["xp_gem", "gold_coin", "ambrosia", "chest", "chest_big", "golden_apple"]:
		assert_false(PixelArt.find("pickups/" + name).is_empty(), "pickup picture " + name)
	for name: String in ["stag", "hammer", "crow", "sun_barque"]:
		assert_false(PixelArt.find("summons/" + name).is_empty(), "summon picture " + name)
	assert_true(PixelArt.pickup_scale(PixelArt.pickup_texture("xp_gem"), 9.0).y < 0.0, "pickups are drawn upright")


func test_every_level_has_ground_tiles_and_scenery() -> void:
	for level: Dictionary in Data.get_file("levels.json"):
		var tiles: Dictionary = level.get("tileset", {})
		var ground: Dictionary = PixelArt.find("ground/" + str(tiles.get("id", "")))
		assert_false(ground.is_empty(), "%s has ground tiles" % level["id"])
		for entry: Dictionary in tiles.get("ground", []):
			assert_eq((ground["frames"].get(str(entry["id"]), []) as Array).size(), 2, "%s: two %s tiles" % [level["id"], entry["id"]])
		for id: Variant in level.get("decorations", []):
			assert_false(PixelArt.find("scenery/" + str(id)).is_empty(), "%s has a picture" % id)


func test_menus_have_frames_and_every_card_an_icon() -> void:
	UiTheme.apply()
	assert_true(ThemeDB.get_default_theme().get_stylebox("normal", "Button") is StyleBoxTexture, "buttons are framed")
	for passive: Dictionary in Data.get_file("passives.json"):
		assert_not_null(UiTheme.card_icon({"kind": LevelUpRules.PASSIVE_NEW, "id": passive["id"]}), "%s has an icon" % passive["id"])
	for stat: String in (Data.cfg("level_up.stat_card_values") as Dictionary):
		assert_not_null(UiTheme.card_icon({"kind": LevelUpRules.STAT, "id": stat}), "stat %s has an icon" % stat)
	for weapon: Dictionary in Data.get_file("weapons.json"):
		assert_not_null(UiTheme.card_icon({"kind": LevelUpRules.WEAPON_NEW, "id": weapon["id"]}), "%s has an icon" % weapon["id"])
	assert_not_null(UiTheme.card_icon({"kind": LevelUpRules.GOLD}), "gold card icon")
	assert_not_null(UiTheme.card_icon({"kind": LevelUpRules.HEAL}), "heal card icon")


func test_ruins_dungeon_has_its_own_parts_and_reachable_vault() -> void:
	assert_true(RuinsDungeon.has_art(), "the ruins have dungeon parts")
	var frames: Dictionary = PixelArt.find(RuinsDungeon.PARTS)["frames"]
	for part: String in ["floor", "wall", "column", "altar", "brazier", "decor", "debris", "entrance"]:
		assert_true(frames.has(part), "ruins part " + part)
	for seed_value: int in 10:
		var layout: Dictionary = ShrineDungeon.plan(seed_value * 977, "")
		var walk: Dictionary = layout["walk"]
		var start: Vector2i = layout["start"]
		var goal := Vector2i(Vector2(layout["room_origin"]).floor())
		var seen := {start: true}
		var queue: Array = [start]
		while not queue.is_empty():
			var t: Vector2i = queue.pop_front()
			for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if walk.has(t + d) and not seen.has(t + d):
					seen[t + d] = true
					queue.append(t + d)
		assert_true(seen.has(goal), "the vault is reachable (seed %d)" % seed_value)


func test_passive_cards_without_a_stat_show_no_stat_line() -> void:
	for id: String in ["mirrored_shield", "tyrs_oath"]:
		var text: String = CardText.full({"kind": LevelUpRules.PASSIVE_NEW, "id": id})
		assert_false(text.contains("STAT_"), id + " card has no untranslated stat line")
		assert_false(text.contains("+0%"), id + " card has no +0% line")


func test_flora_blocks_slides_slows_and_keeps_clear() -> void:
	var level: Dictionary = {}
	for entry: Dictionary in Data.get_file("levels.json"):
		if str(entry["id"]) == "the_misty_isles":
			level = entry
	var flora := Flora.new()
	_parent.add_child(flora)
	flora.setup(level, 12345)
	flora.set_process(false)
	assert_true(flora.has_art(), "the level has trees and rocks")
	flora._load(Vector2i(3, 3))
	flora._repack()
	var tree: Dictionary = {}
	for item: Dictionary in flora._chunks[Vector2i(3, 3)]:
		if str(item["kind"]) == "tree" and not bool(item["hidden"]):
			tree = item
			break
	assert_false(tree.is_empty(), "a forest chunk has trees")
	var trunk: Vector2 = Vector2(tree["at"])
	var moved: Vector2 = flora.move(trunk + Vector2(-20, 0), Vector2(20, 0), 6.0)
	assert_true(moved.distance_to(trunk) >= float(tree["solid"]) + 5.9, "a Hero can't walk into a trunk")
	flora.clear_zone("test", trunk, 30.0)
	flora._repack()
	assert_true(bool(tree["hidden"]), "a clear zone removes the tree")
	assert_eq(flora.move(trunk + Vector2(-20, 0), Vector2(20, 0), 6.0), trunk, "and nothing blocks there")
	flora.enabled = false
	assert_eq(flora.move(Vector2.ZERO, Vector2(5, 0), 6.0), Vector2(5, 0), "nothing blocks in a dungeon")
	flora.queue_free()


func test_hidden_shrine_opens_a_third_god_slot() -> void:
	var player: Player = _hero("heracles")
	var gods := GodManager.new()
	_parent.add_child(gods)
	assert_eq(gods.max_slots(player), 2, "two god slots normally")
	player.god_flags["extra_god_slot"] = 1
	assert_eq(gods.max_slots(player), 3, "three after the hidden shrine")
	gods.queue_free()


func test_hidden_groves_ring_a_clearing_with_a_way_in() -> void:
	var level: Dictionary = {}
	for entry: Dictionary in Data.get_file("levels.json"):
		if str(entry["id"]) == "the_misty_isles":
			level = entry
	var flora := Flora.new()
	_parent.add_child(flora)
	flora.setup(level, 777)
	flora.set_process(false)
	var found: Dictionary = {}
	for x: int in 40:
		var rng := RandomNumberGenerator.new()
		rng.seed = x
		var items: Array = []
		var grove: Dictionary = HiddenGroves.carve(flora, Vector2i(x, x * 3), items, rng)
		if not grove.is_empty():
			found = grove
			var ways_in: int = items.filter(func(i: Dictionary) -> bool: return bool(i.get("secret", false))).size()
			assert_eq(ways_in, Data.cfg_int("world.grove_gate_trees"), "the ring has its walk-through trees")
			for item: Dictionary in items:
				assert_true(Vector2(item["at"]).distance_to(grove["at"]) >= float(grove["r"]) - 1.0, "nothing grows in the clearing")
			break
	assert_false(found.is_empty(), "thick forest hides groves")
	flora.queue_free()


func test_some_hidden_groves_are_empty() -> void:
	var world: Dictionary = Data.get_file("config.json")["world"]
	var before: float = float(world["grove_empty_chance"])
	assert_true(before > 0.0 and before < 1.0, "groves are only sometimes empty")
	world["grove_empty_chance"] = 1.0
	var groves := HiddenGroves.new()
	groves.set_process(false)
	_parent.add_child(groves)
	var grove: Dictionary = {"key": "grove_test_empty", "shrine": false}
	groves._open(grove, Vector2.ZERO, null)
	assert_eq(GameAuthority.run.poi_state.get("grove_test_empty", ""), "empty", "this one hid nothing")
	world["grove_empty_chance"] = before
	groves.queue_free()


func test_mountains_have_ways_up_a_bridge_and_a_cave() -> void:
	var mountains := Mountains.new()
	_parent.add_child(mountains)
	mountains.setup({"id": "aegean_shore"}, 4242)
	mountains.set_process(false)
	var m: Dictionary = {}
	for ry: int in range(-3, 4):
		for rx: int in range(-3, 4):
			if m.is_empty():
				m = mountains.plan(Vector2i(rx, ry))
	assert_false(m.is_empty(), "the world has mountains")
	var kinds: Array = (m["spots"] as Array).map(func(s: Dictionary) -> String: return str(s["kind"]))
	assert_true(kinds.has("hand") and kinds.has("ladder"), "handholds and a rope ladder up the cliff")
	assert_false((m["bridge"] as Array).is_empty(), "a rope bridge between the peaks")
	assert_eq(int(m["tiles"][m["cave"]]), 2, "the cave is up on a peak")
	# Roads lead to it (owner request 10/31/2026): from the foot of each way up, winding away across the land.
	var centre: Vector2 = (Vector2(m["c"]) + Vector2(0.5, 0.5)) * Mountains.TILE
	assert_false((m["roads"] as Array).is_empty(), "roads lead to the mountain")
	for road: PackedVector2Array in m["roads"]:
		assert_gt(road[road.size() - 1].distance_to(centre), road[0].distance_to(centre) + 300.0, "each runs away from it")
	mountains._index(m)
	var bridge_tile: Vector2i = m["bridge"][0]
	assert_false(mountains.walkable(bridge_tile, 2), "the broken bridge can't be crossed")
	GameAuthority.run.poi_state[str(m["key"]) + "_bridge"] = "fixed"
	assert_true(mountains.walkable(bridge_tile, 2), "the mended bridge can")
	assert_false(mountains.walkable(m["cave"], 0), "ground-level Heroes can't walk onto the peaks")
	mountains.queue_free()


func test_menu_backdrop_never_repeats_and_has_its_style() -> void:
	var frames: Dictionary = PixelArt.find("ui/frames")["frames"]
	for name: Variant in Data.cfg("ui.menu_backdrops"):
		assert_false(PixelArt.find("menu/" + str(name)).is_empty(), "backdrop %s has its picture" % name)
	var last: String = ""
	for k: int in 12:
		MenuBackdrop._scene = ""
		MenuBackdrop._choose()
		assert_ne(MenuBackdrop.scene(), last, "never the same backdrop twice in a row")
		last = MenuBackdrop.scene()
		assert_true(frames.has(MenuBackdrop.style() + "_button"), "%s has its matching buttons" % last)
	assert_false(PixelArt.find("menu/logo").is_empty(), "the logo")


func test_you_go_in_by_the_doorway_not_over_the_building() -> void:
	var site: Dictionary = {"pos": Vector2(100, 100)}
	assert_true(ShrineDungeon.in_doorway(Vector2(100, 92), site), "standing in the shrine's doorway")
	assert_false(ShrineDungeon.in_doorway(Vector2(132, 92), site), "not on its wall beside the door")
	assert_false(ShrineDungeon.in_doorway(Vector2(100, 130), site), "not out in front of it")
	var level: Dictionary = {}
	for entry: Dictionary in Data.get_file("levels.json"):
		if str(entry["id"]) == "aegean_shore":
			level = entry
	var flora := Flora.new()
	_parent.add_child(flora)
	flora.setup(level, 1)
	flora.set_process(false)
	flora._structures = Flora.blockers("shrine", Vector2(0, 0))
	flora._repack()
	# A Hero walks a step at a time (about 1.5 px a frame).
	var walk := func(from: Vector2, way: Vector2, frames: int) -> Vector2:
		var at: Vector2 = from
		for k: int in frames:
			at = flora.move(at, way * 1.5, 7.0)
		return at
	assert_gt((walk.call(Vector2(32, 20), Vector2.UP, 40) as Vector2).y, -2.0, "the wall beside the door stops you")
	assert_lt((walk.call(Vector2(0, 20), Vector2.UP, 40) as Vector2).y, -6.0, "the doorway lets you in")
	assert_lt((walk.call(Vector2(0, -70), Vector2.DOWN, 40) as Vector2).y, -38.0, "the back of the doorway is closed")
	flora.queue_free()


func test_every_achievement_unlock_names_a_real_achievement() -> void:
	var ids: Array = AchievementRules.all().map(func(entry: Dictionary) -> String: return str(entry.get("id", "")))
	for file: String in ["weapons.json", "heroes.json"]:
		for entry: Variant in Data.get_file(file):
			var unlock: Variant = (entry as Dictionary).get("unlock") if entry is Dictionary else null
			if unlock is Dictionary and str(unlock.get("type", "")) == "achievement":
				assert_true(ids.has(str(unlock.get("achievement", ""))), "%s: %s is an achievement" % [entry.get("id"), unlock.get("achievement")])


func test_rerolls_are_free_first_then_bought_at_a_rising_price() -> void:
	var player := Player.new()
	add_child_autofree(player)
	Rerolls.start(player)
	var run: RunState = GameAuthority.run
	run.reroll_tokens = 0
	run.gold = 1000.0
	assert_eq(player.free_rerolls, Data.cfg_int("level_up.free_rerolls_start"), "one free reroll to start")
	assert_true(Rerolls.spend(player), "the free one")
	assert_eq(player.gold_spent, 0.0, "cost nothing")
	var first: int = Rerolls.price(player)
	assert_eq(first, Data.cfg_int("level_up.reroll_price"))
	assert_true(Rerolls.spend(player))
	assert_eq(player.gold_spent, float(first), "then bought with run gold")
	assert_eq(Rerolls.price(player), first * 2, "each one bought costs double")
	run.gold = player.gold_spent + 1.0
	assert_false(Rerolls.spend(player), "not enough gold: no reroll")
	player.free_rerolls = 0
	GameAuthority.players.append(player)
	Rerolls.on_level(Data.cfg_int("level_up.free_reroll_every_levels"))
	Rerolls.on_level(Data.cfg_int("level_up.free_reroll_every_levels") + 1)
	GameAuthority.players.erase(player)
	assert_eq(player.free_rerolls, 1, "another free one every 5 levels")


func test_orpheus_charms_monsters_into_turning_on_each_other() -> void:
	var orpheus: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, "orpheus")
	assert_eq(str(orpheus.hero.get("id", "")), "orpheus")
	assert_almost_eq(orpheus.kit_attack_speed_bonus(), 0.1, 0.001, "Outsinging the Sirens: +10% attack speed")
	var a: int = _enemies.spawn("satyr_skirmisher", Vector2(30, 0))
	var b: int = _enemies.spawn("satyr_skirmisher", Vector2(40, 10))
	_enemies.hash_grid.rebuild(_enemies.positions, _enemies.active)
	orpheus.kit._song_in = 0.0
	orpheus.kit._process(0.01)
	assert_eq(_enemies.charmed[a], 1, "his song charms the monsters round him")
	var hp_before: float = _enemies.hp[b]
	_enemies.charmed[b] = 0
	_enemies._charm_strike_in = 0.0
	_enemies._tick_charms(0.01)
	assert_lt(_enemies.hp[b], hp_before, "a charmed monster strikes another")
	_enemies._tick_charms(10.0)
	assert_eq(_enemies.charmed[a], 0, "the charm wears off")
	GameAuthority.remove_player(orpheus)
