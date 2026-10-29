class_name SecretRules
extends RefCounted
## Secret unlocks (GAME_DESIGN.md: Discovery and feel / Secret unlocks):
## hidden rewards for unusual feats, shown as "???" in Achievements until
## found. Each is saved the moment it's found. The game systems that see a
## feat call Meta.note_secret(id). After every 5 runs, the Oracle (in the Hall
## of Legends) offers a cryptic hint about one undiscovered secret.

const FILE := "secrets.json"


static func all() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var listed: Variant = Data.get_file(FILE)
	for entry: Variant in (listed if listed is Array else []):
		if entry is Dictionary:
			found.append(entry)
	return found


static func find(secret_id: String) -> Dictionary:
	for secret: Dictionary in all():
		if str(secret.get("id", "")) == secret_id:
			return secret
	return {}


static func is_found(secret_id: String) -> bool:
	return SaveGame.list("secrets").has(secret_id)


## Marks a secret found and grants its reward. Returns the results-screen
## lines (empty if it was already found or doesn't exist).
static func reveal(secret_id: String) -> PackedStringArray:
	var secret: Dictionary = find(secret_id)
	if secret.is_empty() or not SaveGame.add_to("secrets", secret_id):
		return PackedStringArray()
	var lines: PackedStringArray = [TranslationServer.translate("SECRET_FOUND") % TranslationServer.translate(str(secret.get("name_key", "")))]
	var reward_line: String = Rewards.grant(secret.get("reward", {}))
	if reward_line != "":
		lines.append(reward_line)
	return lines


## Hints the Oracle has given (secret ids, oldest first).
static func hints() -> PackedStringArray:
	return PackedStringArray((SaveGame.data()["oracle"] as Dictionary).get("hints", []))


## Counts a finished run; every `meta.oracle_runs_per_hint` runs the Oracle
## gives a hint about a secret not yet found or hinted. Returns that secret's
## id, or "" (saved by the caller's commit).
static func count_run() -> String:
	var oracle: Dictionary = SaveGame.data()["oracle"]
	oracle["runs"] = int(oracle.get("runs", 0)) + 1
	if int(oracle["runs"]) < Data.cfg_int("meta.oracle_runs_per_hint"):
		return ""
	for secret: Dictionary in all():
		var id: String = str(secret.get("id", ""))
		if not is_found(id) and not hints().has(id):
			oracle["runs"] = 0
			var given: Array = oracle.get("hints", [])
			given.append(id)
			oracle["hints"] = given
			return id
	return ""
