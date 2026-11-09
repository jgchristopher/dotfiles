# shellcheck shell=bash
# Mirror a sketchybar item into the OmniShell bar (OmniWM 0.8+), so both bars
# render from the same script run and can't drift apart.
#
#   omni_push KEY JSON   -> `omniwmctl shell set KEY JSON` (ctx.data.vars[KEY])
#   omni_push KEY        -> `omniwmctl shell unset KEY`    (widget hides)
#
# The widgets in omniwm/.config/omniwm/shell/widgets/<KEY>/ only draw; all
# thresholds and colors are decided here, in the sketchybar plugins.
# OMNIWMCTL overrides the binary (tests set it to echo). Never fails the caller.
omni_push() {
  local ctl="${OMNIWMCTL:-omniwmctl}"
  command -v "$ctl" >/dev/null 2>&1 || return 0
  local out=/dev/null
  [ -n "${OMNIWMCTL:-}" ] && out=/dev/stdout # tests capture the call
  if [ -n "${2:-}" ]; then
    "$ctl" shell set "$1" "$2" >"$out" 2>/dev/null || true
  else
    "$ctl" shell unset "$1" >"$out" 2>/dev/null || true
  fi
}
