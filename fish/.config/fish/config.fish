eval (/opt/homebrew/bin/brew shellenv)
set -U fish_greeting # disable fish greeting
set -Ux EDITOR nvim


function __auto_add_local_node_bin --on-event fish_postexec
    set -l node_modules_path "$PWD/node_modules/.bin"
    if test -e "$node_modules_path"
        addpaths $node_modules_path
    end
end

source /opt/homebrew/opt/asdf/libexec/asdf.fish

set -Ux FZF_TMUX_OPTS "-p 55%,60%"

fish_add_path $HOME/.config/bin

# pnpm
set -gx PNPM_HOME /Users/johnchristopher/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
#

zoxide init fish | source
starship init fish | source
atuin init fish | source
