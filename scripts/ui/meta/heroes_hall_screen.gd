class_name HeroesHallScreen
extends MenuScreen
## The Hall of Heroes (GAME_DESIGN.md: Collections): each Hero's legend in
## brief, with source, their mastery, and their best time. A list with a detail panel (owner decision 10/31/2026):
## portraits and names on the left; the chosen Hero's picture, numbers and legend on the right.

var _chosen: String = ""


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	set_title(tr_key("UI_HALL_OF_HEROES"))
	var boxes: Array = add_split()
	var list: VBoxContainer = boxes[0]
	var detail: VBoxContainer = boxes[1]
	var first: Button = null
	var shown: Dictionary = {}
	for hero: Dictionary in HeroRules.all():
		var id: String = str(hero.get("id", ""))
		var known: bool = HeroRules.is_unlocked(hero)
		var picture: Texture2D = UiTheme.portrait(PixelArt.find(id), 2)
		var item: Button = add_list_item(list, picture, tr_key(str(hero.get("name_key", id))) if known else tr_key("BESTIARY_UNKNOWN"),
				func() -> void:
					_chosen = id
					_show(detail, hero, picture))
		if not known:
			silhouette(item)
		if first == null or id == _chosen:
			first = item
			shown = hero
	if first != null:
		first.set_pressed_no_signal(true)
		_show(detail, shown, first.icon)


func _show(detail: VBoxContainer, hero: Dictionary, picture: Texture2D) -> void:
	var id: String = str(hero.get("id", ""))
	if not HeroRules.is_unlocked(hero):
		fill_detail(detail, null, tr_key("BESTIARY_UNKNOWN"), [tr_key("HEROES_HALL_LOCKED")], [])
		return
	var best: float = Records.get_best(Records.key("hero", id, false))
	fill_detail(detail, picture, tr_key(str(hero.get("name_key", id))), [
		tr_key(str(hero.get("tradition_key", ""))) + "  ·  " + tr_key("HEROES_HALL_MASTERY") % Rewards.mastery(id),
		tr_key("HEROES_HALL_BEST") % (TextFormat.run_time(best) if best > 0.0 else tr_key("UI_NONE_YET")),
	], [tr_key("HERO_%s_LEGEND" % id.to_upper()), tr_key("UI_SOURCE") % str(hero.get("lore_source", ""))])
