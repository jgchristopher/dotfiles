if status is-interactive
    # Commands to run in interactive sessions can go here
end

source ~/.config/fish/conf.d/abbr.fish
source ~/.asdf/asdf.fish

starship init fish | source


fish_add_path ~/gitprojects/dotfiles/bin
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin

function __auto_add_local_node_bin --on-event fish_postexec
    set -l node_modules_path "$PWD/node_modules/.bin"
    if test -e "$node_modules_path"
        addpaths $node_modules_path
    end
end
