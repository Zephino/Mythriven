class_name OnlineConfig
extends RefCounted
## Where the shared leaderboard lives (see leaderboard-api/README.md).
## These are addresses, not settings to tune, so they stay here for the
## setup script to fill in rather than in config.json.

## Public board (read-only) on the `data` branch, written only by the Worker.
const LEADERBOARD_READ_URL := "https://raw.githubusercontent.com/Zephino/Mythriven/data/leaderboard.json"

## The Cloudflare Worker's address only (no path, no trailing slash). Empty
## until the owner runs leaderboard-api/Setup-Leaderboard.bat, which fills it in.
## Example: "https://mythriven-leaderboard.your-name.workers.dev"
const API_BASE_URL := "https://mythriven.thebotcoder.workers.dev"

## For testing against a Worker running on this computer (`npx wrangler dev`):
## set from the command line with `-- --api=http://127.0.0.1:8787`.
static var base_override: String = ""


static func api_base() -> String:
	if base_override == "":
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--api="):
				base_override = arg.trim_prefix("--api=")
	return (base_override if base_override != "" else API_BASE_URL).strip_edges().trim_suffix("/")


static func post_url() -> String:
	var base: String = api_base()
	if base.is_empty():
		return ""
	return base + "/leaderboard"


## The Worker when it's set up (always up to date); otherwise GitHub (can lag a few minutes).
static func read_url() -> String:
	var worker: String = post_url()
	return worker if not worker.is_empty() else LEADERBOARD_READ_URL


static func suggestion_url() -> String:
	var base: String = api_base()
	if base.is_empty():
		return ""
	return base + "/suggestions"


## Cloud saves (leaderboard-api/src/cloud.js); "" until the Worker is set up.
static func cloud_url() -> String:
	var base: String = api_base()
	return "" if base.is_empty() else base + "/cloud/save"


## Co-op lobbies (leaderboard-api/src/lobby.js), as a WebSocket address; "" until set up.
static func lobby_url() -> String:
	var base: String = api_base()
	if base.is_empty():
		return ""
	return base.replace("https://", "wss://").replace("http://", "ws://") + "/lobby"


static func can_post() -> bool:
	return not post_url().is_empty()
