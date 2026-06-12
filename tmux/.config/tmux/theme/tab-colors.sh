#!/usr/bin/env bash
# Give each tmux window a distinct, stable color via the per-window @tabcolor
# user option, which window-status-format reads as #{@tabcolor}.
#
# Why a script instead of doing it in the format string: tmux 3.6b's format
# arithmetic/comparison modifiers (#{e|...}, #{==:...}, #{m:...}) return empty
# here, so an index->color mapping can't be expressed in the format. The shell
# has real arithmetic, so the mapping is computed here and pushed onto each
# window. The palette itself is defined per-theme in colors/dark.sh and
# colors/light.sh as @thm_tab_palette, so each scheme curates its own tab
# colors and the set tracks light/dark automatically.
#
# Re-run idempotently: at config load and on the after-new-window hook.
set -euo pipefail

opt() { tmux show-option -gqv "$1"; }

read -ra palette <<< "$(opt @thm_tab_palette)"
# Fallback if the theme hasn't defined a palette (e.g. partial reload).
if [ "${#palette[@]}" -eq 0 ]; then
  palette=("$(opt @thm_blue)" "$(opt @thm_orange)" "$(opt @thm_green)" "$(opt @thm_magenta)")
fi
n=${#palette[@]}

# Color by window index so a given window number always gets the same hue.
while read -r wid widx; do
  tmux set-window-option -t "$wid" @tabcolor "${palette[$(( widx % n ))]}"
done < <(tmux list-windows -a -F '#{window_id} #{window_index}')
