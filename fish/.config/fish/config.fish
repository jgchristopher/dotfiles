eval (/opt/homebrew/bin/brew shellenv)
set -U fish_greeting # disable fish greeting
set -Ux EDITOR nvim

# updated my implementation from this https://github.com/oh-my-fish/plugin-node-binpath/blob/master/conf.d/plugin-node-binpath.fish
# function __auto_add_local_node_bin --on-event fish_postexec
#     set -l node_modules_path "$PWD/node_modules/.bin"
#     if test -e "$node_modules_path"
#         set -g __node_binpath "$node_modules_path"
#         set -x PATH $PATH $__node_binpath
#     else
#         set -q __node_binpath
#         and set -l index (contains -i -- $__node_binpath $PATH)
#         and set -e PATH[$index]
#         and set -e __node_binpath
#     end
# end

set -Ux FZF_TMUX_OPTS "-p 55%,60%"
set -gx DOTFILES /Users/johnchristopher/gitprojects/dotfiles/

fish_add_path $HOME/.config/bin
fish_add_path $HOME/bin

elixir_exports

# pnpm
set -gx PNPM_HOME /Users/johnchristopher/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

#homebrew
#source /opt/homebrew/opt/asdf/libexec/asdf.fish

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

zoxide init fish | source
starship init fish | source

# fish 4.0 deprecates `bind -k`. transform's Atuin's init to drop -k and ensure up-binding works
if type -q atuin
    set -l __atuin_init (atuin init fish | string replace -ra -- 'bind -M ([^ ]+)\s+-k ' 'bind -M $1 ' | string replace -ra -- 'bind\s+-k ' 'bind ')
    if test -n "$__atuin_init"
        printf '%s\n' $__atuin_init | source
        if functions -q _atuin_bind_up
            bind up _atuin_bind_up
            bind -M insert up _atuin_bind_up
        end
    else
        # fallback: source unmodified but silence deprecation noise
        atuin init fish 2>/dev/null | source
    end
end

fish_add_path "/Applications/Obsidian.app/Contents/MacOS"
