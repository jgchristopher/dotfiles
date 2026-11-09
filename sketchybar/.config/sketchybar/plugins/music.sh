#!/usr/bin/env bash
# Now-playing chip via bin/current-song ("Title - Artist", empty unless
# Sonos or Music.app is actively playing). Hidden when silent.
# Mirrored to the OmniShell `music` widget via omni_push.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/omni_push.sh"

SONG=$("$HOME/gitprojects/dotfiles/bin/bin/current-song" 2>/dev/null)

if [ -n "$SONG" ]; then
  sketchybar --animate tanh 30 --set "$NAME" drawing=on label="$SONG"
  omni_push music "$(jq -nc --arg l "$SONG" '{label: $l}')"
else
  sketchybar --set "$NAME" drawing=off
  omni_push music
fi
