class_name CoopChoices
extends RefCounted
## Co-op choices made on the player's own device (GAME_DESIGN.md: Online
## co-op / Fairness rules): their level-up cards, their chest reveal, a third
## god at a shrine, their Boon after a boss, the Wandering Trader (spending
## only their own run gold), and Ruins. The host's game decides that a choice
## is due and sends an OFFER to that player; their device shows the usual
## screen and sends back a CHOICE, which the host applies to that player.
## Also shows the host's other announcements (banners, banter, drops, turns).

## Group of the screens that pause this device while open (cards, chest, choices…).
const MODAL := "coop_modal"


static func _tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree


static func _screen(group: String) -> Node:
	return _tree().get_first_node_in_group(group)


## True on the host when `player` plays on another device.
## True while one of this device's own choice screens is open.
static func local_modal_open() -> bool:
	for node: Node in _tree().get_nodes_in_group(MODAL):
		if node is CanvasLayer and (node as CanvasLayer).visible:
			return true
	return false


static func is_remote(player: Player) -> bool:
	return Net.is_host() and Net.in_run() and player != null and not player.is_local


## Sent inside the host's updates, so it arrives in order with the turn notices around it.
static func offer(player: Player, kind: String, data: Variant) -> void:
	var host: CoopHost = _tree().get_first_node_in_group(CoopHost.GROUP) as CoopHost
	if host != null:
		host.add_event([CoopCodec.E_OFFER, player.player_id, kind, data])
	else:
		Net.send(player.player_id, [NetMsg.OFFER, kind, data])


static func choose(kind: String, data: Variant) -> void:
	Net.send(LobbyService.HOST_ID, [NetMsg.CHOICE, kind, data])


## Pauses everyone for a moment (a joining player's chest reveal plays on their device).
static func pause_briefly(seconds: float) -> void:
	var tree: SceneTree = _tree()
	if tree.paused:
		return
	tree.paused = true
	tree.create_timer(seconds, true).timeout.connect(func() -> void:
		if not local_modal_open():
			_tree().paused = false)


## A chest plan without objects (the infusion choice names the weapon by id).
static func plain_plan(plan: Dictionary) -> Dictionary:
	var out: Dictionary = plan.duplicate(true)
	if plan.has("choose"):
		var choose: Dictionary = plan["choose"]
		out["choose"] = {"weapon_id": (choose["weapon"] as WeaponInstance).id(), "gods": choose.get("gods", [])}
	return out


# --- On a joining player's device ------------------------------------------------------------

static func on_offer(kind: String, data: Variant) -> void:
	var me: Player = GameAuthority.local_player()
	if me == null:
		return
	match kind:
		"cards":
			var screen: LevelUpScreen = _screen("level_up_screen")
			if screen != null:
				screen.show_coop_cards(data, _on_card_picked, Data.cfg_int("coop.turn_s"))
		"chest":
			var chest: ChestScreen = _screen("chest_screen")
			var plan: Dictionary = data[0]
			var evolved: Array[Dictionary] = []
			for recipe: Variant in data[1]:
				evolved.append(recipe)
				EvolutionRules.discover(recipe)
			if plan.has("choose"):
				var choose: Dictionary = plan["choose"]
				for weapon: WeaponInstance in me.weapons:
					if weapon.id() == str(choose.get("weapon_id", "")):
						plan["choose"] = {"weapon": weapon, "gods": choose.get("gods", [])}
			if chest != null:
				chest.play(plan, evolved)
		"god":
			var god_choice: GodChoiceScreen = _screen("god_choice_screen")
			if god_choice != null:
				god_choice.ask(me, str(data))
		"boon":
			var boons: BoonScreen = _screen("boon_screen")
			if boons != null:
				boons.offer()
		"trader":
			var trader: TraderScreen = _screen("trader_screen")
			if trader != null:
				trader.open_for(me)
		"ruins":
			var ruins: RuinsChoiceScreen = _screen("ruins_choice_screen")
			if ruins != null:
				ruins.show_options(me, float(data[0]), data[1])


static func _on_card_picked(index: int) -> void:
	Net.send(LobbyService.HOST_ID, [NetMsg.CARD, index])
	var screen: LevelUpScreen = _screen("level_up_screen")
	if screen != null:
		screen.show_coop_wait(TranslationServer.translate("UI_COOP_PICKED"))


## Host events that aren't about enemies or players.
static func on_event(event: Array) -> void:
	match int(event[0]):
		CoopCodec.E_TURN:
			var screen: LevelUpScreen = _screen("level_up_screen")
			if screen == null:
				return
			var id: int = int(event[1])
			if id == -1:
				screen.hide_coop()
			elif id != Net.my_id:
				var player: Player = GameAuthority.player_by_id(id)
				if player != null:
					screen.show_coop_wait(CoopTurns._waiting_text(player) + "  " + str(int(event[2])))
		CoopCodec.E_OFFER:
			if int(event[1]) == Net.my_id:
				on_offer(str(event[2]), event[3])
		CoopCodec.E_BANNER:
			var banner: Banner = _screen(Banner.GROUP)
			if banner != null:
				banner.show_text(str(event[1]))
		CoopCodec.E_BANTER:
			var banter: BanterBubble = _screen("banter_bubble")
			if banter != null and event[1] is Dictionary:
				banter.say_line(event[1])
		CoopCodec.E_DROP:
			_apply_drop(str(event[1]), Vector2(float(event[2]), float(event[3])), float(event[4]))


static func _apply_drop(kind: String, at: Vector2, value: float) -> void:
	match kind:
		"gold":
			var gold: GoldPickups = _screen("gold_pickups")
			if gold != null:
				gold.drop(at, value)
		"heal":
			var heals: HealPickups = _screen("heal_pickups")
			if heals != null:
				heals.drop(at)
		"pull":
			var coins: GoldPickups = _screen("gold_pickups")
			if coins != null:
				coins.pull_all()


# --- On the host ------------------------------------------------------------------------------

## A joining player's choice, applied to their Hero here.
static func on_choice(player: Player, kind: String, data: Variant) -> void:
	match kind:
		"god":
			var row: Array = data
			if row.size() >= 2 and int(row[1]) >= 0 and GameAuthority.gods != null:
				GameAuthority.gods.bind(player, str(row[0]), int(row[1]))
		"infuse":
			var pick: Array = data
			for weapon: WeaponInstance in player.weapons:
				if weapon.id() == str(pick[0]):
					Infusions.infuse(weapon, str(pick[1]))
		"boon":
			for boon: Dictionary in BoonScreen.all():
				if str(boon["id"]) == str(data):
					BoonScreen.apply(player, boon)
		"buy":
			var item: Array = data
			TraderScreen.buy(player, str(item[0]), int(item[1]))
		"ruins":
			var take: Array = data
			RuinsChoiceScreen.apply_choice(player, str(take[0]), take[1])
