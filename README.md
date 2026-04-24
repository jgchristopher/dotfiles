# dotfiles

Personal macOS dotfiles. Symlinked into `~/`, `~/.config/`, etc. via `install.sh`.

## Initial setup on a new machine

```sh
git clone https://github.com/<you>/dotfiles ~/gitprojects/dotfiles
cd ~/gitprojects/dotfiles
./install.sh all
brew bundle install
brew install cormacrelf/tap/dark-notify   # required for theme-sync; cormacrelf/tap isn't auto-tapped
./install.sh terminal-theme-sync           # bootstraps the LaunchAgent
```

## What `./install.sh` actions do

| Action | Effect |
| --- | --- |
| `link` | Symlink `*.symlink` files to `~/`, and `<dir>/.config/*` into `~/.config/`. Idempotent. |
| `homebrew` | Install Homebrew + run `brew bundle`. |
| `shell` | Set login shell to fish. |
| `git` | Write `~/.gitconfig-local` with name/email/github user. |
| `terminfo` | Install custom terminfo entries. |
| `terminal-theme-sync` | Install the LaunchAgent that auto-switches Ghostty/Starship/Neovim/Tmux/Claude themes on macOS appearance change. Requires `dark-notify` already installed. |
| `macos` | Apply opinionated macOS defaults. Run once, then ignore. |
| `all` | Everything above. |

## Theme system

Light → Solarized Light. Dark → TokyoNight Night. Switches automatically on macOS appearance change across Ghostty, Neovim (LazyVim), Starship, tmux, and Claude Code. Designed for sun-readability — Solarized was engineered specifically for direct daylight.

Architecture and gotchas: see `CLAUDE.md` and `docs/superpowers/specs/2026-04-24-light-theme-redesign-design.md`.

## Verifying the theme switcher

```sh
launchctl list | grep com.jc.terminal-theme-sync   # PID column should be a number, not '-'
tail -f ~/.local/state/sync-terminal-theme/log     # toggle macOS appearance; new lines should appear
```

If toggling doesn't fire log lines: `launchctl print gui/$(id -u)/com.jc.terminal-theme-sync` — confirm the watcher process is alive. KeepAlive will respawn `dark-notify` if it crashes.
