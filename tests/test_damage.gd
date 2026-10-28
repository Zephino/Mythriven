extends GutTest
## Phase 5: the damage formula runs in the design's order:
## base (+expertise) → × (1 + Might) → crit → weakness/resistance → − Armor → minimum 1.


func test_full_order_of_operations() -> void:
	# (10 + 2) × 1.5 = 18 → crit ×2 = 36 → weak ×1.5 = 54 → − 4 Armor = 50
	var result: Dictionary = Damage.hit(10.0, 2.0, 0.5, 0.05, 2.0, 0.0, 1.5, 4.0, 1.0)
	assert_almost_eq(float(result["amount"]), 50.0, 0.0001)
	assert_true(result["crit"])


func test_armor_comes_after_multipliers() -> void:
	# If Armor were subtracted first, this would be (10 − 4) × 2 = 12, not 16.
	var result: Dictionary = Damage.hit(10.0, 0.0, 1.0, 0.0, 2.0, 0.5, 1.0, 4.0, 1.0)
	assert_almost_eq(float(result["amount"]), 16.0, 0.0001)


func test_resistance_halves_before_armor() -> void:
	# 20 × 0.5 = 10 − 3 = 7
	var result: Dictionary = Damage.hit(20.0, 0.0, 0.0, 0.0, 2.0, 0.9, 0.5, 3.0, 1.0)
	assert_almost_eq(float(result["amount"]), 7.0, 0.0001)


func test_minimum_one_damage() -> void:
	var result: Dictionary = Damage.hit(2.0, 0.0, 0.0, 0.0, 2.0, 0.9, 1.0, 50.0, 1.0)
	assert_eq(float(result["amount"]), 1.0)


func test_crit_only_when_roll_is_below_chance() -> void:
	assert_false(Damage.hit(10.0, 0.0, 0.0, 0.05, 2.0, 0.05, 1.0, 0.0, 1.0)["crit"])
	assert_true(Damage.hit(10.0, 0.0, 0.0, 0.05, 2.0, 0.049, 1.0, 0.0, 1.0)["crit"])


func test_damage_over_time_skips_armor() -> void:
	var result: Dictionary = Damage.hit(10.0, 0.0, 0.0, 0.0, 2.0, 0.9, 1.0, 4.0, 1.0, true)
	assert_almost_eq(float(result["amount"]), 10.0, 0.0001)


func test_soft_caps() -> void:
	assert_almost_eq(PlayerStats.soft(0.5, 1.0), 0.5, 0.0001)
	assert_almost_eq(PlayerStats.soft(2.0, 1.0), 1.5, 0.0001, "bonus above the cap counts half")
	var stats := PlayerStats.new({"move_speed": 100.0})
	stats.add_bonus("cooldown", 1.0)
	assert_almost_eq(stats.cooldown_mult(), 0.5, 0.0001, "cooldown = base ÷ (1 + bonus)")
	stats.add_bonus("move_speed", 1.5)
	assert_almost_eq(stats.move_speed(), 225.0, 0.0001, "+150% counts as +125%")
