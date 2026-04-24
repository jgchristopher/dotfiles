# Sun-readable light theme — design

## Goal

Configure Ghostty, Neovim, Starship, and Lualine so that:

1. **Light mode** uses **Solarized Light** with **no transparency** — readable in direct sunlight and bright indoor light.
2. **Dark mode** uses **TokyoNight Night** uniformly across all tools — fixes the current Ghostty/Neovim/Starship palette mismatch.
3. **macOS appearance changes** (Light ↔ Dark) trigger an automatic theme refresh in already-open Ghostty windows, including the per-mode opacity switch.

## Current state (baseline)

| Tool       | Light                                | Dark                                | Notes                                                                                       |
| ---------- | ------------------------------------ | ----------------------------------- | ------------------------------------------------------------------------------------------- |
| Ghostty    | `TokyoNight Day`                     | `TokyoNight Night`                  | `background-opacity = 0.85`, `background-blur-radius = 30` apply to both modes              |
| Neovim     | `catppuccin-latte` with transparency | `catppuccin-mocha` with transparency | `os_is_dark()` shell-out picks at startup; `tokyonight.lua` plugin also has `transparent = true` |
| Starship   | `catppuccin_macchiato` (always)      | `catppuccin_macchiato` (always)     | Hard-coded dark palette regardless of OS appearance                                         |
| Lualine    | `catppuccin`                         | `catppuccin`                        | Static                                                                                      |

## Why the current setup fails in sunlight

1. **Transparency in light mode** — Ghostty's 85% opacity + 30px blur lets whatever is behind the window bleed through, crushing contrast against the (already low-contrast) Catppuccin Latte / TokyoNight Day palettes.
2. **Catppuccin Latte / TokyoNight Day are intentionally soft palettes** — pastel accents and pale gray comments fail in direct sunlight even at full opacity.
3. **Starship locked to a dark palette** — in light mode, dark-mode-tuned prompt glyphs render against a light background, producing washed-out segments.
4. **Tool mismatch** — Ghostty (TokyoNight) and Neovim (Catppuccin) disagree, so terminal panes inside nvim, gutter colors, and `:terminal` buffers look inconsistent.

## Target state

| Tool       | Light             | Dark               | Transparency                                                                |
| ---------- | ----------------- | ------------------ | --------------------------------------------------------------------------- |
| Ghostty    | `Solarized Light` | `tokyonight_night` | Off in light, `opacity 0.85` + `blur 30` in dark, switched automatically    |
| Neovim     | `solarized-osaka` (light variant) or `vim-solarized8` | `tokyonight-night` | `transparent = false` in light, `transparent = true` in dark            |
| Starship   | `solarized_light` palette | `tokyonight` palette | n/a (palette only) |
| Lualine    | `auto` (follows colorscheme) | `auto` | n/a |

## Architecture

### Component 1 — Ghostty config split

**File: `ghostty/.config/ghostty/config`**

- Change theme line to: `theme = dark:tokyonight_night,light:Solarized Light` (use built-in Ghostty theme names).
- Set base `background-opacity = 1.0`.
- Remove `background-blur-radius` from base config.
- Keep existing line `config-file = ?./overrides` (already at line 125; the leading `?` makes it optional).

**New file: `ghostty/.config/ghostty/overrides.dark`**

```
background-opacity = 0.85
background-blur-radius = 30
```

This file is the *source* for dark-mode visual extras. It is never read by Ghostty directly — it only gets copied into `overrides` when in dark mode.

**Generated file (gitignored): `ghostty/.config/ghostty/overrides`**

- Present (= contents of `overrides.dark`) when macOS appearance is Dark.
- Absent when macOS appearance is Light. The `?` prefix on `config-file` makes Ghostty skip silently.

### Component 2 — Theme sync script

**New file: `bin/sync-terminal-theme`**

Behavior:

1. Detect macOS appearance with `defaults read -g AppleInterfaceStyle 2>/dev/null`. Exit code 0 + output `Dark` = dark mode; nonzero = light mode.
2. If dark: `cp ~/.config/ghostty/overrides.dark ~/.config/ghostty/overrides`
3. If light: `rm -f ~/.config/ghostty/overrides`
4. Reload all running Ghostty processes: `pkill -SIGUSR2 -x ghostty` (Ghostty's documented config-reload signal).
5. Write the resolved palette name to `~/.config/starship/active-palette` (consumed by Starship — see Component 4).

The script must be idempotent and safe to invoke multiple times (no-op if already in target state).

### Component 3 — launchd agent for auto-switching

**New file: `~/Library/LaunchAgents/com.jc.terminal-theme-sync.plist`**

- Triggers via `LaunchEvents` → `com.apple.distributed_notifications.matching` listening for `AppleInterfaceThemeChangedNotification`.
- Also runs at login (`RunAtLoad = true`) to set initial state.
- `Program` points to absolute path of `~/bin/sync-terminal-theme`.
- Loaded once via `launchctl bootstrap gui/<uid> ~/Library/LaunchAgents/com.jc.terminal-theme-sync.plist`.

The plist itself **lives outside the dotfiles repo** (in `~/Library/LaunchAgents`) since it's macOS-specific and contains absolute paths. Ship a template at `bin/com.jc.terminal-theme-sync.plist.template` and document install steps in the install script.

### Component 4 — Starship per-mode palette

**File: `starship.toml`**

- Define both palettes inline: `[palettes.solarized_light]` and `[palettes.tokyonight]`.
- Replace the hard-coded `palette = "catppuccin_macchiato"` line with `palette = "$STARSHIP_PALETTE"` — Starship supports env-var palette selection.

**File: `fish/.config/fish/config.fish`**

- Add a function `_set_starship_palette` that:
  - Reads `~/.config/starship/active-palette` if it exists (written by `sync-terminal-theme`).
  - Falls back to detecting `defaults read -g AppleInterfaceStyle` directly if the file is missing.
  - Exports `STARSHIP_PALETTE=tokyonight` or `STARSHIP_PALETTE=solarized_light`.
- Call `_set_starship_palette` once at shell startup.

Each new shell picks up the right palette. (Already-running shells require a manual `_set_starship_palette; exec fish` to refresh — acceptable trade-off vs. polling in the prompt.)

### Component 5 — Neovim themes

**File: `nvim/.config/nvim/lua/plugins/catppuccin.lua`**

- Replace the `os_is_dark()` branch:
  - Dark → `"tokyonight-night"`
  - Light → `"solarized-osaka"` (light flavor) — already a folke-style plugin, well-maintained.
- Remove `transparent_background = true` from catppuccin opts (catppuccin no longer drives the colorscheme).
- Lualine `theme = "auto"` (replaces `theme = "catppuccin"`).

**File: `nvim/.config/nvim/lua/plugins/tokyonight.lua`**

- Set `transparent` based on OS appearance: `true` only in dark mode, `false` in light. Use the same `os_is_dark()` helper.

**New plugin spec**: add `craftzdog/solarized-osaka.nvim` (or `lifepillar/vim-solarized8` if user prefers vim-script port). Configure with `transparent = false`.

The catppuccin plugin can stay loaded (LazyVim ships it as a soft dep), but it no longer drives the colorscheme. We could remove it later as a YAGNI follow-up; not in scope here.

## Data flow

```
macOS appearance change
        │
        ▼
AppleInterfaceThemeChangedNotification (distributed notification)
        │
        ▼
launchd agent (com.jc.terminal-theme-sync)
        │
        ▼
~/bin/sync-terminal-theme
        │
        ├── writes/removes ~/.config/ghostty/overrides
        ├── writes ~/.config/starship/active-palette
        └── pkill -SIGUSR2 ghostty  ──► Ghostty reloads config (palette + opacity)

(new shell start)
        │
        ▼
fish config.fish → _set_starship_palette
        │
        └── reads active-palette → exports $STARSHIP_PALETTE → starship picks palette

(neovim start)
        │
        ▼
catppuccin.lua → os_is_dark() shell-out → picks tokyonight-night or solarized-osaka
```

## Files changed / added

**Modified:**
- `ghostty/.config/ghostty/config` — theme line, opacity defaults, remove blur from base
- `nvim/.config/nvim/lua/plugins/catppuccin.lua` — switch colorscheme picker, drop transparent
- `nvim/.config/nvim/lua/plugins/tokyonight.lua` — conditional transparency
- `starship.toml` — add `solarized_light` + `tokyonight` palettes, swap hard-coded palette to `$STARSHIP_PALETTE`
- `fish/.config/fish/config.fish` — add `_set_starship_palette` and call at startup
- `install.sh` — document/automate launchd agent install

**New:**
- `ghostty/.config/ghostty/overrides.dark` — dark-mode opacity overrides (committed)
- `bin/sync-terminal-theme` — appearance-driven sync script
- `bin/com.jc.terminal-theme-sync.plist.template` — LaunchAgent template
- `nvim/.config/nvim/lua/plugins/solarized-osaka.lua` — new plugin spec

**Gitignore additions:**
- `ghostty/.config/ghostty/overrides` (generated state)

## Testing strategy

This is a config repo — testing is manual verification, not unit tests. Test plan:

1. `sync-terminal-theme` script: run with macOS in Light, then Dark — verify `overrides` file present/absent, `active-palette` content correct, Ghostty reloads without restarting.
2. Toggle macOS appearance via System Settings; verify launchd fires within ~1 second and Ghostty repaints.
3. Open new fish shell in each mode; verify Starship colors match palette.
4. Open neovim in each mode; verify colorscheme + transparency match expectations.
5. Sun test: take laptop into direct sunlight in light mode and confirm comments, prompt segments, and syntax tokens are readable.

## Out of scope

- Migrating `kitty` and `wezterm` configs (still present in repo but Ghostty is the daily driver).
- Tmux theme — uses terminal palette directly, will inherit the new colors automatically.
- Removing the now-unused catppuccin plugin from neovim (separate cleanup PR).
- Lazygit, glow, mailmate themes — secondary tools, leave as-is unless user finds issues post-rollout.
