class_name EliteBars
extends Node2D
## Health bars over elites, with one icon per modifier above the bar and the
## Warded shield shown as a second bar (GAME_DESIGN.md: Elites). Icons are
## placeholder shapes in each modifier's colour (elite_modifiers.json).

var enemies: EnemyManager


func _ready() -> void:
	z_index = 15


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if enemies == null:
		return
	var width: float = Data.cfg_float("enemies.elite_bar_width_px")
	var height: float = Data.cfg_float("enemies.elite_bar_height_px")
	var back := Color.html(Data.cfg_string("player.hp_bar_back_color"))
	var fill := Color.html(Data.cfg_string("enemies.elite_bar_color"))
	var shield_color := Color.html(Data.cfg_string("enemies.elite_shield_color"))
	for i: int in enemies.capacity:
		if enemies.active[i] == 0 or not enemies.is_elite(i):
			continue
		var top_left: Vector2 = enemies.positions[i] + Vector2(-width * 0.5, -enemies.radius[i] - height - 4.0)
		draw_rect(Rect2(top_left, Vector2(width, height)), back)
		draw_rect(Rect2(top_left, Vector2(width * clampf(enemies.hp[i] / maxf(enemies.max_hp[i], 1.0), 0.0, 1.0), height)), fill)
		if enemies.elites.shield[i] > 0.0:
			var shield_frac: float = enemies.elites.shield[i] / maxf(enemies.max_hp[i], 1.0)
			draw_rect(Rect2(top_left + Vector2(0.0, height), Vector2(width * clampf(shield_frac, 0.0, 1.0), 2.0)), shield_color)
		var mods: PackedStringArray = enemies.elites.mods[i]
		for k: int in mods.size():
			_draw_icon(top_left + Vector2(4.0 + k * 9.0, -6.0), EliteState.modifier(mods[k]))


func _draw_icon(at: Vector2, modifier: Dictionary) -> void:
	var color := Color.html(str(modifier.get("icon_color", "#ffffff")))
	var size: float = 3.5
	match str(modifier.get("icon_shape", "circle")):
		"triangle":
			draw_colored_polygon(PackedVector2Array([at + Vector2(0, -size), at + Vector2(size, size), at + Vector2(-size, size)]), color)
		"square":
			draw_rect(Rect2(at - Vector2.ONE * size, Vector2.ONE * size * 2.0), color)
		"diamond":
			draw_colored_polygon(PackedVector2Array([at + Vector2(0, -size), at + Vector2(size, 0), at + Vector2(0, size),
					at + Vector2(-size, 0)]), color)
		"ring":
			draw_arc(at, size, 0.0, TAU, 12, color, 1.5)
		"cross":
			draw_line(at - Vector2(size, 0), at + Vector2(size, 0), color, 2.0)
			draw_line(at - Vector2(0, size), at + Vector2(0, size), color, 2.0)
		_:
			draw_circle(at, size, color)
