class_name ThanatosBoss
extends BossController
## Thanatos, 20:00, Death himself (docs/PACK_2_PLAN.md: the Underworld; GAME_DESIGN.md Act II bosses). Signature,
## the mark of death: every so often he marks a Hero for death, with a countdown over them. Hit him hard enough
## before it runs out (a share of his health) and the mark breaks; if not, it lands (half the Hero's Max HP). Heracles
## breaks it twice as easily: in Euripides' Alcestis he wrestles Death and wins Alcestis back. Phases: sword sweeps
## → the dead rise to fight for him → spiralling darkness.

## The marked Hero's id (-1 = none), seconds left, and damage dealt to Thanatos since the mark.
var marked: int = -1
var mark_left: float = 0.0
var mark_dealt: float = 0.0
var _next_mark: float = -1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


## Damage needed to break the mark on `player` (half for Heracles).
func cancel_needed(player: Player) -> float:
	var need: float = float(_sig().get("cancel_hp_fraction", 0.06)) * GameAuthority.enemies.max_hp[slot]
	if player != null and str(player.hero.get("id", "")) == "heracles":
		need *= float(_sig().get("heracles_cancel_mult", 0.5))
	return need


func modify_hit(amount: float, attacker: Player, push: Vector2) -> float:
	if marked != -1:
		mark_dealt += amount
	return super.modify_hit(amount, attacker, push)


func signature(delta: float) -> void:
	if _next_mark < 0.0:
		_next_mark = float(_sig().get("first_s", 6.0))
	if marked == -1:
		_next_mark -= delta
		if _next_mark <= 0.0 and target != null and target.alive:
			_mark(target)
		return
	var player: Player = GameAuthority.player_by_id(marked)
	if player == null or not player.alive:
		_clear_mark()
		return
	mark_left -= delta
	if mark_dealt >= cancel_needed(player):
		_say("BOSS_THANATOS_MARK_BROKEN")
		_clear_mark()
	elif mark_left <= 0.0:
		GameAuthority.damage_player(player, player.max_hp * float(_sig().get("hit_max_hp_fraction", 0.5)), "thanatos_mark",
				position_now())
		_clear_mark()


func _mark(player: Player) -> void:
	marked = player.player_id
	mark_left = float(_sig().get("countdown_s", 10.0))
	mark_dealt = 0.0
	_say("BOSS_THANATOS_HERACLES" if str(player.hero.get("id", "")) == "heracles" else "BOSS_THANATOS_MARK")


func _clear_mark() -> void:
	marked = -1
	_next_mark = float(_sig().get("every_s", 16.0))


func _say(key: String) -> void:
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr(key))


func _draw() -> void:
	super._draw()
	if marked == -1 or not is_alive():
		return
	var player: Player = GameAuthority.player_by_id(marked)
	if player == null:
		return
	# Over the marked Hero: a dark ring closing as time runs out, the seconds left, and how close the mark is to
	# breaking (a pale arc that fills as Thanatos is hurt).
	var at: Vector2 = player.position - global_position + Vector2(0, -28)
	var full: float = maxf(float(_sig().get("countdown_s", 10.0)), 0.01)
	var dark := Color.html(Data.cfg_string("bosses.death_mark_color"))
	draw_circle(at, 10.0, Color(0, 0, 0, 0.55))
	draw_arc(at, 10.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(mark_left / full, 0.0, 1.0), 24, dark, 2.5)
	draw_arc(at, 13.5, -PI * 0.5, -PI * 0.5 + TAU * clampf(mark_dealt / maxf(cancel_needed(player), 1.0), 0.0, 1.0), 24,
			Color(0.9, 0.92, 0.95, 0.9), 1.5)
	var font: Font = ThemeDB.fallback_font
	var text: String = str(ceili(maxf(mark_left, 0.0)))
	draw_string(font, at + Vector2(-4 * text.length(), 5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
