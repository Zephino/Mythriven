class_name AchievementsScreen
extends MenuScreen
## Achievements (GAME_DESIGN.md: Collections) and secrets (Secret unlocks):
## earned ones are lit and marked; secrets stay "???" until found. Each is a small card (owner decision
## 10/31/2026: the menus' information laid out tidily), earned first.


func page_width() -> float:
	return Data.cfg_float("ui.menu_wide_px")


func build() -> void:
	var achievements: Array[Dictionary] = AchievementRules.all()
	var earned: Array[Dictionary] = []
	var left: Array[Dictionary] = []
	for achievement: Dictionary in achievements:
		(earned if AchievementRules.is_earned(str(achievement.get("id", ""))) else left).append(achievement)
	set_title(tr_key("UI_ACHIEVEMENTS") + "  ·  %d / %d" % [earned.size(), achievements.size()])
	add_section(tr_key("UI_ACHIEVEMENTS") + "  ·  %d / %d" % [earned.size(), achievements.size()])
	for achievement: Dictionary in earned + left:
		var done: bool = earned.has(achievement)
		add_card(null, tr_key(str(achievement.get("name_key", ""))), [tr_key(str(achievement.get("desc_key", "")))],
				tr_key("ACH_EARNED") if done else "", "", Callable(), true, not done)
	var secrets: Array = SecretRules.all()
	var found: int = secrets.filter(func(secret: Dictionary) -> bool: return SecretRules.is_found(str(secret.get("id", "")))).size()
	add_section(tr_key("UI_SECRETS") + "  ·  %d / %d" % [found, secrets.size()])
	for secret: Dictionary in secrets:
		if SecretRules.is_found(str(secret.get("id", ""))):
			add_card(null, tr_key(str(secret.get("name_key", ""))), [tr_key(str(secret.get("desc_key", "")))], tr_key("ACH_EARNED"))
		else:
			add_card(null, tr_key("SECRET_UNKNOWN"), [tr_key("SECRET_HIDDEN")], "", "", Callable(), true, true)
