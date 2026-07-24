# Per-agent fleet pills in sketchybar

Date: 2026-07-23

## Problem

The bar collapses the whole fleet into one aggregate `agents` pill (robot +
count) plus one `attention` chip naming the top waiting agent. Two issues:

1. The aggregate abstraction does not give an at-a-glance read of *which*
   agents are in *which* state, and it is not a per-agent click target.
2. The pill is currently invisible anyway: `agents.sh` computes its `TOTAL`
   by grepping `pane_current_command` for `claude|codex|pi`, but panes running
   Claude report `bash`/`fish`/`node` (Claude's foreground child), so
   `TOTAL=0` and the pill draws off. The robot the user actually sees is the
   center `title` item's LED, which just tracks the focused window.

## Goals

- One pill per live agent, showing its state, visible on every workspace.
- Click a pill to jump straight to that agent's pane.
- Bounded width: cap inline pills, overflow into a popup.

Non-goals: changing the center `title` robot LED; cross-machine agents; any
change to fleet itself.

## Definitions

- **Live agent**: a status file `~/.cache/{claude,codex,pi}-status/<pane>.status`
  whose `pane` (`%N`) still appears in `tmux list-panes -a -F '#{pane_id}'`.
  Closed panes leave stale files; the liveness check drops them.
- **State**: derived per agent, one of `waiting` (permit), `asking`
  (question), `done`, `working`, `idle`.

## Data and state derivation

Reuse the derivation already in `agents.sh:38-68`: for each `.status` file,
fuse the snapshot with the tail of the sibling `.events.jsonl`, so an
`AskUserQuestion` turn resolves to `asking`, a permission prompt to `waiting`,
a `Stop` to `done`, and so on. The one change: keep *all* derived states, not
only the waiting tiers. Emit one record per live agent:

```
state|pane|session|tool
```

Status file shape (confirmed):

```json
{"state":"idle","pane":"%0","session":"ice_chat_cme","tool":"","ts":...,"tmux_pid":81311}
```

## Item topology

Pre-allocated pools (no runtime `--add`/`--remove`), mirroring the `space.*`
pattern in `sketchybarrc`:

- `agent.1 … agent.5` — inline pill slots (right region).
- `agent.more` — overflow pill; its popup anchors the overflow rows.
- `agent.pop.1 … agent.pop.15` — popup rows under `agent.more`'s popup.
- `agent_cluster` bracket spans `spend agent.more agent.5 … agent.1` — an
  explicit item list, not a `/agent\..*/` regex, so the popup rows
  (`agent.pop.*`) stay out of the bar. `spend` remains in the cluster;
  `attention` and `agents` leave it.

`POOL=5` and `POPUP_POOL=15` are constants at the top of `sketchybarrc` and the
render script so the cap is a one-line change. If live agents exceed
`POOL + POPUP_POOL` (20), the last popup row reads `+K more…` and opens
`fleet` (TUI) as a final escape hatch.

## Rendering

A single controller item (`drawing=off width=0`) runs the render script on
`fleet_state_change`, `aerospace_workspace_change`, and a `~30s` backstop
`update_freq` (the backstop reaps pills for panes that closed without writing
a status file). One batched `sketchybar --set …` call per render.

Render algorithm:

1. Snapshot live pane ids once: `tmux list-panes -a -F '#{pane_id}'`.
2. Build `state|pane|session|tool` records for live agents (derivation above).
3. Sort by urgency rank then session name (stable, so pills do not reorder
   between renders):

   | rank | state |
   |------|-------|
   | 0 | waiting |
   | 1 | asking |
   | 2 | done |
   | 3 | working |
   | 4 | idle |

4. Assign records `1..POOL` to `agent.1..agent.5`: set glyph, colors, label
   (session, `max_chars≈8`), `click_script`, `drawing=on`. Turn off unused
   slots.
5. If `count > POOL`: `agent.more` `drawing=on`, `label="+N"`
   (`N = count - POOL`); fill `agent.pop.*` rows with the overflow records,
   turn off unused rows. Else `agent.more drawing=off` and all rows off.

## Colors and glyphs

Glyphs match fleet's legend. Colors from `colors.sh`:

| State | Glyph | Icon/label color | Border | Fill |
|-------|-------|------------------|--------|------|
| waiting | ⚠ | `YELLOW` | `YELLOW_BORDER` | `YELLOW_FILL` |
| asking | ? | `MAGENTA` | `MAGENTA_BORDER` | `MAGENTA_FILL` |
| done | ✓ | `GREEN` | `GREEN_BORDER` | `GREEN_FILL` |
| working | ◉ | `GLOW_FULL` (accent) | `GLOW_EDGE` | `GLOW_FILL` |
| idle | ● | `GREY` | `HAIRLINE` | `ITEM_BG` |

Idle pills stay unlit (resting hairline) so a calm fleet reads quiet; active
and attention states light their edge. This keeps the Phosphor "structure
drawn with light" language.

## Interaction

- Pill click (any slot): `aerospace workspace D; fleet switch <pane>`
  (`fleet switch <pane-id>` is real, though absent from the summary help).
- `agent.more` click: `sketchybar --set agent.more popup.drawing=toggle`.
- Popup row click: same jump as a pill, plus close the popup.

## Removed / changed

- `attention` chip: removed (per-agent pills subsume it).
- `agents` pill and `agents.sh` `TOTAL`-via-`pane_current_command`: replaced by
  status-file enumeration.
- Workspace-D suppression: removed (pills always show).
- `bin/sketchybar-fleet-watch`: unchanged, reused as-is.

## Edge cases

- No live agents: all pool items and `agent.more` draw off; cluster bracket
  collapses to nothing.
- Stale status file, dead pane: dropped by the liveness check; backstop
  `update_freq` reaps a pill whose pane closed between pushes.
- `codex`/`pi` status dirs absent: glob must not error (guard with
  `[ -e "$f" ] || continue`; the current fish-glob error is a shell artifact,
  not a bug in the bash plugin).
- Item-name safety: pool names use `agent.N`, not the raw `%N` pane id, so
  sketchybar item names stay well-formed.

## Testing

- **Unit (pure function):** extract sort+derivation so it reads fixture
  `.status` / `.events.jsonl` from a temp dir and a fake pane-id list on
  stdin, and asserts the emitted ordered `state|pane|session|tool` lines.
  Cases: mixed states order correctly; stale pane dropped; >POOL splits into
  overflow; empty input yields nothing.
- **Visual:** with real sessions, `sketchybar --trigger fleet_state_change`
  and confirm slot assignment, colors, `+N`, and popup rows via
  `sketchybar --query agent.1` etc.
- **Interaction:** click each state's pill and the popup rows; confirm the
  jump lands on the right pane.

## Rollout

Single commit touching `sketchybarrc` (item pools + bracket), the render
script (replacing `agents.sh`'s body), and deleting `agents_click.sh` (its
left/right handlers are unreferenced once the aggregate pill is gone — pills
carry their own `click_script`, `agent.more` toggles its popup). No migration;
`sketchybar --reload` picks it up.

## Follow-up (2026-07-24): pane enumeration for brand-new sessions

The original **Definitions** keyed a live agent off "a status file whose pane
exists." That structurally missed a just-started session: fleet's hooks write
the `.status` file on the first event (tool use, notification, stop), not at
session start, so a fresh idle session had no file and no pill — while fleet's
own TUI showed it.

Shipped change: the live-agent set is now discovered by scanning each tmux
pane's process subtree for a `claude`/`codex`/`pi` process (the same reliable
signal used for tmux window naming — `pane_current_command` reports the
agent's foreground child, not the agent). `fleet_pills.sh` does that scan and
hands `pane|session` lines to `fleet-agent-rows`, which uses the derived state
where a status file exists and falls back to `idle` (label = current-path
basename) where one does not. New idle sessions now appear on the next render
(fswatch push fires only on status-file writes, so a file-less session shows on
the 30s backstop poll or the moment it acts).
