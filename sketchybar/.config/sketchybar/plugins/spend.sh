#!/usr/bin/env bash
# Running daily agent spend across claude-code/codex/pi, via
# `sessions report` (LiteLLM pricing over the local session files).
# The report takes ~13s to parse history — fine here: sketchybar runs
# scripts async and keeps the previous label, so the chip just updates
# late, never blocks. update_freq=900 keeps the CPU cost negligible.
# Neutral colors on purpose: spend is information, not an alarm.

source "$CONFIG_DIR/colors.sh"

# `sessions report` unconditionally writes report.html + usage-report.json
# into $PWD. A sketchybar script's $PWD is $CONFIG_DIR, and `--hotload true`
# watches $CONFIG_DIR — so writing there triggers a full config reload, which
# re-runs this script, which writes again: a tight reload loop that spams
# "Set: Item not found" as items churn. Run from a scratch dir to break it.
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar-spend"
mkdir -p "$CACHE_DIR"
TOTAL=$( (cd "$CACHE_DIR" && sessions report --today --stdout 2>/dev/null) | jq -r '.summary.totalCostUSD // 0')

# Hide until the day has a real number
if [ -z "$TOTAL" ] || [ "$(printf '%.0f' "$TOTAL")" -eq 0 ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

# The chip's $ icon carries the currency; the label is just the number
if [ "$(printf '%.0f' "$TOTAL")" -ge 10 ]; then
  LABEL=$(printf '%.0f' "$TOTAL")
else
  LABEL=$(printf '%.2f' "$TOTAL")
fi

sketchybar --animate tanh 15 --set "$NAME" drawing=on \
  label="$LABEL" label.color="$FG" icon.color="$GREY"
