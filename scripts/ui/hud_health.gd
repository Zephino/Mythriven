class_name HudHealth
extends Control
## The Hero's health bar on the HUD (owner request 11/03/2026: a health gauge on screen, made to look good with the
## weapon slots): a framed bar at the top left, over the weapon slots, its red fill showing the Hero's health with the
## numbers on it ("85 / 120"). A paler strip trails behind when a hit lands, so you can see how much it took; below
## the low-health line the bar pulses. Sizes and colours are in data/config.json (ui.hud_hp_*).

var _shown_fraction: float = 1.0
var _trail_fraction: float = 1.0
var _text: String = ""
var _low: bool = false
var _font: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(Data.cfg_float("ui.hud_hp_width_px"), Data.cfg_float("ui.hud_hp_height_px"))
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
	_text = TranslationServer.translate("UI_HUD_HP") % [ceili(player.hp), ceili(player.max_hp)]
	_low = _shown_fraction <= Data.cfg_float("ui.hud_hp_low_fraction")
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var border: float = Data.cfg_float("ui.hud_hp_border_px")
	draw_rect(rect, Color.html(Data.cfg_string("ui.hud_hp_frame_color")))                # frame
	var inner := rect.grow(-border)
	draw_rect(inner, Color.html(Data.cfg_string("ui.hud_hp_empty_color")))               # what's been lost
	draw_rect(Rect2(inner.position, Vector2(inner.size.x * _trail_fraction, inner.size.y)),
			Color.html(Data.cfg_string("ui.hud_hp_trail_color")))                        # the last hit, fading
	var fill := Color.html(Data.cfg_string("ui.hud_hp_fill_color"))
	if _low:
		var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU * Data.cfg_float("ui.hud_hp_pulse_hz"))
		fill = fill.lerp(Color.WHITE, pulse * 0.35)
	var filled := Rect2(inner.position, Vector2(inner.size.x * _shown_fraction, inner.size.y))
	draw_rect(filled, fill)
	draw_rect(Rect2(filled.position, Vector2(filled.size.x, maxf(1.0, inner.size.y * 0.3))), fill.lightened(0.25))   # shine
	var font_size: int = roundi(ThemeDB.get_default_theme().default_font_size * Data.cfg_float("ui.hud_hp_text_scale"))
	var text_size: Vector2 = _font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var at := Vector2((size.x - text_size.x) * 0.5, (size.y + _font.get_ascent(font_size) - _font.get_descent(font_size)) * 0.5)
	draw_string_outline(_font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, Color.BLACK)
	draw_string(_font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
