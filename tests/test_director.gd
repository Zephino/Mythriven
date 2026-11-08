extends GutTest
## Director mode (the AI's filming tool): it can't switch on by itself, shot
## lists are checked for mistakes, and the enemy HP multiplier starts at 1.


func test_not_active_without_the_argument() -> void:
	assert_false(DirectorMode.is_active())


func test_path_comes_from_the_argument() -> void:
	var args := PackedStringArray(["--other", "--director=/game/shots/a.json"])
	assert_eq(DirectorMode.path_from_args(args), "/game/shots/a.json")
	assert_eq(DirectorMode.path_from_args(PackedStringArray(["--other"])), "")


func test_a_good_shot_list_passes() -> void:
	var text: String = '{"hero":"heracles","steps":[{"do":"wait","seconds":2},{"do":"density","mult":3},{"do":"teleport","x":100,"y":0}]}'
	var result: Dictionary = DirectorMode.parse(text)
	assert_eq((result["errors"] as PackedStringArray).size(), 0)
	assert_false((result["list"] as Dictionary).is_empty())


func test_mistakes_are_reported() -> void:
	var result: Dictionary = DirectorMode.parse('{"steps":[{"do":"explode"},{"do":"density"},"oops"]}')
	assert_eq((result["errors"] as PackedStringArray).size(), 3)
	assert_true((result["list"] as Dictionary).is_empty())
	assert_eq((DirectorMode.parse("not json")["errors"] as PackedStringArray).size(), 1)
	assert_eq((DirectorMode.parse('{"hero":"x"}')["errors"] as PackedStringArray).size(), 1)


func test_the_example_shot_lists_are_valid() -> void:
	var dir: DirAccess = DirAccess.open("res://tools/video/shots")
	if dir == null:
		pending("shot lists are not in this build")
		return
	for file: String in dir.get_files():
		if file.ends_with(".json"):
			var text: String = FileAccess.get_file_as_string("res://tools/video/shots/" + file)
			var errors: PackedStringArray = DirectorMode.parse(text)["errors"]
			assert_eq(errors.size(), 0, "%s: %s" % [file, ", ".join(errors)])


func test_enemy_hp_multiplier_defaults_to_one() -> void:
	assert_eq(RunState.new(1, {}).director_hp_mult, 1.0)
