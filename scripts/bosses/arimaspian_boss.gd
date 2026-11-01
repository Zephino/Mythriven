class_name ArimaspianBoss
extends BossController
## The Arimaspian Chieftain, 10:00 (docs/PACK_10_PLAN.md: Hyperborea). Signature, the gold thief: the one-eyed
## Arimaspians steal the griffins' gold, and every blow he lands steals some of a Hero's run gold. When his guard breaks
## he drops all he has stolen. Source: Herodotus, Histories 3.116 and 4.13, 4.27 (the one-eyed Arimaspians who steal gold
## from the griffins).

var stolen: float = 0.0
var thefts: int = 0


func _sig() -> Dictionary:
	return data.get("signature", {})


func _ready() -> void:
	super._ready()
	GameAuthority.player_damaged.connect(_on_player_damaged)


func _on_player_damaged(player: Player, _amount: float, source_id: String) -> void:
	if not is_alive() or not source_id.begins_with(str(data.get("id", ""))) or GameAuthority.run == null:
		return
	var take: float = minf(float(_sig().get("steal", 5.0)), GameAuthority.run.gold)
	if take > 0.0:
		GameAuthority.run.gold -= take
		stolen += take
		thefts += 1


## His guard breaks: everything he stole spills back to the Heroes.
func guard_break() -> void:
	super.guard_break()
	if stolen > 0.0:
		var near: Player = GameAuthority.enemies.nearest_player(position_now())
		GameAuthority.collect_gold(near, stolen)
		stolen = 0.0
