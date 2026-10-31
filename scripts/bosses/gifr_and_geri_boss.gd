class_name GifrAndGeriBoss
extends BossController
## Gifr and Geri, 10:00 (docs/PACK_4_PLAN.md: Muspelheim). Signature, watch by turns: two hounds guard the gate; one
## keeps watch while the other sleeps nearby, and every few seconds they change over: the sleeper wakes where it lay
## and the watcher lies down. Only the hound awake can be hurt (and it fights); the sleeper can't be harmed.
## Source: the Poetic Edda, Fjolsvinnsmal 13-18 (the two hounds who sleep by turns).

## Where the sleeping hound lies.
var sleeper := Vector2.INF
var _swap_in: float = 4.0
## Times they have changed watch (Past the Hounds secret: beat them before the third change).
var swaps: int = 0


func secret_earned() -> String:
	return "past_the_hounds" if swaps < 3 else ""


func _sig() -> Dictionary:
	return data.get("signature", {})


func signature(delta: float) -> void:
	if not is_alive():
		return
	if sleeper == Vector2.INF:
		sleeper = position_now() + Vector2(-float(_sig().get("apart_px", 120.0)), 0)
	_swap_in -= delta
	if _swap_in <= 0.0:
		_swap_in = float(_sig().get("swap_every_s", 7.0))
		swap()


## The watcher lies down where it stands; the sleeper wakes and takes up the watch.
func swap() -> void:
	swaps += 1
	var was: Vector2 = position_now()
	GameAuthority.enemies.positions[slot] = sleeper
	sleeper = was
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_GIFR_GERI_SWAP"))


func on_origin_shifted(shift_px: Vector2, _shift_chunks: Vector2i) -> void:
	if sleeper != Vector2.INF:
		sleeper -= shift_px


func _draw() -> void:
	if is_alive() and sleeper != Vector2.INF:
		var art: Dictionary = PixelArt.boss("gifr_and_geri_asleep")
		if not art.is_empty():
			PixelArt.draw_standing(self, art, sleeper - global_position + Vector2(0, GameAuthority.enemies.radius[slot]), true)
	super._draw()
