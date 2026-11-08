# Gameplay video on Railway

Records a clip of Mythriven without anyone playing. Not part of the game.

**How it works:** the Dockerfile installs Godot 4.7.2, a virtual screen (Xvfb), `xdotool` and ffmpeg.
`record.sh` runs the game on the virtual screen, `bot.sh` presses keys (Space through menus and level-up cards,
WASD to walk), ffmpeg records the screen, then `serve.py` serves the files.

**Railway setup:** service from this repo, variable `RAILWAY_DOCKERFILE_PATH=tools/video/Dockerfile`, then generate a domain.
Open `https://<domain>/mythriven-gameplay.mp4` once the logs say `serving /out`. Logs: `godot.log`, `ffmpeg.log`, `xvfb.log` on the same URL.

**Optional variables:** `VIDEO_SECONDS` (90), `VIDEO_FPS` (30), `VIDEO_WIDTH` (1280), `VIDEO_HEIGHT` (720).

**Limits:** no graphics card, so Godot draws in software and the frame rate may be low; the video has no sound; the files
disappear when the service redeploys, so download the MP4 right away. The bot is simple and not tested in Godot yet.

## Director mode (the AI's filming tool)

Director mode lets the AI play the game for the camera: skip the menus, pick the Hero and level, jump around the map, and set
the time, monster density and HP. A player can't turn it on: it needs a **debug build that is not the web build** and the
start-up argument `--director=<shot list>` (after `--`), which only the recording container or a terminal can give. Director
runs are marked as debug runs, so they never reach the leaderboard. Code: `scripts/core/director_*.gd`.

**Use it:** set the Railway variable `VIDEO_SHOTS=tour.json` (a file in `tools/video/shots/`) and `VIDEO_SECONDS` to a little more
than the shot list's length, then redeploy. Locally: `godot --path . -- --director=tools/video/shots/tour.json`.

**A shot list** is JSON: `{"hero": "heracles", "level": "aegean_shore", "seed": 1234, "god_mode": true, "steps": [ ... ]}`.
`hero`, `level` (any level, even locked ones) and `seed` (same seed, same map) are optional; `god_mode` defaults to true.
Each step is `{"do": "<command>", ...}`, done in order. Only `wait`, `walk` and `quit` take time.

| Command | Keys | What it does |
|---|---|---|
| `wait` | `seconds` | Lets the game play. |
| `set_time` | `seconds` | Jumps the run clock (waves, Ages, enemy strength follow it). `next_age` jumps to the next Age. |
| `teleport` | `x`,`y` or `dx`,`dy` or `radius`; `clear` | Moves the Hero to a spot, by an offset, or to a random spot within `radius`. `"clear": true` removes enemies first. |
| `density` | `mult` | Spawn rate multiplier (0.25 = light, 1 = normal, 6 = very dense). |
| `enemy_hp` | `mult` | Multiplies enemy HP, for those on screen and new ones (bosses keep theirs). |
| `fill` | `type` (optional) | Spawns monsters up to the 500 cap, right now. |
| `spawn` | `type`, `count`, `mode` (`ring` or `pack`) | Spawns a specific monster. `elite` spawns an elite. |
| `kill_all` | | Removes every enemy (no rewards). |
| `auto_spawn` | `on` | Turns the normal spawning on or off. |
| `god_mode`, `heal`, `player_hp` | `on` / `fraction` | Invincible, full heal, or set the Hero's HP (0.1 = nearly dead, for drama). |
| `levels` | `count` | Gains levels, taking the first card each time, with no screen. `max_build` fills every slot at max level. |
| `loadout` | `weapons`, `level` | Replaces the Hero's weapons with exactly this list (ids from `data/weapons.json`; `level` 1–8 for all). Keep to 5 weapons and 3 spells. `give_weapon` (`id`, `level`) adds one. |
| `walk` | `dx`,`dy`,`seconds` | Holds a direction (each from -1 to 1) for that long. `autopilot` (`on`) wanders in changing directions. |
| `auto_pick` | `on` | Picks the first card whenever a level-up screen opens. |
| `hud`, `zoom` | `on` / `value` | Hides or shows the HUD; sets the camera zoom. |
| `quit` | | Ends the game (the recording stops). It also ends by itself after the last step or the Hero's death. |

**Several Heroes or levels in one video:** use `{"chapters": [ {...}, {...} ]}` instead of one `hero`/`steps`. Each chapter has its own
`hero`, `level`, `seed`, `god_mode` and `steps`. When a chapter's steps are done (or the Hero dies) the game starts a new run for the next one,
and quits after the last (or at a `quit` step). Set `VIDEO_SECONDS` to a bit more than the total.

`shots/tour.json` is a full example (four Heroes on four Pack 1 levels, each from a light start with one or two weapons to a dense screen with a full loadout, about 2 minutes: use `VIDEO_SECONDS=150`). Not run in Godot yet: the first Railway run will show what needs fixing.
