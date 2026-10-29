function sl --description 'Pick a sesh session (ctrl-n: new named session in that dir)'
    set -l fzf_opts \
        --ansi \
        --prompt=' > ' \
        --layout=reverse \
        --border=rounded \
        --border-label=' Sesh ' \
        --border-label-pos=3 \
        --header='enter: connect   ctrl-n: new named session here' \
        --expect=ctrl-n \
        --info=inline-right \
        --height=80% \
        --margin=10% \
        --padding=1

    if set -q TMUX
        set -a fzf_opts --tmux center,70%,60%
    end

    # --expect prints the pressed key on line 1 (empty for enter), selection on line 2
    set -l out (sesh list --icons | fzf $fzf_opts)
    set -l key $out[1]
    set -l selection $out[2]
    test -n "$selection"; or return

    if test "$key" != ctrl-n
        sesh connect "$selection"
        return
    end

    # Strip the leading icon, then resolve the entry's directory via sesh's JSON
    set -l name (string replace -r '^\S+\s+' '' -- $selection)
    set -l dir (sesh list -j | jq -r --arg n "$name" 'map(select(.Name == $n)) | .[0].Path // empty')
    test -n "$dir"; or set dir (string replace -r '^~' $HOME -- $name)
    if not test -d "$dir"
        echo "sl: can't resolve a directory for '$name'" >&2
        return 1
    end

    set -l new (read -P "session name ($dir): " -c (basename $dir)-2)
    test -n "$new"; or return
    # tmux disallows . and : in session names
    set new (string replace -a -r '[.:]' _ -- $new)

    tmux has-session -t "=$new" 2>/dev/null; or tmux new-session -d -s "$new" -c "$dir"
    sesh connect "$new"
end
