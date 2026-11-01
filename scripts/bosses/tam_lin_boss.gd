class_name TamLinBoss
extends BossController
## Tam Lin, 10:00 (docs/PACK_7_PLAN.md: Elfame). Signature, hold him fast: the fairies turn him from shape to shape
## (an adder, a bear, burning iron), and his shapes burn whoever is close. But a Hero who stays beside him through a
## whole shape, as Janet held him, frees him for a while: his guard breaks. Source: the ballad Tam Lin (Child 39).

const SHAPES := ["adder", "bear", "iron"]

var shape: int = 0
var freed: int = 0
var held_s: float = 0.0
var _left: float = -1.0
var _burn_in: float = 1.0


func _sig() -> Dictionary:
	return data.get("signature", {})


func art_id() -> String:
	return "tam_lin_" + str(SHAPES[shape])


func signature(delta: float) -> void:
	if not is_alive():
		return
	if _left < 0.0:
		_left = float(_sig().get("shape_s", 4.0))
	var reach: float = float(_sig().get("hold_radius_px", 50.0))
	var close: Array[Player] = []
	for player: Player in GameAuthority.players:
		if player.alive and player.position.distance_to(position_now()) <= reach + player.body_radius:
			close.append(player)
	held_s = held_s + delta if not close.is_empty() else 0.0
	_burn_in -= delta
	if _burn_in <= 0.0:
		_burn_in = 1.0
		for player: Player in close:
			GameAuthority.damage_player(player, float(_sig().get("burn_damage", 4.0)), str(data.get("id", "")), position_now())
	if held_s >= float(_sig().get("shape_s", 4.0)) and broken_s <= 0.0:
		free_him()
	_left -= delta
	if _left <= 0.0:
		_left = float(_sig().get("shape_s", 4.0))
		shape = (shape + 1) % SHAPES.size()


## Held through a whole change: he is freed for a while.
func free_him() -> void:
	freed += 1
	held_s = 0.0
	guard_break()
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_TAM_LIN_HELD"))


## The ring a Hero must stay inside, filling as they hold on.
func _draw() -> void:
	super._draw()
	if not is_alive():
		return
	var at: Vector2 = position_now() - global_position
	var reach: float = float(_sig().get("hold_radius_px", 50.0))
	draw_arc(at, reach, 0.0, TAU, 32, Color(1.0, 0.6, 0.3, 0.35), 1.0)
	if held_s > 0.0:
		draw_arc(at, reach, -PI / 2, -PI / 2 + TAU * minf(held_s / float(_sig().get("shape_s", 4.0)), 1.0), 32, Color(1.0, 0.85, 0.5), 2.5)
