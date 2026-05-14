function sl
    set -l fzf_opts \
        --prompt=' > ' \
        --layout=reverse \
        --border=rounded \
        --border-label=' Sesh ' \
        --border-label-pos=3 \
        --info=inline-right \
        --height=80% \
        --margin=10% \
        --padding=1

    if set -q TMUX
        set -a fzf_opts --tmux center,70%,60%
    end

    set -l selection (sesh list | fzf $fzf_opts)
    test -n "$selection"; and sesh connect "$selection"
end
