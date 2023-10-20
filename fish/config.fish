eval (/opt/homebrew/bin/brew shellenv)
zoxide init fish | source
starship init fish | source



function __auto_add_local_node_bin --on-event fish_postexec
    set -l node_modules_path "$PWD/node_modules/.bin"
    if test -e "$node_modules_path"
        addpaths $node_modules_path
    end
end

source /opt/homebrew/opt/asdf/libexec/asdf.fish


set -Ux FZF_TMUX_OPTS "-p 55%,60%"

fish_add_path $HOME/.config/bin
fish_add_path $HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin
