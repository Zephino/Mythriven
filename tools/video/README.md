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
