class_name CoopTether
extends Node
## Co-op tether (GAME_DESIGN.md: Endless world / Co-op tether): players can't
## move more than ~1.5 screens apart. Each device holds back its own Hero.


func _ready() -> void:
	# After the players move (0) and before the world shifts and the camera follows (5, 10).
	process_priority = 2


func _process(_delta: float) -> void:
	var me: Player = GameAuthority.local_player()
	if me == null or not (me.alive or me.shade):
		return
	var view: Vector2 = get_viewport().get_visible_rect().size / maxf(Data.cfg_float("camera.zoom"), 0.01)
	var limit: float = view.x * Data.cfg_float("coop.tether_screens")
	for other: Player in GameAuthority.players:
		if other == me:
			continue
		var offset: Vector2 = me.position - other.position
		if offset.length() > limit:
			me.position = other.position + offset.normalized() * limit
