#!/usr/bin/env bash
# Tests for fleet_pills.sh slot assignment + overflow. Uses SKETCHYBAR=echo to
# capture the batched call instead of touching a live bar.
HERE="$(cd "$(dirname "$0")" && pwd)"
SUT="$HERE/fleet_pills.sh"
export CONFIG_DIR="$(cd "$HERE/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { # name pattern output
  if grep -qF -- "$2" <<<"$3"; then echo "ok - $1"
  else echo "FAIL - $1"; printf '  missing: [%s]\n' "$2"; fail=1; fi
}
refute() { # name pattern output
  if grep -qF -- "$2" <<<"$3"; then echo "FAIL - $1"; printf '  present: [%s]\n' "$2"; fail=1
  else echo "ok - $1"; fi
}

# 7 agents -> 5 inline, agent.more=+2, 2 popup rows used, rest off
rows="$TMP/rows"; : >"$rows"
for n in 1 2 3 4 5 6 7; do printf 'working|%%%d|sess%d|\n' "$n" "$n" >>"$rows"; done
out=$(FLEET_ROWS_FILE="$rows" SKETCHYBAR=echo bash "$SUT")

check "slot 1 on"        '--set agent.1 drawing=on'  "$out"
check "slot 5 on"        '--set agent.5 drawing=on'  "$out"
check "overflow on"      '--set agent.more drawing=on' "$out"
check "overflow count"   'label=+2' "$out"
check "popup row 1 on"   '--set agent.pop.1 drawing=on' "$out"
check "popup row 2 on"   '--set agent.pop.2 drawing=on' "$out"
check "popup row 3 off"  '--set agent.pop.3 drawing=off' "$out"

# 3 agents -> no overflow, agent.more off, popup all off
rows2="$TMP/rows2"; printf 'waiting|%%1|a|\nidle|%%2|b|\ndone|%%3|c|\n' >"$rows2"
out2=$(FLEET_ROWS_FILE="$rows2" SKETCHYBAR=echo bash "$SUT")
check "no overflow -> more off" '--set agent.more drawing=off' "$out2"
check "slot 4 off"              '--set agent.4 drawing=off' "$out2"
refute "no popup rows on"       'agent.pop.1 drawing=on' "$out2"
check "waiting glyph mapped"    'icon=⚠' "$out2"

exit $fail
