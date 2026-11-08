#!/usr/bin/env bash
# Starts a virtual screen, runs Mythriven on it, lets a simple bot play,
# records the screen with ffmpeg, then serves the MP4 on $PORT.
# Settings (Railway variables, all optional):
#   VIDEO_SECONDS (default 90)  VIDEO_FPS (30)  VIDEO_WIDTH (1280)  VIDEO_HEIGHT (720)
set -u
SECONDS_TO_RECORD="${VIDEO_SECONDS:-90}"
FPS="${VIDEO_FPS:-30}"
W="${VIDEO_WIDTH:-1280}"
H="${VIDEO_HEIGHT:-720}"
OUT=/out
mkdir -p "$OUT"
HERE="$(cd "$(dirname "$0")" && pwd)"

echo "[record] starting virtual screen ${W}x${H}"
Xvfb :99 -screen 0 "${W}x${H}x24" +extension GLX -nolisten tcp >"$OUT/xvfb.log" 2>&1 &
export DISPLAY=:99
sleep 2

echo "[record] starting Mythriven (software rendering, no sound)"
export LIBGL_ALWAYS_SOFTWARE=1
godot --path /game --rendering-driver opengl3 --audio-driver Dummy \
      --resolution "${W}x${H}" --position 0,0 >"$OUT/godot.log" 2>&1 &
GODOT_PID=$!
sleep 12   # let the title screen appear

if ! kill -0 "$GODOT_PID" 2>/dev/null; then
  echo "[record] Godot exited early; see godot.log"
  tail -n 40 "$OUT/godot.log"
else
  echo "[record] recording ${SECONDS_TO_RECORD}s at ${FPS} fps"
  ffmpeg -y -loglevel warning -f x11grab -framerate "$FPS" -video_size "${W}x${H}" -i :99 \
         -t "$SECONDS_TO_RECORD" -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p \
         -movflags +faststart "$OUT/mythriven-gameplay.mp4" 2>"$OUT/ffmpeg.log" &
  FFMPEG_PID=$!
  bash "$HERE/bot.sh" "$SECONDS_TO_RECORD" "$GODOT_PID" &
  wait "$FFMPEG_PID"
  echo "[record] done"
fi

kill "$GODOT_PID" 2>/dev/null || true
ls -la "$OUT"
echo "[record] serving $OUT on port ${PORT:-8080}"
exec python3 "$HERE/serve.py" "$OUT"
