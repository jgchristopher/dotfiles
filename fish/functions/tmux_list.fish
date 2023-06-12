function tmux_list 
  set items default kickstart LazyVim NvChad
  set config $(printf "%s\n" $items | fzf --prompt="Tmux Session >> " --height=~50% --layout=reverse --border --exit-0)


  echo "WTF!"

  switch $config
    case default
      echo Default was Sent!
    case '*'
      echo $config
  end
end
