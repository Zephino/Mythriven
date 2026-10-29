class_name AmmitBoss
extends BossController
## Ammit, 10:00 (GAME_DESIGN.md: The Two Lands bosses). Signature, the
## scales: from phase 2 a giant scale hangs over her; every hit the player
## takes tips it, and it slowly settles while they avoid harm. When it tips
## fully, Ammit lunges with a huge devouring bite (telegraphed). Phases:
## charges → the scale → faster charges with sand bursts.

## How far the scale has tipped, 0–1.
var tipped: float = 0.0


func _ready() -> void:
	super._ready()
	GameAuthority.player_damaged.connect(_on_player_damaged)


func _sig() -> Dictionary:
	return data.get("signature", {})


func scale_active() -> bool:
	return phase_index >= 1 and is_alive()


func _on_player_damaged(player: Player, amount: float, _source_id: String) -> void:
	if scale_active() and player.is_local:
		tipped = minf(tipped + amount / maxf(float(_sig().get("tip_damage", 60.0)), 1.0), 1.0)


func signature(delta: float) -> void:
	if not scale_active():
		return
	if tipped >= 1.0 and target != null and patterns != null and not patterns.busy():
		tipped = 0.0
		var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
		if banner != null:
			banner.show_text(tr("BOSS_AMMIT_DEVOURS"))
		_fire(_sig().get("devour", {"pattern": "charge_trail", "damage": 30}))
		return
	tipped = maxf(tipped - float(_sig().get("settle_per_s", 0.03)) * delta, 0.0)


func _draw() -> void:
	super._draw()
	if not scale_active():
		return
	var top: Vector2 = position_now() - global_position + Vector2(0, -GameAuthority.enemies.radius[slot] - 26.0)
	var color := Color.html(Data.cfg_string("bosses.scale_color"))
	var tilt: float = tipped * 0.6
	var left: Vector2 = top + Vector2(-22, 0).rotated(tilt)
	var right: Vector2 = top + Vector2(22, 0).rotated(tilt)
	draw_line(top, top + Vector2(0, 12), color, 2.0)
	draw_line(left, right, color, 2.0)
	draw_arc(left + Vector2(0, 6), 6.0, 0.0, PI, 8, color, 2.0)
	draw_arc(right + Vector2(0, 6), 6.0, 0.0, PI, 8, Color.html(Data.cfg_string("bosses.fire_telegraph_color")) if tipped > 0.7 else color, 2.0)
