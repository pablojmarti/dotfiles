# Path to your oh-my-zsh installation.
export ZSH=/home/pablo/.oh-my-zsh

# GO PATH
export GOPATH=/Users/pablo/Workspace/EMN/go
PATH=$PATH:$GOPATH/bin

#########################
#	ALIASES		#
#########################
alias fucking="sudo"
alias ok="clear"
alias chrome="open -a 'Google Chrome' $1"
alias tmux="tmux -2"
alias gbutt="gcloud"
alias yq="/Users/pablo/Workspace/EMN/go/bin/yq"
alias lol="ls"
alias kon="kubeon"
alias koff="kubeoff"
alias kgp="kubectl get pods"
alias composer="composer.phar"

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

# had to move this alias below source of ZSH
# in order for it to override the custom zsh 
# git alias
alias gts="git town sync"
alias gth="git town hack"

# source autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

bindkey -v
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#Update Path
PATH=$PATH:/Users/pablo/google-cloud-sdk/bin
PATH=$PATH:/Users/pablo/bin

# Add Docker Completion
fpath=(~/.zsh/completion $fpath)

eval "$(rbenv init -)"

# set kube auto complete
source <(kubectl completion zsh)

# set helm autocomplete
source <(helm completion zsh)

# more kube stuff
source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
PROMPT='$(kube_ps1)'$PROMPT


alias composer=/usr/local/bin/composer.phar

# use nvm
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

source ~/.bundler-exec.sh

### replacing command prompt?
command_not_found_handler () {
      printf "Command Not Found, dingus"
          return 127

}
eval "$(pyenv init -)"
