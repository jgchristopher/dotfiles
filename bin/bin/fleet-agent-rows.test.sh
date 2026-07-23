#!/usr/bin/env bash
# Tests for fleet-agent-rows. Run: bash bin/bin/fleet-agent-rows.test.sh
HERE="$(cd "$(dirname "$0")" && pwd)"
SUT="$HERE/fleet-agent-rows"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkstatus() { # dir pane session state
  local d="$TMP/$1-status"; mkdir -p "$d"
  printf '{"state":"%s","pane":"%s","session":"%s","tool":"","ts":1,"tmux_pid":1}\n' \
    "$4" "$2" "$3" >"$d/${2#%}.status"
  : >"$d/${2#%}.events.jsonl"
}

fail=0
check() { # name expected actual
  if [ "$2" = "$3" ]; then echo "ok - $1"
  else echo "FAIL - $1"; printf '  expected: [%s]\n  actual:   [%s]\n' "$2" "$3"; fail=1; fi
}

# Case 1: urgency then session ordering, all panes live
mkstatus claude %0 zeta idle
mkstatus claude %1 alpha working
mkstatus claude %2 mid waiting
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<$'%0\n%1\n%2' | cut -d'|' -f1,3)
check "urgency+session ordering" $'waiting|mid\nworking|alpha\nidle|zeta' "$out"

# Case 2: stale pane (not in live set) is dropped
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<'%1' | cut -d'|' -f2)
check "liveness filter" '%1' "$out"

# Case 3: no live panes -> empty
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<'')
check "empty when nothing live" '' "$out"

# Case 4: last event overrides snapshot (permission_prompt -> waiting)
rm -rf "$TMP"/claude-status; mkdir -p "$TMP/claude-status"
printf '{"state":"working","pane":"%%5","session":"svc","tool":"","ts":1,"tmux_pid":1}\n' \
  >"$TMP/claude-status/5.status"
printf '%s\n' '{"event":"Notification","notification_type":"permission_prompt"}' \
  >"$TMP/claude-status/5.events.jsonl"
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<'%5' | cut -d'|' -f1)
check "permission_prompt derives waiting" 'waiting' "$out"

exit $fail
