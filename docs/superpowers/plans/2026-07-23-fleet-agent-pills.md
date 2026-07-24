# Fleet Agent Pills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the dead aggregate `agents` pill with one clickable sketchybar pill per live fleet agent, capped at 5 inline with a popup for the rest.

**Architecture:** A standalone `fleet-agent-rows` script derives per-agent state from fleet's status files (fused with event logs) and emits sorted rows. A `fleet_pills.sh` sketchybar plugin maps those rows onto a pre-allocated item pool (`agent.1..5`, `agent.more`, popup rows `agent.pop.1..15`) in one batched call. `sketchybarrc` wires the pool and a controller item driven by the existing `fleet_state_change` fswatch push.

**Tech Stack:** bash, jq, tmux, sketchybar, aerospace, fleet CLI.

## Global Constraints

- Target: macOS, bash (`#!/usr/bin/env bash`), no `set -e` (pipeline-heavy, matches existing plugins).
- Colors come from `$CONFIG_DIR/colors.sh`; never hardcode hex.
- Canonical states: `waiting asking done working idle` (fleet glyphs: ⚠ ? ✓ ◉ ●).
- Commit explicit paths (`git commit -- <files>`), never `git add -A`. No `--no-verify`.
- `POOL=5`, `POPUP_POOL=15` are constants; the cap must be a one-line change.
- `~/bin` is `dotfiles/bin/bin/` (on `$PATH`); `~/.config/sketchybar` is `dotfiles/sketchybar/.config/sketchybar` (both via stow symlinks — edit the repo paths).

---

### Task 1: `fleet-agent-rows` — derive and sort live-agent rows

**Files:**
- Create: `bin/bin/fleet-agent-rows`
- Test: `bin/bin/fleet-agent-rows.test.sh`

**Interfaces:**
- Consumes: newline-separated live tmux pane ids on stdin (e.g. `%0\n%1`). `FLEET_STATUS_ROOT` env overrides the cache root (default `$HOME/.cache`).
- Produces: stdout, one line per live agent, `state|pane|session|tool`, sorted by urgency rank (waiting<asking<done<working<idle) then session name. Empty output when no live agents.

- [ ] **Step 1: Write the failing test**

Create `bin/bin/fleet-agent-rows.test.sh`:

```bash
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash bin/bin/fleet-agent-rows.test.sh`
Expected: FAIL — `fleet-agent-rows` does not exist yet (all cases error / print nothing).

- [ ] **Step 3: Write the implementation**

Create `bin/bin/fleet-agent-rows` (then `chmod +x`):

```bash
#!/usr/bin/env bash
# Emit "state|pane|session|tool" per LIVE agent, sorted by urgency then
# session. Live pane ids arrive on stdin (one per line). State fuses each
# fleet .status snapshot with the tail of its sibling .events.jsonl, mirroring
# sketchybar's old agents pill (see git history of plugins/agents.sh). Derived
# vocabulary is normalized to: waiting asking done working idle.
# FLEET_STATUS_ROOT overrides the cache root (default ~/.cache) for tests.

ROOT="${FLEET_STATUS_ROOT:-$HOME/.cache}"
LIVE=$(cat)

emit_row() {
  local sf="$1"
  tail -n 25 "${sf%.status}.events.jsonl" 2>/dev/null |
    jq -crsR --slurpfile st "$sf" '
      [splits("\n") | select(length > 0) | fromjson?] as $ev
      | $st[0] as $s
      | ($ev | last) as $l
      | (if $l == null then null
         elif $l.event == "Acknowledged" then "idle"
         elif $l.event == "Stop" or $l.event == "SubagentStop" then
           (if $l.background_tasks == true or $l.stop_reason == "tool_use"
            then "working" else "done" end)
         elif $l.event == "PreToolUse" then
           (if $l.tool == "AskUserQuestion" then "question" else "working" end)
         elif $l.event == "Notification" then
           (if $l.notification_type == "elicitation_dialog" then "question"
            elif $l.notification_type == "idle_prompt" then "done"
            elif $l.notification_type == "permission_prompt" then
              (($ev[0:-1] | reverse | map(select(
                  .event == "Stop" or .event == "SubagentStop"
                  or .event == "PreToolUse")) | first // null) as $t
               | if $t != null and $t.event == "PreToolUse"
                   and $t.tool == "AskUserQuestion"
                 then "question" else "permit" end)
            else null end)
         else null end) as $derived
      | ($derived // {waiting: "permit", completed: "done"}[$s.state] // $s.state) as $raw
      | ($raw | if . == "permit" then "waiting"
                elif . == "question" then "asking" else . end) as $state
      | "\($state)|\($s.pane)|\($s.session)|\($s.tool)"
    ' 2>/dev/null
}

for dir in claude codex pi; do
  for sf in "$ROOT/${dir}-status"/*.status; do
    [ -e "$sf" ] || continue
    emit_row "$sf"
  done
done |
  while IFS='|' read -r state pane session tool; do
    [ -n "$pane" ] || continue
    grep -qxF -- "$pane" <<<"$LIVE" || continue
    printf '%s|%s|%s|%s\n' "$state" "$pane" "$session" "$tool"
  done |
  awk -F'|' '
    { r = ($1=="waiting")?0:($1=="asking")?1:($1=="done")?2:($1=="working")?3:($1=="idle")?4:5
      print r "|" $0 }' |
  sort -t'|' -k1,1n -k4,4 |
  cut -d'|' -f2-
```

- [ ] **Step 4: Make it executable and run the test to verify it passes**

Run: `chmod +x bin/bin/fleet-agent-rows && bash bin/bin/fleet-agent-rows.test.sh`
Expected: four `ok -` lines, exit 0.

- [ ] **Step 5: Smoke-test against real data**

Run: `tmux list-panes -a -F '#{pane_id}' | bin/bin/fleet-agent-rows`
Expected: zero or more `state|%pane|session|tool` lines for your currently-open agent sessions (no error output).

- [ ] **Step 6: Commit**

```bash
git commit -- bin/bin/fleet-agent-rows bin/bin/fleet-agent-rows.test.sh \
  -m "feat(sketchybar): fleet-agent-rows — per-agent state derivation"
```

---

### Task 2: `fleet_pills.sh` — map rows onto the sketchybar item pool

**Files:**
- Create: `sketchybar/.config/sketchybar/plugins/fleet_pills.sh`
- Test: `sketchybar/.config/sketchybar/plugins/fleet_pills.test.sh`

**Interfaces:**
- Consumes: `fleet-agent-rows` output. Env seams for testing: `FLEET_ROWS_FILE` (read rows from a file instead of calling the row script + tmux) and `SKETCHYBAR` (command to invoke, default `sketchybar`). `CONFIG_DIR` must point at the sketchybar config dir so `colors.sh` resolves.
- Produces: a single `sketchybar --set ...` batched call assigning the top `POOL` rows to `agent.1..agent.5`, the remainder to `agent.pop.1..15` (last row becomes a `+K more` escape hatch when total exceeds `POOL+POPUP_POOL`), sets `agent.more` to `+N` when overflowing, and turns off every unused pool item.

- [ ] **Step 1: Write the failing test**

Create `sketchybar/.config/sketchybar/plugins/fleet_pills.test.sh`:

```bash
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash sketchybar/.config/sketchybar/plugins/fleet_pills.test.sh`
Expected: FAIL — `fleet_pills.sh` does not exist.

- [ ] **Step 3: Write the implementation**

Create `sketchybar/.config/sketchybar/plugins/fleet_pills.sh`:

```bash
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

if [ -n "${FLEET_ROWS_FILE:-}" ]; then
  ROWS=$(cat "$FLEET_ROWS_FILE")
else
  ROWS=$(tmux list-panes -a -F '#{pane_id}' 2>/dev/null | "$HOME/bin/fleet-agent-rows")
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
```

- [ ] **Step 4: Make executable and run the test to verify it passes**

Run: `chmod +x sketchybar/.config/sketchybar/plugins/fleet_pills.sh && bash sketchybar/.config/sketchybar/plugins/fleet_pills.test.sh`
Expected: all `ok -` lines, exit 0.

- [ ] **Step 5: Commit**

```bash
git commit -- sketchybar/.config/sketchybar/plugins/fleet_pills.sh \
  sketchybar/.config/sketchybar/plugins/fleet_pills.test.sh \
  -m "feat(sketchybar): fleet_pills.sh — render one pill per agent"
```

---

### Task 3: Wire the pool into `sketchybarrc`; remove the old aggregate pill

**Files:**
- Modify: `sketchybar/.config/sketchybar/sketchybarrc:146-182` (the `agents`/`attention`/`spend`/`agent_cluster` block)
- Delete: `sketchybar/.config/sketchybar/plugins/agents.sh`, `sketchybar/.config/sketchybar/plugins/agents_click.sh`

**Interfaces:**
- Consumes: `fleet_pills.sh` (Task 2), the existing `fleet_state_change` event and `bin/sketchybar-fleet-watch` fswatch (unchanged).
- Produces: items `fleet_controller`, `agent.1..agent.5`, `agent.more`, `agent.pop.1..agent.pop.15`, and bracket `agent_cluster`.

- [ ] **Step 1: Replace the item block in `sketchybarrc`**

Replace the block from the `# ── Right: agents ...` comment through the end of the `agent_cluster` bracket definition (currently lines 146-182) with:

```bash
# ── Right: fleet agent pills · spend ─────────────────────────────
# One pill per live agent (fleet), rendered by fleet_pills.sh in a single
# batched call. Inline pool agent.1..5; overflow into agent.more's popup
# (agent.pop.1..15). Push via fleet_state_change (fswatch); update_freq is a
# backstop that reaps pills whose pane closed without writing a status file.
FLEET_POOL=5
FLEET_POPUP_POOL=15

sketchybar --add item fleet_controller right \
  --subscribe fleet_controller fleet_state_change aerospace_workspace_change \
  --set fleet_controller drawing=off width=0 \
  update_freq=30 \
  script="$PLUGIN_DIR/fleet_pills.sh"

# Inline pills. Added high-index-first so agent.1 sits leftmost in the group.
for i in $(seq "$FLEET_POOL" -1 1); do
  sketchybar --add item agent."$i" right \
    --set agent."$i" \
    drawing=off \
    label.max_chars=8 \
    icon.font="JetBrainsMono Nerd Font Mono:Regular:13.0"
done

# Overflow badge + popup rows (rows anchor on agent.more's popup).
sketchybar --add item agent.more right \
  --set agent.more drawing=off icon="⋯" icon.color="$GREY"
for j in $(seq 1 "$FLEET_POPUP_POOL"); do
  sketchybar --add item agent.pop."$j" popup.agent.more \
    --set agent.pop."$j" drawing=off label.max_chars=40 \
    icon.font="JetBrainsMono Nerd Font Mono:Regular:13.0"
done

# spend: running daily dollar total across claude/codex/pi via
# `sessions report` — placed beside the agents it measures
sketchybar --add item spend right \
  --set spend \
  icon="$" \
  icon.font="$MONO:Bold:12.0" \
  update_freq=900 \
  drawing=off \
  script="$PLUGIN_DIR/spend.sh"

# The agent instrument cluster shares one shelf outline, mirroring the
# workspace shelf on the left. Explicit item list (not a /agent\..*/ regex)
# so the popup rows stay out of the bar bracket.
sketchybar --add bracket agent_cluster spend agent.more agent.5 agent.4 agent.3 agent.2 agent.1 \
  --set agent_cluster \
  background.color="$TRANSPARENT" \
  background.border_width=1 \
  background.border_color="$GLOW_TRACE" \
  background.corner_radius=6 \
  background.height=28
```

- [ ] **Step 2: Delete the obsolete plugins**

```bash
git rm sketchybar/.config/sketchybar/plugins/agents.sh \
  sketchybar/.config/sketchybar/plugins/agents_click.sh
```

- [ ] **Step 3: Reload and verify item wiring**

Run:
```bash
sketchybar --reload && sleep 1
sketchybar --trigger fleet_state_change && sleep 1
for it in fleet_controller agent.1 agent.more agent.pop.1; do
  echo "== $it =="; sketchybar --query "$it" | jq -r '.geometry.drawing // "missing"'
done
```
Expected: each item resolves (prints `on`/`off`, not `missing`). With live agent sessions open, `agent.1` reads `on`; with none, `off`. No errors from `--reload`.

- [ ] **Step 4: Visual + interaction check**

With at least one agent session running: confirm a colored pill appears on the right cluster; click it and confirm focus jumps to workspace D and that agent's pane (`fleet switch`). If more than 5 agents run, confirm `agent.more` shows `+N` and clicking it toggles a popup listing the rest.

- [ ] **Step 5: Commit**

```bash
git commit -- sketchybar/.config/sketchybar/sketchybarrc \
  sketchybar/.config/sketchybar/plugins/agents.sh \
  sketchybar/.config/sketchybar/plugins/agents_click.sh \
  -m "feat(sketchybar): per-agent fleet pills replace aggregate pill"
```

---

## Notes for the implementer

- The `fleet switch <pane-id>` subcommand is real but absent from `fleet --help`'s summary; do not "fix" it.
- Right-region item order in sketchybar: items added later sit further left. Step 1 of Task 3 adds pills high-index-first so `agent.1` is leftmost; verify visually in Task 3 Step 4 and flip the `seq` direction if the order reads backwards.
- `label.max_chars=8` truncates the session name in the bar; popup rows allow 40.
- Do not touch the center `title` item's robot LED — separate concern, out of scope.
- **Pool-size coupling:** `sketchybarrc` pre-allocates `FLEET_POOL`/`FLEET_POPUP_POOL` items and `fleet_pills.sh` addresses `POOL`/`POPUP_POOL` of them. These must stay equal (5 and 15). If you change the cap, change both files or the extra items will never draw / the script will address items that were never added.
