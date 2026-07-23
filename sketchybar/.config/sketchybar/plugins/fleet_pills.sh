#!/usr/bin/env bash
# One pill per live fleet agent. Inline pool agent.1..agent.5; overflow into
# agent.more whose popup holds agent.pop.1..agent.pop.15. Rendered in one
# batched call on fleet_state_change (fswatch push) + a slow backstop.
#
# Phosphor language: lit edge = active/needs-you; idle stays unlit and quiet.

source "$CONFIG_DIR/colors.sh"

POOL=5
POPUP_POOL=15
SB="${SKETCHYBAR:-sketchybar}"

# Discover the live agent panes: any tmux pane with a claude/codex/pi process
# in its subtree. pane_current_command can't be trusted (it reports the agent's
# foreground child — bash/node — not the agent), so walk the process tree from
# each pane's pid using one ps snapshot. Emits "pane|session" (session =
# current-path basename, a fallback fleet-agent-rows overrides when a status
# file exists). This catches brand-new sessions that haven't written a status
# file yet — the ones fleet's TUI shows but the status files don't.
agent_panes() {
  local snap; snap=$(ps -axo pid=,ppid=,comm=)
  tmux list-panes -a -F '#{pane_id}|#{pane_pid}|#{pane_current_path}' 2>/dev/null |
    while IFS='|' read -r pane ppid path; do
      awk -v root="$ppid" '
        { pp[$1] = $2; cm[$1] = $3 }
        END {
          n = 0; q[n++] = root
          for (i = 0; i < n; i++) {
            for (p in pp) if (pp[p] == q[i]) q[n++] = p
            if (cm[q[i]] ~ /(^|\/)(claude|codex|pi)$/) exit 0
          }
          exit 1
        }' <<<"$snap" || continue
      printf '%s|%s\n' "$pane" "$(basename "$path")"
    done
}

if [ -n "${FLEET_ROWS_FILE:-}" ]; then
  ROWS=$(cat "$FLEET_ROWS_FILE")
else
  ROWS=$(agent_panes | "$HOME/bin/fleet-agent-rows")
fi

COUNT=0
[ -n "$ROWS" ] && COUNT=$(grep -c '' <<<"$ROWS")

style() { # state -> GLYPH ICOLOR BORDER FILL
  case "$1" in
  waiting) GLYPH="⚠" ICOLOR="$YELLOW"  BORDER="$YELLOW_BORDER"  FILL="$YELLOW_FILL" ;;
  asking)  GLYPH="?" ICOLOR="$MAGENTA" BORDER="$MAGENTA_BORDER" FILL="$MAGENTA_FILL" ;;
  done)    GLYPH="✓" ICOLOR="$GREEN"   BORDER="$GREEN_BORDER"   FILL="$GREEN_FILL" ;;
  working) GLYPH="◉" ICOLOR="$GLOW_FULL" BORDER="$GLOW_EDGE"    FILL="$GLOW_FILL" ;;
  *)       GLYPH="●" ICOLOR="$GREY"    BORDER="$HAIRLINE"       FILL="$ITEM_BG" ;;
  esac
}

args=()
used_inline=0
used_popup=0
i=0
while IFS='|' read -r state pane session tool; do
  [ -n "$state" ] || continue
  i=$((i + 1))
  style "$state"
  if [ "$i" -le "$POOL" ]; then
    used_inline=$i
    args+=(--set "agent.$i" drawing=on icon="$GLYPH" icon.color="$ICOLOR"
      label="${session:0:8}" label.color="$ICOLOR"
      background.border_color="$BORDER" background.color="$FILL"
      click_script="aerospace workspace D; fleet switch $pane")
  else
    j=$((i - POOL))
    [ "$j" -le "$POPUP_POOL" ] || continue
    used_popup=$j
    if [ "$j" -eq "$POPUP_POOL" ] && [ "$COUNT" -gt $((POOL + POPUP_POOL)) ]; then
      args+=(--set "agent.pop.$j" drawing=on icon="⋯" icon.color="$GREY"
        label="+$((COUNT - POOL - POPUP_POOL + 1)) more" label.color="$GREY"
        click_script="$SB --set agent.more popup.drawing=off; tmux display-popup -E -w 90% -h 80% fleet")
    else
      task=""
      command -v tmux >/dev/null 2>&1 &&
        task=$(tmux display-message -p -t "$pane" '#{pane_title}' 2>/dev/null |
          sed -E 's/^[^A-Za-z0-9]+ *//')
      [ -n "$task" ] || task="$tool"
      args+=(--set "agent.pop.$j" drawing=on icon="$GLYPH" icon.color="$ICOLOR"
        label="$session ${task:0:24}" label.color="$ICOLOR"
        click_script="$SB --set agent.more popup.drawing=off; aerospace workspace D; fleet switch $pane")
    fi
  fi
done <<<"$ROWS"

for ((k = 1; k <= POOL; k++)); do
  [ "$k" -le "$used_inline" ] || args+=(--set "agent.$k" drawing=off)
done
for ((k = 1; k <= POPUP_POOL; k++)); do
  [ "$k" -le "$used_popup" ] || args+=(--set "agent.pop.$k" drawing=off)
done
if [ "$COUNT" -gt "$POOL" ]; then
  args+=(--set agent.more drawing=on icon="⋯" icon.color="$GREY"
    label="+$((COUNT - POOL))"
    click_script="$SB --set agent.more popup.drawing=toggle")
else
  args+=(--set agent.more drawing=off popup.drawing=off)
fi

"$SB" "${args[@]}"
