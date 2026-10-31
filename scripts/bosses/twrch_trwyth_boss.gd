class_name TwrchTrwythBoss
extends BossController
## Twrch Trwyth, 30:00 (docs/PACK_2_PLAN.md: Avalon's Shadow). Signature, the treasures between his ears: he charges
## across the whole field with his young pigs; each Guard Break knocks loose one of the treasures between his ears
## (the comb, the razor, the shears), which drops as a chest and gold. Source: Culhwch and Olwen.

var treasures_left: int = -1


func guard_break() -> void:
	super.guard_break()
	if treasures_left < 0:
		treasures_left = int((data.get("signature", {}) as Dictionary).get("treasures", 3))
	if treasures_left <= 0 or slot == -1:
		return
	treasures_left -= 1
	var bosses: BossManager = GameAuthority.bosses
	var at: Vector2 = position_now() + Vector2(0, -20)
	if bosses != null and bosses.chests != null:
		bosses.chests.drop(at, false)
	if bosses != null and bosses.gold != null:
		bosses.gold.drop_pile(at, 60.0, Data.cfg_int("pickups.pile_coins"))
	var banner: Banner = get_tree().get_first_node_in_group(Banner.GROUP) as Banner
	if banner != null:
		banner.show_text(tr("BOSS_TWRCH_TREASURE"))
