class_name HeroesHallScreen
extends MenuScreen
## The Hall of Heroes (GAME_DESIGN.md: Collections): each Hero's legend in
## brief, with source, their mastery, and their best time.


func build() -> void:
	set_title(tr_key("UI_HALL_OF_HEROES"))
	for hero: Dictionary in HeroRules.all():
		var id: String = str(hero.get("id", ""))
		if not HeroRules.is_unlocked(hero):
			add_line(tr_key("HEROES_HALL_LOCKED"))
			continue
		var best: float = Records.get_best(Records.key("hero", id, false))
		add_line("\n".join([tr_key("HEROES_HALL_ROW") % [tr_key(str(hero.get("name_key", id))), tr_key(str(hero.get("tradition_key", ""))),
				Rewards.mastery(id), TextFormat.run_time(best) if best > 0.0 else tr_key("UI_NONE_YET")],
			tr_key("HERO_%s_LEGEND" % id.to_upper()), tr_key("UI_SOURCE") % str(hero.get("lore_source", ""))]))
