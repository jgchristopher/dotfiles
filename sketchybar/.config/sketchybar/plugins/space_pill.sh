#!/usr/bin/env bash
# Shared construction args for AeroSpace workspace pills. Sourced by BOTH
# sketchybarrc (startup warm-up) and workspaces.sh (runtime reconcile) so the
# two renderings can't drift. Callers must have colors.sh sourced and
# CONFIG_DIR set. Appends via nameref — bash 4+ (brew bash), same floor
# workspaces.sh already requires.

SPACE_PILL_MONO="Monaspace Neon"

space_pill_add_args() { # <sid> <out-array-name>
  local sid=$1
  local -n _out=$2
  # Pill is a dumb view (hover handler only); workspaces.sh renders state.
  # Bright inner border on the pill + dim outer ring on its personal bracket
  # = the JankyBorders glow falloff in two honest 1px lines.
  _out+=(--add item "space.$sid" left
    --subscribe "space.$sid" mouse.entered mouse.exited
    --set "space.$sid"
    icon="$sid"
    icon.font="$SPACE_PILL_MONO:Bold:11.0"
    label.font="JetBrainsMono Nerd Font Mono:Regular:13.0"
    label.drawing=off
    drawing=off
    updates=when_shown
    background.height=22
    background.color="$PILL_BG"
    click_script="aerospace workspace $sid"
    script="$CONFIG_DIR/plugins/space_hover.sh"
    --add bracket "ring.$sid" "space.$sid"
    --set "ring.$sid"
    background.color="$TRANSPARENT"
    background.border_width=1
    background.border_color="$TRANSPARENT"
    background.height=26
    background.corner_radius=6)
}

spaces_shelf_args() { # <out-array-name>
  local -n _out=$1
  # Workspace shelf: a drawn outline, not a fill — visible structure at
  # near-zero luminance. Regex membership is evaluated once at creation,
  # so the shelf must be re-added whenever the pill set changes.
  _out+=(--add bracket spaces '/space\..*/'
    --set spaces
    background.color="$TRANSPARENT"
    background.border_width=1
    background.border_color="$GLOW_TRACE"
    background.corner_radius=6
    background.height=28)
}
