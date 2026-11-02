#!/usr/bin/env bash
# Now-playing chip via bin/current-song ("Title - Artist", empty unless
# Sonos or Music.app is actively playing). Hidden when silent.

source "$CONFIG_DIR/colors.sh"

SONG=$("$HOME/gitprojects/dotfiles/bin/bin/current-song" 2>/dev/null)

if [ -n "$SONG" ]; then
  sketchybar --animate tanh 30 --set "$NAME" drawing=on label="$SONG"
else
  sketchybar --set "$NAME" drawing=off
fi
