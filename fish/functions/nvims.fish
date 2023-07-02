function nvims
  set items default LazyVim 
  set config $(printf "%s\n" $items | fzf --prompt=" Neovim Config   " --height=~50% --layout=reverse --border --exit-0)

  switch $config
    case default 
      nvim 
    case '*'
      begin; set -lx NVIM_APPNAME $config; nvim; end
  end
end
