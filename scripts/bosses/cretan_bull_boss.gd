class_name CretanBullBoss
extends MorvarchBoss
## The Cretan Bull, 10:00 (docs/PACK_8_PLAN.md: Knossos). Signature, the maddened charge: it charges across the arena
## (the gallop); if a charge hits no one, it skids to a halt dazed for a few seconds and is easier to hurt. Make it
## miss. Source: Apollodorus, Library 2.5.7 (Poseidon's bull, maddened, which Heracles caught and brought to Eurystheus).

var dazed_s: float = 0.0
var misses: int = 0
var _hit_this_charge: bool = false
var _was_charging: bool = false


func _on_player_damaged(player: Player, amount: float, source_id: String) -> void:
	super._on_player_damaged(player, amount, source_id)
	if is_alive() and source_id.begins_with(str(data.get("id", ""))):
		_hit_this_charge = true


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	amount = super.modify_hit(amount, attacker, push)
	return amount * float(_sig().get("dazed_damage_taken", 1.5)) if dazed_s > 0.0 else amount


func signature(delta: float) -> void:
	if not is_alive():
		return
	if dazed_s > 0.0:
		dazed_s -= delta
		GameAuthority.enemies.statuses.stun[slot] = maxf(GameAuthority.enemies.statuses.stun[slot], minf(dazed_s, 0.2))
		return
	var waiting: float = _gallop_in
	super.signature(delta)
	# A new charge began this frame (the wait to the next one was reset).
	if _gallop_in > waiting:
		_hit_this_charge = false
		_was_charging = true
	if _was_charging and gallop_s <= 0.0:
		_was_charging = false
		end_charge()


## The charge is over: dazed if it hit no one.
func end_charge() -> void:
	if not _hit_this_charge:
		misses += 1
		dazed_s = float(_sig().get("dazed_s", 2.5))
