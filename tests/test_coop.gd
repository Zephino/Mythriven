extends GutTest
## Phase 20 co-op: the lobby (through an in-program lobby instead of the
## Worker), message packing, what a joining player's device may decide,
## revives and the Wandering Shade, the tether, and co-op gold.

const TEST_SAVE := "user://test_coop_save.json"
const SESSION := preload("res://scripts/net/net_session.gd")

var _parent: Node2D
var _sessions: Array[Node] = []


func before_each() -> void:
	SaveGame.use_test_file(TEST_SAVE)
	_parent = add_child_autofree(Node2D.new())


func after_each() -> void:
	for session: Node in _sessions:
		if is_instance_valid(session):
			session.call("leave")
	_sessions.clear()
	Net.state = Net.State.OFF
	Net.my_id = 0
	Net.roster = {}
	Net.public_game = false
	Net.joined_late = false
	GameAuthority.replicating = false
	GameAuthority.end_scene()
	GameAuthority.selected_hero_id = ""
	SaveGame.use_test_file("")
	for file: String in [TEST_SAVE, TEST_SAVE + ".bak", TEST_SAVE + ".tmp"]:
		DirAccess.remove_absolute(file)


func _session() -> Node:
	var session: Node = SESSION.new()
	session.set("service_override", LocalLobby.new())
	add_child_autofree(session)
	_sessions.append(session)
	return session


func _wait_frames(count: int) -> void:
	for _i: int in count:
		await get_tree().process_frame


func test_host_and_join_share_a_roster_and_start_together() -> void:
	var host: Node = _session()
	var guest: Node = _session()
	host.call("host_game", "heracles")
	await _wait_frames(3)
	var code: String = host.get("code")
	assert_eq(code.length(), 6, "a 6-digit code")
	guest.call("join_game", code, "cu_chulainn")
	await _wait_frames(6)
	assert_eq(int(guest.get("my_id")), 2)
	assert_eq((host.get("roster") as Dictionary).size(), 2, "the host sees both players")
	assert_eq(str((guest.get("roster") as Dictionary)[1]["hero"]), "heracles", "the guest sees the host's Hero")
	assert_true(host.call("everyone_ready"))
	guest.call("choose_hero", "tomoe_gozen")
	await _wait_frames(6)
	assert_eq(str((host.get("roster") as Dictionary)[2]["hero"]), "tomoe_gozen", "a new Hero choice reaches the host")
	host.call("start_run")
	await _wait_frames(4)
	assert_eq(int(guest.get("state")), Net.State.IN_RUN, "the guest starts too")
	assert_eq(int(guest.get("run_seed")), int(host.get("run_seed")), "the same map for everyone")
	assert_eq(GameAuthority.selected_hero_id, "tomoe_gozen", "each player plays their own Hero")


func test_after_a_run_everyone_returns_to_the_same_lobby() -> void:
	var host: Node = _session()
	var guest: Node = _session()
	host.call("host_game", "heracles")
	await _wait_frames(3)
	guest.call("join_game", host.get("code"), "cu_chulainn")
	await _wait_frames(6)
	host.call("start_run")
	await _wait_frames(4)
	host.call("back_to_lobby")
	await _wait_frames(4)
	assert_eq(int(host.get("state")), Net.State.LOBBY)
	assert_false(host.call("everyone_ready"), "waits for the friend still on the results screen")
	guest.call("back_to_lobby")
	await _wait_frames(6)
	assert_true(host.call("everyone_ready"), "everyone is back: Start opens again")
	assert_eq(str(host.get("code")), str(guest.get("code")), "the same game code")
	var newcomer: Node = _session()
	newcomer.call("join_game", host.get("code"), "heracles")
	await _wait_frames(6)
	assert_eq(int(newcomer.get("state")), Net.State.LOBBY, "friends can join between runs")


func test_a_started_or_unknown_game_cant_be_joined() -> void:
	var host: Node = _session()
	var late: Node = _session()
	var reasons: Array[String] = []
	late.connect("ended", func(reason: String) -> void: reasons.append(reason))
	late.call("join_game", "000000", "heracles")
	await _wait_frames(3)
	assert_eq(reasons, ["UI_COOP_JOIN_REFUSED"] as Array[String])
	host.call("host_game", "heracles")
	await _wait_frames(3)
	(host.get("lobby") as LobbyService).lock()
	var other: Node = _session()
	other.call("join_game", host.get("code"), "heracles")
	await _wait_frames(3)
	assert_eq(int(other.get("state")), Net.State.OFF, "no joining once the run has started")


func test_when_the_host_leaves_the_game_ends_for_everyone() -> void:
	var host: Node = _session()
	var guest: Node = _session()
	var reasons: Array[String] = []
	guest.connect("ended", func(reason: String) -> void: reasons.append(reason))
	host.call("host_game", "heracles")
	await _wait_frames(3)
	guest.call("join_game", host.get("code"), "heracles")
	await _wait_frames(4)
	host.call("leave")
	await _wait_frames(3)
	assert_eq(reasons, ["UI_COOP_HOST_LEFT"] as Array[String])


func test_messages_carry_only_plain_values() -> void:
	var msg: Array = [NetMsg.TICK, 3, false, [1.5, 2], {"a": Vector2(1, 2)}]
	assert_eq(NetMsg.decode(NetMsg.encode(msg)), msg)
	assert_eq(NetMsg.decode(var_to_bytes("not a message")), [], "anything but a message is ignored")
	# Objects are never decoded (bytes_to_var refuses them), so a message can't run code.


func test_player_state_and_build_round_trip() -> void:
	GameAuthority.start_run("aegean_shore")
	var a: Player = GameAuthority.spawn_player(_parent, Vector2(10, 20), null, false, "heracles", 1)
	var b: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, false, "heracles", 2)
	GameAuthority.give_weapon(a, "great_club")
	GameAuthority.give_weapon(a, "throwing_axe")
	a.weapons[0].level = 4
	a.stats.add_bonus("might", 0.3)
	a.hp = 42.0
	a.downed = true
	a.alive = false
	a.gold_spent = 15.0
	CoopCodec.apply_build(b, CoopCodec.build(a))
	assert_eq(b.weapons.size(), 2)
	assert_eq(b.weapons[0].level, 4)
	assert_almost_eq(float(b.stats.bonus["might"]), 0.3, 0.001)
	CoopCodec.apply_player_state(b, CoopCodec.player_state(a, null), false)
	assert_eq(b.hp, 42.0)
	assert_true(b.downed and not b.alive)
	assert_eq(b.gold_spent, 15.0)
	assert_eq(b.get_meta("net_target"), Vector2(10, 20), "others glide to where the host says")
	CoopCodec.apply_player_state(b, CoopCodec.player_state(a, null), true)
	assert_eq(b.position, Vector2.ZERO, "a device keeps moving its own Hero")


func test_enemies_follow_the_host_on_a_joining_device() -> void:
	GameAuthority.start_run("aegean_shore")
	var host_side: EnemyManager = _manager()
	var guest_side: EnemyManager = _manager()
	guest_side.remote = true
	host_side.spawn("shade_swarm", Vector2.ZERO)
	var slot: int = host_side.spawn("satyr_skirmisher", Vector2(50, 60))
	guest_side.spawn_into(slot, host_side.kind[slot], Vector2(50, 60), host_side.max_hp[slot])
	assert_eq(guest_side.active[slot], 1, "the same slot number as on the host")
	assert_eq(guest_side.active_count(), 1)
	host_side.positions[slot] = Vector2(80, 60)
	host_side.hp[slot] = host_side.max_hp[slot] * 0.5
	CoopCodec.apply_enemy_batch(guest_side, CoopCodec.enemy_batch(host_side, PackedInt32Array([slot])))
	for _i: int in 30:
		guest_side._process(0.05)
	assert_almost_eq(guest_side.positions[slot].x, 80.0, 1.0, "glides to the host's position")
	assert_almost_eq(guest_side.hp[slot] / guest_side.max_hp[slot], 0.5, 0.01)


func test_a_joining_device_only_acts_on_the_hosts_word() -> void:
	GameAuthority.start_run("aegean_shore")
	var enemies: EnemyManager = _manager()
	GameAuthority.enemies = enemies
	var player: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true)
	Net.state = Net.State.IN_RUN
	Net.my_id = 2
	assert_eq(GameAuthority.spawn_enemy("shade_swarm", Vector2.ZERO), -1, "the host spawns enemies")
	GameAuthority.damage_player(player, 30.0, "test")
	assert_eq(player.hp, player.max_hp, "the host decides damage")
	GameAuthority.collect_xp(player, 100.0)
	assert_eq(GameAuthority.run.xp, 0.0, "and XP")
	GameAuthority.replicating = true
	var slot: int = GameAuthority.spawn_enemy("shade_swarm", Vector2.ZERO)
	GameAuthority.kill_enemy(slot, player)
	GameAuthority.replicating = false
	assert_ne(slot, -1, "what the host says still happens")
	assert_eq(enemies.active_count(), 0)


func test_downed_players_bleed_out_unless_an_ally_revives_them() -> void:
	GameAuthority.start_run("aegean_shore")
	var a: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, "", 1)
	var b: Player = GameAuthority.spawn_player(_parent, Vector2(5, 0), null, false, "", 2)
	var revives: CoopRevives = add_child_autofree(CoopRevives.new())
	GameAuthority.damage_player(b, 9999.0, "test")
	assert_true(b.downed, "downed, not dead, in co-op")
	assert_false(GameAuthority.run.ended)
	for _i: int in 4:
		revives._process(1.0)
	assert_true(b.alive, "an ally beside them for 3 s revives them")
	assert_almost_eq(b.hp, b.max_hp * Data.cfg_float("coop.revive_hp_pct"), 0.01)
	assert_eq(CoopRevives.revive_time(b), 5.0, "the next revive takes longer")
	GameAuthority.damage_player(b, 9999.0, "test")
	b.position = Vector2(500, 0)
	revives._process(Data.cfg_float("coop.bleed_out_s") + 1.0)
	assert_true(b.shade, "bleeding out makes a Wandering Shade")
	assert_almost_eq(CoopRevives.shade_charge_mult(a), 1.0, 0.001, "too far for the Shade's help")
	b.position = Vector2(20, 0)
	assert_almost_eq(CoopRevives.shade_charge_mult(a), 1.0 + Data.cfg_float("coop.shade_god_charge_bonus"), 0.001)
	GameAuthority.damage_player(a, 9999.0, "test")
	assert_true(GameAuthority.run.ended, "the run ends when no one is left fighting")


func test_out_of_revives_means_a_shade_at_once() -> void:
	GameAuthority.start_run("aegean_shore")
	GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, "", 1)
	var b: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, false, "", 2)
	b.revives_used = Data.cfg_int("coop.revives_per_player")
	GameAuthority.damage_player(b, 9999.0, "test")
	assert_true(b.shade and not b.downed)


func test_the_tether_keeps_players_within_reach() -> void:
	GameAuthority.start_run("aegean_shore")
	var me: Player = GameAuthority.spawn_player(_parent, Vector2(10000, 0), null, true, "", 1)
	GameAuthority.spawn_player(_parent, Vector2.ZERO, null, false, "", 2)
	var tether: CoopTether = add_child_autofree(CoopTether.new())
	tether._process(0.016)
	var view: Vector2 = tether.get_viewport().get_visible_rect().size / Data.cfg_float("camera.zoom")
	assert_almost_eq(me.position.x, view.x * Data.cfg_float("coop.tether_screens"), 1.0)


func test_coop_scaling_and_each_players_own_trader_gold() -> void:
	var run: RunState = GameAuthority.start_run("aegean_shore")
	Meta._apply_coop_scaling(run, 3)
	assert_almost_eq(run.coop_hp_mult, 1.0 + 2 * Data.cfg_float("coop.enemy_hp_per_extra_player"), 0.001)
	assert_almost_eq(run.coop_boss_hp_mult, 1.0 + 2 * Data.cfg_float("coop.boss_hp_per_extra_player"), 0.001)
	var buyer: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, "", 1)
	var friend: Player = GameAuthority.spawn_player(_parent, Vector2.ZERO, null, false, "", 2)
	run.gold = 500.0
	Net.state = Net.State.IN_RUN
	Net.my_id = 1
	assert_true(TraderScreen.buy(buyer, "reroll_token"))
	assert_eq(run.gold, 500.0, "every coin still counts for everyone")
	assert_lt(TraderScreen.wallet(buyer), 500.0, "the buyer spends only their own share")
	assert_eq(TraderScreen.wallet(friend), 500.0)


func _manager() -> EnemyManager:
	var manager: EnemyManager = EnemyManager.new()
	_parent.add_child(manager)
	manager.setup()
	manager.set_process(false)
	return manager


func test_the_coop_end_screen_has_a_way_back_to_the_title() -> void:
	GameAuthority.start_run("aegean_shore")
	GameAuthority.spawn_player(_parent, Vector2.ZERO, null, true, "heracles", 1)
	var screen: DeathScreen = add_child_autofree(DeathScreen.new())
	Net.state = Net.State.IN_RUN
	Net.my_id = 1
	screen.show_summary(PackedStringArray(["line"]), {}, true, "")
	assert_false(screen._retry.visible, "no Retry in co-op")
	assert_true(screen._title_button.visible, "Back to Title is there")
	assert_true(screen._lobby_button.visible, "and Back to Co-op Lobby")
	assert_true(screen._lobby_button.has_focus(), "which starts selected")
	assert_eq(screen._board_status.text, tr("UI_LB_COOP"))


func test_a_public_game_is_listed_and_can_be_joined_during_a_run() -> void:
	var host: Node = _session()
	host.call("host_game", "heracles", true)
	await _wait_frames(3)
	assert_true(host.call("everyone_ready"), "a public game can start with one player")
	var listed: Array[Dictionary] = PublicGameList.offered(LocalLobby.public_games())
	assert_eq(listed.size(), 1, "on the public list")
	assert_eq(str(listed[0]["code"]), str(host.get("code")))
	assert_eq(str(listed[0]["level"]), str(host.get("level_id")), "with its level")
	var friends: Node = _session()
	friends.call("host_game", "heracles")
	await _wait_frames(3)
	assert_eq(PublicGameList.offered(LocalLobby.public_games()).size(), 1, "friend games are never listed")
	GameAuthority.start_run("aegean_shore")
	host.call("start_run")
	await _wait_frames(3)
	assert_true(bool(LocalLobby.public_games()[0]["in_run"]), "the list says it's in a run")
	var joined: Array[int] = []
	host.connect("late_joined", func(id: int) -> void: joined.append(id))
	var late: Node = _session()
	late.call("join_game", host.get("code"), "atalanta", true)
	await _wait_frames(8)
	assert_eq(int(late.get("state")), Net.State.IN_RUN, "joined straight into the run")
	assert_true(bool(late.get("joined_late")), "and waits for the world's snapshot")
	assert_eq(int(late.get("run_seed")), int(host.get("run_seed")), "the same map")
	assert_eq(joined, [2] as Array[int], "the host adds their Hero")


func test_a_newcomers_snapshot_has_the_world_so_far() -> void:
	GameAuthority.start_run("aegean_shore")
	var enemies: EnemyManager = _manager()
	GameAuthority.enemies = enemies
	var world: WorldRoot = add_child_autofree(WorldRoot.new())
	GameAuthority.spawn_player(world, Vector2.ZERO, null, true, "heracles", 1)
	world.shift_by(Vector2i(2, -1))
	var slot: int = enemies.spawn("satyr_skirmisher", Vector2(70, 20))
	var shade: Player = GameAuthority.spawn_player(world, Vector2(5, 0), null, false, "heracles", 2)
	var newcomer: Player = CoopLateJoin.add_hero(world, 2, "atalanta", Vector2(40, 0))
	assert_false(is_instance_valid(shade) and GameAuthority.players.has(shade), "a Shade with the same id makes way")
	assert_eq(str(newcomer.hero.get("id", "")), "atalanta")
	assert_false(newcomer.weapons.is_empty(), "with the signature weapon")
	var host := CoopHost.new()
	host.world = world
	host.enemies = enemies
	var late_join := CoopLateJoin.new()
	late_join.host = host
	add_child_autofree(late_join)
	var snapshot: Array = late_join.snapshot(2)
	late_join.queue_free()
	host.free()
	assert_eq(int(snapshot[0]), NetMsg.SNAPSHOT)
	assert_eq(Vector2i(int(snapshot[1]), int(snapshot[2])), Vector2i(2, -1), "every origin shift so far")
	assert_eq(Vector2(float(snapshot[3]), float(snapshot[4])), Vector2(40, 0), "where the newcomer appears")
	var spawns: Array = (snapshot[5] as Array).filter(func(e: Array) -> bool: return int(e[0]) == CoopCodec.E_SPAWN)
	assert_eq(spawns.size(), 1, "every enemy")
	assert_eq(int(spawns[0][1]), slot)
	assert_eq((snapshot[6] as Array).size(), 2, "every player's place")
	assert_true(NetMsg.encode(snapshot).size() < 256000, "fits in one message")
