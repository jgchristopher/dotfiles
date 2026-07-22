#!/usr/bin/env bash
# App name -> Nerd Font glyph (Font Awesome set in JetBrainsMono Nerd Font Mono).
# Names are what `aerospace list-windows --format '%{app-name}'` reports.
# GENERATED with real glyph bytes (see git history); extend the case as
# new apps join the rotation.

app_icon() {
  case "$1" in
  Ghostty | WezTerm | kitty | Terminal | Alacritty) echo "" ;; # terminal
  Safari*) echo "" ;;                                          # safari
  Zen | Firefox*) echo "" ;;                                   # firefox — Zen is a Firefox fork
  *Chrome*) echo "" ;;                                         # chrome
  Slack) echo "" ;;                                            # slack
  Discord) echo "" ;;                                          # comments
  Messages) echo "" ;;                                         # comment
  Mimestream | Spark* | Mail) echo "" ;;                       # envelope
  Calendar | Fantastical) echo "" ;;                           # calendar
  Music | Spotify) echo "" ;;                                  # music
  Notion) echo "" ;;                                           # sticky note
  Obsidian) echo "" ;;                                         # diamond
  Linear) echo "" ;;                                           # tasks
  OmniFocus*) echo "" ;;                                       # check square
  zoom.us | FaceTime) echo "" ;;                               # video camera
  Finder) echo "" ;;                                           # folder
  1Password*) echo "" ;;                                       # lock
  Code | "Visual Studio Code") echo "" ;;                      # code
  GitHub*) echo "" ;;                                          # github
  "System Settings") echo "" ;;                                # cog
  *) echo "" ;;                                                # window — unknown app
  esac
}
