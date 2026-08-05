#!/usr/bin/env bash
# Tests for workspaces.sh pill reconcile. Stub binaries capture the batched
# sketchybar calls instead of touching a live bar (fleet_pills.test.sh pattern).
HERE="$(cd "$(dirname "$0")" && pwd)"
SUT="$HERE/workspaces.sh"
export CONFIG_DIR="$(cd "$HERE/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export STATE_DIR="$TMP/state"

# aerospace stub: workspace set + windows controlled by WS_* env vars
cat >"$TMP/aerospace" <<'EOF'
#!/usr/bin/env bash
case "$1 $2" in
"list-workspaces --all") [ -n "$WS_ALL" ] && printf '%s\n' $WS_ALL ;;
"list-workspaces --focused") echo "$WS_FOCUSED" ;;
"list-windows --all") [ -n "$WS_WINDOWS" ] && printf '%s\n' $WS_WINDOWS ;;
"list-windows --focused") echo "$WS_TITLE" ;;
esac
EOF
# sketchybar stub: --query returns canned JSON, everything else echoes
cat >"$TMP/sketchybar" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = "--query" ]; then cat "$SB_QUERY_JSON"; else echo "$@"; fi
EOF
chmod +x "$TMP/aerospace" "$TMP/sketchybar"
export SKETCHYBAR="$TMP/sketchybar" AEROSPACE="$TMP/aerospace"

fail=0
check() { # name pattern output
  if grep -qF -- "$2" <<<"$3"; then echo "ok - $1"
  else echo "FAIL - $1"; printf '  missing: [%s]\n' "$2"; fail=1; fi
}
refute() { # name pattern output
  if grep -qF -- "$2" <<<"$3"; then echo "FAIL - $1"; printf '  present: [%s]\n' "$2"; fail=1
  else echo "ok - $1"; fi
}

# Stale numeric pills from startup; live set is letters -> add B C D, drop 1 2
export SB_QUERY_JSON="$TMP/q1.json"
printf '{"items":["space.1","ring.1","space.2","ring.2","spaces_controller"]}' >"$SB_QUERY_JSON"
out=$(WS_ALL="B C D" WS_FOCUSED=D WS_WINDOWS="B|Ghostty D|Safari" WS_TITLE="hello" bash "$SUT")
check "adds missing pill"        '--add item space.B left' "$out"
check "adds matching ring"       '--add bracket ring.B space.B' "$out"
check "removes stale pill"       '--remove space.1' "$out"
check "removes stale ring"       '--remove ring.1' "$out"
check "sorts pills into place"   '--move space.B before spaces_controller' "$out"
check "rebuilds shelf bracket"   '--remove spaces' "$out"
check "re-adds shelf bracket"    '--add bracket spaces' "$out"
check "renders focused pill"     '--set space.D drawing=on' "$out"
check "renders occupied pill"    '--set space.B drawing=on' "$out"

# Pill set already matches -> reconcile is a no-op, render only
printf '{"items":["space.B","ring.B","space.C","ring.C","space.D","ring.D"]}' >"$TMP/q2.json"
out2=$(SB_QUERY_JSON="$TMP/q2.json" WS_ALL="B C D" WS_FOCUSED=D WS_WINDOWS="D|Safari" WS_TITLE=t bash "$SUT")
refute "no adds when in sync"    '--add item' "$out2"
refute "no removes when in sync" '--remove' "$out2"
refute "no moves when in sync"   '--move' "$out2"

# aerospace query dead (startup race / WM gone) -> never mass-remove pills
out3=$(SB_QUERY_JSON="$TMP/q2.json" WS_ALL="" WS_FOCUSED="" WS_WINDOWS="" WS_TITLE="" bash "$SUT")
refute "empty list never removes" '--remove' "$out3"

exit $fail
