# CLAUDE.md — dotfiles

Personal macOS dotfiles. Single-user repo; work happens directly on `main`, no feature branches.

## Layout
- Stow-style symlinks: `install.sh link` creates `~/.config/<tool>` → `dotfiles/<tool>/.config/<tool>` and `~/.<name>` ← `dotfiles/**/<name>.symlink`.
- `~/bin` → `dotfiles/bin/bin/` (already on `$PATH`). Drop new scripts here.
- `~/.claude/settings.json` is symlinked into the repo; `~/.claude/settings.local.json` is **not** — it's machine-local and may be auto-generated.
- Plans/specs in `docs/superpowers/{specs,plans}/`. Check for an existing plan before starting non-trivial work.

## Theme system (Solarized Light / TokyoNight Night)
- Single entry point: `bin/bin/sync-terminal-theme` — idempotent; swaps Ghostty overrides, regenerates `~/.config/starship.dark.toml`, writes `~/.claude/settings.local.json`, re-sources tmux, signals Ghostty (`SIGUSR2`).
- Triggered by `bin/bin/terminal-theme-watcher` (runs `dark-notify` from cormacrelf/tap under launchd `KeepAlive`).
- Plist template: `bin/com.jc.terminal-theme-sync.plist.template`. Install: `./install.sh terminal-theme-sync`.
- Ghostty per-mode opacity: base config is `opacity 1.0`; `ghostty/.config/ghostty/overrides.dark` is copied to `overrides` (gitignored) in dark mode. The `?./overrides` in `config` makes it optional.
- `os_is_dark()` shell-out helper is intentionally duplicated in `nvim/.config/nvim/lua/plugins/{catppuccin,tokyonight}.lua` — both need it for conditional transparency.

## macOS quirks
- `defaults read -g AppleInterfaceStyle` errors out (non-zero) in Light — Light is the *absence* of the key. Use exit-code probing, not output parsing.
- `AppleInterfaceThemeChangedNotification` fires **twice per toggle** (animation start + end). Dedup by value.
- launchd's `LaunchEvents`/`distributed_notifications.matching` is unreliable on modern macOS — use a `dark-notify`-style foreground listener.

## Tool quirks
- **Starship**: does not interpolate env vars in the `palette` field. Use `STARSHIP_CONFIG` to point at an alternate file.
- **Ghostty**: the canonical solarized theme is named `iTerm2 Solarized Light` (no plain "Solarized Light"). Verify any new theme name with `ghostty +list-themes`.
- **Tmux**: `theme.tmux` re-runs on `tmux source-file ~/.config/tmux/tmux.conf` — that's the reload path used by `sync-terminal-theme` and by your `bind r`.

## Conventions
- Commit explicit paths (`git commit -- <files>`) not `git add -A` — `claude/.claude/` has stale state and there are many separately-tracked subtrees.
- Don't use `--no-verify`. No hooks today, but the convention holds.
- Generated state files (`ghostty/.config/ghostty/overrides`, `~/.config/starship.dark.toml`, `~/.claude/settings.local.json`) are not committed.
