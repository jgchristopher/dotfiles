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

mkstatus() { # dir pane session state [tmux_pid]
  local d="$TMP/$1-status"; mkdir -p "$d"
  printf '{"state":"%s","pane":"%s","session":"%s","tool":"","ts":1,"tmux_pid":%s}\n' \
    "$4" "$2" "$3" "${5:-1}" >"$d/${2#%}.status"
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
out=$(FLEET_STATUS_ROOT="$TMP" FLEET_TMUX_PID=1 "$SUT" <<<$'%0|ig0\n%1|ig1\n%2|ig2' | cut -d'|' -f1,3)
check "urgency+session ordering" $'waiting|mid\nworking|alpha\nidle|zeta' "$out"

# Case 2: a live pane with NO status file falls back to idle with its label
out=$(FLEET_STATUS_ROOT="$TMP" FLEET_TMUX_PID=1 "$SUT" <<<'%9|newsess')
check "file-less pane -> idle with label" 'idle|%9|newsess|' "$out"

# Case 3: no panes -> empty
out=$(FLEET_STATUS_ROOT="$TMP" FLEET_TMUX_PID=1 "$SUT" <<<'')
check "empty when no panes" '' "$out"

# Case 4: last event overrides snapshot (permission_prompt -> waiting)
rm -rf "$TMP"/claude-status; mkdir -p "$TMP/claude-status"
printf '{"state":"working","pane":"%%5","session":"svc","tool":"","ts":1,"tmux_pid":1}\n' \
  >"$TMP/claude-status/5.status"
printf '%s\n' '{"event":"Notification","notification_type":"permission_prompt"}' \
  >"$TMP/claude-status/5.events.jsonl"
out=$(FLEET_STATUS_ROOT="$TMP" FLEET_TMUX_PID=1 "$SUT" <<<'%5|whatever' | cut -d'|' -f1)
check "permission_prompt derives waiting" 'waiting' "$out"

# Case 5: the status file's session wins over the passed-in label
out=$(FLEET_STATUS_ROOT="$TMP" FLEET_TMUX_PID=1 "$SUT" <<<'%5|WRONGLABEL' | cut -d'|' -f3)
check "status session authoritative" 'svc' "$out"

# Case 6: union of a file-backed pane and a file-less one, correctly ordered
rm -rf "$TMP"/claude-status; mkdir -p "$TMP/claude-status"
mkstatus claude %7 dotf working
out=$(FLEET_STATUS_ROOT="$TMP" FLEET_TMUX_PID=1 "$SUT" <<<$'%9|newsess\n%7|ig' | cut -d'|' -f1,3)
check "union file-backed + file-less, sorted" $'working|dotf\nidle|newsess' "$out"

# Case 7: status file from a DEAD tmux server is ignored (pane ids restart at %0
# on every new server, so a stale N.status must not be adopted by a new pane).
rm -rf "$TMP"/claude-status; mkdir -p "$TMP/claude-status"
mkstatus claude %0 jcOS working 22247
out=$(FLEET_STATUS_ROOT="$TMP" FLEET_TMUX_PID=12264 "$SUT" <<<'%0|dotfiles')
check "stale tmux_pid ignored" 'idle|%0|dotfiles|' "$out"

# Case 8 (regression guard): a matching tmux_pid is still honoured.
out=$(FLEET_STATUS_ROOT="$TMP" FLEET_TMUX_PID=22247 "$SUT" <<<'%0|dotfiles' | cut -d'|' -f1,3)
check "live tmux_pid honoured" 'working|jcOS' "$out"


# ── Session names from Claude Code's live registry (~/.claude/sessions) ──────
# A user-set title (/rename -> nameSource "user") replaces the label; derived
# titles, dead pids, and other panes must not. FLEET_SESSIONS_DIR overrides the
# registry dir. Fixtures use $$ (this test's pid) as the live pid; 99999 is
# above macOS's pid ceiling so `kill -0` always fails for it.
mkreg() { # pid pane name source
  mkdir -p "$TMP/sessions"
  printf '{"pid":%s,"tmux":"sess:@1.%s","name":"%s","nameSource":"%s"}\n' \
    "$1" "$2" "$3" "$4" >"$TMP/sessions/$1.json"
}
run_named() { FLEET_STATUS_ROOT="$TMP" FLEET_TMUX_PID=1 FLEET_SESSIONS_DIR="$TMP/sessions" "$SUT"; }

# Case 9: a user-named live session overrides the status file's session label
rm -rf "$TMP"/claude-status "$TMP"/sessions; mkdir -p "$TMP/claude-status"
mkstatus claude %3 dotfiles working
mkreg $$ %3 "OmniWM Cheat" user
out=$(run_named <<<'%3|dotfiles')
check "user session name overrides label" 'working|%3|OmniWM Cheat|' "$out"

# Case 10: a derived (auto-generated) title is ignored
rm -rf "$TMP"/claude-status "$TMP"/sessions; mkdir -p "$TMP/claude-status"
mkstatus claude %4 jcOS working
mkreg $$ %4 "jcos-c1" derived
out=$(run_named <<<'%4|jcOS' | cut -d'|' -f3)
check "derived name ignored" 'jcOS' "$out"

# Case 11: a registry entry whose claude pid is dead is ignored
rm -rf "$TMP"/claude-status "$TMP"/sessions; mkdir -p "$TMP/claude-status"
mkstatus claude %3 dotfiles working
mkreg 99999 %3 "Ghost Session" user
out=$(run_named <<<'%3|dotfiles' | cut -d'|' -f3)
check "dead pid ignored" 'dotfiles' "$out"

# Case 12: a pane with NO status file still gets the user-set name
rm -rf "$TMP"/claude-status "$TMP"/sessions; mkdir -p "$TMP/claude-status"
mkreg $$ %8 "IPX Tunnel" user
out=$(run_named <<<'%8|scripts')
check "file-less pane gets user name" 'idle|%8|IPX Tunnel|' "$out"

# Case 13: a pipe in the title cannot break the pipe-delimited row format
rm -rf "$TMP"/claude-status "$TMP"/sessions; mkdir -p "$TMP/claude-status"
mkreg $$ %8 "a|b" user
out=$(run_named <<<'%8|scripts' | awk -F'|' '{print NF}')
check "pipe in name sanitized" '4' "$out"

# Case 14: pane match is exact — a registry entry for %32 must not label %3
rm -rf "$TMP"/claude-status "$TMP"/sessions; mkdir -p "$TMP/claude-status"
mkreg $$ %32 "Other Pane" user
out=$(run_named <<<'%3|dotfiles' | cut -d'|' -f3)
check "pane suffix match is exact" 'dotfiles' "$out"

exit $fail
