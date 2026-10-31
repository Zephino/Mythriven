extends GutTest
## Phase 20: cloud saves (sync codes, merging the cloud copy, when to upload).

const TEST_SAVE := "user://test_online_save.json"


func before_each() -> void:
	SaveGame.use_test_file(TEST_SAVE)
	CloudSync.set_code("")


func after_each() -> void:
	CloudSync.set_code("")
	DirAccess.remove_absolute(CloudSync.file_path())
	SaveGame.use_test_file("")
	for file: String in [TEST_SAVE, TEST_SAVE + ".bak", TEST_SAVE + ".tmp"]:
		DirAccess.remove_absolute(file)


func test_codes_are_random_readable_and_checked() -> void:
	var a: String = CloudSync.new_code()
	assert_eq(a.length(), CloudSync.CODE_LENGTH)
	assert_ne(a, CloudSync.new_code())
	assert_eq(CloudSync.normalize(CloudSync.pretty(a).to_lower()), a, "dashes and lower case are fine")
	assert_eq(CloudSync.normalize("ABCD-EFGH-JK2O"), "", "no O (looks like 0)")
	assert_eq(CloudSync.normalize("ABCD"), "")
	assert_eq(CloudSync.pretty("abcdefghjk23"), "ABCD-EFGH-JK23")


func test_the_code_is_kept_on_this_device_never_in_the_save() -> void:
	assert_ne(CloudSync.file_path(), Data.cfg_string("save.cloud_file"), "tests never touch the real code file")
	CloudSync.set_code("ABCDEFGHJK23")
	assert_eq(CloudSync.code(), "ABCDEFGHJK23")
	assert_false(JSON.stringify(SaveGame.data()).contains("ABCDEFGHJK23"))
	CloudSync.set_code("")
	assert_false(CloudSync.is_on())


func test_only_lasting_progress_counts_as_a_change_to_upload() -> void:
	SaveGame.take_cloud_change()
	SaveGame.commit("run_in_progress")
	assert_false(SaveGame.take_cloud_change(), "the mid-run checkpoint isn't uploaded")
	SaveGame.add_gold(5)
	assert_true(SaveGame.take_cloud_change())
	assert_false(SaveGame.take_cloud_change(), "reported once")


func test_the_cloud_copy_is_merged_in_and_saved_here() -> void:
	SaveGame.add_gold(100)
	SaveGame.add_to("heroes_unlocked", "king_arthur")
	var cloud: Dictionary = SaveGame.migrate({"save_version": 3, "gold": 40, "heroes_unlocked": ["atalanta"],
		"last_modified": {"gold": int(Time.get_unix_time_from_system()) + 1000}})
	var sync: CloudSync = add_child_autofree(CloudSync.new())
	SaveGame.take_cloud_change()
	sync.apply_cloud(cloud)
	assert_true(SaveGame.list("heroes_unlocked").has("king_arthur") and SaveGame.list("heroes_unlocked").has("atalanta"))
	assert_eq(SaveGame.gold(), 40, "gold from the device played last")
	assert_true(sync.notice.contains("40"), "the player is told")
	assert_false(SaveGame.take_cloud_change(), "merging isn't itself a new change")
	SaveGame.forget_loaded()
	assert_true(SaveGame.list("heroes_unlocked").has("atalanta"), "saved on this device")


func test_a_newly_linked_device_takes_the_clouds_gold() -> void:
	SaveGame.add_to("heroes_unlocked", "atalanta")
	var cloud: Dictionary = SaveGame.migrate({"save_version": 3, "gold": 250, "heroes_unlocked": ["odysseus"], "last_modified": {"gold": 1}})
	var sync: CloudSync = add_child_autofree(CloudSync.new())
	sync.apply_cloud(cloud, true)
	assert_eq(SaveGame.gold(), 250, "linking never wipes the other device's gold")
	assert_true(SaveGame.list("heroes_unlocked").has("atalanta") and SaveGame.list("heroes_unlocked").has("odysseus"))


func test_merge_keeps_the_later_time_for_each_section() -> void:
	var a: Dictionary = SaveGame.migrate({"last_modified": {"gold": 10, "gods": 50}})
	var b: Dictionary = SaveGame.migrate({"last_modified": {"gold": 20, "gods": 5}})
	var merged: Dictionary = SaveGame.merge(a, b)
	assert_eq(int(merged["last_modified"]["gold"]), 20)
	assert_eq(int(merged["last_modified"]["gods"]), 50)


func test_sync_waits_while_off_and_batches_during_a_run() -> void:
	var sync: CloudSync = add_child_autofree(CloudSync.new())
	sync.request_sync(true)
	assert_eq(sync._wait_s, -1.0, "off: nothing to do")
	CloudSync.set_code("ABCDEFGHJK23")
	sync.request_sync(false)
	assert_gt(sync._wait_s, CloudSync.SOON_S, "batched")
	sync.request_sync(true)
	assert_almost_eq(sync._wait_s, CloudSync.SOON_S, 0.01, "soon after a purchase or a run")
	sync._wait_s = -1.0


func test_this_device_keeps_its_own_id_and_account_alongside_the_code() -> void:
	var id: String = CloudSync.device_id()
	assert_true(id.length() >= 16, "a random device id")
	CloudSync.set_code("ABCDEFGHJK23")
	CloudSync.set_account("google")
	assert_eq(CloudSync.device_id(), id, "kept when the code changes")
	assert_eq(CloudSync.account(), "google")
	CloudSync.set_account("")
	assert_eq(CloudSync.code(), "ABCDEFGHJK23", "signing out keeps nothing else from changing")


func test_signing_in_links_this_device_to_the_accounts_save() -> void:
	SaveGame.add_to("heroes_unlocked", "atalanta")
	var sync: CloudSync = add_child_autofree(CloudSync.new())
	sync.sign_in.finish("ABCD-EFGH-JK23", "Bot Coder", "bot@example.com")
	assert_eq(CloudSync.code(), "ABCDEFGHJK23", "the account's save")
	assert_eq(CloudSync.account(), "google")
	assert_eq(CloudSync.account_name(), "Bot Coder", "who is signed in, kept on this device")
	assert_eq(CloudSync.account_email(), "bot@example.com")
	assert_false(JSON.stringify(SaveGame.data()).contains("bot@example.com"), "never inside the save that goes to the cloud")
	assert_eq(sync.sign_in.state, "done")
	sync.sign_in.finish("not a code")
	assert_eq(sync.sign_in.error, "UI_SIGNIN_NO_CONNECTION")
	assert_eq(CloudSync.code(), "ABCDEFGHJK23", "a bad reply changes nothing")
	sync.turn_off()
	assert_eq(CloudSync.account(), "", "signing out forgets the account on this device")
	assert_eq(CloudSync.account_name() + CloudSync.account_email(), "", "and its name and email")


func test_without_cloud_saves_play_is_always_allowed_here() -> void:
	var sync: CloudSync = add_child_autofree(CloudSync.new())
	var answers: Array[bool] = []
	sync.play_lock.claim(func(allowed: bool) -> void: answers.append(allowed))
	assert_eq(answers, [true] as Array[bool], "no account: nothing to check")


func test_losing_the_save_to_another_device_ends_the_run_here() -> void:
	GameAuthority.start_run("aegean_shore")
	var sync: CloudSync = add_child_autofree(CloudSync.new())
	watch_signals(GameAuthority)
	sync.play_lock.lost.emit()
	assert_true(GameAuthority.run.ended, "the run ends with a message")
	assert_signal_emitted(GameAuthority, "run_ended")
	GameAuthority.end_scene()
