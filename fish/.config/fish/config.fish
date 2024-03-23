eval (/opt/homebrew/bin/brew shellenv)
set -U fish_greeting # disable fish greeting
set -Ux EDITOR nvim

# updated my implementation from this https://github.com/oh-my-fish/plugin-node-binpath/blob/master/conf.d/plugin-node-binpath.fish
function __auto_add_local_node_bin --on-event fish_postexec
    set -l node_modules_path "$PWD/node_modules/.bin"
    if test -e "$node_modules_path"
        set -g __node_binpath "$node_modules_path"
        set -x PATH $PATH $__node_binpath
    else
        set -q __node_binpath
        and set -l index (contains -i -- $__node_binpath $PATH)
        and set -e PATH[$index]
        and set -e __node_binpath
    end
end


set -Ux FZF_TMUX_OPTS "-p 55%,60%"

fish_add_path $HOME/.config/bin

# pnpm
set -gx PNPM_HOME /Users/johnchristopher/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

zoxide init fish | source
starship init fish | source
atuin init fish | source

source /opt/homebrew/opt/asdf/libexec/asdf.fish
