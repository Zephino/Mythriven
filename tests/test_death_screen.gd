extends GutTest
## The results screen fits the window: when its contents are taller than the screen (a small window or big text),
## the whole screen scrolls instead of running off the bottom (owner report 11/03/2026: the end-of-run menu was cut
## off with no way to reach the buttons).

const TEST_SAVE := "user://test_death_screen_save.json"


func before_each() -> void:
	SaveGame.use_test_file(TEST_SAVE)


func test_a_tall_results_screen_fits_the_window_and_scrolls() -> void:
	var screen: DeathScreen = add_child_autofree(DeathScreen.new())
	var room: float = SafeArea.rect(screen.get_viewport()).size.y
	var filler := Control.new()
	filler.custom_minimum_size.y = room * 2.0                                           # as if the text were huge
	screen._box.add_child(filler)
	screen._box.move_child(filler, 1)
	screen.show_summary(PackedStringArray(["a recap line"]), {}, false, "a tip")
	await wait_process_frames(2)
	assert_true(screen._box.get_combined_minimum_size().y > room, "the contents are taller than the window")
	assert_true(screen._panel.get_combined_minimum_size().y <= room, "but the screen itself fits inside it")
	assert_true(screen._outer.is_ancestor_of(screen._title_button), "and the last button is in the part that scrolls")
	screen._title_button.grab_focus()
	await wait_process_frames(2)
	assert_true(screen._outer.scroll_vertical > 0, "selecting the last button scrolls down to it")


func test_a_short_results_screen_does_not_stretch() -> void:
	var screen: DeathScreen = add_child_autofree(DeathScreen.new())
	screen.show_summary(PackedStringArray(["one line"]), {}, false, "")
	await wait_process_frames(2)
	assert_almost_eq(screen._outer.custom_minimum_size.y, screen._box.get_combined_minimum_size().y, 1.0,
			"a screen that fits is exactly as tall as its contents")
