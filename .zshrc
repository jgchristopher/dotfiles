# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="dpree"
ZSH_THEME="robbyrussell"
#ZSH_THEME="mortalscumbag"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias myt='mysql --auto-rehash -h pollen-db-test -u pollenadmin -p'
alias myc='mysql --auto-rehash -h pollen-db-clone -u pollenadmin -p'
alias myp='mysql --auto-rehash -h pollen-ds -u pollenadmin -p'
alias mys='mysql --auto-rehash -h pollen-db-slave -u pollenadmin -p'
alias myl='mysql --auto-rehash -u pollenadmin -p ddmbid'
alias myv='mysql --auto-rehash -h 10.211.55.3 -u pollenadmin -p ddmbid'

alias ssv='ssh pollenvm@10.211.55.3'

alias rdb='cd /pollen/db ; rake sequel:migrate ; cd -'

alias pmgb='cd /usr/local/lib/pollen-model-gem ; gem build pollen-model.gemspec ; cd -'

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh
NODE_PATH=/usr/local/lib/node_modules

# Customize to your needs...
export PATH=$NODE_PATH:/usr/local/bin:/usr/local/Cellar/ruby/1.9.3-p194/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin
