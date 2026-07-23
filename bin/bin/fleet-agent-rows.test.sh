#!/usr/bin/env bash
# Tests for fleet-agent-rows. Run: bash bin/bin/fleet-agent-rows.test.sh
#
# Contract: stdin is "pane|session" lines (the live agent panes, discovered by
# the caller). For each, emit "state|pane|session|tool" sorted by urgency then
# session. A pane WITH a status file uses its derived state and authoritative
# session/tool; a pane WITHOUT one (a brand-new session that hasn't acted yet)
# falls back to idle with the passed-in session label.
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

# Case 1: urgency then session ordering (status sessions used, labels ignored)
mkstatus claude %0 zeta idle
mkstatus claude %1 alpha working
mkstatus claude %2 mid waiting
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<$'%0|ig0\n%1|ig1\n%2|ig2' | cut -d'|' -f1,3)
check "urgency+session ordering" $'waiting|mid\nworking|alpha\nidle|zeta' "$out"

# Case 2: a live pane with NO status file falls back to idle with its label
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<'%9|newsess')
check "file-less pane -> idle with label" 'idle|%9|newsess|' "$out"

# Case 3: no panes -> empty
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<'')
check "empty when no panes" '' "$out"

# Case 4: last event overrides snapshot (permission_prompt -> waiting)
rm -rf "$TMP"/claude-status; mkdir -p "$TMP/claude-status"
printf '{"state":"working","pane":"%%5","session":"svc","tool":"","ts":1,"tmux_pid":1}\n' \
  >"$TMP/claude-status/5.status"
printf '%s\n' '{"event":"Notification","notification_type":"permission_prompt"}' \
  >"$TMP/claude-status/5.events.jsonl"
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<'%5|whatever' | cut -d'|' -f1)
check "permission_prompt derives waiting" 'waiting' "$out"

# Case 5: the status file's session wins over the passed-in label
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<'%5|WRONGLABEL' | cut -d'|' -f3)
check "status session authoritative" 'svc' "$out"

# Case 6: union of a file-backed pane and a file-less one, correctly ordered
rm -rf "$TMP"/claude-status; mkdir -p "$TMP/claude-status"
mkstatus claude %7 dotf working
out=$(FLEET_STATUS_ROOT="$TMP" "$SUT" <<<$'%9|newsess\n%7|ig' | cut -d'|' -f1,3)
check "union file-backed + file-less, sorted" $'working|dotf\nidle|newsess' "$out"

exit $fail
