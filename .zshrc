# Path to your oh-my-zsh installation.
export ZSH=/Users/pablo/.oh-my-zsh

# GO PATH
export GOPATH=/Users/pablo/Workspace/EMN/go

#########################
#	ALIASES		#
#########################
alias fucking="sudo"
alias ok="clear"
alias chrome="open -a 'Google Chrome' $1"
alias tmux="tmux -2"
alias gbutt="gcloud"
alias yq="/Users/pablo/Workspace/EMN/go/bin/yq"

#########################
#	ZSH THEME 	#
#########################
ZSH_THEME="odin"
ZSH_CUSTOM=~/Worskpace/zsh_custom/

plugins=(
  git
  vi-mode
  npm
  osx
  zsh-syntax-highlighting
  history-substring-search
  command-not-found
)

# source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# source autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

bindkey -v
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#Update Path
PATH=$PATH:/Users/pablo/google-cloud-sdk/bin

# Add Docker Completion
fpath=(~/.zsh/completion $fpath)

eval "$(rbenv init -)"
