class_name AchievementsScreen
extends MenuScreen
## Achievements (GAME_DESIGN.md: Collections) and secrets (Secret unlocks):
## earned ones are marked; secrets stay "???" until found.


func build() -> void:
	var achievements: Array[Dictionary] = AchievementRules.all()
	var earned: int = 0
	for achievement: Dictionary in achievements:
		earned += 1 if AchievementRules.is_earned(str(achievement.get("id", ""))) else 0
	set_title(tr_key("UI_ACHIEVEMENTS") + "  ·  %d / %d" % [earned, achievements.size()])
	for achievement: Dictionary in achievements:
		var done: bool = AchievementRules.is_earned(str(achievement.get("id", "")))
		add_line((tr_key("UI_ON_MARK") if done else tr_key("UI_OFF_MARK")) + " " + tr_key(str(achievement.get("name_key", ""))) + " — "
				+ tr_key(str(achievement.get("desc_key", ""))))
	add_line(tr_key("UI_SECRETS"))
	for secret: Dictionary in SecretRules.all():
		if SecretRules.is_found(str(secret.get("id", ""))):
			add_line(tr_key("UI_ON_MARK") + " " + tr_key(str(secret.get("name_key", ""))) + " — " + tr_key(str(secret.get("desc_key", ""))))
		else:
			add_line(tr_key("UI_OFF_MARK") + " " + tr_key("SECRET_UNKNOWN"))
