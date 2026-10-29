class_name CoopTurns
extends Node
## Co-op level-ups (GAME_DESIGN.md: Core mechanics / Co-op; Fairness rules):
## XP is shared, so everyone levels up at the same moment. The game fully
## pauses and the timer stops; players choose one at a time in turn order,
## each from their own 3 cards, up to 20 s each (then the first card is
## taken for them). The first picker rotates each level-up. Maxed builds take
## Gold or Heal at once. Runs on the host; joining players see their cards on
## their turn (an OFFER) and who is choosing (E_TURN events).

var level_up: LevelUpScreen
var host: CoopHost

var _order: Array[Player] = []
var _current: Player = null
var _cards: Array = []
var _left_s: float = 0.0
var _rounds: int = 0
var _active: bool = false
var _announce_in: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Net.is_host():
		GameAuthority.level_up_ready.connect(_on_level_up_ready)


func is_active() -> bool:
	return _active


## True while this device's own level-up cards are showing (it keeps itself paused).
func local_screen_open() -> bool:
	return level_up != null and level_up.visible


func _on_level_up_ready(_run: RunState) -> void:
	if not _active:
		_start_round()


func _start_round() -> void:
	var run: RunState = GameAuthority.run
	if run == null or run.ended or run.unspent_level_ups <= 0:
		_finish()
		return
	_active = true
	get_tree().paused = true
	_order.clear()
	var everyone: Array[Player] = []
	for player: Player in GameAuthority.players:
		if not player.shade:
			everyone.append(player)
	for i: int in everyone.size():
		_order.append(everyone[(i + _rounds) % everyone.size()])
	_rounds += 1
	_next_turn()


func _next_turn() -> void:
	var run: RunState = GameAuthority.run
	while not _order.is_empty():
		_current = _order.pop_front()
		if not is_instance_valid(_current):
			continue
		if LevelUpRules.is_maxed(_current):
			var auto: String = GameAuthority.auto_collect if _current.is_local else "smart"
			var card: Dictionary = LevelUpRules.auto_collect_card("smart" if auto == "off" else auto, _current)
			if not card.is_empty():
				GameAuthority.apply_card(_current, card, false)
				continue
		_cards = LevelUpRules.build_offer(_current, run.rng.loot)
		if _cards.is_empty():
			continue
		_left_s = Data.cfg_float("coop.turn_s")
		_announce_in = 0.0
		if _current.is_local:
			level_up.show_coop_cards(_cards, _on_local_pick, ceili(_left_s))
		else:
			CoopChoices.offer(_current, "cards", _cards)
			level_up.show_coop_wait(_waiting_text(_current))
		return
	# Everyone has picked: that level-up is used up.
	_current = null
	run.unspent_level_ups = maxi(run.unspent_level_ups - 1, 0)
	_start_round()


func _process(delta: float) -> void:
	if not _active or _current == null:
		return
	_left_s -= delta
	_announce_in -= delta
	if _announce_in <= 0.0:
		_announce_in = 1.0
		host.add_event([CoopCodec.E_TURN, _current.player_id, ceili(maxf(_left_s, 0.0))])
	if _left_s <= 0.0:
		# Time's up: the first card is taken for them.
		pick(_current, 0)


func _on_local_pick(index: int) -> void:
	pick(GameAuthority.local_player(), index)


## A joining player's choice (from CoopHost).
func on_card(player: Player, index: int) -> void:
	pick(player, index)


func pick(player: Player, index: int) -> void:
	if not _active or player != _current or _cards.is_empty():
		return
	var card: Dictionary = _cards[clampi(index, 0, _cards.size() - 1)]
	_cards = []
	GameAuthority.apply_card(player, card, false)
	if player.is_local:
		level_up.show_coop_wait(tr("UI_COOP_PICKED"))
	_next_turn()


func _finish() -> void:
	if not _active:
		return
	_active = false
	_current = null
	level_up.hide_coop()
	host.add_event([CoopCodec.E_TURN, -1, 0])
	get_tree().paused = false


static func _waiting_text(player: Player) -> String:
	var hero_name: String = TranslationServer.translate(str(player.hero.get("name_key", "")))
	return TranslationServer.translate("UI_COOP_TURN_OF") % [player.player_id, hero_name]
