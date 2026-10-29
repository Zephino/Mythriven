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
const API_BASE_URL := ""


static func post_url() -> String:
	var base: String = API_BASE_URL.strip_edges().trim_suffix("/")
	if base.is_empty():
		return ""
	return base + "/leaderboard"


## The Worker when it's set up (always up to date); otherwise GitHub (can lag a few minutes).
static func read_url() -> String:
	var worker: String = post_url()
	return worker if not worker.is_empty() else LEADERBOARD_READ_URL


static func suggestion_url() -> String:
	var base: String = API_BASE_URL.strip_edges().trim_suffix("/")
	if base.is_empty():
		return ""
	return base + "/suggestions"


static func can_post() -> bool:
	return not post_url().is_empty()
