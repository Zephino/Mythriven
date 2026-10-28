class_name GodManager
extends Node
## The gods bound to each player this run (GAME_DESIGN.md: Gods (summons);
## Binding and summoning). Each player can bind 2 gods. Each god has its own
## meter, filled by its trigger:
##   pickups (Tyche), damage taken (Cernunnos), attacks made (Thor), time
##   (Skadi, Ra, the Morrígan: twice as fast below 50% HP), enemies hit
##   (Sekhmet), kills (Poseidon)
## and its own button: Q / E on PC, LB / RB on a gamepad, the god buttons on
## touch. A full meter can be held. Auto-summon (accessibility) fires a full
## god when 30+ enemies are on screen or a boss is present. Summoning also
## triggers the Hero's Divine Link.

signal god_bound(player: Player, god_id: String)
signal god_released(player: Player, god_id: String)
signal summoned(player: Player, god_id: String)

var summons: SummonLayer
var banter: BanterBubble
var resonance: ResonanceManager
## Used by Harmony and infusions for ground patches and gold drops.
var ground: GroundEffects
var gold: GoldPickups
var auto_summon: bool = false

## player_id -> Array of {"id": String, "god": Dictionary, "meter": float (0–1)}.
var _bound: Dictionary = {}
var _auto_check_s: float = 0.0
## A summon button pressed while a Resonance is ready waits a moment for the other (Q+E, LB+RB).
var _pending_index: int = -1
var _pending_left: float = 0.0


func _ready() -> void:
	GameAuthority.gods = self
	auto_summon = Data.cfg_bool("gods.auto_summon_default")
	GameAuthority.xp_collected.connect(_on_pickup)
	GameAuthority.gold_collected.connect(_on_pickup)
	GameAuthority.player_damaged.connect(_on_player_damaged)
	GameAuthority.weapon_fired.connect(_on_weapon_fired)
	GameAuthority.enemy_damaged.connect(_on_enemy_damaged)
	GameAuthority.enemy_killed.connect(_on_enemy_killed)


func gods_of(player: Player) -> Array:
	return _bound.get(player.player_id, [])


func bound_ids(player: Player) -> PackedStringArray:
	var ids := PackedStringArray()
	for slot: Dictionary in gods_of(player):
		ids.append(str(slot["id"]))
	return ids


## Every god bound to any player (shrines never offer them).
func all_bound_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for player: Player in GameAuthority.players:
		ids.append_array(bound_ids(player))
	return ids


func is_full(player: Player) -> bool:
	return gods_of(player).size() >= Data.cfg_int("gods.max_bound")


## Binds a god. If both slots are full, `release_index` says which god to let go.
func bind(player: Player, god_id: String, release_index: int = -1) -> bool:
	var god: Dictionary = GodRules.find(god_id)
	if god.is_empty() or bound_ids(player).has(god_id):
		return false
	if is_full(player):
		if release_index < 0:
			return false
		release(player, release_index)
	var slots: Array = gods_of(player)
	slots.append({"id": god_id, "god": god, "meter": 0.0})
	_bound[player.player_id] = slots
	Blessings.apply(player, god, 1.0)
	_refresh_links(player)
	god_bound.emit(player, god_id)
	var special: Dictionary = GodRules.line("bound", god_id, str(player.hero.get("id", "")))
	if special.is_empty() or str(special.get("hero", "")) == "":
		var hero_line: Dictionary = GodRules.line("hero_bind", "", str(player.hero.get("id", "")))
		if not hero_line.is_empty() and banter != null:
			banter.say_line(hero_line)
	if banter != null:
		banter.say_line(special)
	return true


func release(player: Player, index: int) -> void:
	var slots: Array = gods_of(player)
	if index < 0 or index >= slots.size():
		return
	var slot: Dictionary = slots.pop_at(index)
	Blessings.apply(player, slot["god"], -1.0)
	_refresh_links(player)
	god_released.emit(player, str(slot["id"]))


func meter(player: Player, index: int) -> float:
	var slots: Array = gods_of(player)
	return float(slots[index]["meter"]) if index < slots.size() else 0.0


func set_meter(player: Player, index: int, value: float) -> void:
	var slots: Array = gods_of(player)
	if index < slots.size():
		slots[index]["meter"] = clampf(value, 0.0, 1.0)


## Fires a god's summon if its meter is full. Returns true if it fired.
func summon(player: Player, index: int) -> bool:
	var slots: Array = gods_of(player)
	if index >= slots.size() or float(slots[index]["meter"]) < 1.0 or not player.alive:
		return false
	var god: Dictionary = slots[index]["god"]
	slots[index]["meter"] = 0.0
	if summons != null:
		summons.run(god, player)
	_divine_link_on_summon(player)
	summoned.emit(player, str(god["id"]))
	if banter != null:
		var rng: RandomNumberGenerator = GameAuthority.run.rng.loot
		if GodRules.is_patron(player, god):
			banter.say_line(GodRules.line("patron", str(god["id"]), ""))
		elif rng.randf() < Data.cfg_float("banter.summon_line_chance"):
			banter.say_line(GodRules.line("summon", str(god["id"]), ""))
	return true


func _unhandled_input(event: InputEvent) -> void:
	var player: Player = GameAuthority.local_player()
	if player == null or get_tree().paused:
		return
	for index: int in 2:
		if not event.is_action_pressed("summon_%d" % (index + 1)):
			continue
		get_viewport().set_input_as_handled()
		if resonance != null and resonance.ready_for(player):
			var other_held: bool = Input.is_action_pressed("summon_%d" % (2 - index))
			if other_held or (_pending_index == 1 - index and _pending_left > 0.0):
				_pending_index = -1
				resonance.fire(player)
				return
			_pending_index = index
			_pending_left = Data.cfg_float("gods.resonance_press_window_s")
			return
		summon(player, index)


func _process(delta: float) -> void:
	var run: RunState = GameAuthority.run
	if run == null or run.ended:
		return
	if _pending_index != -1:
		_pending_left -= delta
		if _pending_left <= 0.0:
			var waiting: Player = GameAuthority.local_player()
			if waiting != null:
				summon(waiting, _pending_index)
			_pending_index = -1
	for player: Player in GameAuthority.players:
		if not player.alive:
			continue
		var regen: float = float(player.god_flags.get("regen_pct_per_s", 0.0))
		if regen > 0.0:
			GameAuthority.heal_player(player, player.max_hp * regen / 100.0 * delta)
		for slot: Dictionary in gods_of(player):
			var trigger: Dictionary = slot["god"].get("trigger", {})
			if str(trigger.get("type", "")) == "every_s":
				var rate: float = 1.0
				if player.hp < player.max_hp * float(trigger.get("low_hp_below", 0.0)):
					rate = float(trigger.get("low_hp_mult", 1.0))
				_charge_slot(player, slot, delta * rate)
	_auto_check_s -= delta
	if auto_summon and _auto_check_s <= 0.0:
		_auto_check_s = 0.5
		_auto_fire()


func _on_pickup(player: Player, _amount: float) -> void:
	_charge(player, "pickups", 1.0)


func _on_player_damaged(player: Player, amount: float, _source_id: String) -> void:
	_charge(player, "damage_taken", amount)


func _on_weapon_fired(player: Player, _weapon: WeaponInstance) -> void:
	_charge(player, "attacks_made", 1.0)


func _on_enemy_damaged(_slot: int, _amount: float, kind: String, _at: Vector2) -> void:
	if kind == "dot":
		return
	for player: Player in GameAuthority.players:
		_charge(player, "enemies_hit", 1.0)


func _on_enemy_killed(slot: int, _enemy_type: Dictionary, at: Vector2, killer: Player) -> void:
	if killer == null:
		return
	_charge(killer, "kills", 1.0)
	Blessings.on_kill(killer, slot)
	# Burning Greenwood Harmony: Burning enemies leave short fire patches.
	var patch_s: float = float(killer.god_flags.get(ResonanceManager.HARMONY + "burn_death_patch_s", 0.0))
	if patch_s > 0.0 and ground != null and GameAuthority.enemies.statuses.burn[slot] > 0.0:
		ground.add(at, float(killer.god_flags.get(ResonanceManager.HARMONY + "burn_death_patch_radius_px", 16.0)), patch_s,
				float(killer.god_flags.get(ResonanceManager.HARMONY + "burn_death_patch_dps", 8.0)), "fire", killer)


func _charge(player: Player, trigger_type: String, amount: float) -> void:
	if player == null:
		return
	for slot: Dictionary in gods_of(player):
		if str((slot["god"].get("trigger", {}) as Dictionary).get("type", "")) == trigger_type:
			_charge_slot(player, slot, amount)


func _charge_slot(player: Player, slot: Dictionary, amount: float) -> void:
	var god: Dictionary = slot["god"]
	var needed: float = maxf(float((god.get("trigger", {}) as Dictionary).get("amount", 100.0)), 0.01)
	var mult: float = GodRules.charge_mult(player, god) * GameAuthority.run.god_charge_mult
	slot["meter"] = minf(float(slot["meter"]) + amount / needed * mult, 1.0)


func _auto_fire() -> void:
	var enemies: EnemyManager = GameAuthority.enemies
	var busy: bool = GameAuthority.run.boss_arena_active or (enemies != null and _on_screen(enemies) >= Data.cfg_int("gods.auto_summon_min_enemies"))
	if not busy:
		return
	for player: Player in GameAuthority.players:
		for index: int in gods_of(player).size():
			if summon(player, index):
				return


func _on_screen(enemies: EnemyManager) -> int:
	var player: Player = GameAuthority.local_player()
	if player == null:
		return 0
	var view: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	return enemies.query(player.position, view.length() * 0.5).size()


## Divine Links that last while gods are bound (Väinämöinen; Cú Chulainn's landing elements).
func _refresh_links(player: Player) -> void:
	player.god_elements = PackedStringArray()
	for slot: Dictionary in gods_of(player):
		player.god_elements.append(str(slot["god"].get("element", "")))
	var link: String = str((player.hero.get("divine_link", {}) as Dictionary).get("id", ""))
	if link == "gods_join_song":
		player.reaction_damage_mult = 1.0 + (Data.cfg_float("gods.song_reaction_bonus") if not player.god_elements.is_empty() else 0.0)


## Heracles' Divine Link: each summon empowers his next 3 slams into full shockwaves.
func _divine_link_on_summon(player: Player) -> void:
	var link: String = str((player.hero.get("divine_link", {}) as Dictionary).get("id", ""))
	if link == "summon_empowers_slams" and player.kit != null and player.kit.get("empowered_slams") != null:
		player.kit.set("empowered_slams", int(player.kit.get("empowered_slams")) + Data.cfg_int("gods.empowered_slams"))
