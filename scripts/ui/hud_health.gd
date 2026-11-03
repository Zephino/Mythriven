class_name HudHealth
extends Control
## The Hero's health orb on the HUD (owner requests 11/03/2026: a health gauge on screen that looks good with the
## weapon slots; then an orb, as there isn't much room on phones): a round glass orb in the top-left corner, over the
## weapon slots, filling with red from the bottom as far as the Hero's health, the number in its middle. A paler band
## trails above the red when a hit lands, so you can see how much it took; below the low-health line the orb pulses.
## Sizes and colours are in data/config.json (ui.hud_hp_*).

var _shown_fraction: float = 1.0
var _trail_fraction: float = 1.0
var _text: String = ""
var _low: bool = false
var _font: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2.ONE * Data.cfg_float("ui.hud_hp_orb_px")
	_font = ThemeDB.fallback_font


func _process(delta: float) -> void:
	var player: Player = GameAuthority.local_player()
	if player == null or player.max_hp <= 0.0:
		visible = false
		return
	visible = true
	_shown_fraction = clampf(player.hp / player.max_hp, 0.0, 1.0)
	if _trail_fraction < _shown_fraction:
		_trail_fraction = _shown_fraction                                                # healing: no trail
	else:
		_trail_fraction = move_toward(_trail_fraction, _shown_fraction, Data.cfg_float("ui.hud_hp_trail_per_s") * delta)
	_text = TranslationServer.translate("UI_HUD_HP") % ceili(player.hp)
	_low = _shown_fraction <= Data.cfg_float("ui.hud_hp_low_fraction")
	queue_redraw()


func _draw() -> void:
	var d: float = minf(size.x, size.y)
	var centre := Vector2(d, d) * 0.5
	var border: float = Data.cfg_float("ui.hud_hp_border_px")
	draw_circle(centre, d * 0.5, Color.html(Data.cfg_string("ui.hud_hp_frame_color")))   # the rim
	var r: float = d * 0.5 - border
	var fill := Color.html(Data.cfg_string("ui.hud_hp_fill_color"))
	if _low:
		var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU * Data.cfg_float("ui.hud_hp_pulse_hz"))
		fill = fill.lerp(Color.WHITE, pulse * 0.35)
	var empty := Color.html(Data.cfg_string("ui.hud_hp_empty_color"))
	var trail := Color.html(Data.cfg_string("ui.hud_hp_trail_color"))
	var top: float = centre.y - r
	var rows: int = ceili(r * 2.0)
	for i: int in rows:                                                                  # the orb, filled from the bottom
		var y: float = top + i + 0.5
		var half: float = sqrt(maxf(r * r - (y - centre.y) * (y - centre.y), 0.0))
		var height_from_bottom: float = (centre.y + r - y) / (r * 2.0)
		var colour: Color = empty
		if height_from_bottom <= _shown_fraction:
			colour = fill
		elif height_from_bottom <= _trail_fraction:
			colour = trail
		draw_rect(Rect2(centre.x - half, y - 0.5, half * 2.0, 1.0), colour)
	var level_y: float = centre.y + r - _shown_fraction * r * 2.0                        # the red's surface, lit
	if _shown_fraction > 0.02 and _shown_fraction < 0.98:
		var half_w: float = sqrt(maxf(r * r - (level_y - centre.y) * (level_y - centre.y), 0.0))
		draw_line(Vector2(centre.x - half_w, level_y), Vector2(centre.x + half_w, level_y), fill.lightened(0.35), 1.0)
	draw_circle(centre + Vector2(-r * 0.38, -r * 0.42), r * 0.2, Color(1, 1, 1, 0.35))  # the glass's glint
	draw_arc(centre, r, 0.0, TAU, 40, Color(1, 1, 1, 0.12), 1.5)
	var font_size: int = roundi(ThemeDB.get_default_theme().default_font_size * Data.cfg_float("ui.hud_hp_text_scale"))
	var text_size: Vector2 = _font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var at := Vector2(centre.x - text_size.x * 0.5, centre.y + (_font.get_ascent(font_size) - _font.get_descent(font_size)) * 0.5)
	draw_string_outline(_font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 5, Color.BLACK)
	draw_string(_font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
