#!/usr/bin/env bash
# A very simple "player": presses Space to get through menus and pick the
# first level-up card, and walks in changing directions with W A S D.
# Uses only keys the game already has (MenuKeys: WASD + Space in menus).
# Usage: bot.sh <seconds> <godot_pid>
DURATION="${1:-90}"
GODOT_PID="${2:-}"
END=$((SECONDS + DURATION))
DIRS=(w a s d "w d" "w a" "s d" "s a")
i=0
while [ "$SECONDS" -lt "$END" ]; do
  [ -n "$GODOT_PID" ] && ! kill -0 "$GODOT_PID" 2>/dev/null && break
  i=$((i + 1))
  # Menus / level-up cards / death screen: accept.
  xdotool key space
  # Walk one direction (two keys = diagonal) for about 1.5 s.
  dir="${DIRS[$((RANDOM % ${#DIRS[@]}))]}"
  for k in $dir; do xdotool keydown "$k"; done
  sleep 1.5
  for k in $dir; do xdotool keyup "$k"; done
  # Every few steps, tap Space again so cards get picked quickly.
  if [ $((i % 3)) -eq 0 ]; then xdotool key space; sleep 0.3; xdotool key space; fi
done
