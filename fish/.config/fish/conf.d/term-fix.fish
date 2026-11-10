# Tailscale SSH sessions arrive with TERM=network, which tmux and clear reject.
if test "$TERM" = network
    set -gx TERM xterm-ghostty
end

# They also arrive with no locale, so tmux falls back to ASCII and draws _ for every glyph.
if test -z "$LANG"
    set -gx LANG en_US.UTF-8
end
