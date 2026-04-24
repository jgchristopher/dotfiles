#!/usr/bin/env bash
# Light theme colors — Solarized Light, mapped to TokyoNight-style @thm_* keys
# expected by theme.tmux. https://ethanschoonover.com/solarized/

# Backgrounds — base3 (#fdf6e3) is the lightest cream; base2 (#eee8d5) is the
# subtle highlight band. base1 / base0 are darker tints used for separators.
tmux set -g @thm_bg "#fdf6e3"
tmux set -g @thm_bg_dark "#eee8d5"
tmux set -g @thm_bg_dark1 "#eee8d5"
tmux set -g @thm_bg_highlight "#eee8d5"

# Foregrounds — base00 (#657b83) is body text on light bg; base01 deeper.
tmux set -g @thm_fg "#586e75"
tmux set -g @thm_fg_dark "#657b83"
tmux set -g @thm_fg_gutter "#93a1a1"

# Accents — Solarized canonical hues (deep saturated, not pastel)
tmux set -g @thm_blue "#268bd2"
tmux set -g @thm_blue0 "#268bd2"
tmux set -g @thm_blue1 "#2aa198"
tmux set -g @thm_blue2 "#268bd2"
tmux set -g @thm_blue5 "#2aa198"
tmux set -g @thm_blue6 "#586e75"
tmux set -g @thm_blue7 "#eee8d5"

tmux set -g @thm_cyan "#2aa198"
tmux set -g @thm_teal "#2aa198"
tmux set -g @thm_green "#859900"
tmux set -g @thm_green1 "#859900"
tmux set -g @thm_green2 "#2aa198"

tmux set -g @thm_magenta "#d33682"
tmux set -g @thm_magenta2 "#d33682"
tmux set -g @thm_purple "#6c71c4"
tmux set -g @thm_orange "#cb4b16"
tmux set -g @thm_red "#dc322f"
tmux set -g @thm_red1 "#dc322f"
tmux set -g @thm_yellow "#b58900"

# Muted / structural
tmux set -g @thm_comment "#93a1a1"
tmux set -g @thm_dark3 "#93a1a1"
tmux set -g @thm_dark5 "#586e75"
tmux set -g @thm_terminal_black "#586e75"
