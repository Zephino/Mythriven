class_name PlayerHealth
extends RefCounted
## How players are hurt and healed. Always called through GameAuthority (its
## damage_player, damage_player_over_time, status_player_from_enemy, and
## heal_player), which keeps every game event in one place and, in co-op,
## lets only the host's game decide (GameAuthority.decides()).


## Enemy damage − Armor, minimum 1; no invulnerability frames. `from` is where
## the hit came from (Vector2.INF when unknown).
static func damage(player: Player, amount: float, source_id: String, from: Vector2) -> void:
	if not GameAuthority.decides() or not player.alive or player.god_mode or player.invulnerable_s > 0.0 \
			or (player.kit != null and player.kit.is_untargetable()):
		return
	var armor: float = player.armor * player.statuses.armor_mult()
	var dealt: float = Damage.to_player(amount * player.statuses.consume_shock(), armor, Data.cfg_float("combat.min_damage"))
	if player.kit != null:
		dealt = player.kit.incoming_damage_at(dealt, from)
		if dealt <= 0.0:
			return
	player.hp -= dealt
	GameAuthority.player_damaged.emit(player, dealt, source_id)
	if player.hp <= 0.0 and not SecretPassives.girdle_saves(player):
		_fall(player, source_id)


## Burn and Poison on a player: skips Armor.
static func damage_over_time(player: Player, amount: float) -> void:
	if not GameAuthority.decides() or not player.alive or player.god_mode or (player.kit != null and player.kit.immune_to_dot()):
		return
	player.hp -= amount
	if player.hp <= 0.0 and not SecretPassives.girdle_saves(player):
		_fall(player, "status")


## From 30:00, an enemy touching a player can pass on its element's status.
static func status_from_enemy(player: Player, element: String) -> void:
	var run: RunState = GameAuthority.run
	if element == "" or run == null or run.arc_s() < Data.cfg_float("combat.player_status_start_s"):
		return
	if player.alive and not player.god_mode and GameAuthority.decides():
		player.statuses.apply(Elements.status_of(element))


static func heal(player: Player, amount: float) -> void:
	if player.alive and GameAuthority.decides():
		player.hp = minf(player.hp + amount, player.max_hp)


## At 0 HP: fallen in solo; downed in co-op (CoopRevives handles bleeding out and revives).
static func _fall(player: Player, cause_id: String) -> void:
	player.hp = 0.0
	player.alive = false
	player.cause_of_death = cause_id
	if GameAuthority.players.size() > 1:
		CoopRevives.go_down(player)
	GameAuthority.player_died.emit(player, cause_id)
	GameAuthority.check_run_over()
