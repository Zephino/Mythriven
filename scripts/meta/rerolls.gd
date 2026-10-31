class_name Rerolls
extends RefCounted
## Rerolling the level-up cards (owner decisions 10/31/2026; GAME_DESIGN.md: Level-up choices). Each Hero gets
## level_up.free_rerolls_start free rerolls at the start of a run and one more every level_up.free_reroll_every_levels
## levels. The Reroll button uses a free one first, then a reroll token (bought from the Wandering Trader or found),
## and after that buys one with run gold: level_up.reroll_price, doubling (reroll_price_mult) each time that Hero
## buys one this run. In co-op each player has their own free rerolls and pays from their own share of the gold.


## Free rerolls at the start of a run (GameAuthority.spawn_player).
static func start(player: Player) -> void:
	player.free_rerolls = Data.cfg_int("level_up.free_rerolls_start")
	player.rerolls_bought = 0


## One more free reroll for every Hero each time the shared level reaches a multiple of the setting.
static func on_level(new_level: int) -> void:
	var every: int = Data.cfg_int("level_up.free_reroll_every_levels")
	if every <= 0 or new_level % every != 0:
		return
	for player: Player in GameAuthority.players:
		player.free_rerolls += 1


## What the next reroll costs in run gold, if it has to be bought.
static func price(player: Player) -> int:
	return roundi(Data.cfg_float("level_up.reroll_price") * pow(Data.cfg_float("level_up.reroll_price_mult"), player.rerolls_bought))


## Free rerolls and tokens this Hero can use before paying.
static func free_count(player: Player) -> int:
	var run: RunState = GameAuthority.run
	return player.free_rerolls + (run.reroll_tokens if run != null else 0)


static func can_reroll(player: Player) -> bool:
	return free_count(player) > 0 or TraderScreen.wallet(player) >= price(player)


## Uses a free reroll, else a token, else pays. False if none is left and the gold isn't enough.
static func spend(player: Player) -> bool:
	var run: RunState = GameAuthority.run
	if run == null or player == null:
		return false
	if player.free_rerolls > 0:
		player.free_rerolls -= 1
		return true
	if run.reroll_tokens > 0:
		run.reroll_tokens -= 1
		return true
	var cost: int = price(player)
	if TraderScreen.wallet(player) < cost:
		return false
	player.gold_spent += cost
	player.rerolls_bought += 1
	return true


## The button's state for a player, as plain values (sent to a joining player in co-op).
static func info(player: Player) -> Dictionary:
	return {"free": free_count(player), "price": price(player), "can": can_reroll(player)}


## The Reroll button's text: "Reroll (free: 2)" or "Reroll: 50 gold".
static func label(state: Dictionary) -> String:
	if int(state.get("free", 0)) > 0:
		return TranslationServer.translate("UI_REROLL_FREE") % int(state["free"])
	return TranslationServer.translate("UI_REROLL_BUY") % int(state.get("price", 0))
