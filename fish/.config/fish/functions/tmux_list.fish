function tmux_list 
  # Check if we are in a TMUX session already
  if status is-interactive 
    and not set -q TMUX

    # If not then go ahead and get list of tmux sessions or new

    set items new (tmux list-sessions -F "#S") 
    set config $(printf "%s\n" $items | fzf --prompt="Tmux Session >> " --height=~50% --layout=reverse --border --exit-0)

    switch $config
      case new 
        read session
        tmux new -s $session
      case '*'
        tmux attach-session -t $config
    end
  end
end
