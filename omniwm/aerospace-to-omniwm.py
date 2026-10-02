#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["tomlkit>=0.13"]
# ///
"""Translate aerospace.toml onto an OmniWM-generated settings.toml.

OmniWM's schema is strict: a missing key or hotkey id rejects the whole file.
So this never builds settings.toml from scratch. Launch OmniWM once so it
writes a complete default file, then run this to patch values in place.

    omniwm/aerospace-to-omniwm.py [--dry-run]

Targets OmniWM 0.7.4 (schemaVersion 4).
"""

import sys
import tomllib
import uuid
from pathlib import Path

import tomlkit

DOTFILES = Path(__file__).resolve().parent.parent
AEROSPACE = DOTFILES / "aerospace/.config/aerospace/aerospace.toml"
SETTINGS = Path.home() / ".config/omniwm/settings.toml"

# OmniWM workspace names must be positive integers; anything else is silently
# dropped (WorkspaceSettings.normalizedConfigurations). Letters map to 10+,
# keep the letter as displayName, and keep the Option+<letter> chord.
LETTERS = "ABCDEFGIMNOPQRSTUVWXYZ"  # aerospace's set: no H/J/K/L
WORKSPACES = {str(n): str(n) for n in range(1, 10)}
WORKSPACES |= {letter: str(10 + i) for i, letter in enumerate(LETTERS)}

# aerospace [workspace-to-monitor-force-assignment], expressed as OmniWM roles.
# specificDisplay needs a display UUID, which differs per machine; roles plus
# monitors.ranking stay portable across the laptop and the Studio Display desk.
WORKSPACE_ROLE = {"D": "main", "B": "secondary"}
MONITOR_RANKING = [
    {"name": "Studio Display", "displayUUID": "735066A6-B923-43EF-BA3C-C2E9525C5804"},
    {"name": "Built-in Retina Display"},
    {"name": "Sidecar Display"},
]

LAYOUT = "dwindle"  # closest to aerospace 'tiles'; niri is the scrolling layout


def hotkey_plan() -> dict[str, str]:
    """OmniWM hotkey id -> chord, mirroring aerospace [mode.main.binding]."""
    plan = {
        # alt-hjkl / alt-shift-hjkl. OmniWM's own "move" joins/consumes in
        # dwindle/niri, so the aerospace-style swap lives on moveColumn.
        "focus.left": "Option+H",
        "focus.down": "Option+J",
        "focus.up": "Option+K",
        "focus.right": "Option+L",
        "moveColumn.left": "Option+Shift+H",
        "moveColumn.down": "Option+Shift+J",
        "moveColumn.up": "Option+Shift+K",
        "moveColumn.right": "Option+Shift+L",
        # service-mode join-with hjkl, minus the mode.
        "move.left": "Control+Option+Shift+H",
        "move.down": "Control+Option+Shift+J",
        "move.up": "Control+Option+Shift+K",
        "move.right": "Control+Option+Shift+L",
        # alt-slash (tiles orientation) / alt-comma (accordion).
        "toggleSplit": "Option+Slash",
        "toggleColumnTabbed": "Option+Comma",
        "toggleWorkspaceLayout": "Control+Option+Slash",
        # alt-minus / alt-equal: 'resize smart'.
        "resizeFocusedWindow.shrink": "Option+Minus",
        "resizeFocusedWindow.grow": "Option+Equal",
        "setContainerPrimarySpan.decrease10Percent": "Control+Option+Minus",
        "setContainerPrimarySpan.increase10Percent": "Control+Option+Equal",
        # alt-tab / alt-shift-tab. OmniWM has no "next monitor, wrap".
        "workspaceBackAndForth": "Option+Tab",
        "focusPrevious": "Control+Option+Tab",
        "moveWorkspaceToMonitor.right": "Option+Shift+Tab",
        # service mode f / r. Option+Shift+<letter> is all workspace moves now.
        "toggleFocusedWindowFloating": "Control+Option+F",
        "balanceSizes": "Control+Option+R",
        "toggleOverview": "Control+Option+O",
    }
    for key, number in WORKSPACES.items():
        index = int(number) - 1  # hotkey ids are zero-based
        plan[f"switchWorkspace.{index}"] = f"Option+{key}"
        plan[f"moveToWorkspace.{index}"] = f"Option+Shift+{key}"
    return plan


def require(table, *path):
    """Walk a key path, failing loudly: a missing key means a schema change."""
    node = table
    for key in path:
        if key not in node:
            sys.exit(f"settings.toml has no {'.'.join(path)}; schema changed?")
        node = node[key]
    return node


def set_value(doc, path: str, value):
    *parents, leaf = path.split(".")
    table = require(doc, *parents) if parents else doc
    require(table, leaf)
    table[leaf] = value


def stable_id(kind: str, name: str) -> str:
    """Deterministic UUIDs so re-running doesn't churn ids."""
    return str(uuid.uuid5(uuid.NAMESPACE_URL, f"omniwm:{kind}:{name}")).upper()


def apply_scalars(doc):
    for path, value in {
        "general.defaultLayoutType": LAYOUT,
        "general.ipcEnabled": True,  # sketchybar talks to omniwmctl
        # on-focused-monitor-changed = move-mouse monitor-lazy-center
        "focus.moveMouseToFocusedWindow": True,
        # [gaps]: the non-built-in values; built-in overrides need that
        # display's UUID (Settings > Monitors records it).
        "gaps.size": 20.0,
        "gaps.outer.left": 25.0,
        "gaps.outer.right": 25.0,
        "gaps.outer.bottom": 25.0,
        # Both bars share one 30pt row at y=34, clear of the auto-hiding menu
        # bar; windows start 25pt below it (34 + 30 + 25).
        "gaps.outer.top": 89.0,
        # A lone window's "fill" fit uses the fullscreen frame; without this
        # it covers sketchybar the way aerospace never did.
        "gaps.fullscreenUsesOuterGaps": True,
        # OmniWM's workspaces on the left of the row, sketchybar's
        # fleet/github/usage/music on the right. Horizontal OmniWM bars are
        # always centered and xOffset only shifts the center, so the left
        # edge drifts by half of any width change. fillLeftOfNotch is the one
        # left-anchored mode, but it is locked to the menu-bar strip.
        # belowMenuBar measures from y=0 while the menu bar auto-hides, hence
        # yOffset -34 (positive moves up).
        "workspaceBar.enabled": True,
        "workspaceBar.notchMode": "moveBelowMenuBar",
        "workspaceBar.position": "belowMenuBar",
        "workspaceBar.height": 30.0,
        "workspaceBar.xOffset": -1277.0,
        "workspaceBar.yOffset": -34.0,
        "workspaceBar.reserveLayoutSpace": False,
        "workspaceBar.showFloatingWindows": True,
        "workspaceBar.hideEmptyWorkspaces": True,
    }.items():
        set_value(doc, path, value)


def apply_workspaces(doc):
    workspaces = tomlkit.aot()
    for key, number in WORKSPACES.items():
        ws = tomlkit.table()
        if key != number:
            ws["displayName"] = key
        ws["id"] = stable_id("workspace", number)
        ws["layoutType"] = "default"
        ws["name"] = number
        ws["monitorAssignment"] = {"type": WORKSPACE_ROLE.get(key, "main")}
        workspaces.append(ws)
    doc["workspaces"] = workspaces

    ranking = tomlkit.aot()
    for row in MONITOR_RANKING:
        ranking.append(tomlkit.item(row))
    doc.setdefault("monitors", tomlkit.table())["ranking"] = ranking


def apply_hotkeys(doc) -> list[str]:
    plan = hotkey_plan()
    hotkeys = require(doc, "hotkeys")
    by_id = {hk["id"]: hk for hk in hotkeys}

    # Workspace 10+ ids exist only while those workspaces do; add them.
    for hk_id in plan:
        if hk_id not in by_id:
            if not hk_id.startswith(("switchWorkspace.", "moveToWorkspace.")):
                sys.exit(f"hotkey id {hk_id} not in settings.toml; renamed upstream?")
            entry = tomlkit.table()
            entry["binding"] = "Unassigned"
            entry["id"] = hk_id
            hotkeys.append(entry)
            by_id[hk_id] = entry

    # Free every chord we claim from whatever default held it.
    claimed = set(plan.values())
    displaced = []
    for hk in hotkeys:
        if hk["id"] not in plan and hk["binding"] in claimed:
            displaced.append(f"{hk['id']} (was {hk['binding']})")
            hk["binding"] = "Unassigned"

    for hk_id, chord in plan.items():
        by_id[hk_id]["binding"] = chord
    return displaced


def aerospace_app_rules() -> dict[str, dict]:
    """Collapse [[on-window-detected]] into one rule per bundle id."""
    config = tomllib.loads(AEROSPACE.read_text())
    rules: dict[str, dict] = {}
    for detected in config.get("on-window-detected", []):
        app_id = detected["if"]["app-id"]
        run = detected["run"]
        commands = [run] if isinstance(run, str) else run
        rule = rules.setdefault(app_id, {})
        for command in commands:
            verb, _, arg = command.partition(" ")
            if command == "layout floating":
                rule["layout"] = "float"
            elif verb == "move-node-to-workspace":
                rule["assignToWorkspace"] = WORKSPACES[arg]
            # 'layout accordion' (Obsidian) has no per-app equivalent.
    return rules


def apply_app_rules(doc):
    app_rules = doc.setdefault("appRules", tomlkit.aot())
    existing = {rule["bundleId"]: rule for rule in app_rules}
    for bundle_id, fields in aerospace_app_rules().items():
        if not fields:
            continue
        rule = existing.get(bundle_id)
        if rule is None:
            rule = tomlkit.table()
            rule["bundleId"] = bundle_id
            rule["id"] = stable_id("appRule", bundle_id)
            app_rules.append(rule)
        rule.update(fields)


def main():
    dry_run = "--dry-run" in sys.argv
    if not SETTINGS.exists():
        sys.exit(f"{SETTINGS} missing. Launch OmniWM once so it writes defaults.")

    doc = tomlkit.parse(SETTINGS.read_text())
    if doc.get("schemaVersion") != 4:
        sys.exit(f"expected schemaVersion 4, got {doc.get('schemaVersion')}")

    apply_scalars(doc)
    apply_workspaces(doc)
    displaced = apply_hotkeys(doc)
    apply_app_rules(doc)

    output = tomlkit.dumps(doc)
    if dry_run:
        print(output)
    else:
        SETTINGS.write_text(output)  # write_text follows the dotfiles symlink
    print("Unassigned defaults (chord now used by the aerospace layout):", file=sys.stderr)
    for line in displaced:
        print(f"  {line}", file=sys.stderr)


if __name__ == "__main__":
    main()
